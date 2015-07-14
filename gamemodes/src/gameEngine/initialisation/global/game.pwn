/**
	This file will load the games from the gameList.cfg file every so often for the sake of caching in the gamemode.
	The cache will be updated after x seconds
**/

#define this gameEngine::initialisation->game

// this data should be readonly, since it's loaded from the CSV file
enum E_GAME_DATA_GLOBAL
{
	name[MAX_NAME_STRING], 
	filename[MAX_FILENAME_STRING], 
	type 
}

static  stock   gameData[MAX_NUMBER_OF_GAMES_IN_CACHE][E_GAME_DATA_GLOBAL];
static  stock   numberOfGamesLoaded = 0;


this.addToCache(gameName[], fileName[], gameType) {
	if(this.getNumberOfGamesLoaded() >= MAX_NUMBER_OF_GAMES_IN_CACHE) {
		Log(sprintf("Unable to add game to cache - filename: %s, gameName: %s, gameType: %s - MAX_NUMBER_OF_GAMES_IN_CACHE exceeded (value: %d, loaded: %d)", 
			fileName, gameName, gameType, MAX_NUMBER_OF_GAMES_IN_CACHE, this.getNumberOfGamesLoaded()), LOG_LEVEL_ERROR);
		return 0;
	}
	
	format(gameData[numberOfGamesLoaded][name], MAX_NAME_STRING, "%s", gameName);

	format(gameData[numberOfGamesLoaded][filename], MAX_NAME_STRING, "%s", fileName);

	gameData[numberOfGamesLoaded][type] = gameType;

	Log(sprintf("Added game %d to cache. GameName: %s, FileName: %s, Type: %d", 
		numberOfGamesLoaded, gameName, fileName, gameType), LOG_LEVEL_DEBUG);
	
	numberOfGamesLoaded++;
	return 1;
}

this.resetGlobalGameData() {

	for(new i = 0; i < this.getNumberOfGamesLoaded(); i++) {
		format(gameData[i][name], MAX_NAME_STRING, ""); 
		format(gameData[i][filename], MAX_FILENAME_STRING, "");
		gameData[i][type] = GAME_TYPE_NONE;
	}
	numberOfGamesLoaded = 0;
}

this.isValidGame(gameId) {
	return (gameId < 0 || gameId > numberOfGamesLoaded) ? false : true;
}

this.getGameType(gameId) {
	if(gameId < 0 || gameId > this.getNumberOfGamesLoaded()) {
		return GAME_TYPE_NONE;
	}
	return gameData[gameId][type];
}


this.getGameName(gameId) {
	
	new str[MAX_NAME_STRING];
	if(gameId >= 0 && gameId < MAX_NUMBER_OF_GAMES_IN_CACHE) {
		Log(sprintf("GetGameName(%d): %s", gameId, gameData[gameId][name]), LOG_LEVEL_DEBUG);
		format(str, MAX_NAME_STRING, "%s", gameData[gameId][name]);	
	}
	return str;
}

this.getGameFileName(gameId) {
	new str[MAX_NAME_STRING];
	if(gameId >= 0 && gameId < MAX_NUMBER_OF_GAMES_IN_CACHE) {
		Log(sprintf("GetGameFileName(%d): %s", gameId, gameData[gameId][filename]), LOG_LEVEL_DEBUG);
		format(str, MAX_NAME_STRING, "%s", gameData[gameId][filename]);	
	}
	return str;
}


// we'll make this an API function
this.getNumberOfGamesLoaded() {
	return numberOfGamesLoaded;
}

forward GetNumberOfGames();
public GetNumberOfGames() {
	return this.getNumberOfGamesLoaded();
}

#undef this
