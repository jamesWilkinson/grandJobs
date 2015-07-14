/**
*   Grand Duty - a project led by Sanandreas Multiplayer BETA Tester
*   Jay_
*
*/

//#include <a_samp>

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



CMD:unloadgame(playerid, params[]) {
	SendClientInfoMessage(playerid, "lol");
	gameEngine::initialisation->gameUnloader.init();
	return 1;
}

CMD:loadgame(playerid, params[]) {
	gameEngine::initialisation->gameLoader.init();
	return 1;
}

CMD:savepos(playerid, params[]) {

    new string[128], string2[64], Float:X, Float:Z, Float:Y, Float:ang;
    GetPlayerPos(playerid, X, Y, Z);
    GetPlayerFacingAngle(playerid, ang);
    format(string, sizeof(string), "%f, %f, %f, %f //%s \r\n", X, Y, Z, ang, params);
 	new entry[256];
    format(entry, sizeof(entry), "%s\r\n",string);
    new File:hFile;
    hFile = fopen("SavedPos.log", io_append);
    if (hFile)
    {
	    fwrite(hFile, entry);
	    fclose(hFile);
        format(string2, sizeof(string2),"Player Pos Should Be Saved. With comment: %s", params);
   	 	SendClientMessage(playerid, -1,string2);
    }
    return 1;
}

