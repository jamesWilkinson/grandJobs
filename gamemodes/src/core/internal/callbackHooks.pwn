/**
* This file handles all of the callback hooking - its a hacky and messy way
* of handling code segments
**/

public OnGameModeInit()
{
	Log("OnGameModeInit");
	initialiseGamemode();
	core::initialisation->initDatabase.construct();
	core::player->death.init();
	translateInit();
	zcmdInit();
    initialiseLanguage();
	return 1;
}

public OnGameModeExit()
{
	Log(sprintf("Callback: OnGameModeExit"), LOG_LEVEL_CALLBACK);
	core::initialisation->initDatabase.terminate();
	gameEngine::initialisation->gameUnloader.init();
	printf("Grand Jobs Version %s terminated.", GLOBAL_SETTING_VERSION);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	Log(sprintf("Callback: OnPlayerRequestClass(%d, %d)", playerid, classid), LOG_LEVEL_CALLBACK);
	// Enable spectate mode to hide class selection buttons
	TogglePlayerSpectating(playerid, true);
	SpawnPlayer(playerid);
	return 1;
}

public OnPlayerConnect(playerid)
{
	Log(sprintf("Callback: OnPlayerConnect(%d)", playerid), LOG_LEVEL_CALLBACK);
	// Contains threaded mysql queries - this comes first!#
	// P: 1 - Contains mysql q
	database::Controllers->retrieveData.construct(playerid);


	FadePlayerConnect(playerid);
	database::API->IsPlayerRegistered.construct(playerid);
	database::API->IsPlayerLoggedIn.construct(playerid);
	core::playerConnection->handleWelcomeMessage.main(playerid);
	database::API->Account.construct(playerid);
	gameEngine::initialisation->gameChanger.initForPlayer(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	Log(sprintf("Callback: OnPlayerDisconnect(%d, %d)", playerid, reason), LOG_LEVEL_CALLBACK);
	FadePlayerDisconnect(playerid);
	StopAudioStreamForPlayer(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	Log(sprintf("Callback: OnPlayerSpawn(%d)", playerid), LOG_LEVEL_CALLBACK);
	// Class selection disabling low-level
	core::playerAccount->playerAccountCheckLogin.main(playerid);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(IsPlayerConnected(killerid)) {
	//	core::player->kill.main(killerid, playerid, reason);
	}
	core::player->death.main(playerid, killerid, reason);
	Log(sprintf("Callback: OnPlayerDeath(%d, %d, %d)", playerid, killerid, reason), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	Log(sprintf("Callback: OnVehicleSpawn(%d)", vehicleid), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	Log(sprintf("Callback: OnVehicleDeath(%d, %d)", vehicleid, killerid), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnPlayerText(playerid, text[])
{
	Log(sprintf("Callback: OnPlayerText(%d, %s)", playerid, text), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	Log(sprintf("Callback: OnPlayerCommandText(%d, %s)"), LOG_LEVEL_CALLBACK);
	if (strcmp("/mycommand", cmdtext, true, 10) == 0)
	{
		// Do something here
		return 1;
	}
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	Log(sprintf("Callback: OnPlayerEnterVehicle(%d, %d, %d", playerid, vehicleid, ispassenger), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	Log(sprintf("Callback: OnPlayerExitVehicle(%d, %d)", playerid, vehicleid), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	Log(sprintf("Callback: OnPlayerStateChange(%d, %d, %d", playerid, newstate, oldstate), LOG_LEVEL_CALLBACK);
	if(newstate == PLAYER_STATE_DRIVER)
	{
		PlayAudioStreamForPlayer(playerid, "http://play.sa-mp.nl:8000/stream/1/");
	}
	else if (oldstate == PLAYER_STATE_DRIVER) {
		StopAudioStreamForPlayer(playerid);
	}
	core::player->death.checkToHideWastedTextdraw(playerid, oldstate);
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	Log(sprintf("Callback: OnPlayerEnterCheckpoint(%d)", playerid), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	Log(sprintf("Callback: OnPlayerLeaveCheckpoint(%d)", playerid), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	Log(sprintf("Callback: OnPlayerEnterRaceCheckpoint(%d)", playerid), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	Log(sprintf("Callback: OnPlayerLeaveCheckpoint(%d)", playerid), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnRconCommand(cmd[])
{
	Log(sprintf("Callback: OnRconCommand(%s)", cmd), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	Log(sprintf("Callback: OnPlayerRequestSpawn(%d)", playerid), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnObjectMoved(objectid)
{
	Log(sprintf("Callback: OnObjectMoved(%d)", objectid), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	Log(sprintf("Callback: OnPlayerObjectMoved(%d, %d)", playerid, objectid), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	Log(sprintf("Callback: OnPlayerPickupPickup(%d, %d)", playerid, pickupid), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	Log(sprintf("Callback: OnVehicleMod(%d, %d, %d)", playerid, vehicleid, componentid), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	Log(sprintf("Callback: OnVehiclePaintjob(%d, %d, %d)", playerid, vehicleid, paintjobid), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	Log(sprintf("Callback: OnVehicleRespray(%d, %d, %d, %d)", playerid, vehicleid, color1, color2), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	Log(sprintf("Callback: OnPlayerSelectedMenuRow(%d, %d)", playerid, row), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	Log(sprintf("Callback: OnPlayerExitedMenu(%d)", playerid), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	Log(sprintf("Callback: OnPlayerInteriorChange(%d, %d, %d", playerid, newinteriorid, oldinteriorid), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	Log(sprintf("Callback: OnPlayerKeyStateChange(%d, %d, %d)", playerid, newkeys, oldkeys), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	Log(sprintf("Callback: OnRconLoginAttempt(%s, %s, %d)", ip, password, success), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnPlayerUpdate(playerid)
{
	// No.
	// Log(sprintf("Callback: OnPlayerUpdate(%d)", playerid), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	Log(sprintf("Callback: OnPlayerStreamIn(%d, %d)", playerid, forplayerid), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	Log(sprintf("Callback: OnPlayerStreamOut(%d, %d)", playerid, forplayerid), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	Log(sprintf("Callback: OnVehicleStreamIn(%d, %d)", vehicleid, forplayerid), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	Log(sprintf("Callback: OnVehicleStreamOut(%d, %d)", vehicleid, forplayerid), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	Log(sprintf("Callback: OnDialogResponse(%d, %d, %d, %d, %s", playerid, dialogid, response, listitem, inputtext), LOG_LEVEL_CALLBACK);
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	Log(sprintf("Callback: OnPlayerClickPlayer(%d, %d, %d)", playerid, clickedplayerid, source), LOG_LEVEL_CALLBACK);
	return 1;
}

