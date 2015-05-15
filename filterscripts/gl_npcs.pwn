/**
	SERVER SIDE AMMUNATION BY SA-MP BETA TESTER Jay_

	The purpose of this script is to allow servers to improve their anticheat by 
	controlling ammunation from their server side scripts and disabling all client side ammunation
	functionality.

**/

#include <a_samp>


#define NUMBER_OF_AMMUNATIONS 	5

// Gets appended with the ammunation guys ID, eg Ammunation1, Ammunation2, etc
new npcName[MAX_PLAYER_NAME] = "Ammunation";

new npcid[NUMBER_OF_AMMUNATIONS] = {INVALID_PLAYER_ID, ...};
new ammuNationNPCSkinId = 179;

new bool:IsPlayerInAnyAmmunation[MAX_PLAYERS];

new Float:ammunationInteriorInfo[NUMBER_OF_AMMUNATIONS][11] = {
	// interiorId, posX, posY, posZ, NPCSpawnX, NPCSpawnY, NPCSpawnZ, NPCSpawnPosAng, checkpointX, checkpointY, checkpointZ
	// Source: http://wiki.sa-mp.com/wiki/Interiors
	{1.0, 286.148987, -40.644398, 1001.569946, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{4.0, 286.800995, -82.547600, 1001.539978, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{6.0, 296.919983, -108.071999, 1001.569946, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{7.0, 314.820984, -141.431992, 999.661987, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{6.0, 316.524994, -167.706985, 999.661987, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0}
};





public OnFilterScriptInit() {
	new name[MAX_PLAYER_NAME];
	// Connect the relevant number of NPCs based on how many ammunations there are
	for(new i = 0; i < NUMBER_OF_AMMUNATIONS; i++) {
		format(name, MAX_PLAYER_NAME, "%s%d", npcName, i);
		ConnectNPC(name, "idle");
	}
}

// Join all the relevant ammunation bots when the filterscript is launched
public OnFilterScriptExit() {
	for(new i = 0; i < NUMBER_OF_AMMUNATIONS; i++) {
		// Just an additional check here incase a gamemode script kicks the NPC
		// or something for any reason - wouldn't want it kicking a player ID!
		if(IsPlayerNPC(npcid[i])) 
			Kick(npcid[i]);
	}
	// For any players in an ammunation, disable the checkpoint
	// so we're not leaving anything behind!
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(IsPlayerInAnyAmmunation[i] == true) {
			DisablePlayerCheckpoint(i);
		}
	}
}

// When an ammunation NPC connects to the server, spawn it immediately at the relevant ammunation
public OnPlayerConnect(playerid) {
	IsPlayerInAnyAmmunation[playerid] = false;
	for(new i = 0; i < NUMBER_OF_AMMUNATIONS; i++) {
		if(!strcmp(npcName[i], ReturnPlayerName(playerid))) {
			npcid[i] = playerid;
			SetSpawnInfo(playerid, NO_TEAM, ammuNationNPCSkinId, ammunationInteriorInfo[i][4], ammunationInteriorInfo[i][5], ammunationInteriorInfo[i][6], ammunationInteriorInfo[i][7], 0,0,0,0,0,0);
			SpawnPlayer(playerid);
			// Wrong to use floatround here but oh well 
			SetPlayerInterior(playerid, floatround(ammunationInteriorInfo[i][0]));
		}
	}
}


forward OnPlayerEnterAmmunation(playerid, ammunationid);
public OnPlayerEnterAmmunation(playerid, ammunationid) {
	// ammunation IDs are 0-5 based on the first 5 listed here (BOOTH AND RANGE NOT INCLUDED): http://wiki.sa-mp.com/wiki/Interiors
	printf("Player %d entering ammunation ID %d", playerid, ammunationid);
	IsPlayerInAnyAmmunation[playerid] = true;
	SetPlayerShopName(playerid, "");
}

forward OnPlayerLeaveAmmunation(playerid, ammunationid);
public OnPlayerLeaveAmmunation(playerid, ammunationid) {
	printf("Player %d leaving ammunation ID %d", playerid, ammunationid);
	IsPlayerInAnyAmmunation[playerid] = false;
}
 


/** 
	Few functions for the API
**/

stock ReturnPlayerName(playerid) {
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	return name;
}

/** Wrapper for detecting when a player enters ammu-nation **/
public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid) {
	#pragma unused oldinteriorid
	for(new i = 0; i < NUMBER_OF_AMMUNATIONS; i++ ) {

		// Do we have an ammu-nation interior ID?
		if(newinteriorid != ammunationInteriorInfo[i][0]) {
			continue;
		}

		if(!IsPlayerInRangeOfPoint(playerid, 5, ammunationInteriorInfo[i][1], ammunationInteriorInfo[i][2], ammunationInteriorInfo[i][3])) { 
			continue; 
		}

		OnPlayerEnterAmmunation(playerid, i);
		break;
	}
}