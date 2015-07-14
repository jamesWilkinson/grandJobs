/**
	Textdraw Fader - original concept by Joe Staff, completely rewritten by Jay_ using a few concepts
**/

// This. is. BAD.
#define  PLAYER_COUNT		200

static PlayerText:FadeTD	[PLAYER_COUNT] 	= {PlayerText:INVALID_TEXT_DRAW, ...};
static fadeTimer			[PLAYER_COUNT] 	= {-1, ...};
static FadeScreenIteration	[PLAYER_COUNT] 	= {-1, ...};
// Once the screen has fulled faded in, this textdraw shows
static Text:GlobalFadeInTD  = 	Text:INVALID_TEXT_DRAW;

stock initScreenFade() {
	if(GlobalFadeInTD == Text:INVALID_TEXT_DRAW)
	{
		GlobalFadeInTD = TextDrawCreate(0, 0, "~r~");
		TextDrawTextSize(GlobalFadeInTD, 640, 480);
		TextDrawLetterSize(GlobalFadeInTD, 0, 50);
		TextDrawUseBox(GlobalFadeInTD, 1);
		TextDrawBoxColor(GlobalFadeInTD, 0x000000FF);
	}
}

ResetPlayerFadeData(playerid) {
	if(fadeTimer[playerid] != -1) {
		KillTimer(fadeTimer[playerid]);
		fadeTimer[playerid] = -1;
	}
	if(FadeTD[playerid] != PlayerText:INVALID_TEXT_DRAW) {
		PlayerTextDrawDestroy(playerid, FadeTD[playerid]);
		FadeTD[playerid] = PlayerText:INVALID_TEXT_DRAW;
	}
	FadeScreenIteration[playerid] = -1;
	TextDrawHideForPlayer(playerid, GlobalFadeInTD);
}

CreateFadeTextdraws(playerid) {
	if(FadeTD[playerid] == PlayerText:INVALID_TEXT_DRAW)
	{
		FadeTD[playerid] = CreatePlayerTextDraw(playerid, 0, 0, "~r~");
		PlayerTextDrawTextSize(playerid, FadeTD[playerid], 640, 480);
		PlayerTextDrawLetterSize(playerid, FadeTD[playerid], 0, 50);
		PlayerTextDrawUseBox(playerid, FadeTD[playerid], 1);
	}
}

forward UnfadePlayerScreen(playerid);
public UnfadePlayerScreen(playerid) {
	if(!IsPlayerConnected(playerid) || IsPlayerNPC(playerid))
		return 0;
	FadePlayerScreen(playerid, true);
	return 1;
}


stock FadePlayerScreen(playerid, bool:fade_out = false) {
	if(!IsPlayerConnected(playerid)) 
		return; 

	if(fadeTimer[playerid] != -1)
		KillTimer(fadeTimer[playerid]);

	FadeScreenIteration[playerid] = -1;

	CreateFadeTextdraws(playerid);
	

	if(fade_out == false) {
		fadeTimer[playerid] = SetTimerEx("UpdateTextdrawFade", 75, 1, "dd", playerid, 1);
	} else {
		fadeTimer[playerid] = SetTimerEx("UpdateTextdrawFade", 75, 1, "dd", playerid, 0);
	}
}

forward UpdateTextdrawFade(playerid, fade_in);
public UpdateTextdrawFade(playerid, fade_in) 
{
	// player has left the server during a screen fade
	if(!IsPlayerConnected(playerid)) {
		ResetPlayerFadeData(playerid);
		return;
	}

	new color;

	// Upon the first iteration, if this is a fade out hide the faded in textdraw
	if(FadeScreenIteration[playerid] == 0 && fade_in == 0) {
		TextDrawHideForPlayer(playerid, GlobalFadeInTD);
	}

	if(fade_in == 0)
   		color = 0xFF - 0x11 * ++FadeScreenIteration[playerid]; 
   	else 
   		color = 0x00 + 0x11 * ++FadeScreenIteration[playerid]; 

   	PlayerTextDrawBoxColor(playerid, FadeTD[playerid], color);
   	PlayerTextDrawShow(playerid, FadeTD[playerid]);

   	// we've reached the maximum fade out point
   	if(FadeScreenIteration[playerid] == 15)
   	{
   		if(fade_in == 1) {
			Log("Screen fade: show textdraw");
			PlayerTextDrawHide(playerid, FadeTD[playerid]);
			TextDrawShowForPlayer(playerid, GlobalFadeInTD);
		}
		else {
			Log("screen fade: hide textdraw");
			TextDrawHideForPlayer(playerid, GlobalFadeInTD);
		}
   		KillTimer(fadeTimer[playerid]);
   		fadeTimer[playerid] = -1;
   		FadeScreenIteration[playerid] = -1;
   	}
}

FadePlayerConnect(playerid) {
	if(playerid >= PLAYER_COUNT)
	{
		Log("TEXTDRAW SCREEN FADE WARNING: buffer overflow - need to increase PLAYER_COUNT");
		return;
	}

	ResetPlayerFadeData(playerid);
	CreateFadeTextdraws(playerid);
}

FadePlayerDisconnect(playerid) {
	ResetPlayerFadeData(playerid);
}