/**
*   Grand Duty - a project led by Sanandreas Multiplayer BETA Tester
*   Jay_
*
*/


#include "core\internal\includes.pwn"

main()
{

	if(core::initialisation->initDatabase.wasConnectionSuccessful())
	{
		new
			year, month, day, hour, minute, second;
		getdate(year, month, day);
		gettime(hour, minute, second);
		
		printf("\n------------ GRAND JOBS GAMEMODE -------------");
		printf("Welcome to Grand Jobs - the number one SA-MP missions server by Jay_");
		printf("Version %s", GLOBAL_SETTING_VERSION);
		printf("Date and Time: %d/%d/%d - %d:%d:%d", day, month, year, hour, minute, second);
		printf("Everything is initialisied and running fine.");
		printf("-------------------------------------------------\n");
	}
}

COMMAND:register(playerid, params[]) {

	if(database::API->IsPlayerRegistered.get(playerid)) {
		return SendClientCommandError(playerid, "You are already registered.");
	}

	database::API->controller.registerPlayer(playerid, "omghax", "wilkinson_929@hotmail.com");
	SendClientCommandSuccess(playerid, "done");
	return 1;
}

COMMAND:check(playerid, params[])
{
	if(isnull(params)) {
		return SendClientCommandUse(playerid, "Use: /check [password]");
	}

	if(database::API->AccountPassword.validate(playerid, params))
	{
		SendClientCommandSuccess(playerid, "Worked!");
	}
	else
	{
		SendClientCommandError(playerid, "Failed!");
	}

	return 1;
}