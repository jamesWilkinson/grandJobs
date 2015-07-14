/**
	This file handles the welcome message that should be shown for player
	when they connect to the server
**/



#define this core::playerConnection->handleWelcomeMessage


// called when the player connects
this.main(playerid)
{
	// First of all handle the screen fade in effect
	#pragma unused playerid
	SendClientInfoMessage(playerid, sprintf(__("Welcome %s to Grand Jobs.", playerid), ReturnPlayerName(playerid)));

//	FadePlayerScreen(playerid);
	SetTimerEx("spawnThePlayer", 5000, 0, "d", playerid);
}

forward spawnThePlayer(playerid);
public spawnThePlayer(playerid) {
	SetSpawnInfo(playerid, NO_TEAM, 0,938.6702,-92.0135,17.8191,266.6740,0,0,0,0,0,0);
	if (GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
	{
	    TogglePlayerSpectating(playerid, false);
	}
}

// when the player has finished with their account shizzle.
forward OnPlayerExitAccountDialog(playerid);
public OnPlayerExitAccountDialog(playerid) {
//	FadePlayerScreen(playerid, true);
}


#undef this