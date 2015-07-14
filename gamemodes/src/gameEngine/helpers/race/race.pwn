/**
	Grand Missions v0.1 by Jay
	Race handler
**/

#define this gameEngine::helpers->race

enum E_RACE_DATA {
	vehicleModel,
	lol
}

static raceData[E_RACE_DATA];

stock resetRaceData() {
	raceData[vehicleModel] = -1;
}

stock this.setVehicleModel(model) {
	if(model < 400 || model > 611)
		return 0;

	raceData[vehicleId] = model;
}

stock this.getVehicleModel() {
	return raceData[vehicleId];
}

stock this.createPlayerVehicle(playerid) {

}


#undef this 