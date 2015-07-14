/**
	This file handles all related events to a player dying.
**/
//#define this core::playerConnection->handleWelcomeMessage

#define this core::player->death

static Text:TDEditor_TD[3] = {Text:INVALID_TEXT_DRAW, ...};
static PlayerText:TDEditor_PTD[SLOTS] = { PlayerText:INVALID_TEXT_DRAW, ...};

// Called from OnGameModeInit to initialise the "Wasted" textdraw affect
this.init() {

	/*TDEditor_TD[0] = TextDrawCreate(-117.333343, -119.192596, "ld_spac:black");
	TextDrawLetterSize(TDEditor_TD[0], 0.000000, 0.000000);
	TextDrawTextSize(TDEditor_TD[0], 914.333129, 783.984985);
	TextDrawAlignment(TDEditor_TD[0], 1);
	TextDrawColor(TDEditor_TD[0], -186);
	TextDrawSetShadow(TDEditor_TD[0], 0);
	TextDrawSetOutline(TDEditor_TD[0], 0);
	TextDrawBackgroundColor(TDEditor_TD[0], 255);
	TextDrawFont(TDEditor_TD[0], 4);
	TextDrawSetProportional(TDEditor_TD[0], 0);
	TextDrawSetShadow(TDEditor_TD[0], 0);*/

	TDEditor_TD[1] = TextDrawCreate(320.000000, 190.000000, "wasted");
	TextDrawLetterSize(TDEditor_TD[1], 0.730997, 3.043555);
	TextDrawAlignment(TDEditor_TD[1], 2);
	TextDrawColor(TDEditor_TD[1], -76);
	TextDrawSetShadow(TDEditor_TD[1], 0);
	TextDrawSetOutline(TDEditor_TD[1], 0);
	TextDrawBackgroundColor(TDEditor_TD[1], 255);
	TextDrawFont(TDEditor_TD[1], 3);
	TextDrawSetProportional(TDEditor_TD[1], 1);
	TextDrawSetShadow(TDEditor_TD[1], 0);

	TDEditor_TD[2] = TextDrawCreate(-17.666658, 165.300109, "");
	TextDrawLetterSize(TDEditor_TD[2], 0.000000, 0.000000);
	TextDrawTextSize(TDEditor_TD[2], 668.000061, 86.266624);
	TextDrawAlignment(TDEditor_TD[2], 1);
	TextDrawColor(TDEditor_TD[2], 140);
	TextDrawSetShadow(TDEditor_TD[2], 0);
	TextDrawSetOutline(TDEditor_TD[2], 0);
	TextDrawBackgroundColor(TDEditor_TD[2], 0);
	TextDrawFont(TDEditor_TD[2], 5);
	TextDrawSetProportional(TDEditor_TD[2], 0);
	TextDrawSetShadow(TDEditor_TD[2], 0);
	TextDrawSetPreviewModel(TDEditor_TD[2], 19454);
	TextDrawSetPreviewRot(TDEditor_TD[2], 0.000000, 0.000000, 70.000000, 0.375391);
}

// Called from OnPlayerDeath
this.main(playerid, killerid, reason) {
	
	// Play a "wasted" sound affect
	gameEngine::helpers->sound.wastedSoundAffect(playerid);

	// Killed camera affect, originally by slice
  	if(IsPlayerConnected(killerid) && IsPlayerStreamedIn(playerid, killerid)) {
	    new
	        Float:x[ 2 ],
	        Float:y[ 2 ],
	        Float:z[ 2 ];

	    GetPlayerPos( playerid, x[ 0 ], y[ 0 ], z[ 0 ] );
	    GetPlayerPos( killerid, x[ 1 ], y[ 1 ], z[ 1 ] );

	    GetPosInFrontOfPlayer(killerid, x[ 1 ], y[ 1 ],   -1.5 );
	    SetPlayerCameraPos   (playerid, x[ 1 ], y[ 1 ], z[ 1 ] + 1.0 );
	    SetPlayerCameraLookAt(playerid, x[ 0 ], y[ 0 ], z[ 0 ] );
    }
    this.showWastedTextdraw(playerid, this.getWastedReasonString(reason, killerid));
}

