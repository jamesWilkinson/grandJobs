/**
	Game Changing - handle
**/

#define this gameEngine::initialisation->gameChanger

static textAnimationTimer = -1;
static textAnimationIteration = 0;
static textAnimationIteration2 = 0;

// Display the server information
static Text:handleWelcomeMessageTitle = Text:INVALID_TEXT_DRAW;
static Text:handleWelcomeMessageAuthor = Text:INVALID_TEXT_DRAW;

static Text:featureShowOff = Text:INVALID_TEXT_DRAW;
static Text:featureShowOffTitle = Text:INVALID_TEXT_DRAW;

static audioStreamURLs[4][256] = {
	{"https://dl.dropboxusercontent.com/u/45389967/grandjobs/Bloons%20TD%205%20OST%20%28Hq%29.mp3"},
	{"https://dl.dropboxusercontent.com/u/45389967/grandjobs/Roller%20Coaster%20Tycoon%203%20OST%20%20-%20%20Summer%20Air.mp3"},
	{"https://dl.dropboxusercontent.com/u/45389967/grandjobs/Roller%20Coaster%20Tycoon%203%20OST%20%20-%20%20Summer%20Air.mp3"},
	{"https://dl.dropboxusercontent.com/u/45389967/grandjobs/Roller%20Coaster%20Tycoon%203%20OST%20%20-%20%20Summer%20Air.mp3"}
};

static featureText[3][128] = {
	{"Over 50 different minigames and minimissions"},
	{"Uses the latest SA-MP features and technology"},
	{"Official Sanandreas: Multiplayer server"}
};

// Called from OnGameModeInit to initialise the animation timers
this.construct() {
	if(textAnimationTimer != -1) {
		KillTimer(textAnimationTimer);
	}
	textAnimationTimer = SetTimer("AnimateText", 3000, 0);
	this.createTextdraws();
	SetTimer("ChangeFeatureText", 10000, 1);
}

forward ChangeFeatureText();
public ChangeFeatureText() {
	TextDrawSetString(featureShowOff, featureText[random(3)]);
	SetTimer("HideFeatureText", 5000, 0);
}

forward HideFeatureText();
public HideFeatureText() {
	TextDrawSetString(featureShowOff, "__");
}


forward AnimateText();
public AnimateText() {
	
	// first of all kill the initial timer
	if(textAnimationTimer != -1) {
		KillTimer(textAnimationTimer);
		textAnimationTimer = -1;
	}

	// animation complete. when should the next one repeat?
	if(textAnimationIteration > 18)
	{
		new timertime;

		if(textAnimationIteration2 < 2) {
			timertime = 300;
		} else {
			textAnimationIteration2 = 0;
			timertime = 4500;
		}

		textAnimationIteration2++;
		textAnimationTimer = SetTimer("AnimateText", timertime, 0);
		textAnimationIteration = 0;
		TextDrawSetString(handleWelcomeMessageTitle,  sprintf("__Grand Joins v%s_________", GLOBAL_SETTING_VERSION));
		return;
	} 

	textAnimationTimer = SetTimer("AnimateText", 100, 0);

	new originalStr[128];
	format(originalStr, 128, "__Grand Joins v%s_________", GLOBAL_SETTING_VERSION);

	strins(originalStr,  "~y~", textAnimationIteration);
	strins(originalStr, "~w~", textAnimationIteration + 7);
	TextDrawSetString(handleWelcomeMessageTitle, originalStr);
	textAnimationIteration++;
}


// Initialise the game changer screen for all players.
this.init() {
	// fade in the screen for all players
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++) {
		if(!IsPlayerConnected(i) || IsPlayerNPC(i)) {
			continue;
		}
		FadePlayerScreen(i);
		PlayAudioStreamForPlayer(i, audioStreamURLs[random(4)]);
	}

	// Show the textdraw for all players too.
	SetTimer("ShowGameChangeTDs", 5000, 0);
}

// Exit the game changer screen
this.exit() {

	// fade in the screen for all players
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++) {
		if(!IsPlayerConnected(i) || IsPlayerNPC(i)) {
			continue;
		}
		FadePlayerScreen(i, true);
		StopAudioStreamForPlayer(i);
	}
	this.destroyTextdraws();
}

forward ShowGameChangeTDs();
public ShowGameChangeTDs() {
	this.reCreateTextdraws();
	TextDrawShowForAll(handleWelcomeMessageAuthor);
	TextDrawShowForAll(handleWelcomeMessageTitle);
	TextDrawShowForAll(featureShowOff);
	TextDrawShowForAll(featureShowOffTitle);
}

