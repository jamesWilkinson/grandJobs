#include <a_samp>

#include <game/meta.pwn>
#include <game/spawn.pwn>

public OnFilterScriptInit() {

	CallRemoteFunction("InitTheGame", "");


	printf("----------");
	printf("JayDM loaded BABY");

	SetGameName("Jay DM!");
	SetGameType(GAME_TYPE_DM);
	SetGameAuthor("Jay__");
	SetGameVersionMajor(0);
	SetGameVersionMinor(1);

	AddSpawnPoint(211.594009, 1911.574218, 17.640625, -90, NO_TEAM, 0);
		AddSpawnPoint(211.594009, 1911.574218, 17.640625+10, -90, NO_TEAM, 0);
			AddSpawnPoint(211.594009, 1911.574218, 117.640625, -90, NO_TEAM, 0);
	GetNumberOfSpawnPoints();

	return 1;
}

public OnFilterScriptExit() {
	printf("-----------");
	printf("JayDM unloaded");
}

public OnPlayerSpawn(playerid) {

	SpawnPlayerAtRandomPos(playerid);
//	SpawnPlayerAtUniquePos(playerid);
	SendClientMessage(playerid, -1, "Takeout the others!11!");
	GivePlayerWeapon(playerid, 38, 1000);
}