this.showWastedTextdraw(playerid, wastedReasonStr[]) {

	for(new i = 0; i < 3; i++)
		TextDrawShowForPlayer(playerid, TDEditor_TD[i]);

	if(!strlen(wastedReasonStr))
		return;

	if(TDEditor_PTD[playerid] != PlayerText:INVALID_TEXT_DRAW) 
		PlayerTextDrawDestroy(playerid, TDEditor_PTD[playerid]);

	TDEditor_PTD[playerid] = CreatePlayerTextDraw(playerid, 320.000000, 215.100479, wastedReasonStr);
	PlayerTextDrawLetterSize(playerid, TDEditor_PTD[playerid], 0.352331, 1.583407);
	PlayerTextDrawAlignment(playerid, TDEditor_PTD[playerid], 2);
	PlayerTextDrawColor(playerid, TDEditor_PTD[playerid], -2359116);
	PlayerTextDrawSetShadow(playerid, TDEditor_PTD[playerid], 0);
	PlayerTextDrawSetOutline(playerid, TDEditor_PTD[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, TDEditor_PTD[playerid], 255);
	PlayerTextDrawFont(playerid, TDEditor_PTD[playerid], 1);
	PlayerTextDrawSetProportional(playerid, TDEditor_PTD[playerid], 1);
	PlayerTextDrawSetShadow(playerid, TDEditor_PTD[playerid], 0);

	PlayerTextDrawShow(playerid, TDEditor_PTD[playerid]);
}

this.hideWastedTextdraw(playerid) {
	if(TDEditor_PTD[playerid] != PlayerText:INVALID_TEXT_DRAW) {
		PlayerTextDrawDestroy(playerid, TDEditor_PTD[playerid]);
		TDEditor_PTD[playerid] = PlayerText:INVALID_TEXT_DRAW;
	}

	for(new i = 0; i < 3; i++)
		TextDrawHideForPlayer(playerid, TDEditor_TD[i]);
}

// Called from OnPlayerStateChange and is used to show/hide the wasted
// textdraw accordingly
this.checkToHideWastedTextdraw(playerid, oldstate) {
 	if(oldstate == PLAYER_STATE_WASTED) {
		this.hideWastedTextdraw(playerid);
	}
}

this.getWastedReasonString(reason, killerid) {
	new str[64] = "";

	switch(reason) {
		case 0:
			str = "You got punched out";
		case 1:
			str = "Metal faced";
		case 2:
			str = "Golf Clubbed";
		case 3:
			str = "Nightstick Beaten";
		case 4:
			str = "Slashed!";
		case 5: 
			str = "Beaten to a pulp";
		case 6:
			str = "Buried Alive";
		case 7:
			str = "Pool'd";
		case 8:
			str = "Sliced!";
		case 9:
			str = "Ripped up!";
		case 10:
			str = "Sexually abused";
		case 11:
			str = "Sex beaten";
		case 12:
			str = "Sexy kill";
		case 13:
			str = "Kinky kill";
		case 14:
			str = "Garden Abused";
		case 15:
			str = "Cane'd";
		case 16:
			str = "Exploded";
		case 17:
			str = "Gassed Alive";
		case 18:
			str = "Burnt Alive";
		case 22:
			str = "Pistol Whipped";
		case 23:
			str = "Silent kill";
		case 24:
			str = "Deagled";
		case 25:
			str = "Shotgun Kill";	
		case 26:
			str = "Sawned off";
		case 27:
			str = "Blasted away";
		case 28:
			str = "Micro Uzi'd";
		case 29:
			str = "MP5'd";
		case 30:
			str = "Assault Rifled";
		case 31:
			str = "M4 kill";
		case 32:
			str = "Uzi'd";
		case 33:
			str = "Farmers Rifle!";
		case 34:
			str = "Sniped!";
		case 35:
			str = "Rocket Launcher";
		case 36:
			str = "Rocket Launcher";
		case 37:
			str = "Flamed!";
		case 38:
			str = "MINIGUN MASSACRE";
		case 41:
			str = "Sprayed in the face";
		case 42:
			str = "Fire Extingushed!";
		case 49:
			str = "Mowed down by";
		case 51:
			str = "Killed by an explosion";
		case 53:
			str = "Drowned!";
		case 54:
			str = "Splat!";
	}

	// If the killer is connected, append their name to the reason string.
	if(IsPlayerConnected(killerid)) {
		new killerstr[32];
		format(killerstr, 32, " by %s", PlayerName(killerid));
		format(str, 128, "%s%s", str, killerstr);
	}
	return str;
}

#undef this