#include <a_samp>

new Text:_text;

new Text:Textdraw0;



new fadeInColor = 0;
new fadeOutColor = 15;

public OnFilterScriptInit() {

	_text=TextDrawCreate(-20, 0.0,"_");
	TextDrawTextSize(_text,640,480);
	TextDrawLetterSize(_text,0.0,50.0);
	TextDrawUseBox(_text,1);
	TextDrawBoxColor(_text, 0x000000FF);
//	TextDrawShowForAll(_text);

	// In OnGameModeInit prefferably, we procced to create our textdraws:
	Textdraw0 = TextDrawCreate(230.000000, 364.000000, "GRAND JOBS");
	TextDrawFont(Textdraw0, 1);
	TextDrawLetterSize(Textdraw0, 0.999999, 3.599998);
	TextDrawColor(Textdraw0, 0xFFFFFFFF);
	TextDrawSetOutline(Textdraw0, 0);
	TextDrawSetProportional(Textdraw0, 1);
	TextDrawSetShadow(Textdraw0, 1);

	//TextDrawShowForAll(Textdraw0);
}

public OnFilterScriptExit() {

	TextDrawDestroy(_text);
	TextDrawDestroy(Textdraw0);
}

public OnPlayerCommandText(playerid, cmdtext[]) {


	if(!strcmp(cmdtext, "/color")) {
	
		SendClientMessage(playerid, -1, "Done");
		fadeOut();
		return 1;
	}



	if(!strcmp(cmdtext, "/color2")) {
		SendClientMessage(playerid, -1, "Done");
		fadeIn();
		return 1;
	}


	return 0;
}

forward fadeOut();
public fadeOut() {
	new color = 0;
	switch(++fadeInColor) {
		case 0: color = 0x000000FF;
		case 1: color =  0x000000EE;
		case 2: color =  0x000000DD;
		case 3: color =  0x000000CC;
		case 4: color = 0x000000BB;
		case 5: color = 0x000000AA;
		case 6: color = 0x00000099;
		case 7: color = 0x00000088;
		case 8: color = 0x00000077;
		case 9: color = 0x00000066;
		case 10: color = 0x00000055;
		case 11: color = 0x00000044;
		case 12: color =  0x00000033;
		case 13: color =  0x00000022;
		case 14: color =  0x00000011;
		case 15: color = 0x00000000;
	}

	TextDrawBoxColor(_text, color);
	TextDrawShowForAll(_text);
	if(fadeInColor < 15) {
		SetTimer("fadeOut", 100, 0);
	} else {
		fadeInColor = 0;
	}
}


forward fadeIn();
public fadeIn() {
	new color = 0;
	switch(--fadeOutColor) {
				case 0: color = 0x000000FF;
		case 1: color =  0x000000EE;
		case 2: color =  0x000000DD;
		case 3: color =  0x000000CC;
		case 4: color = 0x000000BB;
		case 5: color = 0x000000AA;
		case 6: color = 0x00000099;
		case 7: color = 0x00000088;
		case 8: color = 0x00000077;
		case 9: color = 0x00000066;
		case 10: color = 0x00000055;
		case 11: color = 0x00000044;
		case 12: color =  0x00000033;
		case 13: color =  0x00000022;
		case 14: color =  0x00000011;
		case 15: color = 0x00000000;
	}

	TextDrawBoxColor(_text, color);
	TextDrawShowForAll(_text);

	if(fadeOutColor > 0) {
		SetTimer("fadeIn", 100, 0);
	} else {
		fadeOutColor = 15;
	}
}


new Text:Sprite0 = Text:INVALID_TEXT_DRAW;

ShowRandomLoadingScreen() {

	if(Sprite0 != Text:INVALID_TEXT_DRAW) {
		TextDrawDestroy(Sprite0):
	}

  	Sprite0 = TextDrawCreate(245.500, 7.000, "outro:outro");
    TextDrawFont(Sprite0, 4);
    TextDrawTextSize(Sprite0, 100.000, 100.000);
    TextDrawColor(Sprite0, -1);

}

HideRandomLoadingScreen() {
	TextDrawDestroy(Text:Sprite0);
}