// This will initialise the game change screen for the speficied player only.
// The purpose of this is for when the player connects.
this.initForPlayer(playerid) {
	FadePlayerScreen(playerid);
	SetTimerEx("ShowGameChangeTDSForPlayer", 3000, 0, "d", playerid);
	PlayAudioStreamForPlayer(playerid, audioStreamURLs[random(4)]);
}


forward ShowGameChangeTDSForPlayer(playerid);
public ShowGameChangeTDSForPlayer(playerid) {

	TextDrawShowForPlayer(playerid, handleWelcomeMessageTitle);
	TextDrawShowForPlayer(playerid, handleWelcomeMessageAuthor);
	TextDrawShowForPlayer(playerid, featureShowOff);
	TextDrawShowForPlayer(playerid, featureShowOffTitle);
}

this.createTextdraws() {
	if(handleWelcomeMessageTitle != Text:INVALID_TEXT_DRAW)
		TextDrawDestroy(handleWelcomeMessageTitle);

	handleWelcomeMessageTitle = TextDrawCreate(234.000000, 343.000000, sprintf("__Grand Joins v%s_________", GLOBAL_SETTING_VERSION));
	TextDrawBackgroundColor(handleWelcomeMessageTitle, 255);
	TextDrawFont(handleWelcomeMessageTitle, 1);
	TextDrawLetterSize(handleWelcomeMessageTitle, 0.529999, 2.199999);
	TextDrawColor(handleWelcomeMessageTitle, -1);
	TextDrawSetOutline(handleWelcomeMessageTitle, 0);
	TextDrawSetProportional(handleWelcomeMessageTitle, 1);
	TextDrawSetShadow(handleWelcomeMessageTitle, 1);

	if(handleWelcomeMessageAuthor != Text:INVALID_TEXT_DRAW)
		TextDrawDestroy(handleWelcomeMessageAuthor);

	handleWelcomeMessageAuthor = TextDrawCreate(282.000000, 366.000000, "Created by Jay");
	TextDrawBackgroundColor(handleWelcomeMessageAuthor, 255);
	TextDrawFont(handleWelcomeMessageAuthor, 2);
	TextDrawLetterSize(handleWelcomeMessageAuthor, 0.370000, 1.400000);
	TextDrawColor(handleWelcomeMessageAuthor, 16777215);
	TextDrawSetOutline(handleWelcomeMessageAuthor, 0);
	TextDrawSetProportional(handleWelcomeMessageAuthor, 1);
	TextDrawSetShadow(handleWelcomeMessageAuthor, 1);

	if(featureShowOff != Text:INVALID_TEXT_DRAW)
		TextDrawDestroy(featureShowOff);

	featureShowOff = TextDrawCreate(30.000000, 320.000000, "__");
	TextDrawBackgroundColor(featureShowOff, 255);
	TextDrawFont(featureShowOff, 1);
	TextDrawLetterSize(featureShowOff, 0.310000, 1.100000);
	TextDrawColor(featureShowOff, -1);
	TextDrawSetOutline(featureShowOff, 0);
	TextDrawSetProportional(featureShowOff, 1);
	TextDrawSetShadow(featureShowOff, 1);

	if(featureShowOffTitle != Text:INVALID_TEXT_DRAW) 
		TextDrawDestroy(featureShowOff);

	featureShowOffTitle = TextDrawCreate(30.000000, 301.000000, "WELCOME TO GRAND JOBS");
	TextDrawBackgroundColor(featureShowOffTitle, 255);
	TextDrawFont(featureShowOffTitle, 2);
	TextDrawLetterSize(featureShowOffTitle, 0.320000, 1.300000);
	TextDrawColor(featureShowOffTitle, 16711935);
	TextDrawSetOutline(featureShowOffTitle, 1);
	TextDrawSetProportional(featureShowOffTitle, 1);

}

this.destroyTextdraws() {
	if(handleWelcomeMessageTitle != Text:INVALID_TEXT_DRAW)
		TextDrawDestroy(handleWelcomeMessageTitle);

	if(handleWelcomeMessageAuthor != Text:INVALID_TEXT_DRAW)
		TextDrawDestroy(handleWelcomeMessageAuthor);

	if(featureShowOff != Text:INVALID_TEXT_DRAW) {
		TextDrawDestroy(featureShowOff);
	}

	if(featureShowOffTitle != Text:INVALID_TEXT_DRAW) {
		TextDrawDestroy(featureShowOffTitle);
	}

	handleWelcomeMessageTitle = Text:INVALID_TEXT_DRAW;
	handleWelcomeMessageAuthor = Text:INVALID_TEXT_DRAW;
	featureShowOffTitle = Text:INVALID_TEXT_DRAW;
	featureShowOff = Text:INVALID_TEXT_DRAW;
}

this.reCreateTextdraws() {
	this.destroyTextdraws();
	this.createTextdraws();
}



#undef this
