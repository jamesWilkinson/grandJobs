/**
	SERVER SIDE AMMUNATION BY SA-MP BETA TESTER Jay_

	The purpose of this script is to allow servers to improve their anticheat by 
	controlling ammunation from their server side scripts and disabling all client side ammunation
	functionality.

	December 2014

**/
new version[4] = "1.0";


native ActorMoveTo(actorid, movetype, Float:X, Float:Y, Float:Z );

#include <a_samp>
#include menuHandler.pwn
#include utils.pwn 
#include storeHandler.pwn





public OnFilterScriptInit() {
	printf("Server side ammu-nation by Jay_ version %s", version);
	initActors();
	InitMenus();
}


public OnFilterScriptExit() {
	removeActors();
}


// Reset data on connect
public OnPlayerConnect(playerid) {

	IsPlayerInAnyAmmunation[playerid] = false;
	playerAmmunationID[playerid] = -1;
	return 1;
}


public OnPlayerCommandText(playerid, cmdtext[]) {


	if(!strcmp(cmdtext, "/jay")) {
	//	new Float:x, Float:y, Float:z;
	//	GetPlayerPos(playerid, x, y, z);
	//	CreateObject(353, x, y, z, 0, 0, 0);
		AnimateAmmunationActor(playerid, 331);
		return 1;
	}

	if(!strcmp(cmdtext, "/ammu")) {
		SetPlayerPos(playerid, 2536.0796,2085.4226,10.8203);
		return 1;
	}

	new cmd[256];
    new idx;
    new tmp[256];

    cmd = strtok(cmdtext, idx);
    if(strcmp(cmd,"/savepos",true)==0)
    {
        tmp = strtok(cmdtext,idx);
        new string[128], string2[64], Float:X, Float:Z, Float:Y, Float:ang;
        GetPlayerPos(playerid, X, Y, Z);
        GetPlayerFacingAngle(playerid, ang);
        format(string, sizeof(string), "%f, %f, %f, %f //%s \r\n", X, Y, Z, ang, cmdtext[9]);
     	new entry[256];
	    format(entry, sizeof(entry), "%s\r\n",string);
	    new File:hFile;
	    hFile = fopen("SavedPos.log", io_append);
	    if (hFile)
	    {
		    fwrite(hFile, entry);
		    fclose(hFile);
            format(string2, sizeof(string2),"Player Pos Should Be Saved. With comment: %s", cmdtext[9]);
       	 	SendClientMessage(playerid, -1,string2);
	    }
        return 1;
    }


	return 0;
}




forward OnPlayerEnterAmmunation(playerid, ammunationid);
public OnPlayerEnterAmmunation(playerid, ammunationid) {
	// ammunation IDs are 0-5 based on the first 5 listed here (BOOTH AND RANGE NOT INCLUDED): http://wiki.sa-mp.com/wiki/Interiors
	printf("Player %d entering ammunation ID %d", playerid, ammunationid);

}

forward OnPlayerLeaveAmmunation(playerid);
public OnPlayerLeaveAmmunation(playerid) {
	printf("Player %d leaving ammunation ID", playerid);
}



forward OnPlayerEnterAmmuCP(playerid, ammuid);
public OnPlayerEnterAmmuCP(playerid, ammuid) {
	printf("Player %d entered checkpoint in ammunation: %d", playerid, ammuid);
	SetPlayerAmmunationCamera(playerid, ammuid);
}





new state1;

forward AnimateAmmunationActor(actorid, weaponid);
public AnimateAmmunationActor(actorid, weaponid)
{
	switch(++state1) 
	{
	//	case 1: 
//			ApplyAnimation(actorid, "WEAPONS", "SHP_TRAY_POSE", 4.0, 0, 0, 0, 1, 0, 1); // shop_idle
		case 1:
			ApplyActorAnimation(actorid, "WEAPONS", "SHP_TRAY_OUT", 4.0, 0, 0, 0, 0, 0); // STEP1
		case 2: 
			ApplyActorAnimation(actorid, "WEAPONS", "SHP_G_LIFT_IN", 4.0, 0, 0, 0, 0, 0); // LIFT_IN
		case 3:
			ApplyActorAnimation(actorid, "WEAPONS", "SHP_1H_LIFT", 4.0, 0, 0, 0, 0, 0); // 2
		case 4:
			ApplyActorAnimation(actorid, "WEAPONS", "SHP_2H_LIFT_END", 4.0, 0, 0, 0, 1, 0); // 3
		case 5: {
			state1 = 0;
		}
	}

	if(state1 > 0 && state1 < 6) {
		SetTimerEx("AnimateAmmunationActor", 500, 0, "d", actorid);
	}
}
