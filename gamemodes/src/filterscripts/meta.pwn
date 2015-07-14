/**
	Grand Missions by Jay_: Sanandreas: Multiplayer missions server
	Meta API
**/

#include <a_samp>

#if defined _meta_included
	#endinput
#endif
#define _meta_included
#pragma library meta

#define		GAME_TYPE_NONE			-1
#define		GAME_TYPE_RACE			1
#define		GAME_TYPE_DM			2
#define		GAME_TYPE_TDM			3

#define 	MAX_AUTHOR_STRING		64
#define 	MAX_NAME_STRING 		64
#define 	MAX_FILENAME_STRING		64
#define		MAX_OBJECTIVE_LENGTH	2048

stock SetGameObjective(obj[]) {
	return CallRemoteFunction("SetGameObjective", obj);
}

stock GetGameObjective() {
	return CallRemoteFunction("GetGameObjective");
}


stock GetGameType() {
	return CallRemoteFunction("GetGameType", "");
}

stock SetGameType(type) {
	return CallRemoteFunction("SetGameType", "d", type);
}

stock SetGameAuthor(author[]) {
	return CallRemoteFunction("SetGameAuthor", "d", author);
}

stock GetGameAuthor() {
	return CallRemoteFunction("GetGameAuthor", "");
}

stock GetGameName(){
	return CallRemoteFunction("GetGameName", "");
}

stock SetGameName(name[]) {
	return CallRemoteFunction("SetGameName", "s", name);
}

stock SetGameFilename(name[]) {
	return CallRemoteFunction("SetFilename", "s", name);
}

// This has been removed because it's only a getter of the SetGameFilename function
// and won't tie in with the actual filename
//stock GetGameFilename() {
	// return CallRemoteFunction("GetFilename", "");
//}

stock SetGameVersionMinor(ver) {
	return CallRemoteFunction("SetVersionMinor", "d", ver);
}

stock GetGameVersionMinor(ver) {
	return CallRemoteFunction("GetVersionMinor", "");
}

stock SetGameVersionMajor(ver) {
	return CallRemoteFunction("SetVersionMajor", "d", ver);
}

stock GetGameVersionMajor() {
	return CallRemoteFunction("GetVersionMajor", "");
}

stock GetGameVersionString() {
	new str[64];
	format(str, sizeof(str), "%d.%d", GetGameVersionMajor(), GetGameVersionMinor());
	return str;
}
