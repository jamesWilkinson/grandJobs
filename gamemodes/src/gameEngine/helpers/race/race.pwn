/**
	Grand Missions v0.1 by Jay
	Race handler
**/

#define this gameEngine::helpers->race

enum E_RACE_DATA {
	vehicleModel,
}

static raceData[E_RACE_DATA];
static playerRaceVehicle[SLOTS] = {-1, ...};


stock this.resetRaceData() {
	raceData[vehicleModel] = -1;

	// remove all player vehicles
	for(new i = 0; i < SLOTS; i++) {
		this.destroyPlayerVehicle(i);
	}
}


stock this.setVehicleModel(model) {
	if(model < 400 || model > 611)
		return 0;

	raceData[vehicleModel] = model;
	return 1;
}


stock this.getVehicleModel() {
	return raceData[vehicleModel];
}


// Create a race vehicle and put the player inside it - 
// return the vehicle id.
stock this.createPlayerVehicle(playerid) {
	if(!IsPlayerConnected(playerid) || IsPlayerNPC(playerid) || this.getVehicleModel() == -1) {
		return 0;
	}

	// check to destroy the players vehicle first
	this.destroyPlayerVehicle(playerid);

	// create the new vehicle and put the player inside it.
	new Float:x, Float:y, Float:z, Float:ang;
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, ang);
	playerRaceVehicle[playerid] = CreateVehicle(this.getVehicleModel(), x, y, z, ang, -1, -1, 120);
	SetVehicleVirtualWorld(playerRaceVehicle[playerid], GetPlayerVirtualWorld(playerid));
	LinkVehicleToInterior(playerRaceVehicle[playerid], GetPlayerInterior(playerid));
	PutPlayerInVehicle(playerid, playerRaceVehicle[playerid], 0);
	return playerRaceVehicle[playerid];
}

stock this.destroyPlayerVehicle(playerid) {
	if(playerid < 0 || playerid >= SLOTS) {
		return 0;
	}
	if(playerRaceVehicle[playerid] != -1) {
		DestroyVehicle(playerRaceVehicle[playerid]);
		playerRaceVehicle[playerid] = -1;
		return 1;
	}
	return 0;
}

// This is called from OnVehicleSpawn and OnVehicleDeath
// when the players vehicle has died/respawned, we get rid of it
stock this.checkToDestroyVehicle(vehicleid) {
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)  {
		if(playerRaceVehicle[i] == -1)
			continue;

		if(vehicleid != playerRaceVehicle[i])
			continue;
		
		// phew we have a match - destroy the players vehicle and we're done here.		
		this.destroyPlayerVehicle(i);
		break;
	}
}


// API functions

forward SetRaceVehicle(modelid);
public SetRaceVehicle(modelid) {
	Log("API Call: SetRaceVehicle");
	this.setVehicleModel(modelid);
	return 1;
}

forward GetRaceVehicle();
public GetRaceVehicle() {
	Log("API Call: GetRaceVehicle");
	return this.getVehicleModel();
}

forward CreatePlayerRaceVehicle(playerid);
public CreatePlayerRaceVehicle(playerid) {
	Log("API Call: CreatePlayerRaceVehicle");
	return this.createPlayerVehicle(playerid);
}


forward DestroyPlayerRaceVehicle(playerid);
public DestroyPlayerRaceVehicle(playerid) {
	Log("API Call: DestroyPlayerRaceVehicle");
	return this.destroyPlayerVehicle(playerid);
}

#undef this 