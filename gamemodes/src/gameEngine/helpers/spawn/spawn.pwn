/**
	This file will handle the adding of spawn points for games

**/


#define this gameEngine::helpers->spawn

// There should be a spawn point for every available player
// this is defined in globals
//#define	MAX_SPAWN_POINTS	SLOTS 

enum E_SPAWN_DATA
{
	Float:spawnX,
	Float:spawnY,
	Float:spawnZ,
	Float:spawnAng,
	spawnInterior,
	spawnTeamId
}

static spawnData[MAX_SPAWN_POINTS][E_SPAWN_DATA];
static numberOfSpawnPositions = 0;
static currentUniqueSpawnId = 0;

this.addSpawnPoint(Float:X, Float:Y, Float:Z, Float:ang, teamId, interiorId){
	if(numberOfSpawnPositions >= MAX_SPAWN_POINTS) {
		Log(sprintf("Unable to add spawn point at position %f, %f %f: Too many spawn points.", X, Y, Z), LOG_LEVEL_WARNING);
		return 0;
	}
	new i = numberOfSpawnPositions;

	spawnData[i][spawnX] = X;
	spawnData[i][spawnY] = Y;
	spawnData[i][spawnZ] = Z;
	spawnData[i][spawnAng] = ang;
	spawnData[i][spawnInterior] = interiorId;
	spawnData[i][spawnTeamId] = teamId;
	numberOfSpawnPositions++;
	return 1;
}

this.spawnPlayer(playerid, spawnId) {
	// logic here for races too
	SetPlayerPos(playerid, spawnData[spawnId][spawnX], spawnData[spawnId][spawnY], spawnData[spawnId][spawnZ]);
	SetPlayerFacingAngle(playerid, spawnData[spawnId][spawnAng]);
	SetPlayerInterior(playerid, spawnData[spawnId][spawnInterior]);
}

this.randomSpawnPlayer(playerid) {
	
	if(!numberOfSpawnPositions) {
		return 0;
	}

	new spawnId;
	new teamId = GetPlayerTeam(playerid);

	if(teamId == NO_TEAM) {
		spawnId = random(numberOfSpawnPositions + 1) -1;
		Log(sprintf("randomSpawnPlayer: spawnId: %d (NO_TEAM)", spawnId));
	} else {
		// ok we have a team based spawn id request
		// First of all build an array of spawns for this team id
		new spawnIds[MAX_SPAWN_POINTS];
		new spawnIdCount;
		for(new i = 0; i < numberOfSpawnPositions; i++)
		{
			if(spawnData[i][spawnTeamId] != teamId)
				continue;

			spawnIds[++spawnIdCount] = i;
		}
		// Do we have any results?
		if(!spawnIdCount) 
			return 0;

		// Ok, lets pick a random spawn id with the correct team
		spawnId = spawnIds[random(spawnIdCount +1)-1];
	}	
	Log(sprintf("randomSpawnPlayer: spawnId: %d", spawnId));
	this.spawnPlayer(playerid, spawnId);
	return 1;
}

// spawn a player in a unique position that is much less likely to have someone
// else standing there or in the way.
// NOTE: Doesn't work for players in a team currently!!
this.spawnPlayerUnique(playerid)
{
	if(!numberOfSpawnPositions) {
		return 0;
	}

	new teamId = GetPlayerTeam(playerid);

	if(teamId == NO_TEAM) {
		if(currentUniqueSpawnId == numberOfSpawnPositions) {
			currentUniqueSpawnId = 0;
		}

		this.spawnPlayer(playerid, currentUniqueSpawnId);
		currentUniqueSpawnId++;
	} else {
		return 0;
	}
	return 1;
}


// when a game is unloaded all spawn data needs to reset
this.resetSpawnData() {
	for(new i = 0; i < SLOTS; i++) {
		spawnData[i][spawnX] = 0;
		spawnData[i][spawnY] = 0;
		spawnData[i][spawnZ] = 0;
		spawnData[i][spawnAng] = 0;
		spawnData[i][spawnInterior] = 0;
		spawnData[i][spawnTeamId] = NO_TEAM;

	}
	numberOfSpawnPositions = 0;
	currentUniqueSpawnId = 0;
}

forward AddSpawnPos(Float:x, Float:y, Float:z, Float:ang, interiorId, teamId);
public AddSpawnPos(Float:x, Float:y, Float:z, Float:ang, interiorId, teamId) {
	Log("API Call: AddSpawnPos()", LOG_LEVEL_DEBUG);
	printf("API AddSpawnPos");
	return this.addSpawnPoint(x, y, z, ang, interiorId, teamId);
}

forward GetNumberOfSpawnPoints();
public GetNumberOfSpawnPoints() {
	Log("API Call: GetNumberOfSpawnPoints", LOG_LEVEL_DEBUG);
	return numberOfSpawnPositions;
}

forward SpawnPlayerAtRandomPos(playerid);
public SpawnPlayerAtRandomPos(playerid) {
	Log("API Call: SpawnPlayerAtRandomPos", LOG_LEVEL_DEBUG);
	return this.randomSpawnPlayer(playerid);
}

forward SpawnPlayerAtUniquePos(playerid);
public SpawnPlayerAtUniquePos(playerid) {
	Log("API CALL: SpawnPlayerAtUniquePos", LOG_LEVEL_DEBUG);
	return this.spawnPlayerUnique(playerid);
}

#undef this