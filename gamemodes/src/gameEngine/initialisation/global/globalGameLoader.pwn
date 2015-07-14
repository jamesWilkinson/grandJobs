/**
	This file will load the games from the gameList.cfg file every so often for the sake of caching in the gamemode.
	The cache will be updated after x seconds
**/

#define this gameEngine::initialisation->globalGameLoader

#define 	GAME_LOADER_CACHE_TIME			3600000		// the game list will only be updated once an hour

static 	stock 	gameFile[13] = "gameList.csv";
static 	stock 	cacheTime = 0;

this.init() {
	if(!(cacheTime) || (GetTickCount() - cacheTime > GAME_LOADER_CACHE_TIME)) {
		cacheTime = GetTickCount();
		this.loadRegisteredGamesFromFile();
	}
}


this.loadRegisteredGamesFromFile()
{
	Log(sprintf("Loading games from file: %s", gameFile), LOG_LEVEL_DEBUG);

	new File:gameCSV;
	gameCSV = fopen(gameFile);

	// an error occured :(
	if(!gameCSV)  {
		Log("Game file cannot be opened/created", LOG_LEVEL_CRITICAL);
		return;
	}
	// reset number of games loaded
	gameEngine::initialisation->game.resetGlobalGameData();
	
	new 
		readString[256];

	while(fread(gameCSV, readString)) 
	{
		new
			tempFileName[MAX_FILENAME_STRING],
			tempGameName[MAX_NAME_STRING],
			tempGameType;

		Log(sprintf("Read string: %s", readString), LOG_LEVEL_DEBUG);
		sscanf(readString, "p<,>s[" #MAX_NAME_STRING "]s[" #MAX_FILENAME_STRING "]d", tempGameName, tempFileName, tempGameType);
		
		if(strlen(tempGameName) == 0 || strlen(tempFileName) == 0)
			continue;
		
		// Attempt to add the game to the cache
		if(!gameEngine::initialisation->game.addToCache(tempGameName, tempFileName, tempGameType))
			break;
		
	}
	fclose(gameCSV);
}


#undef this