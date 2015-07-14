/**
	Grand Jobs - Spawn position helpers / API
**/

#include <a_samp>

#if defined _meta_included
	#endinput
#endif
#define _meta_included
#pragma library meta

stock AddSpawnPoint(Float:X, Float:Y, Float:Z, Float:ang, teamId, interiorId) {
	return CallRemoteFunction("AddSpawnPos", "ffffdd", X, Y, Z, ang, teamId, interiorId);
}

stock GetNumberOfSpawnPoints() {
	return CallRemoteFunction("GetNumberOfSpawnPoints", "");
}

stock SpawnPlayerAtRandomPos(playerid) {
	return CallRemoteFunction("SpawnPlayerAtRandomPos", "d", playerid);
}

// Note: doesn't work if the player is in a team!
stock SpawnPlayerAtUniquePos(playerid) {
	return CallRemoteFunction("SpawnPlayerAtUniquePos", "d", playerid);
}
