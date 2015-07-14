/**
	This file will handle the unloading of a game, by resetting all of the relevant
	game and player data, and putting each player in the game idle phase
**/

#define this gameEngine::initialisation->gameUnloader

this.init()
{
	new currentGameId;
	currentGameId = gameEngine::initialisation->gameLoader.getCurrentGame();

	if(currentGameId == INVALID_GAME_ID)
	{
		Log("gameUnloader init: No game currently loaded.", LOG_LEVEL_DEBUG);
		return;
	}

	Log("----------------");
	Log(sprintf("Unloading game: %s", gameEngine::initialisation->game.getGameName(currentGameId)));
	SendRconCommand(sprintf("unloadfs game/%s", gameEngine::initialisation->game.getGameFileName(currentGameId)));

	// ENTER THE GAME LOAD SCREEN AS NO GAME IS LOADED
	gameEngine::initialisation->gameChanger.init();

	// reset data across all handlers
	gameEngine::initialisation->Meta.reset();
	gameEngine::helpers->spawn.resetSpawnData();


	gameEngine::initialisation->gameLoader.resetCurrentGame();
	
	// wait 2.5 seconds before respawning all players so the screen has faded in
	SetTimer("RespawnAllPlayers", 2500, 0);
}

forward RespawnAllPlayers();
public RespawnAllPlayers()
{
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		SpawnPlayer(i);
		SendClientMessage(i, -1, "The game has been unloaded. You've been respawned.");
	}
}

#undef this
