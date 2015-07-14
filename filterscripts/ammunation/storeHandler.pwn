/**
* Server Side Ammu-Nation by SA-MP BETA Tester Jay_
* Utils for loading store data and actors, and checking when
* a player enters/exits a store
**/

#define 	NUMBER_OF_AMMUNATIONS 		5
#define     AMMUNATION_STAFF_SKIN       179     // Skin id for the ammunation actor

new bool:IsPlayerInAnyAmmunation[MAX_PLAYERS];
new playerAmmunationID[MAX_PLAYERS] = {-1, ...};

new Float:ammunationInteriorInfo[NUMBER_OF_AMMUNATIONS][11] = {
	// interiorId, posX, posY, posZ, NPCSpawnX, NPCSpawnY, NPCSpawnZ, NPCSpawnPosAng, checkpointX, checkpointY, checkpointZ
	// Source: http://wiki.sa-mp.com/wiki/Interiors
	{1.0, 286.148987, -40.644398, 1001.569946, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{4.0, 286.800995, -82.547600, 1001.539978, 295.623748, -82.527412, 1001.515625, 0.839534, 295.689727, -80.810287, 1001.515625},
	{6.0, 296.919983, -108.071999, 1001.569946, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{7.0, 314.820984, -141.431992, 999.661987, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
	{6.0, 316.524994, -167.706985, 999.661987, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0}
};

new ammunationActorIDs[NUMBER_OF_AMMUNATIONS] = {INVALID_PLAYER_ID, ...};


// Load up the actors and put them in their shop respectively
initActors() {
	for(new i = 0; i < NUMBER_OF_AMMUNATIONS; i++){
		new Float:x = ammunationInteriorInfo[i][1],
		    Float:y = ammunationInteriorInfo[i][2],
		    Float:z = ammunationInteriorInfo[i][3],
		    Float:ang = ammunationInteriorInfo[i][4];
		    
		ammunationActorIDs[i] = CreateActor(AMMUNATION_STAFF_SKIN, x, y, z, ang);
		
		ActorMoveTo(ammunationActorIDs[i], 0, 0, 0, 0 );
		
		new str[128];
		format(str, 128, "Actor Pos: %f, %f, %f", x, y, z);
		Create3DTextLabel(str, -1, x, y, z, 30, 0);
		printf("[Ammunation] Created actor %d at %f %f %f", i, x, y, z);
	}
}

removeActors() {
	for(new i = 0; i < NUMBER_OF_AMMUNATIONS; i++) {
		if(ammunationActorIDs[i] == INVALID_PLAYER_ID)
		    continue;
		    
		DestroyActor(ammunationActorIDs[i]);
		ammunationActorIDs[i] = INVALID_PLAYER_ID;
	}
}

SetPlayerAmmunationCamera(playerid, ammunationId) {
	if(ammunationId < 0 || ammunationId > NUMBER_OF_AMMUNATIONS)
		return;
		
	new actorid = ammunationActorIDs[ammunationId];
	if(actorid == INVALID_PLAYER_ID)
	    return;
		
	new Float:x, Float:y, Float:z;
	new Float:frontx, Float:fronty;

	GetActorPos(actorid, x, y, z);
	GetXYInFrontOfActor(actorid, frontx, fronty, 2);

	SetPlayerCameraPos(playerid, frontx, fronty, z+0.4);
	SetPlayerCameraLookAt(playerid, x, y, z+0.4);
}

/** Wrapper for detecting when a player enters ammu-nation **/
public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid) {
	#pragma unused oldinteriorid
	
	// If the player is inside any ammunation and is changing we'll trigger the callback
	if(IsPlayerInAnyAmmunation[playerid] == true) {
		IsPlayerInAnyAmmunation[playerid] = false;
		playerAmmunationID[playerid] = -1;
		DisablePlayerCheckpoint(playerid);
		OnPlayerLeaveAmmunation(playerid);
		return;
	}

	// Check if the new interior ID is one of those ammunation interior IDs
	for(new i = 0; i < NUMBER_OF_AMMUNATIONS; i++ )
	{
	    // Extra check to make sure its valid - we can't have ammunations outside.
	    if(ammunationInteriorInfo[i][0] == 0)
	        continue;
	        
		// Do we have an ammu-nation interior ID?
		if(newinteriorid == ammunationInteriorInfo[i][0]) {
			// This is called as SOON as the player enters the MARKER - it takes about 1.5 seconds
			// for them to actually enter the interior.
			SetTimerEx("ammunationCheck", 1500, 0, "d", playerid);
			break;
		}
	}
}

forward ammunationCheck(playerid);
public ammunationCheck(playerid) {
	for(new i = 0; i < NUMBER_OF_AMMUNATIONS; i++ ) {
		// This could be heavy if the NUMBER_OF_AMMUNATIONS is high. Anything > 50 wouldn't be ideal.
		// TODO: This could be optimized by removing this check and using OnActorStreamIn
		if(!IsPlayerInRangeOfPoint(playerid, 5, ammunationInteriorInfo[i][1], ammunationInteriorInfo[i][2], ammunationInteriorInfo[i][3]))
			continue; 

		// OK - We have the ammunation that the player has entered.
		// Update the flags and disable the "ShopName"
		IsPlayerInAnyAmmunation[playerid] = true;
		playerAmmunationID[playerid] = i;
		SetPlayerShopName(playerid, "");

		// Show the checkpoint for this ammunation
		SetPlayerCheckpoint(playerid, ammunationInteriorInfo[i][8], ammunationInteriorInfo[i][9], ammunationInteriorInfo[i][10], 1.0);

		CallLocalFunction("OnPlayerEnterAmmunation", "dd", playerid, i);
		break;
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

	CallLocalFunction("OnPlayerEnterAmmuCP", "dd", playerid, playerAmmunationID[playerid]);
	return 1;
}


// This is called when the player exits the ammunation menu
// it will run on a continus loop until they are 5 units away from the checkpoint position
// and reshow it to simulate the client side ammu
forward CheckToShowAmmuCheckpoint(playerid);
public CheckToShowAmmuCheckpoint(playerid)
{
	if(!IsPlayerConnected(playerid))
	    return;

	if(!IsPlayerInAnyAmmunation[playerid] || GetPlayerInterior(playerid) == 0 || playerAmmunationID[playerid] == -1)
		return;

	new ammunationId = playerAmmunationID[playerid];
	if(!IsPlayerInRangeOfPoint(playerid, 2.0, ammunationInteriorInfo[ammunationId][8], ammunationInteriorInfo[ammunationId][9], ammunationInteriorInfo[ammunationId][10])){
		SetPlayerCheckpoint(playerid, ammunationInteriorInfo[ammunationId][8], ammunationInteriorInfo[ammunationId][9], ammunationInteriorInfo[ammunationId][10], 1.0);
	} else {
	    SetTimerEx("CheckToShowAmmuCheckpoint", 500, 0, "d", playerid);
	}
}
