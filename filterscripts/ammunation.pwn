/**
	SERVER SIDE AMMUNATION BY SA-MP BETA TESTER Jay_

	The purpose of this script is to allow servers to improve their anticheat by 
	controlling ammunation from their server side scripts and disabling all client side ammunation
	functionality.

	December 2014

**/

#include <a_samp>

#define FIND_NPC_MODE 1

#define NUMBER_OF_AMMUNATIONS 	5


new version[4] = "0.1";

// Gets appended with the ammunation guys ID, eg Ammunation1, Ammunation2, etc
new npcName[MAX_PLAYER_NAME] = "Ammunation";

new npcid[NUMBER_OF_AMMUNATIONS] = {INVALID_PLAYER_ID, ...};
new ammuNationNPCSkinId = 179;

new bool:IsPlayerInAnyAmmunation[MAX_PLAYERS];
new playerAmmunationID[MAX_PLAYERS] = {-1, ...};

new state1;

new Float:ammunationInteriorInfo[NUMBER_OF_AMMUNATIONS][11] = {
	// interiorId, posX, posY, posZ, NPCSpawnX, NPCSpawnY, NPCSpawnZ, NPCSpawnPosAng, checkpointX, checkpointY, checkpointZ
	// Source: http://wiki.sa-mp.com/wiki/Interiors
	{1.0, 286.148987, -40.644398, 1001.569946, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{4.0, 286.800995, -82.547600, 1001.539978, 295.623748, -82.527412, 1001.515625, 0.839534, 295.689727, -80.810287, 1001.515625},
	{6.0, 296.919983, -108.071999, 1001.569946, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{7.0, 314.820984, -141.431992, 999.661987, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{6.0, 316.524994, -167.706985, 999.661987, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0}
};





public OnFilterScriptInit() {
	printf("Server side ammu-nation by Jay_ version %s", version);

	InitMenus();
}

// Join all the relevant ammunation bots when the filterscript is launched
public OnFilterScriptExit() {

}


new Menu:MainMenu;
new Menu:PistolMenu;
new Menu:ShotgunMenu;
new Menu:MicroSMGMenu;
new Menu:ArmorMenu;
new Menu:SMGMenu;
new Menu:AssaultMenu;

// Menu formatting settings
new menuHeader[12] = "Ammu-Nation";
new Float:menuX = 30.0;
new Float:menuY = 140.0;
new Float:menuColumnWidth = 190.0;


InitMenus() {
	MainMenu = CreateMenu(menuHeader, 1, menuX, menuY, menuColumnWidth, menuColumnWidth);
	AddMenuItem(MainMenu, 0, "Pistols");
	AddMenuItem(MainMenu, 0, "Micro SMGs");
	AddMenuItem(MainMenu, 0, "Shotguns");
	AddMenuItem(MainMenu, 0, "Armor");
	AddMenuItem(MainMenu, 0, "SMG");
	AddMenuItem(MainMenu, 0, "Assault");

	PistolMenu = CreateMenu(menuHeader, 1, menuX, menuY, menuColumnWidth, menuColumnWidth);
	AddMenuItem(PistolMenu, 0, "9mm");
	AddMenuItem(PistolMenu, 0, "Silenced 9mm");
	AddMenuItem(PistolMenu, 0, "Desert Eagle");

	MicroSMGMenu = CreateMenu(menuHeader, 1, menuX, menuY, menuColumnWidth, menuColumnWidth);
	AddMenuItem(MicroSMGMenu, 0, "Tec9");
	AddMenuItem(MicroSMGMenu, 0, "Micro SMG");

	ShotgunMenu = CreateMenu(menuHeader, 1, menuX, menuY, menuColumnWidth, menuColumnWidth);
	AddMenuItem(ShotgunMenu, 0, "Shotgun");
	AddMenuItem(ShotgunMenu, 0, "Sawnoff Shotgun");
	AddMenuItem(ShotgunMenu, 0, "Combat Shotgun");

	ArmorMenu = CreateMenu(menuHeader, 1, menuX, menuY, menuColumnWidth, menuColumnWidth);
	AddMenuItem(ArmorMenu, 0, "Body Armor");

	SMGMenu = CreateMenu(menuHeader, 1, menuX, menuY, menuColumnWidth, menuColumnWidth);
	AddMenuItem(SMGMenu, 0, "Tec9");
	AddMenuItem(SMGMenu, 0, "Micro SMG");

	AssaultMenu = CreateMenu(menuHeader, 1, menuX, menuY, menuColumnWidth, menuColumnWidth);
	AddMenuItem(AssaultMenu, 0, "AK47");
	AddMenuItem(AssaultMenu, 0, "M4");
}

public OnPlayerSelectedMenuRow(playerid, row) {
	if(GetPlayerMenu(playerid) == MainMenu) {
		switch(row) {
			case 0: ShowMenuForPlayer(PistolMenu, playerid);
			case 1: ShowMenuForPlayer(MicroSMGMenu, playerid);
			case 2: ShowMenuForPlayer(ShotgunMenu, playerid);
			case 3: ShowMenuForPlayer(ArmorMenu, playerid);
			case 4: ShowMenuForPlayer(SMGMenu, playerid);
			case 5: ShowMenuForPlayer(AssaultMenu, playerid);
		}
		// Pistol menu
	} else if(GetPlayerMenu(playerid) == PistolMenu){
		switch(row) {
			case 0: {
				AnimateAmmunationActor(npcid[playerAmmunationID[playerid]], WEAPON_COLT45);
			}
			case 1: {
				AnimateAmmunationActor(npcid[playerAmmunationID[playerid]], WEAPON_SILENCED);
			}
			case 2: {
				AnimateAmmunationActor(npcid[playerAmmunationID[playerid]], WEAPON_DEAGLE);
			}
		}
	}
}

public OnPlayerExitedMenu(playerid) {
	if (GetPlayerMenu(playerid) == MainMenu){
		TogglePlayerControllable(playerid, 1);
		SetCameraBehindPlayer(playerid);
		printf("exited main menu");
	} else if(GetPlayerMenu(playerid) >= PistolMenu || GetPlayerMenu(playerid) <= AssaultMenu) {
		ShowMenuForPlayer(MainMenu, playerid);
		printf("exited sub menu");
	}
}


// When an ammunation NPC connects to the server, spawn it immediately at the relevant ammunation
public OnPlayerConnect(playerid) {

	IsPlayerInAnyAmmunation[playerid] = false;
	playerAmmunationID[playerid] = -1;

	if(!IsPlayerNPC(playerid)) {
		return 1;
	}

	new name[MAX_PLAYER_NAME];

	//  track the NPC id so we can set the spawn data later
	for(new i = 0; i < NUMBER_OF_AMMUNATIONS; i++) {

		format(name, MAX_PLAYER_NAME, "%s%d", npcName, i);

		if(!strcmp(name, ReturnPlayerName(playerid))) {
			npcid[i] = playerid;
			SetSpawnInfo(playerid, NO_TEAM, ammuNationNPCSkinId, ammunationInteriorInfo[i][4], ammunationInteriorInfo[i][5], ammunationInteriorInfo[i][6], ammunationInteriorInfo[i][7], 0,0,0,0,0,0);
		}
	}
	return 1;
}

public OnPlayerRequestClass(playerid, classid) {
	
	// When an NPC enters class selection immediately spawn it
	// with the correct spawn info

	for(new i =0; i < NUMBER_OF_AMMUNATIONS; i++) {
		if(playerid == npcid[i]) {
			SetSpawnInfo(playerid, NO_TEAM, ammuNationNPCSkinId, ammunationInteriorInfo[i][4], ammunationInteriorInfo[i][5], ammunationInteriorInfo[i][6], ammunationInteriorInfo[i][7], 0,0,0,0,0,0);
			SpawnPlayer(playerid);
			return 1;
		}
	}
	return 1;
}


public OnPlayerCommandText(playerid, cmdtext[]) {


	if(!strcmp(cmdtext, "/jay")) {
	//	new Float:x, Float:y, Float:z;
	//	GetPlayerPos(playerid, x, y, z);
	//	CreateObject(353, x, y, z, 0, 0, 0);
		AnimateAmmunationActor(playerid, 331);
		return 1;
	}


	if(!strcmp(cmdtext, "/here")) {
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		DisablePlayerCheckpoint(playerid);
		SetPlayerCheckpoint(playerid, x, y, z, 1);
		return 1;
	}

	if(!strcmp(cmdtext, "/ammu")) {
		SetPlayerPos(playerid, 2536.0796,2085.4226,10.8203);
		return 1;
	}



	return 0;
}


forward OnPlayerEnterAmmunation(playerid, ammunationid);
public OnPlayerEnterAmmunation(playerid, ammunationid) {
	// ammunation IDs are 0-5 based on the first 5 listed here (BOOTH AND RANGE NOT INCLUDED): http://wiki.sa-mp.com/wiki/Interiors
	printf("Player %d entering ammunation ID %d", playerid, ammunationid);
	IsPlayerInAnyAmmunation[playerid] = true;
	playerAmmunationID[playerid] = ammunationid;
	//SetPlayerShopName(playerid, "");

	// Show the checkpoint for this ammunation
	SetPlayerCheckpoint(playerid, ammunationInteriorInfo[ammunationid][8], ammunationInteriorInfo[ammunationid][9], ammunationInteriorInfo[ammunationid][10], 1.0);

}

forward OnPlayerLeaveAmmunation(playerid);
public OnPlayerLeaveAmmunation(playerid) {
	printf("Player %d leaving ammunation ID", playerid);
	IsPlayerInAnyAmmunation[playerid] = false;
	playerAmmunationID[playerid] = -1;
	DisablePlayerCheckpoint(playerid);
}
 
public OnPlayerStreamIn(playerid, forplayerid) {
	// For some reason using SetPlayerSkin or SetSpawnInfo with the relevant skin
	// was causing the skin ID to reset with NPCs in interiors
	// When the NPC streams in for the player this will patch that issue by re-setting the skin.
	if(IsPlayerAmmunationNPC(playerid)) {
		SetPlayerSkin(playerid, ammuNationNPCSkinId);
		// idle in the shop animation
		ApplyAnimation(playerid, "WEAPONS", "SHP_TRAY_POSE", 4.0, 0, 0, 0, 1, 0, 1); // shop_idle
	}
}

public OnPlayerEnterCheckpoint(playerid) {
	if(!IsPlayerInAnyAmmunation[playerid]) {
		return 1;
	}

	// OK The player has entered an ammunation checkpoint - hide it and build the menu
	DisablePlayerCheckpoint(playerid);

	ShowMenuForPlayer(MainMenu, playerid);
	TogglePlayerControllable(playerid, 0);

	SetPlayerAmmunationCamera(playerid, playerAmmunationID[playerid]);

	return 1;
}


/** 
	Few functions for the API
**/



/**
Return the weapon object model id based on the weapon id
*/
stock GetModelFromWeaponID(weaponid) {
	if(weaponid < 1 || weaponid > 46)
		return INVALID_OBJECT_ID;

	switch(weaponid) {
		case WEAPON_BRASSKNUCKLE: return 331;
		case WEAPON_GOLFCLUB: return 333;
		case WEAPON_NITESTICK: return 334;
		case WEAPON_KNIFE: return 335;
		case WEAPON_BAT: return 336;
		case WEAPON_SHOVEL: return 337;
		case WEAPON_POOLSTICK: return 338;
		case WEAPON_KATANA: return 339;
		case WEAPON_CHAINSAW: return 341;
		case WEAPON_DILDO: return 321;
		case WEAPON_DILDO2: return 322;
		case WEAPON_VIBRATOR: return 323;
		case WEAPON_VIBRATOR2: return 324;
		case WEAPON_FLOWER: return 325;
		case WEAPON_CANE: return 326;
		case WEAPON_GRENADE: return 324;
		case WEAPON_TEARGAS: return 343;
		case WEAPON_MOLTOV: return 344;
		case WEAPON_COLT45: return 346;
		case WEAPON_SILENCED: return 347;
		case WEAPON_DEAGLE: return 348;
		case WEAPON_SHOTGUN: return 349;
		case WEAPON_SAWEDOFF: return 350;
		case WEAPON_SHOTGSPA: return 351;
		case WEAPON_UZI: return 352;
		case WEAPON_MP5: return 353;
		case WEAPON_AK47: return 355;
		case WEAPON_M4: return 356;
		case WEAPON_TEC9: return 372;
		case WEAPON_RIFLE: return 357;
		case WEAPON_SNIPER: return 358;
		case WEAPON_ROCKETLAUNCHER: return 359;
		case WEAPON_HEATSEEKER: return 360;
		case WEAPON_FLAMETHROWER: return 361;
		case WEAPON_MINIGUN: return 362;
		case WEAPON_SATCHEL: return 363;
		case WEAPON_BOMB: return 364;
		case WEAPON_SPRAYCAN: return 365;
		case WEAPON_FIREEXTINGUISHER: return 366;
		case WEAPON_CAMERA: return 367;
		case WEAPON_PARACHUTE: return 371;
		default: return -1;

	}
	return -1;
}

SetPlayerAmmunationCamera(playerid, ammunationId) {
	new Float:x, Float:y, Float:z;
	new Float:frontx, Float:fronty;
	new npcplayerid = npcid[ammunationId];
	
	GetPlayerPos(npcplayerid, x, y, z);
	GetXYInFrontOfPlayer(npcplayerid, frontx, fronty, 2);

	SetPlayerCameraPos(playerid, frontx, fronty, z+0.4);
	SetPlayerCameraLookAt(playerid, x, y, z+0.4);
}


stock IsPlayerAmmunationNPC(playerid) {
	if(!IsPlayerConnected(playerid) || !IsPlayerNPC(playerid)) {
		return 0;
	}

	for(new i = 0; i < NUMBER_OF_AMMUNATIONS; i++) {
		if(npcid[i] == playerid) {
			return 1;
		}
	}
	return 0;
}

stock ReturnPlayerName(playerid) {
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	return name;
}

/** Wrapper for detecting when a player enters ammu-nation **/
public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid) {
	#pragma unused oldinteriorid
	
	// If the player is inside any ammunation and is changing we'll trigger the callback
	if(IsPlayerInAnyAmmunation[playerid] == true) {
		OnPlayerLeaveAmmunation(playerid);
	}

	// Check if the new interior ID is one of those ammunation interior IDs
	for(new i = 0; i < NUMBER_OF_AMMUNATIONS; i++ ) {

		// Do we have an ammu-nation interior ID?
		if(newinteriorid == ammunationInteriorInfo[i][0]) {
			// This is called as SOON as the player enters the marker - it takes about 2.5 seconds 
			// for them to actually enter the interior.
			SetTimerEx("ammunationCheck", 1500, 0, "d", playerid);
			break;
		}
	}
}

forward ammunationCheck(playerid);
public ammunationCheck(playerid) {
	for(new i = 0; i < NUMBER_OF_AMMUNATIONS; i++ ) {

		if(!IsPlayerInRangeOfPoint(playerid, 5, ammunationInteriorInfo[i][1], ammunationInteriorInfo[i][2], ammunationInteriorInfo[i][3])) { 
			continue; 
		}

		OnPlayerEnterAmmunation(playerid, i);
		break;
	}
}

stock strtok(const string[], &index,seperator=' ')
{
    new length = strlen(string);
    new offset = index;
    new result[255];
    while ((index < length) && (string[index] != seperator) && ((index - offset) < (sizeof(result) - 1)))
    {
        result[index - offset] = string[index];
        index++;
    }

    result[index - offset] = EOS;
    if ((index < length) && (string[index] == seperator))
    {
        index++;
    }
    return result;
}



GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
	new Float:a;
	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);
	if (GetPlayerVehicleID(playerid))
	{
	    GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}
	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}
