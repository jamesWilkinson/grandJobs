/**
	Grand Jobs by Jay_
	Some misc commands such as /kill and /help etc
**/

COMMAND:kill(playerid, params[]) {
	#pragma unused params
	SetPlayerHealth(playerid, 0);
	return 1;
}