
#include <a_samp>

#if defined _race_included
	#endinput
#endif
#define _race_included
#pragma library race 

stock SetRaceVehicleModel(modelid) {
	return CallRemoteFunction("SetRaceVehicle", "d", modelid);
}

stock GetRaceVehicleModel() {
	return CallRemoteFunction("GetRaceVehicle", "");
}

stock CreatePlayerRaceVehicle(playerid) {
	return CallRemoteFunction("CreatePlayerRaceVehicle", "d", playerid);
}

stock DestroyPlayerRaceVehicle(playerid) {
	return CallRemoteFunction("DestroyPlayerRaceVehicle", "");
}