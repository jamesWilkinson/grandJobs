/**
	This file handles the welcome message that should be shown for player
	when they connect to the server
**/

static Text:handleWelcomeMessageTitle;
static Text:handleWelcomeMessageAuthor;

#define this core::playerConnection->handleWelcomeMessage
/*
* Initialiser - called when the gamemode initialises for the textdraw creation
*/
this.Construct()
{
	handleWelcomeMessageTitle = TextDrawCreate(234.000000, 343.000000, "Grand Jobs v0.0.1");
	TextDrawBackgroundColor(handleWelcomeMessageTitle, 255);
	TextDrawFont(handleWelcomeMessageTitle, 1);
	TextDrawLetterSize(handleWelcomeMessageTitle, 0.529999, 2.199999);
	TextDrawColor(handleWelcomeMessageTitle, -1);
	TextDrawSetOutline(handleWelcomeMessageTitle, 0);
	TextDrawSetProportional(handleWelcomeMessageTitle, 1);
	TextDrawSetShadow(handleWelcomeMessageTitle, 1);

	handleWelcomeMessageAuthor = TextDrawCreate(282.000000, 366.000000, "Created by Jay");
	TextDrawBackgroundColor(handleWelcomeMessageAuthor, 255);
	TextDrawFont(handleWelcomeMessageAuthor, 2);
	TextDrawLetterSize(handleWelcomeMessageAuthor, 0.370000, 1.400000);
	TextDrawColor(handleWelcomeMessageAuthor, 16777215);
	TextDrawSetOutline(handleWelcomeMessageAuthor, 0);
	TextDrawSetProportional(handleWelcomeMessageAuthor, 1);
	TextDrawSetShadow(handleWelcomeMessageAuthor, 1);
}

this.main(playerid)
{
	// First of all handle the screen fade in effect
	#pragma unused playerid
	SendClientMessage(playerid, -1, sprintf(__("Welcome %s to Grand Jobs.", playerid), ReturnPlayerName(playerid)));

	
	TextDrawShowForPlayer(playerid, handleWelcomeMessageTitle);
	TextDrawShowForPlayer(playerid, handleWelcomeMessageAuthor);

	SetTimerEx("hideTextdraws", 4000, 0, "d", playerid);
	SetTimerEx("spawnThePlayer", 5000, 0, "d", playerid);
}

forward spawnThePlayer(playerid);
public spawnThePlayer(playerid) {
	SetSpawnInfo(playerid, NO_TEAM, 0,938.6702,-92.0135,17.8191,266.6740,0,0,0,0,0,0);
	SpawnPlayer(playerid);
}

forward hideTextdraws(playerid);
public hideTextdraws(playerid)
{
	TextDrawHideForPlayer(playerid, handleWelcomeMessageTitle);
	TextDrawHideForPlayer(playerid, handleWelcomeMessageAuthor);
}


#undef this