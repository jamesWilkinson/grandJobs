/**
	List of global settings
**/

// versioning
#define     GLOBAL_SETTING_VERSION     "0.0.1"		// The number of the script

// Logging

#define		LOG_LEVEL_MESSAGE	0
#define		LOG_LEVEL_CALLBACK	10
#define		LOG_LEVEL_DEBUG		20
#define		LOG_LEVEL_WARNING	30
#define		LOG_LEVEL_ERROR		40
#define		LOG_LEVEL_CRITICAL	50

// Game engine
#define	MAX_NUMBER_OF_GAMES_IN_CACHE 	32

#define 	MAX_AUTHOR_STRING		64
#define 	MAX_NAME_STRING 		64
#define 	MAX_FILENAME_STRING		64
#define		MAX_OBJ_STRING			2048


#define		GAME_TYPE_NONE			-1
#define		GAME_TYPE_RACE			1
#define		GAME_TYPE_DM			2
#define		GAME_TYPE_TDM			3

#define		INVALID_GAME_ID			-1

// there should be a spawn point per game for every single player!
#define		MAX_SPAWN_POINTS		SLOTS 

stock GetGameID() {
	return gameEngine::initialisation->gameLoader.getCurrentGame();
}

stock PlayerName(playerid) {
	new name[MAX_PLAYER_NAME];
	if(!IsPlayerConnected(playerid)) {
		return name;
	}

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	return name;
}