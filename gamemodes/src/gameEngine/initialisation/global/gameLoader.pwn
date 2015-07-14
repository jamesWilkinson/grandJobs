/**
	Load a game - one of the first things that happens upon initialisation :>
**/

#define this gameEngine::initialisation->gameLoader

static currentGameId = INVALID_GAME_ID;
static timeoutTimer = -1;
static exitGameChangerTimer = -1;

#define		GAME_LOAD_TIMEOUT		3000	// if we don't have communication from a fs after this amount of seconds, request times out

this.init(gameId = -1)
{
	// before attempting to load a game, unload any current ones.
	if(this.getCurrentGame() != INVALID_GAME_ID) 
		gameEngine::initialisation->gameUnloader.init();

	if(gameId == -1) {
		currentGameId = gameEngine::initialisation->gamePicker.chooseRandomGame();
	} else {
		// load a game with the specified ID!
		currentGameId = gameId;
	}
	
	// check to kill any existing timers before starting a new one
	if(timeoutTimer != -1) {
		KillTimer(timeoutTimer);
	}

	timeoutTimer = SetTimer("GameLoadTimeout", GAME_LOAD_TIMEOUT, 0);

	SendRconCommand(sprintf("loadfs game/%s", gameEngine::initialisation->game.getGameFileName(currentGameId)));
}


forward GameLoadTimeout();
public GameLoadTimeout() {

	// A gme has been loaded - kill timeout check ;)
	if(timeoutTimer == -1)
		return;

	Log("Could not load game: request timed out.", LOG_LEVEL_CRITICAL);
	SendClientMessageToAll(-1, "COULD NOT LOAD  GAME: REQUEST TIMED OUT!!");
	gameEngine::initialisation->gameUnloader.init();
	timeoutTimer = -1;
}


forward InitTheGame();
public InitTheGame() {
	Log(sprintf("GameInit called from a filterscript. timeouttimer: %d", timeoutTimer), LOG_LEVEL_DEBUG);
	
	// Kill time timeout timer since the game has loaded :)
	if(timeoutTimer != -1) {
		KillTimer(timeoutTimer);
		timeoutTimer = -1;
	}


	SendClientMessageToAll(-1, "The game loaded and did not time out woo");

	SendClientMessageToAll(-1, sprintf("The next game is... %s", gameEngine::initialisation->game.getGameName(currentGameId)));
	Log(sprintf("Loading Game: %s (ID:%d)", gameEngine::initialisation->game.getGameName(currentGameId), currentGameId), LOG_LEVEL_MESSAGE);
	
	if(exitGameChangerTimer != -1) {
		KillTimer(exitGameChangerTimer);
	}

	exitGameChangerTimer = SetTimer("ExitGameChangerScreen", 5500, 0);
	return 1;
}

forward ExitGameChangerScreen();
public ExitGameChangerScreen() {
	
	// check if this timer has been killed by a premature game exit or load
	if(exitGameChangerTimer == -1) 
		return;

	exitGameChangerTimer = -1;

	Log("ExitGameChangerScreen", LOG_LEVEL_DEBUG);
	

	gameEngine::initialisation->gameChanger.exit();

	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++) {
		SpawnPlayer(i);
	}
}

this.resetCurrentGame() {
	currentGameId = INVALID_GAME_ID;
	if(timeoutTimer != -1) {
		KillTimer(timeoutTimer);
		timeoutTimer = -1;
	}
	if(exitGameChangerTimer != -1) {
		KillTimer(exitGameChangerTimer);
	}
}

this.getCurrentGame() {
	return currentGameId;
}

#undef this
