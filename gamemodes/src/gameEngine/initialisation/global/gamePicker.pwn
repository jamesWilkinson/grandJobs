/**
	The file handles the game picking - version 0.1 is only a random
	game picker, however, votes etc will be added to future versions
**/

#define this gameEngine::initialisation->gamePicker

this.chooseRandomGame(gametype = -1)
{
	Log(sprintf("Choosing a game: parameter: %d", gametype), LOG_LEVEL_DEBUG);
	// check to update the games we have stored.
	gameEngine::initialisation->globalGameLoader.init();

	new gameCount; 
	gameCount = gameEngine::initialisation->game.getNumberOfGamesLoaded();

	if(gameCount < 1)
	{
		Log("Unable to choose random game - Not enough games loaded.", LOG_LEVEL_CRITICAL);
		return -1;
	}

	// Ok, we want to load a random game with a specified type.
	if(gametype != -1) {
		new game = 0;
		new gameTypesFound = 0;
		new gameTypeIds[MAX_NUMBER_OF_GAMES_IN_CACHE];
		while(game != gameCount)
		{
			game++;
			if(gameEngine::initialisation->game.getGameType(game) == gametype)
			{	
				gameTypeIds[gameTypesFound] = game;
				gameTypesFound++;
			}
		}
		if(gameTypesFound > 0) {
			return gameTypeIds[random(gameTypesFound)];
		}
		Log(sprintf("chooseRandomGame(): No games found for type: %d. Choosing random game for type: ANY", gametype), LOG_LEVEL_ERROR);
	}

	// When type is set to -1, that means any game type!
	return random(gameCount);
}

this.showGameDialog(playerid) {
	new dialogStr[256];
	new gameCount; 
	gameCount = gameEngine::initialisation->game.getNumberOfGamesLoaded();


	for(new i = 0; i < gameCount; i++) {
		format(dialogStr, 256, "%s%s\n", dialogStr, gameEngine::initialisation->game.getGameName(i));
	}
	ShowPlayerDialog(playerid, 1337, DIALOG_STYLE_LIST, "Games loaded", dialogStr, "Close", "");
}

#undef this
