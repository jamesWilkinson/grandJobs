/**
	Runaway Race! By Jay

	Coded for LVP on SA-MP 0.3z
	
	THIS USES THE GENERIC MINIGAME FS BY JAY
	
	Credits to the author of this map:
	http://forum.sa-mp.com/showthread.php?t=333255
**/

#include	<a_samp>
#include    <streamer>

#define     SLOTS       		100     // AKA max_players w/e

#define     GAME_WORLD_ID       83783   // random

#define     GAME_STATE_IDLE     0
#define     GAME_STATE_SIGNUP   1
#define     GAME_STATE_RUNNING  2

#define     COUNTDOWN_SECONDS   15

#define     DEBUG_MODE        0


/**
	CONFIGURATION
	**/
	
	
	
	
	
	
// url for music to stream
static  stock   musicUrl[128] = "https://dl.dropboxusercontent.com/u/45389967/door_run/music.mp3";

static  stock   Float:endPos[3] = {324.6409, 2542.0944, 18.2409};
// x, y, z, ang
static  stock   Float:startPos[4] = { 420.9242, 2504.5681, 16.4843, 89.9681};

// Camera Angles when it starts
static 	stock	Float:interpolateCamPos[6] = {420.9242, 2504.5681, 16.4843, 148.0256, 2506.7898, 72.1655};
static 	stock	Float:interpolateCamLookAt[8] = {238.0256,2506.7898,52.1655, 238.0256,2506.7898,52.1655};

static  stock   cmdName[9] = "/runrace";
static  stock   top3CmdName[6] = "/rrt3";

static  stock   textdrawTitle[18] = "JAYS RUNAWAY RACE";
static  stock   textdrawInstructions[74] = "Pass through the doors and be the~n~first player to reach the checkpoint.";

static  stock   gameTitle[64] = "Runaway Race";

// Database used for storing best times
static  stock   db_name[32] = "runrace_times.db";
static  stock   db_table[32] = "runrace_times";

// PLEASE NOTE: To configure the map, see the CreateDynamicObject statements when the filterscript loads.







/** END OF CONFIG - DONT TOUCH UNLESS YOU KNOW WHAT YOU'RE DOING THANKS **/









static 	stock 	bool:HasPlayerSignedUp[SLOTS];
static  stock   CurrentGameState = GAME_STATE_IDLE;
static  stock   bool:HasAnyoneWon = false;
static  stock   numberOfPeopleFinished = 0;
static  stock   playerStartTimeTicks[SLOTS];

static  stock   playerCountdownSeconds[SLOTS] = COUNTDOWN_SECONDS;
static  stock   playerCountdownTimer[SLOTS] = {-1, ...};
static  stock   playerTimeUpdateTimer[SLOTS] = {-1, ...};

// for the cmd to show the top 3
static  stock   bool:isTop3Showing[SLOTS];

// track objects to delete them when the FS is unloaded
static  stock   mapObjects[2];
static  stock   gateObject = INVALID_OBJECT_ID;

// Note: THIS IS NOT a config option - dont amend it please.
static  stock   bool:UseDatabase = true;

// textdraws
new Text:title;
new Text:instructions;
new Text:signup;
new Text:getReady;
new Text:countdown;
new Text:endTitle;
new Text:top3Times;
new Text:top3timesTitle;
new PlayerText:endInfo[SLOTS] = {PlayerText:INVALID_TEXT_DRAW, ...};
new PlayerText:yourTime[SLOTS] = {PlayerText:INVALID_TEXT_DRAW, ...};


// Keep track of the top 3 entries
new 	Top3Times[3];   // UNIX MS
new     Top3Names[3][MAX_PLAYER_NAME];


// LVP uses an outdated streamer - need this hack in for an extra param
#if DEBUG_MODE == 1
	native CreateDynamicObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, worldid = -1, interiorid = -1, playerid = -1, Float:streamdistance = 1200.0, Float:bla=2000.0);
#else
	native CreateDynamicObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, worldid = -1, interiorid = -1, playerid = -1, Float:streamdistance = 1200.0);
#endif

