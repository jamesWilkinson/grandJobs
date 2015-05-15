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