public OnFilterScriptInit()
{

	SetTimer("promo", 5*1000*60, 1);

	new str[128];
	SendClientMessageToAll(-1, "-----------");
	format(str, 128, "%s by Jay has been loaded on the server!", gameTitle);
	SendClientMessageToAll(-1, str);
	SendClientMessageToAll(-1, cmdName);
	SendClientMessageToAll(-1, "----------");
	
	if(!fexist(db_name))
	{
		initDb();
	}
	updateBestPlayersAndTimes();
	
	
	#if DEBUG_MODE == 1
		printf("----------------------------");
	    printf("Jay's Minigame Filterscript DEBUG BUILD loaded");
	    printf("----------------------------");
	#endif
	
	SetTimer("CheckGameEnd", 2000, 1);
	
	
	title = TextDrawCreate(187.000000, 162.000000, textdrawTitle);
	TextDrawBackgroundColor(title, 255);
	TextDrawFont(title, 2);
	TextDrawLetterSize(title, 0.700000, 3.199999);
	TextDrawColor(title, -1);
	TextDrawSetOutline(title, 0);
	TextDrawSetProportional(title, 1);
	TextDrawSetShadow(title, 1);

	instructions = TextDrawCreate(166.000000, 195.000000, textdrawInstructions);
	TextDrawBackgroundColor(instructions, 255);
	TextDrawFont(instructions, 1);
	TextDrawLetterSize(instructions, 0.580000, 2.300000);
	TextDrawColor(instructions, -1);
	TextDrawSetOutline(instructions, 0);
	TextDrawSetProportional(instructions, 1);
	TextDrawSetShadow(instructions, 1);

	getReady = TextDrawCreate(247.000000, 247.000000, "GET READY!");
	TextDrawBackgroundColor(getReady, 255);
	TextDrawFont(getReady, 3);
	TextDrawLetterSize(getReady, 0.839999, 3.000000);
	TextDrawColor(getReady, -1);
	TextDrawSetOutline(getReady, 0);
	TextDrawSetProportional(getReady, 1);
	TextDrawSetShadow(getReady, 1);

	countdown = TextDrawCreate(297.000000, 279.000000, "_");
	TextDrawBackgroundColor(countdown, 255);
	TextDrawFont(countdown, 3);
	TextDrawLetterSize(countdown, 1.000000, 4.199999);
	TextDrawColor(countdown, -1);
	TextDrawSetOutline(countdown, 0);
	TextDrawSetProportional(countdown, 1);
	TextDrawSetShadow(countdown, 1);
	
	format(str, 128, "MINIGAME: JAY'S %s~n~Use ~y~%s~w~ to signup now! ~n~See if you can make the ~r~%s~w~!", gameTitle, cmdName, top3CmdName);
	signup = TextDrawCreate(19.000000, 258.000000, str);
	TextDrawBackgroundColor(signup, 255);
	TextDrawFont(signup, 1);
	TextDrawLetterSize(signup, 0.490000, 2.000000);
	TextDrawColor(signup, -1);
	TextDrawSetOutline(signup, 0);
	TextDrawSetProportional(signup, 1);
	TextDrawSetShadow(signup, 1);
	
	format(str, 128, "Jay's %s", gameTitle);
	endTitle = TextDrawCreate(224.000000, 155.000000, str);
	TextDrawBackgroundColor(endTitle, 255);
	TextDrawFont(endTitle, 1);
	TextDrawLetterSize(endTitle, 0.750000, 3.099999);
	TextDrawColor(endTitle, -1);
	TextDrawSetOutline(endTitle, 0);
	TextDrawSetProportional(endTitle, 1);
	TextDrawSetShadow(endTitle, 1);

	top3Times = TextDrawCreate(35.000000, 274.000000, "~y~TOP 3 TIMES:~n~~w~~r~#1~w~ Jay: 1:23~n~~r~#2~w~ Chris: 2:32~n~~r~#3~w~ Tom: 3:11");
	TextDrawBackgroundColor(top3Times, 255);
	TextDrawFont(top3Times, 1);
	TextDrawLetterSize(top3Times, 0.370000, 1.400000);
	TextDrawColor(top3Times, -1);
	TextDrawSetOutline(top3Times, 0);
	TextDrawSetProportional(top3Times, 1);
	TextDrawSetShadow(top3Times, 1);
	
	format(str, 128, "Jay's %s", gameTitle);
	top3timesTitle = TextDrawCreate(34.000000, 234.000000, str);
	TextDrawBackgroundColor(top3timesTitle, 255);
	TextDrawFont(top3timesTitle, 2);
	TextDrawLetterSize(top3timesTitle, 0.340000, 1.600000);
	TextDrawColor(top3timesTitle, -1);
	TextDrawSetOutline(top3timesTitle, 0);
	TextDrawSetProportional(top3timesTitle, 1);
	TextDrawSetShadow(top3timesTitle, 1);
	
	// Load the object map
	mapObjects[0] = CreateDynamicObject(987, 418.1, 2526.6999, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 406.1, 2526.8999, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 394.2, 2526.8999, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 382.2999, 2527.0, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 370.2, 2527.0, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 358.6992, 2527.0996, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 346.7999, 2527.1, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 334.7, 2527.0, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 323.1, 2527.3999, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 311.2999, 2527.6999, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 299.2999, 2527.8, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 287.2999, 2527.8, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 275.3994, 2527.7998, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 435.3999, 2488.5, 15.5, 0.0, 0.0, 246.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 383.7, 2478.0, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 419.3994, 2478.1992, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 407.5996, 2478.1992, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 395.6992, 2478.1992, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 360.1, 2478.5, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 371.8994, 2478.0996, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 312.3999, 2478.1999, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 348.1992, 2478.2998, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 336.2998, 2478.1992, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 324.2998, 2478.0996, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 288.5996, 2477.5996, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 300.5, 2478.0, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 431.2998, 2478.0996, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 435.5, 2500.3999, 15.5, 0.0, 0.0, 269.9948, GAME_WORLD_ID);
	CreateDynamicObject(987, 435.5, 2512.3, 15.5, 0.0, 0.0, 269.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 435.1, 2524.1, 15.6999, 0.0, 0.0, 269.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 426.0, 2528.5, 15.6, 0.0, 0.0, 334.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 406.5, 2521.3, 15.5, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(987, 407.7, 2478.1999, 15.5, 0.0, 0.0, 91.9885, GAME_WORLD_ID);
	CreateDynamicObject(987, 407.3999, 2487.3, 15.8, 0.0, 0.0, 91.9885, GAME_WORLD_ID);
	CreateDynamicObject(987, 406.3994, 2509.7998, 15.5, 0.0, 0.0, 91.983, GAME_WORLD_ID);
	CreateDynamicObject(980, 406.7999, 2503.8999, 23.8999, 0.0, 0.0, 271.9995, GAME_WORLD_ID);
	CreateDynamicObject(1491, 375.6, 2515.5, 15.6, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(1491, 375.6, 2496.8999, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(1491, 375.6, 2502.6, 15.6, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(1491, 375.5, 2509.8, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(1491, 375.3999, 2522.6999, 15.6, 0.0, 0.0, 269.9949, GAME_WORLD_ID);
	CreateDynamicObject(1491, 375.5, 2519.1, 15.6, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(990, 406.7999, 2492.8999, 17.0, 0.0, 0.0, 270.0, GAME_WORLD_ID);
	CreateDynamicObject(990, 407.0996, 2483.0, 17.0, 0.0, 0.0, 271.9954, GAME_WORLD_ID);
	CreateDynamicObject(990, 406.2, 2514.1999, 17.0, 0.0, 0.0, 272.0, GAME_WORLD_ID);
	CreateDynamicObject(990, 406.2, 2522.3, 17.0, 0.0, 0.0, 270.0, GAME_WORLD_ID);
	CreateDynamicObject(990, 406.7, 2493.8999, 17.0, 0.0, 0.0, 272.0, GAME_WORLD_ID);
	CreateDynamicObject(3749, 404.2998, 2504.5, 21.2999, 0.0, 0.0, 90.0, GAME_WORLD_ID);
	CreateDynamicObject(2466, 374.9501, 2498.2617, 17.244, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 375.5, 2521.1992, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 375.3994, 2526.8994, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 375.3994, 2524.7998, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 375.5, 2517.6, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 375.6, 2514.0, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 375.5, 2504.6992, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 375.6992, 2511.8994, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 375.6992, 2508.2998, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 375.5, 2506.1999, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 375.5996, 2501.1992, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 375.2999, 2488.3, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 375.6, 2499.0, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 351.5, 2482.3, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 375.5996, 2495.3994, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 375.6992, 2493.2998, 15.6, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 375.5996, 2491.7998, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 351.5, 2484.3999, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 375.2999, 2486.1999, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 326.5, 2520.1, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 375.1992, 2480.1992, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 375.1992, 2482.3994, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 375.2999, 2484.0, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(1491, 351.5, 2485.8999, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 351.6, 2495.1999, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 351.6, 2489.5, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 351.5996, 2488.0, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 352.0, 2511.6, 15.6, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 351.5996, 2491.5996, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 351.7999, 2508.1, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 351.5996, 2493.0996, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 351.5996, 2497.2998, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 351.5996, 2498.7998, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 351.5996, 2500.8994, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 351.5996, 2502.3994, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 351.5996, 2504.5, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 352.0, 2513.6999, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 351.6992, 2506.0, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 351.7998, 2510.1992, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 352.2, 2524.5, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 352.0, 2515.1999, 15.6, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 352.0, 2517.3, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 352.2, 2522.3999, 15.6999, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(1491, 352.0996, 2518.7998, 15.6999, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 352.1992, 2520.8994, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 352.2, 2526.6, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 351.3994, 2480.7998, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 326.5, 2518.0, 15.6999, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 326.2998, 2480.5, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 326.2998, 2482.0, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 326.2998, 2484.0996, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 326.2998, 2485.5996, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 326.2998, 2487.6992, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 326.2998, 2489.1992, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 326.2998, 2491.2998, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 326.2998, 2492.7998, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 326.2998, 2494.8994, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 326.2998, 2496.3994, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 326.2998, 2498.5, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 326.2998, 2500.0, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 326.2998, 2502.0996, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 326.2998, 2503.5996, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 326.2998, 2505.6992, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 326.2998, 2507.1992, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 326.2998, 2509.2998, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 326.3994, 2510.7998, 15.6, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 326.3994, 2512.8994, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 326.3994, 2514.3994, 15.6, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 326.3994, 2516.5, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 326.5, 2521.6, 15.6999, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 326.5, 2523.6999, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 326.6, 2525.1999, 15.8, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 326.6, 2527.3999, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 299.2, 2497.0, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 300.0, 2523.6, 15.8, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 299.1992, 2480.5, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 299.1992, 2482.0, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 299.1992, 2484.0996, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 299.1992, 2485.5996, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 299.1992, 2487.6992, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 299.1992, 2489.1992, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 299.1992, 2491.2998, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 299.1992, 2492.7998, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 299.1992, 2494.8994, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 299.1992, 2492.7998, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 300.0, 2525.6999, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 299.1992, 2498.5, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 299.1992, 2500.5996, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 299.2998, 2502.0996, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 299.3994, 2504.1992, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 299.3994, 2505.6992, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 299.3994, 2507.7998, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 299.3994, 2509.2998, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 299.5996, 2511.3994, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 299.6992, 2512.8994, 15.6, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 299.6992, 2515.0, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 299.7998, 2516.5, 15.6, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 299.8994, 2518.5996, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 299.8994, 2520.0996, 15.6999, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 299.8994, 2522.1992, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 300.0, 2527.8, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 240.3994, 2477.1992, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 276.7998, 2477.5996, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 264.7998, 2477.5996, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 252.5996, 2477.3994, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 263.7999, 2528.1, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 252.1, 2528.1, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 240.3, 2528.0, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 249.5, 2515.6999, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 202.5, 2513.1999, 15.6, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 275.2998, 2479.7998, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 275.2998, 2481.8994, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 275.2998, 2483.3994, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 228.6, 2477.3, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 216.8, 2477.3999, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 192.8999, 2476.8, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(2952, 249.3994, 2479.6992, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 249.3994, 2481.1992, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 227.8999, 2529.6999, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 202.5, 2511.8, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 227.8999, 2525.6, 15.8, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(1491, 227.5996, 2479.0, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 227.5996, 2481.0996, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 227.6999, 2482.6, 15.6, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 227.5996, 2484.6992, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 227.5996, 2486.1992, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 227.5996, 2488.2998, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 275.5, 2525.1, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 275.2, 2508.6, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 275.2998, 2485.5, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 275.2998, 2487.0, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 275.2998, 2489.0996, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 275.2998, 2490.5996, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 275.2998, 2492.6992, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 275.2998, 2494.1992, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 275.2998, 2496.2998, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 275.2998, 2497.7998, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 275.2999, 2499.8999, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 275.1992, 2501.3994, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 275.2999, 2503.5, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 275.1992, 2505.0, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(1491, 275.2999, 2515.8, 15.6, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 275.1992, 2507.0996, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 275.6, 2526.6, 15.8, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 275.1992, 2510.6992, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 275.2998, 2512.1992, 15.6, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 275.2998, 2514.2998, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 275.3994, 2517.8994, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 275.3994, 2519.3994, 15.6999, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 275.3994, 2521.5, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 275.3994, 2523.0, 15.6999, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 275.6, 2528.6999, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 249.5, 2513.6, 15.6, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 249.3994, 2483.2998, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 249.3994, 2484.7998, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 249.3994, 2486.8994, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 249.3994, 2488.3994, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 249.2998, 2490.5, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 249.2998, 2492.0, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 249.2998, 2494.0996, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 249.2998, 2495.5996, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 249.2998, 2497.6992, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 249.2998, 2499.1992, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 249.2998, 2501.2998, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 249.2998, 2502.7998, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 249.2998, 2504.8994, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 249.2998, 2506.3994, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 249.2998, 2508.5, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 249.2998, 2510.0, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 249.3994, 2512.0996, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 249.5, 2517.1999, 15.6, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 249.8, 2528.5, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 249.6999, 2524.3, 15.6999, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 249.6992, 2519.1992, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 249.6992, 2520.6992, 15.6999, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 249.6992, 2522.7998, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 249.7998, 2526.3994, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 227.5996, 2489.7998, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 227.5996, 2491.8994, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 227.5996, 2493.3994, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 227.5996, 2495.5, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 227.5996, 2497.0, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 227.5996, 2499.0996, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 227.5996, 2500.5996, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 227.5996, 2502.6992, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 227.5996, 2504.1992, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 227.6992, 2506.2998, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 227.6992, 2507.7998, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 227.6992, 2509.7998, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 227.7998, 2511.2998, 15.6, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 227.7998, 2513.3994, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 227.7998, 2514.7998, 15.6, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 227.7998, 2516.8994, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 227.8994, 2518.3994, 15.6999, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 227.8994, 2520.5, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 227.8994, 2522.0, 15.6999, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 228.6, 2528.1999, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 217.1, 2528.3999, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 217.0996, 2528.3994, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 205.3999, 2528.6, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 193.6999, 2528.8, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 182.1999, 2528.5, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 207.6999, 2477.3, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(2952, 227.8994, 2524.0996, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 227.8994, 2527.6992, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.0, 2483.0, 18.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 202.1992, 2480.8994, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 202.1992, 2483.0, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 202.1992, 2484.5, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 202.1992, 2486.5996, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 202.1992, 2490.1992, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 202.1992, 2488.0996, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(1491, 202.1992, 2491.6992, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 202.1992, 2493.7998, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 202.1992, 2495.2998, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 202.2998, 2497.3994, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 202.2998, 2498.8994, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 202.2998, 2501.0, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 202.3994, 2502.5, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 202.3994, 2504.5996, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 202.3994, 2506.0996, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 202.3994, 2508.1992, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 202.3994, 2509.6992, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 202.5, 2515.3, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 202.6999, 2527.3, 15.8, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 202.8, 2529.3999, 15.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 202.5996, 2516.7998, 15.6999, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 202.5996, 2518.8994, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 202.5996, 2520.2998, 15.6999, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(1491, 202.5996, 2523.7998, 15.8, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 202.5996, 2522.3994, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 202.5996, 2523.7998, 15.8, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 202.5996, 2525.8994, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2935, 184.2998, 2482.3994, 16.8999, 0.0, 0.0, 90.0, GAME_WORLD_ID);
	CreateDynamicObject(2935, 184.5, 2494.6, 16.8999, 0.0, 0.0, 90.0, GAME_WORLD_ID);
	CreateDynamicObject(2935, 184.5, 2488.6992, 16.8999, 0.0, 0.0, 90.0, GAME_WORLD_ID);
	CreateDynamicObject(2935, 184.3994, 2491.6992, 16.8999, 0.0, 0.0, 90.0, GAME_WORLD_ID);
	CreateDynamicObject(2935, 184.1, 2491.5, 19.7999, 0.0, 0.0, 90.0, GAME_WORLD_ID);
	CreateDynamicObject(2935, 184.2998, 2503.8994, 16.8999, 0.0, 0.0, 90.0, GAME_WORLD_ID);
	CreateDynamicObject(2935, 184.5, 2507.0, 16.8999, 0.0, 0.0, 90.0, GAME_WORLD_ID);
	CreateDynamicObject(2935, 184.5996, 2497.5, 16.8999, 0.0, 0.0, 90.0, GAME_WORLD_ID);
	CreateDynamicObject(2935, 184.6, 2506.8999, 19.7999, 0.0, 0.0, 90.0, GAME_WORLD_ID);
	CreateDynamicObject(2935, 184.6, 2519.3, 17.1, 0.0, 0.0, 90.0, GAME_WORLD_ID);
	CreateDynamicObject(2935, 184.6992, 2510.0, 17.0, 0.0, 0.0, 90.0, GAME_WORLD_ID);
	CreateDynamicObject(2935, 184.1992, 2494.5996, 19.7999, 0.0, 0.0, 90.0, GAME_WORLD_ID);
	CreateDynamicObject(2935, 184.3999, 2509.8999, 19.8999, 0.0, 0.0, 90.0, GAME_WORLD_ID);
	CreateDynamicObject(2935, 184.8994, 2512.8994, 17.0, 0.0, 0.0, 90.0, GAME_WORLD_ID);
	CreateDynamicObject(2935, 184.6, 2522.5, 17.2, 0.0, 0.0, 90.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 181.5, 2493.5, 21.2999, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 202.1992, 2479.3994, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 142.6999, 2475.5, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.8999, 2479.3999, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 180.7998, 2485.5996, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 180.8994, 2485.0, 18.2, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 180.8999, 2486.6, 18.0, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 146.0, 2513.6, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 180.8, 2487.1, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.0996, 2488.5, 18.3999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.6, 2479.0, 18.2, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 180.8999, 2486.1, 20.7, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.1992, 2490.1992, 21.2999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 181.3994, 2490.0, 18.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.5, 2492.0, 21.3999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.5, 2495.6, 21.2999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 181.8999, 2499.0, 18.3999, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.0, 2499.5, 2.0, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 180.6999, 2502.6999, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 181.0, 2500.6, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.8999, 2497.5, 18.3999, 0.0, 0.0, 356.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 182.0, 2499.0, 20.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.7998, 2497.3994, 21.1, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.0, 2504.1, 18.3999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.0, 2501.0, 20.6, 0.0, 0.0, 16.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 180.8999, 2500.6, 18.2, 0.0, 0.0, 18.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 182.6, 2528.3, 15.8, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 180.8994, 2502.1992, 18.1, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.5, 2508.1999, 21.2999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.0996, 2503.0996, 21.0, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 181.5996, 2505.3994, 18.7, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.6992, 2504.7998, 21.2, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.6992, 2506.8994, 21.2999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.8999, 2511.6, 21.2999, 0.0, 0.0, 349.9963, GAME_WORLD_ID);
	CreateDynamicObject(1491, 181.5996, 2509.5996, 21.3999, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 182.6, 2526.8, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.6, 2516.1999, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.7998, 2514.8994, 18.2, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.7998, 2513.0, 20.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 181.8994, 2513.0, 18.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.6, 2516.8999, 18.2, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.8994, 2514.8994, 20.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 181.6992, 2517.6992, 15.6999, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.6992, 2518.8994, 18.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 182.6, 2520.8999, 21.2, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 182.5996, 2521.8994, 18.7, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 182.2998, 2523.8994, 18.7, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 182.5, 2524.6, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 182.6999, 2528.1999, 18.2999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 182.8999, 2525.6999, 21.2, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.1992, 2488.0996, 21.1, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 182.6999, 2518.6999, 21.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.7998, 2516.8994, 20.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 182.8, 2527.8999, 21.0, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 182.7998, 2526.0996, 18.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 182.3999, 2523.3999, 21.1, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 182.5996, 2520.3994, 18.7999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(8613, 436.7, 2471.3999, 20.8999, 0.0, 0.0, 94.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 181.0, 2477.3, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 169.1, 2477.3, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 170.3999, 2528.6999, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 158.6999, 2528.8, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 157.1999, 2477.3999, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 146.6, 2528.6, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 181.1992, 2481.0, 18.3999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 145.8999, 2486.3, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(1491, 145.7998, 2479.0996, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 145.7998, 2481.1992, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 145.7998, 2482.6992, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 145.7998, 2484.7998, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 146.0, 2511.5, 15.6, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 145.8994, 2488.3994, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 145.8994, 2489.8994, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 145.8994, 2492.0, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 145.8994, 2493.5, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(1491, 145.8994, 2497.0996, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 145.8994, 2495.5996, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 145.8994, 2499.1992, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 145.8994, 2500.6992, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 145.8994, 2502.7998, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 145.8994, 2504.2998, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 145.8994, 2506.3994, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 145.8994, 2507.8994, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 145.8994, 2510.0, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 146.0, 2515.1, 15.6, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 146.0, 2517.1999, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 146.1, 2525.8999, 15.8, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 146.1, 2520.8, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 146.1, 2528.0, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 146.0996, 2518.6992, 15.6999, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 146.0, 2524.3999, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 146.0996, 2522.2998, 15.6999, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 145.1999, 2477.8, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 127.1999, 2488.0, 15.5, 0.0, 0.0, 101.9945, GAME_WORLD_ID);
	CreateDynamicObject(987, 133.7998, 2478.0996, 15.5, 0.0, 0.0, 125.9912, GAME_WORLD_ID);
	CreateDynamicObject(987, 125.6999, 2523.1999, 15.6999, 0.0, 0.0, 89.9915, GAME_WORLD_ID);
	CreateDynamicObject(987, 124.9, 2499.5, 15.5, 0.0, 0.0, 89.989, GAME_WORLD_ID);
	CreateDynamicObject(987, 125.2998, 2511.5, 15.6, 0.0, 0.0, 89.989, GAME_WORLD_ID);
	CreateDynamicObject(987, 126.0999, 2535.1, 15.6999, 0.0, 0.0, 89.989, GAME_WORLD_ID);
	CreateDynamicObject(987, 134.5, 2528.3, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 130.8, 2527.8, 15.8, 0.0, 0.0, 272.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 132.3, 2527.6999, 15.8, 0.0, 0.0, 179.995, GAME_WORLD_ID);
	CreateDynamicObject(2952, 134.3999, 2528.1, 15.8, 0.0, 0.0, 275.9995, GAME_WORLD_ID);
	CreateDynamicObject(1491, 128.6999, 2527.6999, 15.8999, 0.0, 0.0, 179.993, GAME_WORLD_ID);
	CreateDynamicObject(2952, 127.0999, 2527.8, 15.8, 0.0, 0.0, 271.9995, GAME_WORLD_ID);
	CreateDynamicObject(987, 126.4, 2546.8999, 15.5, 0.0, 0.0, 89.989, GAME_WORLD_ID);
	CreateDynamicObject(987, 126.5999, 2553.3999, 15.6, 0.0, 0.0, 89.989, GAME_WORLD_ID);
	CreateDynamicObject(987, 134.6, 2540.3999, 15.6, 0.0, 0.0, 269.989, GAME_WORLD_ID);
	CreateDynamicObject(987, 134.6999, 2552.0, 15.5, 0.0, 0.0, 269.989, GAME_WORLD_ID);
	CreateDynamicObject(987, 135.3999, 2557.5, 15.3999, 0.0, 0.0, 269.989, GAME_WORLD_ID);
	CreateDynamicObject(987, 126.8994, 2562.8994, 15.3999, 0.0, 0.0, 1.9885, GAME_WORLD_ID);
	CreateDynamicObject(2952, 128.1, 2553.0, 15.5, 0.0, 0.0, 271.9995, GAME_WORLD_ID);
	CreateDynamicObject(2952, 131.2998, 2539.7998, 15.6, 0.0, 0.0, 271.9995, GAME_WORLD_ID);
	CreateDynamicObject(2952, 143.1999, 2559.5, 15.3999, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(1491, 132.6999, 2539.8, 15.6, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(1491, 129.1999, 2539.6, 15.6, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(1491, 143.1999, 2558.0, 15.3999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(1491, 143.1, 2561.6, 15.5, 0.0, 0.0, 87.984, GAME_WORLD_ID);
	CreateDynamicObject(987, 139.1, 2563.3, 15.3999, 0.0, 0.0, 1.9885, GAME_WORLD_ID);
	CreateDynamicObject(987, 147.3, 2557.6, 15.3999, 0.0, 0.0, 179.9885, GAME_WORLD_ID);
	CreateDynamicObject(987, 150.8999, 2563.3999, 15.3999, 0.0, 0.0, 1.9885, GAME_WORLD_ID);
	CreateDynamicObject(987, 158.8999, 2557.3, 15.5, 0.0, 0.0, 179.9835, GAME_WORLD_ID);
	CreateDynamicObject(987, 170.8, 2557.3, 15.5, 0.0, 0.0, 179.9835, GAME_WORLD_ID);
	CreateDynamicObject(987, 182.5996, 2557.1992, 15.5, 0.0, 0.0, 179.9835, GAME_WORLD_ID);
	CreateDynamicObject(987, 194.3999, 2557.1, 15.5, 0.0, 0.0, 179.9835, GAME_WORLD_ID);
	CreateDynamicObject(987, 205.6999, 2556.8999, 15.6, 0.0, 0.0, 179.9835, GAME_WORLD_ID);
	CreateDynamicObject(987, 217.6999, 2557.0, 15.5, 0.0, 0.0, 179.9835, GAME_WORLD_ID);
	CreateDynamicObject(987, 229.3999, 2556.6999, 15.6, 0.0, 0.0, 179.9835, GAME_WORLD_ID);
	CreateDynamicObject(987, 284.8999, 2537.6999, 15.8, 0.0, 0.0, 91.9835, GAME_WORLD_ID);
	CreateDynamicObject(987, 241.0996, 2556.8994, 15.6, 0.0, 0.0, 179.9835, GAME_WORLD_ID);
	CreateDynamicObject(987, 252.5996, 2556.7998, 15.6, 0.0, 0.0, 179.9835, GAME_WORLD_ID);
	CreateDynamicObject(987, 264.2998, 2556.8994, 15.6, 0.0, 0.0, 179.9835, GAME_WORLD_ID);
	CreateDynamicObject(987, 275.6992, 2556.7998, 15.6, 0.0, 0.0, 179.9835, GAME_WORLD_ID);
	CreateDynamicObject(987, 162.8, 2563.5, 15.5, 0.0, 0.0, 1.9885, GAME_WORLD_ID);
	CreateDynamicObject(987, 174.8, 2564.0, 15.5, 0.0, 0.0, 1.9885, GAME_WORLD_ID);
	CreateDynamicObject(987, 186.8, 2564.3, 15.6, 0.0, 0.0, 1.9885, GAME_WORLD_ID);
	CreateDynamicObject(987, 198.7998, 2564.5996, 15.5, 0.0, 0.0, 1.983, GAME_WORLD_ID);
	CreateDynamicObject(987, 210.3, 2564.8, 15.5, 0.0, 0.0, 1.9885, GAME_WORLD_ID);
	CreateDynamicObject(987, 222.1999, 2565.1, 15.5, 0.0, 0.0, 1.9885, GAME_WORLD_ID);
	CreateDynamicObject(987, 234.1992, 2565.2998, 15.5, 0.0, 0.0, 1.983, GAME_WORLD_ID);
	CreateDynamicObject(987, 245.8, 2565.5, 15.5, 0.0, 0.0, 357.9885, GAME_WORLD_ID);
	CreateDynamicObject(987, 258.1, 2565.1, 15.5, 0.0, 0.0, 359.984, GAME_WORLD_ID);
	CreateDynamicObject(987, 316.5996, 2563.5, 15.5, 0.0, 0.0, 359.978, GAME_WORLD_ID);
	CreateDynamicObject(987, 307.2999, 2538.6999, 15.8, 0.0, 0.0, 179.9835, GAME_WORLD_ID);
	CreateDynamicObject(987, 270.0, 2565.0996, 15.5, 0.0, 0.0, 359.9835, GAME_WORLD_ID);
	CreateDynamicObject(987, 281.5, 2564.6992, 15.5, 0.0, 0.0, 359.9835, GAME_WORLD_ID);
	CreateDynamicObject(987, 293.0996, 2564.2998, 15.6, 0.0, 0.0, 359.9835, GAME_WORLD_ID);
	CreateDynamicObject(987, 284.7, 2545.1999, 15.8, 0.0, 0.0, 91.9775, GAME_WORLD_ID);
	CreateDynamicObject(987, 284.3994, 2556.8994, 15.6, 0.0, 0.0, 179.9835, GAME_WORLD_ID);
	CreateDynamicObject(987, 296.2998, 2539.0996, 15.8, 0.0, 0.0, 179.9835, GAME_WORLD_ID);
	CreateDynamicObject(987, 305.0, 2564.0996, 15.5, 0.0, 0.0, 359.9835, GAME_WORLD_ID);
	CreateDynamicObject(987, 327.8994, 2563.5, 15.5, 0.0, 0.0, 323.9813, GAME_WORLD_ID);
	CreateDynamicObject(987, 336.6, 2557.8999, 15.3999, 0.0, 0.0, 271.981, GAME_WORLD_ID);
	CreateDynamicObject(1271, 325.2, 2542.1, 16.2, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1271, 324.5, 2542.0996, 16.2, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1271, 323.7999, 2542.1, 16.2, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1271, 324.5, 2542.1, 16.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(5269, 324.2998, 2533.0, 18.1, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(5269, 332.2998, 2532.6992, 18.1, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(5269, 317.0, 2533.0996, 18.1, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(5269, 328.5, 2532.5, 22.1, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(5269, 321.0996, 2533.0996, 21.8999, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 375.6, 2489.8999, 18.2999, 0.0, 0.0, 88.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 374.7998, 2478.0, 18.2, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 375.5, 2514.0, 18.1, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 375.5996, 2502.0, 18.1, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 351.5, 2478.6999, 17.7, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(1491, 326.2998, 2482.0, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 326.5, 2514.6, 18.2, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 299.2999, 2478.5, 18.2, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 352.0, 2514.3, 18.1, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 351.6992, 2490.5996, 18.0, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 351.6992, 2502.2998, 17.8999, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 326.3994, 2478.5996, 18.2, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 326.3994, 2490.5996, 18.0, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 326.2998, 2502.5996, 17.8999, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 227.8999, 2515.3, 18.2, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 275.3999, 2515.0, 18.1, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 299.7999, 2513.8, 18.1, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 299.2999, 2490.1, 18.2, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 299.3994, 2501.8994, 18.0, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 249.5, 2479.0, 18.1, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 275.3999, 2490.8, 18.0, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 275.3999, 2502.8, 17.7999, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 275.3994, 2478.6992, 18.2, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 249.6, 2514.6999, 18.2, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 249.2998, 2490.8994, 17.8999, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 249.3994, 2502.7998, 17.8999, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 227.5, 2478.0, 18.0, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 202.6, 2515.8, 18.2, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 227.5, 2503.3, 18.0, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 227.5, 2491.5, 17.7999, 0.0, 0.0, 87.9895, GAME_WORLD_ID);
	CreateDynamicObject(987, 181.1, 2501.3, 23.7, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 202.3, 2490.8, 17.8999, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 202.5, 2503.3, 18.2, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 202.2998, 2478.2998, 18.2, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 146.0, 2490.6999, 18.1, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(2935, 184.6992, 2500.6992, 19.7999, 0.0, 0.0, 90.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 181.2998, 2487.2998, 23.7999, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 145.7998, 2478.5, 18.0, 0.0, 0.0, 87.9895, GAME_WORLD_ID);
	CreateDynamicObject(987, 146.1, 2515.1, 18.2, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(987, 145.7998, 2503.0, 18.0, 0.0, 0.0, 87.9949, GAME_WORLD_ID);
	CreateDynamicObject(2952, 127.6999, 2539.5, 15.6, 0.0, 0.0, 271.9995, GAME_WORLD_ID);
	CreateDynamicObject(2952, 134.8, 2539.8, 15.6, 0.0, 0.0, 271.9995, GAME_WORLD_ID);
	CreateDynamicObject(1491, 129.6, 2553.0, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(1491, 133.1999, 2553.1, 15.5, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(2952, 131.6999, 2553.0, 15.5, 0.0, 0.0, 271.9995, GAME_WORLD_ID);
	CreateDynamicObject(2952, 135.3, 2553.1, 15.6, 0.0, 0.0, 271.9995, GAME_WORLD_ID);
	CreateDynamicObject(1491, 159.0, 2562.0, 15.3999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(1491, 224.0, 2563.3999, 15.3999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(1491, 187.1, 2560.0, 15.3999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(2952, 158.8999, 2559.1, 15.3999, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(2952, 205.3, 2560.8999, 15.3999, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(2952, 173.8999, 2560.1, 15.3999, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(2952, 243.1, 2561.8, 15.3999, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(2952, 262.8999, 2559.8, 15.3999, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(2952, 262.7999, 2561.3999, 15.3999, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(2952, 278.7999, 2559.6999, 15.3999, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(2952, 292.2, 2546.6999, 18.2, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(1491, 158.8, 2557.6, 15.3999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(2952, 159.0, 2559.8994, 15.3999, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(1491, 174.0, 2562.1999, 15.3999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(1491, 174.1999, 2557.3999, 15.3999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(2952, 174.1, 2558.8999, 15.3999, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(1491, 187.3999, 2557.3999, 15.3999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(2952, 187.1999, 2560.5, 15.3999, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(2952, 187.3999, 2558.8999, 15.3999, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(1491, 205.1, 2560.1, 15.3999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(2952, 205.3999, 2558.8, 15.3999, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(1491, 205.3999, 2557.3, 15.5, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(2952, 224.0, 2561.3, 15.3999, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(2952, 224.0, 2559.1999, 15.3999, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(1491, 224.0, 2556.8999, 15.6, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(2952, 224.1999, 2558.3, 15.3999, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(1491, 187.1992, 2562.5996, 15.3999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(1491, 205.1992, 2563.0, 15.3999, 0.0, 0.0, 91.9945, GAME_WORLD_ID);
	CreateDynamicObject(1491, 223.8999, 2560.3, 15.3999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(1491, 173.8999, 2559.8, 15.3999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(1491, 243.1, 2563.8999, 15.5, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(1491, 243.1999, 2560.3, 15.3999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(2952, 243.1999, 2558.1999, 15.3999, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(1491, 243.1999, 2557.0, 15.5, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(1491, 262.7, 2563.5, 15.5, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(1491, 263.0, 2557.1, 15.5, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(2952, 263.2, 2558.6, 15.3999, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(1491, 262.7, 2560.3, 15.3999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(1491, 278.6, 2561.6999, 15.3999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(1491, 291.8999, 2561.1999, 15.3999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(2952, 278.5, 2563.1999, 15.6, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(2952, 278.6, 2556.1, 15.6999, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(5269, 293.0, 2560.6, 17.7, 0.0, 0.0, 179.9949, GAME_WORLD_ID);
	CreateDynamicObject(5269, 292.7999, 2552.6, 18.1, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(2952, 292.3999, 2544.5, 15.8, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(5269, 293.2, 2542.8999, 18.1, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(1491, 278.8994, 2558.1992, 15.3999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(1491, 292.0, 2557.6, 15.3999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(1491, 291.7999, 2553.3999, 15.8999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(1491, 291.7999, 2550.1999, 15.8999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(1491, 292.6, 2547.0, 15.8, 0.0, 0.0, 91.9885, GAME_WORLD_ID);
	CreateDynamicObject(1491, 292.2, 2542.6999, 15.8999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(2952, 307.1, 2561.8, 15.3999, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(1491, 324.2999, 2554.1999, 18.7999, 0.0, 0.0, 357.994, GAME_WORLD_ID);
	CreateDynamicObject(1491, 307.1, 2560.3, 15.3999, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(2952, 307.1, 2558.1999, 15.3999, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(1491, 307.2, 2556.6999, 15.6, 0.0, 0.0, 91.994, GAME_WORLD_ID);
	CreateDynamicObject(2952, 307.2999, 2554.6, 15.8, 0.0, 0.0, 179.9945, GAME_WORLD_ID);
	CreateDynamicObject(2935, 326.1, 2555.3, 17.2999, 0.0, 0.0, 90.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 327.1, 2554.0, 18.7999, 0.0, 0.0, 173.9895, GAME_WORLD_ID);
	CreateDynamicObject(5269, 331.2, 2552.8, 18.1, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(5269, 312.2, 2553.5, 18.1, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(5269, 320.1992, 2553.2998, 18.1, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(5269, 304.2, 2553.6999, 18.1, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(1271, 326.2, 2557.1, 15.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(970, 332.7, 2553.6999, 20.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(970, 329.3994, 2553.7998, 20.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(970, 318.2999, 2554.1999, 20.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(970, 325.7998, 2554.1992, 21.7999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(970, 322.2998, 2554.0996, 20.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1337, 336.1015, 2542.4541, 18.1344, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2722, 336.0, 2567.0, 16.0, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(14467, 335.3999, 2567.6, 18.2999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(987, 307.1, 2563.8, 18.1, 0.0, 0.0, 269.978, GAME_WORLD_ID);
	CreateDynamicObject(987, 292.1, 2564.5, 19.8999, 0.0, 0.0, 269.978, GAME_WORLD_ID);
	CreateDynamicObject(987, 278.5, 2565.3, 18.2999, 0.0, 0.0, 269.978, GAME_WORLD_ID);
	CreateDynamicObject(987, 262.7, 2564.8999, 18.0, 0.0, 0.0, 269.978, GAME_WORLD_ID);
	CreateDynamicObject(987, 278.5, 2565.2998, 18.2999, 0.0, 0.0, 269.978, GAME_WORLD_ID);
	CreateDynamicObject(987, 243.1, 2565.5, 18.0, 0.0, 0.0, 269.978, GAME_WORLD_ID);
	CreateDynamicObject(987, 225.1, 2565.5, 17.7999, 0.0, 0.0, 269.978, GAME_WORLD_ID);
	CreateDynamicObject(987, 262.6992, 2564.8994, 18.0, 0.0, 0.0, 269.978, GAME_WORLD_ID);
	CreateDynamicObject(987, 204.6999, 2564.8999, 17.8999, 0.0, 0.0, 269.978, GAME_WORLD_ID);
	CreateDynamicObject(987, 186.6999, 2564.8, 18.2, 0.0, 0.0, 269.978, GAME_WORLD_ID);
	CreateDynamicObject(987, 186.6992, 2564.7998, 18.2, 0.0, 0.0, 269.978, GAME_WORLD_ID);
	CreateDynamicObject(987, 171.6999, 2564.1999, 18.6, 0.0, 0.0, 269.978, GAME_WORLD_ID);
	CreateDynamicObject(987, 158.8999, 2563.5, 17.8999, 0.0, 0.0, 269.978, GAME_WORLD_ID);
	CreateDynamicObject(987, 142.0, 2563.3, 18.2, 0.0, 0.0, 269.978, GAME_WORLD_ID);
	CreateDynamicObject(987, 125.9, 2552.8, 18.1, 0.0, 0.0, 1.9885, GAME_WORLD_ID);
	CreateDynamicObject(987, 125.6999, 2527.6999, 18.3999, 0.0, 0.0, 1.9885, GAME_WORLD_ID);
	CreateDynamicObject(987, 126.1992, 2538.0, 18.7, 0.0, 0.0, 1.9885, GAME_WORLD_ID);
	CreateDynamicObject(1228, 125.9, 2497.8999, 15.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1228, 127.5, 2489.1999, 15.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1228, 125.3, 2506.5, 15.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1228, 126.0, 2520.6, 16.1, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 375.7, 2489.6999, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2947, 375.3999, 2506.1, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 375.3999, 2519.0, 15.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 375.3999, 2509.6999, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 375.6, 2493.1999, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 375.6, 2489.6, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 375.2, 2483.8999, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 352.1, 2522.3, 15.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 326.5, 2525.1, 15.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 299.7999, 2520.0, 15.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 352.0, 2518.6999, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 351.8999, 2515.1, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 351.8999, 2511.6, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 351.6, 2505.8999, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 351.5, 2502.3, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 351.5, 2489.3999, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 351.3999, 2485.8, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 326.3999, 2521.5, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 326.3999, 2514.3, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 326.2, 2507.1, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 326.2, 2499.8999, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 326.2, 2496.5, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 326.2, 2492.6, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 326.2, 2485.5, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 326.2, 2481.8, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 249.3999, 2517.1, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 275.3999, 2526.5, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 299.7, 2516.3999, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 299.2999, 2509.1999, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 299.2999, 2505.6, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 299.2, 2502.0, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 299.1, 2498.3999, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 299.1, 2492.6999, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 299.1, 2489.1, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 299.1, 2485.5, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 275.2999, 2522.8999, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 275.2, 2515.6999, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 275.2, 2512.1, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 275.1, 2508.5, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 275.1, 2504.8999, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 275.2, 2497.6999, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 275.1, 2494.1, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 275.1, 2486.8999, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 275.2, 2483.3, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 249.1999, 2509.8999, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 249.1999, 2506.3, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 249.1999, 2502.6999, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 249.1999, 2499.1, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 249.1999, 2495.5, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 249.1999, 2491.8999, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 249.3, 2488.3, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 249.3, 2484.6999, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 249.3, 2481.1, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 227.8, 2525.5, 16.0, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 227.8, 2521.8999, 15.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 227.8, 2518.3, 15.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 227.8, 2514.6999, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 227.6999, 2511.1999, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 227.6, 2507.6999, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 227.5, 2496.8999, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 227.5, 2493.3, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 227.5, 2489.6999, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 227.3999, 2486.0, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 227.5, 2482.6, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 227.5, 2478.8, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 202.6, 2527.3, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 202.3999, 2520.1999, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 202.5, 2516.8, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 202.3999, 2513.1, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 202.3, 2509.5, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 202.3, 2506.0, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 202.3, 2502.3, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 202.1999, 2498.8, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 202.1, 2495.1999, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 202.1, 2491.6, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 202.5, 2523.6999, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 202.1, 2484.3999, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 202.0, 2480.6999, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 180.6999, 2487.0, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 181.1999, 2489.8999, 18.3999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 181.5, 2498.6, 18.7, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 180.8999, 2500.5, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 181.5, 2505.3999, 18.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 181.3999, 2509.5, 21.3999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 181.6999, 2512.8, 18.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 181.6, 2517.6, 15.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 182.3999, 2521.6999, 18.7, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 182.5, 2528.3, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 146.0, 2522.1999, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 146.0, 2518.6, 15.8999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 146.0, 2525.8, 16.0, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 145.8999, 2511.3999, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 145.8, 2507.8, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 145.8999, 2504.1999, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 145.8, 2500.5, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 145.8, 2496.8, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 145.8, 2493.3, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 145.8, 2489.8, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 145.6999, 2486.1999, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 145.6999, 2482.5, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 145.6999, 2479.0, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(5269, 188.8999, 2476.8999, 17.7999, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(5269, 196.0, 2473.6, 17.7999, 0.0, 0.0, 349.9949, GAME_WORLD_ID);
	CreateDynamicObject(5269, 191.1999, 2472.8, 17.7999, 0.0, 0.0, 269.9949, GAME_WORLD_ID);
	CreateDynamicObject(5269, 183.0, 2472.8, 17.7999, 0.0, 0.0, 269.9949, GAME_WORLD_ID);
	CreateDynamicObject(5269, 180.3999, 2476.8999, 17.7999, 0.0, 0.0, 269.9949, GAME_WORLD_ID);
	CreateDynamicObject(5269, 174.8, 2472.8, 17.7999, 0.0, 0.0, 269.9945, GAME_WORLD_ID);
	CreateDynamicObject(5269, 172.8999, 2477.0, 17.7999, 0.0, 0.0, 269.9945, GAME_WORLD_ID);
	CreateDynamicObject(5269, 166.8, 2472.8, 17.7999, 0.0, 0.0, 269.9945, GAME_WORLD_ID);
	CreateDynamicObject(5269, 165.1, 2476.8999, 17.7999, 0.0, 0.0, 269.9945, GAME_WORLD_ID);
	CreateDynamicObject(5269, 157.1, 2477.0, 17.8999, 0.0, 0.0, 269.9945, GAME_WORLD_ID);
	CreateDynamicObject(5269, 158.6999, 2472.8, 17.7999, 0.0, 0.0, 269.9945, GAME_WORLD_ID);
	CreateDynamicObject(5269, 150.6999, 2472.6999, 17.7999, 0.0, 0.0, 269.9945, GAME_WORLD_ID);
	CreateDynamicObject(5269, 149.1999, 2477.0, 17.7999, 0.0, 0.0, 269.9945, GAME_WORLD_ID);
	CreateDynamicObject(5269, 142.6, 2472.6999, 17.7999, 0.0, 0.0, 269.9945, GAME_WORLD_ID);
	CreateDynamicObject(5269, 141.3, 2476.8999, 17.7999, 0.0, 0.0, 269.9945, GAME_WORLD_ID);
	CreateDynamicObject(5269, 135.1, 2474.5, 17.7999, 0.0, 0.0, 227.9945, GAME_WORLD_ID);
	CreateDynamicObject(5269, 133.8999, 2476.8999, 17.7999, 0.0, 0.0, 269.9945, GAME_WORLD_ID);
	CreateDynamicObject(1491, 181.5996, 2480.8994, 15.6, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2947, 142.6, 2475.3999, 15.6, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2952, 145.7998, 2481.1992, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(1491, 178.6999, 2475.6999, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(1491, 164.0, 2475.5996, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(1491, 192.3, 2475.5, 15.5, 0.0, 0.0, 267.9949, GAME_WORLD_ID);
	CreateDynamicObject(2947, 143.5, 2559.5, 15.3999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 133.1, 2553.1999, 15.6, 0.0, 0.0, 270.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 132.0996, 2527.7998, 16.0, 0.0, 0.0, 270.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 132.5996, 2539.8994, 15.6999, 0.0, 0.0, 270.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 159.0, 2559.1, 15.3999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 243.6, 2565.3, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 174.2998, 2563.5996, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 187.5996, 2564.0996, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 205.5, 2558.8, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 224.3, 2558.3999, 15.8, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 243.3, 2558.5, 15.6999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 307.2999, 2561.8, 15.3999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	CreateDynamicObject(2947, 263.0996, 2564.8994, 15.5, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	mapObjects[1] = CreateDynamicObject(2947, 279.1992, 2559.6992, 15.3999, 0.0, 0.0, 0.0, GAME_WORLD_ID);
	return 1;
}

forward promo();
public promo()
{
	SendClientMessageToAll(-1, "---------------------------------");
	new str[128];
	format(str, 128, "Jay's %s - See if you can make the {00FF00}/rrt3!!", gameTitle);
	SendClientMessageToAll(-1, str);
	format(str, 128, "Use %s to start the game.", cmdName);
	SendClientMessageToAll(-1, str);
	SendClientMessageToAll(-1, "---------------------------------");

}

stock initDb()
{
	// create the file first
	new File:create = fopen(db_name);
	fclose(create);
	
	// Ok now init the database
	new DB:db_best_times = db_open(db_name);
	new DBResult:result;
	
	// TODO: Sort hardcoded runrace_times here!!!
	
	result = db_query(db_best_times, "CREATE TABLE `runrace_times` (\
	`Id`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,\
	`PlayerName`	TEXT NOT NULL,\
	`Time`	INTEGER NOT NULL,\
    `Timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP);");

	if(result != DBResult:0)
	{
	    printf("Initialised Database Successfully for Jay's %s", gameTitle);
	}
	else
	{
	    UseDatabase = false;
	    printf("WARNING: Failed to initialise database for Jay's %s", gameTitle);
	}
	
	db_close(db_best_times);
}

stock insertDbRecord(PlayerName[], playerTime)
{
	if(UseDatabase == false)
	{
		printf("Unable to save game data for Jay's %s for player: %s with time: %d as the database has an error.", gameTitle, PlayerName, playerTime);
	    return;
	}

	if(!fexist(db_name))
	    initDb();

	new DB:db_best_times = db_open(db_name);
	new DBResult:result;
	
	new str[128];
	format(str, 128, "INSERT INTO %s (PlayerName, Time) VALUES('%s', %d);", db_table, PlayerName, playerTime);
	result = db_query(db_best_times, str);
	
	if(result != DBResult:0)
	{
	    printf("Successfully added data for player %s to database for Jay's %s", PlayerName, gameTitle);
	}
	else
	{
	    UseDatabase = false;
	    printf("WARNING: Error occured when attempting to add data for player %s playing Jay's %s", PlayerName, gameTitle);
	}
	db_close(db_best_times);
}

stock updateBestPlayersAndTimes()
{
	if(UseDatabase == false)
	    return;

	// Database doesn't exist - initialise it and stop here
	// since there can't possibly be any data to retrieve at this point
	if(!fexist(db_name)) {
	    initDb();
		return;
	}
	
	new DB:db_best_times = db_open(db_name);
	new DBResult:result;

	new str[128];
	format(str, 128, "SELECT * FROM %s ORDER BY Time LIMIT 3;", db_table);
	result = db_query(db_best_times, str);
	if(db_num_rows(result) == 3)
	{
		new timeStr[128];
		new i = 0;
		do
		{
			db_get_field_assoc(result, "PlayerName", Top3Names[i], MAX_PLAYER_NAME);
			db_get_field_assoc(result, "Time", timeStr, 128);
			Top3Times[i] = strval(timeStr);
			i++;
		}
		while(db_next_row(result));

		format(str, 128, "~y~TOP 3 TIMES:~n~~w~~r~#1~w~ %s: %s~n~~r~#2~w~ %s: %s~n~~r~#3~w~ %s: %s",
			Top3Names[0], FormatTime(Top3Times[0]),
			Top3Names[1], FormatTime(Top3Times[1]),
			Top3Names[2], FormatTime(Top3Times[2]));
			
		TextDrawSetString(top3Times, str);
	}
	else
	{
	    printf("Only found %d entries in database. Needs to be at least 3.", db_num_rows(result));
	}
	db_close(db_best_times);
	
	
	
}

stock DisplayTop3()
{
	printf("TOP 3 STORED RESULTS:");
	for(new i =0 ; i < 3; i++)
	{
	    printf("Name: %s Time: %d", Top3Names[i], Top3Times[i]);
	}
}

public OnFilterScriptExit()
{
	new str[128];
	format(str, 128, "Jay's %s has been unloaded from the server.", gameTitle);
	SendClientMessageToAll(-1, str);
	SendClientMessageToAll(-1, "SEE YOU NEXT TIME!");

	EndGame();

	for(new i = mapObjects[0]; i < mapObjects[1]; i++)
	{
	    DestroyDynamicObject(i);
	    DestroyDynamicObject(gateObject);
	}
}

// Reset some data when the player leaves
public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	RemovePlayerFromGame(playerid);
	return 1;
}


stock bool:IsPlayerSignedUp(playerid)
{
	if(IsPlayerConnected(playerid)) {
	    if(HasPlayerSignedUp[playerid] == true) {
			return true;
	    }
	}
	return false;
}



public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!strcmp(cmdtext, cmdName, true))
	{
	    if(CurrentGameState == GAME_STATE_RUNNING)
	    {
	        SendClientMessage(playerid, -1, "{FF0000}The game is already running try later.");
	        return 1;
	    }

	    HasPlayerSignedUp[playerid] = true;

		if(CurrentGameState == GAME_STATE_IDLE)
		{
		    StartGame();
		}
		new str[128];
		format(str, 128, "{00FF00}You have signed up for Jay's %s. It's starting soon. Use /leave to leave", gameTitle);
		SendClientMessage(playerid, -1, str);
	    return 1;
	}
	
	if(!strcmp(cmdtext, "/rrt3", true))
	{
		if(isTop3Showing[playerid] == true)
		{
		    TextDrawHideForPlayer(playerid, top3Times);
			isTop3Showing[playerid] = false;
		}
		else
		{
		    TextDrawShowForPlayer(playerid, top3Times);
		    isTop3Showing[playerid] = true;
		}
		return 1;
	}
	else if(!strcmp(cmdtext, "/leave", true))
	{
	    if(IsPlayerSignedUp(playerid) == true)
	    {
			RemovePlayerFromGame(playerid);
			
			new str[128];
			format(str, 128, "You have left Jay's %s", gameTitle);
			SendClientMessage(playerid, -1, str);
			return 1;
	    }
	    return 0;
	}

	else if(!strcmp(cmdtext, "/runfinish", true) && IsPlayerAdmin(playerid))
	{
	    SendClientMessage(playerid, -1, "Teleported you to the end pos.");
	    SetPlayerPos(playerid, endPos[0], endPos[1], endPos[2]);
	    return 1;
	}


	else if(!strcmp(cmdtext, "/show3", true) && IsPlayerAdmin(playerid))
	{
		updateBestPlayersAndTimes();
	    DisplayTop3();
	    return 1;
	}

	else if(IsPlayerSignedUp(playerid) && CurrentGameState == GAME_STATE_IDLE)
	{
	    new str[128];
	    format(str, 128, "You can't use commands whilst taking part in Jay's %s", gameTitle);
	    SendClientMessage(playerid, -1, str);
	    return 1;
	}

	
	return 0;
}

/**
* Check every two seconds if the game is running
* check to end it in case no players are left
**/
forward CheckGameEnd();
public CheckGameEnd()
{
	if(CurrentGameState == GAME_STATE_RUNNING)
	{
	    #if DEBUG_MODE == 0
	
			new numberOfSignups = 0;
		#else
		    new numberOfSignups = 4;
		#endif

		for(new i = 0; i < SLOTS; i++)
		{
		    if(!IsPlayerConnected(i) || IsPlayerNPC(i))
		        continue;

		    if(IsPlayerSignedUp(i) == false)
		        continue;

		    numberOfSignups++;
		}
		
		if(numberOfSignups == 0)
		{
			new str[128];
			format(str, 128, "Jay's %s has ended: there is nobody left!", gameTitle);
			SendClientMessageToAll(-1, str);
		    EndGame();
		}
	}
}


forward StartGame();
public StartGame()
{
	// Game is idle - enter signup phase
	if(CurrentGameState == GAME_STATE_IDLE)
	{
	    TextDrawShowForAll(signup);
		CurrentGameState = GAME_STATE_SIGNUP;
		new str[128];
		SendClientMessageToAll(-1, "-------------");

		format(str, 128, "Jay's %s is now signing up.", gameTitle);
		SendClientMessageToAll(-1, str);
		format(str, 128, "Use %s to join the game. Starting in 20 seconds.", cmdName);
		SendClientMessageToAll(-1, str);
		SendClientMessageToAll(-1, "------------");

		format(str, 128, "~y~Jay's %s~n~~w~Use ~r~%s~w~!!",gameTitle, cmdName);
		GameTextForAll(str, 5000, 5);

		#if DEBUG_MODE == 0
			SetTimer("StartGame", 20*1000, 0);
		#else
			SetTimer("StartGame", 1000, 0);
		#endif
		return;
	}
	TextDrawHideForAll(signup);
	// Game is not idle - start it!

	#if DEBUG_MODE == 0
		new numberOfSignups = 0;
	#else
		new numberOfSignups = 3;
	#endif

	for(new i = 0; i < SLOTS; i++)
	{
	    if(!IsPlayerConnected(i) || IsPlayerNPC(i))
	        continue;
	    
	    if(IsPlayerSignedUp(i) == false)
	        continue;
	    
	    numberOfSignups++;
	}
	// not enough people signed up.
	if(numberOfSignups < 2)
	{
		new str[128];
		format(str, 128, "Not enough people have signed up for Jay's %s :(", gameTitle);
	    SendClientMessageToAll(-1, str);
	    EndGame();
	    return;
	}

	// Ok now loop through the signups again and start this fucker.
	for(new i = 0; i < SLOTS; i++)
	{
	    if(!IsPlayerConnected(i) || IsPlayerNPC(i))
	        continue;

	    if(IsPlayerSignedUp(i) == false)
	        continue;

		ResetPlayerWeapons(i);
		SetPlayerCheckpoint(i, endPos[0], endPos[1], endPos[2], 5.0);
	    TeleportPlayerToGame(i);
	    
	    InterpolateCameraPos(i, interpolateCamPos[0], interpolateCamPos[1], interpolateCamPos[2], interpolateCamPos[3], interpolateCamPos[4], interpolateCamPos[5], 5000, CAMERA_MOVE);
		InterpolateCameraLookAt(i, interpolateCamLookAt[0], interpolateCamLookAt[1], interpolateCamLookAt[2], interpolateCamLookAt[3], interpolateCamLookAt[4], interpolateCamLookAt[5], 5000, CAMERA_MOVE);

		Streamer_Update(i);
		
		playerCountdownSeconds[i] = COUNTDOWN_SECONDS;
		
		TogglePlayerControllable(i, 0);

		playerCountdownTimer[i] = SetTimerEx("processGame", 1000, 1, "d", i);
	}
	
	updateBestPlayersAndTimes();
	HasAnyoneWon = false;
	CurrentGameState = GAME_STATE_RUNNING;
	numberOfPeopleFinished = 0;
}

forward processGame(playerid);
public processGame(playerid)
{
	if(playerCountdownSeconds[playerid] == 0)
	{
	    KillTimer(playerCountdownTimer[playerid]);
	    playerCountdownTimer[playerid] = -1;
	
	    TogglePlayerControllable(playerid, 1);
	
		GameTextForPlayer(playerid, "~g~GO!!", 5000, 5);
		PlayerPlaySound(playerid, 3201, 0, 0, 0);
		
		SetCameraBehindPlayer(playerid);
		TextDrawHideForPlayer(playerid, title);
		TextDrawHideForPlayer(playerid, instructions);
		TextDrawHideForPlayer(playerid, getReady);
		TextDrawHideForPlayer(playerid, countdown);
		
		TextDrawShowForPlayer(playerid, top3timesTitle);
		TextDrawShowForPlayer(playerid, top3Times);
		
		yourTime[playerid] = CreatePlayerTextDraw(playerid,33.000000, 246.000000, "~y~YOUR TIME:~w~ --");
		PlayerTextDrawBackgroundColor(playerid, yourTime[playerid], 255);
		PlayerTextDrawFont(playerid, yourTime[playerid], 1);
		PlayerTextDrawLetterSize(playerid, yourTime[playerid], 0.370000, 1.400000);
		PlayerTextDrawColor(playerid, yourTime[playerid], -1);
		PlayerTextDrawSetOutline(playerid, yourTime[playerid], 0);
		PlayerTextDrawSetProportional(playerid, yourTime[playerid], 1);
		PlayerTextDrawSetShadow(playerid, yourTime[playerid], 1);
		PlayerTextDrawShow(playerid, yourTime[playerid]);
		
		
		playerTimeUpdateTimer[playerid] = SetTimerEx("updatePlayerTime", 250, 1, "d", playerid);
		
		playerStartTimeTicks[playerid] = GetTickCount();
	    return;
	}
	
	if(playerCountdownSeconds[playerid] == COUNTDOWN_SECONDS)
	{
		startMusic(playerid);
	}
	
	if(playerCountdownSeconds[playerid] == 10)
	{
	    TextDrawShowForPlayer(playerid, title);

	}

	if(playerCountdownSeconds[playerid] == 9)
	{
		TextDrawShowForPlayer(playerid, instructions);
	}

	else if(playerCountdownSeconds[playerid] == 5)
	{
	    TextDrawShowForPlayer(playerid, getReady);
	}
	
	else if (playerCountdownSeconds[playerid] == 3)
	{
	    TextDrawShowForPlayer(playerid, countdown);
	}
	
	if(playerCountdownSeconds[playerid] < 4)
	{
	    PlayerPlaySound(playerid, 1056, 0, 0, 0);
	}

	new string[24];
	format(string, 24, "%d", playerCountdownSeconds[playerid]);
   	TextDrawSetString(countdown, string);
	playerCountdownSeconds[playerid]--;
}


forward updatePlayerTime(playerid);
public updatePlayerTime(playerid)
{
	new str[128];
	format(str, 128, "~y~YOUR TIME:~w~ %s", FormatTime(GetTickCount() - playerStartTimeTicks[playerid]));
	PlayerTextDrawSetString(playerid, yourTime[playerid], str);
}

forward startMusic(playerid);
public startMusic(playerid) {
	PlayAudioStreamForPlayer(playerid, musicUrl);
}

stock TeleportPlayerToGame(playerid)
{
	SetPlayerPos(playerid, startPos[0], startPos[1], startPos[2]);
	SetPlayerFacingAngle(playerid, startPos[3]);
	SetPlayerVirtualWorld(playerid, GAME_WORLD_ID);
}

public OnPlayerEnterCheckpoint(playerid)
{
	if(IsPlayerSignedUp(playerid) && CurrentGameState == GAME_STATE_RUNNING)
	{
		KillTimer(playerTimeUpdateTimer[playerid]);
		SetTimerEx("RemovePlayerFromGame", 7000, 0, "d", playerid);
		TextDrawShowForPlayer(playerid, endTitle);
		numberOfPeopleFinished++;
		
		new name [MAX_PLAYER_NAME];
		GetPlayerName(playerid, name, MAX_PLAYER_NAME);

		new finishTime = GetTickCount() - playerStartTimeTicks[playerid];

		// Make it fair - anything less than 30 has to be a cheat.
		if(finishTime > 30000)
			insertDbRecord(name, finishTime);
		updateBestPlayersAndTimes();
		
		new str[128];
		format(str, 128, "You finished in ~y~%s ~w~Place.~n~Your Time: ~y~%s~w~.", ordinal(numberOfPeopleFinished), FormatTime(finishTime));

		if(endInfo[playerid] != PlayerText:INVALID_TEXT_DRAW)
		{
			PlayerTextDrawDestroy(playerid, endInfo[playerid]);
		}
		endInfo[playerid] = CreatePlayerTextDraw(playerid, 225.000000, 185.000000, str);
		PlayerTextDrawBackgroundColor(playerid, endInfo[playerid], 255);
		PlayerTextDrawFont(playerid, endInfo[playerid], 2);
		PlayerTextDrawLetterSize(playerid, endInfo[playerid], 0.500000, 2.500000);
		PlayerTextDrawColor(playerid, endInfo[playerid], -1);
		PlayerTextDrawSetOutline(playerid, endInfo[playerid], 0);
		PlayerTextDrawSetProportional(playerid, endInfo[playerid], 1);
		PlayerTextDrawSetShadow(playerid, endInfo[playerid], 1);
		PlayerTextDrawShow(playerid, endInfo[playerid]);
		
		TogglePlayerControllable(playerid, false);
		SetCameraBehindPlayer(playerid);
		DisablePlayerCheckpoint(playerid);
		PlayAudioStreamForPlayer(playerid, "https://dl.dropboxusercontent.com/u/45389967/door_run/You%20Win%20%28short%29%20-%20Dr.%20Mario%2064%20Music.mp3");

		if(HasAnyoneWon == false)
	    {
	        HasAnyoneWon = true;
	        SendClientMessageToAll(-1, "-------------");
			format(str, 128, "Jay's %s - WE HAVE A WINNER!", gameTitle);
			SendClientMessageToAll(-1, str);
	        format(str, 128, "%s has won!!!", name);
			SendClientMessageToAll(-1, str);
			SendClientMessageToAll(-1, "-----------");
	    } else {
	        format(str, 128, "You have finished Jay's %s. Unfortunately, you didn't win.", gameTitle);
			SendClientMessage(playerid, -1, str);
			SendClientMessage(playerid, -1, "BETTER LUCK NEXT TIME CHUM!");
	    }
	}
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerSignedUp(playerid) && CurrentGameState == GAME_STATE_RUNNING)
	{
	    new str[128];
	    format(str, 128, "You have been removed from Jay's %s because you where respawned.", gameTitle);
	    SendClientMessage(playerid, -1, str);
		RemovePlayerFromGame(playerid);
	}
	return 1;
}

stock EndGame()
{
	for(new i = 0; i < SLOTS; i++)
	{
	    if(!IsPlayerConnected(i) || IsPlayerNPC(i))
	        continue;
	
	    if(IsPlayerSignedUp(i) == false)
	        continue;

		RemovePlayerFromGame(i);
	}
	CurrentGameState = GAME_STATE_IDLE;
}

forward RemovePlayerFromGame(playerid);
public RemovePlayerFromGame(playerid)
{
	if(CurrentGameState == GAME_STATE_RUNNING)
	{
	    SpawnPlayer(playerid);
	    DisablePlayerCheckpoint(playerid);
	   	StopAudioStreamForPlayer(playerid);
	   	KillTimer(playerTimeUpdateTimer[playerid]);
	   	playerTimeUpdateTimer[playerid] = -1;
	}
	
	if(playerCountdownTimer[playerid] != -1)
	{
		KillTimer(playerCountdownTimer[playerid]);
		playerCountdownTimer[playerid] = -1;
	}

	playerCountdownSeconds[playerid] = COUNTDOWN_SECONDS;
	HasPlayerSignedUp[playerid] = false;
	
	if(endInfo[playerid] != PlayerText:INVALID_TEXT_DRAW)
	{
	    PlayerTextDrawDestroy(playerid, endInfo[playerid]);
	    endInfo[playerid] = PlayerText:INVALID_TEXT_DRAW;
	}
	
	if(yourTime[playerid] != PlayerText:INVALID_TEXT_DRAW)
	{
	    PlayerTextDrawDestroy(playerid, yourTime[playerid]);
	    yourTime[playerid] = PlayerText:INVALID_TEXT_DRAW;
	}
	TextDrawHideForPlayer(playerid, endTitle);
	TextDrawHideForPlayer(playerid, top3timesTitle);
	TextDrawHideForPlayer(playerid, top3Times);
}

// ordinal
// Utility function to ordinalize a number; i.e. 1st, 2nd, 3rd, etc.
stock ordinal(iNumber )
{
    new szSuffix[3];
    if ((iNumber % 100) / 10 == 1)
    {
        szSuffix = "th";
    }
    else
    {
        new iMod = iNumber % 10;
        switch (iMod)
        {
            case 1:     szSuffix = "st";
            case 2:     szSuffix = "nd";
            case 3:     szSuffix = "rd";
            default:    szSuffix = "th";
        }
    }
	new str[16];
    format( str, 16, "%d%s", iNumber, szSuffix );
    return str;
}

// FormatTime
// Formats the  time for a player: minutes:seconds.xx
FormatTime( iTime )
{
	new str[128];
	if (iTime >= 60000) format( str, 128, "%d:%02d.%02d", iTime / 60000, ((iTime + 5) % 60000) / 1000, ((iTime + 5) / 10) % 100 ); // woo rounding
    else format( str, 128, "%d.%02d", ((iTime + 5) % 60000) / 1000, ((iTime + 5) / 10) % 100 );
    return str;
}
