/**
	Runaway Race! By Jay

	Coded for LVP on SA-MP 0.3z - v0.2 of the handler made compatiable with 0.3.7
	
	THIS USES THE GENERIC MINIGAME FS BY JAY
	
	Credits to LR for this map
**/

#include	<a_samp>
#include    <streamer>


// MAP SETTINGS:

#define     GAME_WORLD_ID       	999   	// random virtual world for the game
#define     COUNTDOWN_SECONDS   	15      // be careful when adjusting this - should be minimum 15 seconds!

// SA-MP default checkpoints don't float - set this to 1 to use a race cp which does float.
#define 	USE_RACE_CHECKPOINT 	1
// for testing new maps
#define     DEBUG_MODE           0

// comment out for no height checking
// otherwise if a player goes below this height he'll go back to the start (or a safe point)
#define     MINIMUM_HEIGHT          60
// Safe points work with minimum height
// Some maps need "safe points" so that the player will teleport back to them if they cross one -
// so they dont go back to the start if they fall below the minimum height distance.
#define     MAX_SAFE_POINTS     20
#define     SAFEPOINT_RANGE     5

// This makes the checkpoint only show when the player is in range of it. Comment it out to always show it.
#define     CHECKPOINT_RANGE_CHECK

// Makes the game work with only one player
#define     SINGLE_PLAYER_MODE  1

/**
	MAP AND GAME CONFIGURATION
**/
	
// url for game music to stream
static  stock   musicUrl[128] = "https://db.tt/2kTyQ9Tz";
// position of end checkpoint
static  stock   Float:endPos[3] = {3897.7725, 2130.9377, 92.3155};
// x, y, z, ang
static  stock   Float:startPos[4] = { 3894.8491,  1908.1697, 71.3759, 0.8247};

// Camera Angles when it starts
static 	stock	Float:interpolateCamPos[6] = {3900.459228, 1931.925170, 121.677070, 3898.445312, 2158.911376, 99.876800};
static 	stock	Float:interpolateCamLookAt[8] = {3894.8491,  1908.1697, 71.3759, 3894.516845, 2090.730468, 110.785514};

static  stock   cmdName[10] = "/runrace2";
static  stock   top3CmdName[5] = "/rr2";

static  stock   textdrawTitle[23] = "JAYS RUNAWAY RACE ~y~2";
static  stock   textdrawInstructions[74] = "Follow the mystical pathaway!~n~Be the first player to reach the end.";

static  stock   gameTitle[64] = "Runaway Race 2";

// Database used for storing best times
static  stock   db_name[32] = "runrace2_times.db";
static  stock   db_table[32] = "runrace2_times";

// PLEASE NOTE: To configure the map objects, see the CreateDynamicObject statements when the filterscript loads.



/** END OF CONFIG - DONT TOUCH UNLESS YOU KNOW WHAT YOU'RE DOING THANKS **/

/** GAME SPECIFIC GLOBAL VARIABLES AND FORWARDS - THESE WHERE DONE BY LR*/
new e1;
new e2;
new c1;
new c2;
new c3;

forward e11();
forward e12();
forward e21();
forward e22();
forward c11();
forward c12();
forward c21();
forward c22();
forward c31();
forward c32();

// Jay: Original code by LR but I could probably could do with improving this - it can avoid timers
// and use OnObjectMoved

//==========================================================
public e11()
{
	StopDynamicObject(e1);
	MoveDynamicObject(e1,3984.434,2087.951,99.5232,2.00);
	SetTimer("e12",13000,0);
}

public e12()
{
	StopDynamicObject(e1);
	MoveDynamicObject(e1,3984.434,2087.951,127.202,2.00);
	SetTimer("e11",13000,0);
}
//==========================================================

public e21()
{
	StopDynamicObject(e2);
	MoveDynamicObject(e2,3810.168,2084.527,103.2615,2.00);
	SetTimer("e22",13000,0);
}

public e22()
{
	StopDynamicObject(e2);
	MoveDynamicObject(e2,3810.168,2084.527,124.408,2.00);
	SetTimer("e21",13000,0);
}
//==========================================================
public c11()
{
	StopDynamicObject(c1);
	MoveDynamicObject(c1,3897.563,2101.253,71.4238,2.00);
	SetTimer("c12",5000,0);
}

public c12()
{
	StopDynamicObject(c1);
	MoveDynamicObject(c1,3897.563,2101.253,80.464,2.00);
	SetTimer("c11",5000,0);
}
//==========================================================
public c21()
{
	StopDynamicObject(c2);
	MoveDynamicObject(c2,3897.670,2106.577,71.0000,2.00);
	SetTimer("c22",5000,0);
}

public c22()
{
	StopDynamicObject(c2);
	MoveDynamicObject(c2,3897.670,2106.577,80.486,2.00);
	SetTimer("c21",5000,0);
}
//==========================================================
public c31()
{
	StopDynamicObject(c3);
	MoveDynamicObject(c3,3897.675,2112.000,70.6000,2.00);
	SetTimer("c32",5000,0);
}

public c32()
{
	StopDynamicObject(c3);
	MoveDynamicObject(c3,3897.675,2112.000,80.583,2.00);
	SetTimer("c31",5000,0);
}

// IMPORTANT DEFINES

#define     SLOTS       			250     // AKA max_players w/e

#define     GAME_STATE_IDLE     	0
#define     GAME_STATE_SIGNUP   	1
#define     GAME_STATE_RUNNING  	2

/** HANDLER VARIABLES */


static 	stock 	bool:HasPlayerSignedUp[SLOTS];
static  stock   CurrentGameState 						= GAME_STATE_IDLE;
static  stock   bool:HasAnyoneWon 						= false;
static  stock   numberOfPeopleFinished 					= 0;
static  stock   playerStartTimeTicks[SLOTS];

static  stock   playerCountdownSeconds[SLOTS] 			= COUNTDOWN_SECONDS;
static  stock   playerCountdownTimer[SLOTS] 			= {-1, ...};
static  stock   playerCheckpointRangeTimer[SLOTS] 		= {-1, ...};
static  stock   playerTimeUpdateTimer[SLOTS] 			= {-1, ...};
static  stock   playerHeightCheckTimer[SLOTS] 			= {-1, ...};
static  stock   playerSafePointTimer[SLOTS] 			= {-1, ...};

static  stock   safePoints[MAX_SAFE_POINTS][3];
static 	stock	Text3D:safePointText[MAX_SAFE_POINTS] 	= {Text3D:-1, ...};
static  stock   playerLastSafePoint[SLOTS]				= {-1, ...};
static  stock   safePointCount 							= 0;

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


/*// LVP uses an outdated streamer - need this hack in for an extra param
#if DEBUG_MODE == 1
	native CreateDynamicObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, worldid = -1, interiorid = -1, playerid = -1, Float:streamdistance = 1200.0, Float:bla=2000.0);
#else
	native CreateDynamicObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, worldid = -1, interiorid = -1, playerid = -1, Float:streamdistance = 1200.0);
#endif
*/
public OnFilterScriptInit()
{

	#if DEBUG_MODE == 0
		SetTimer("promo", 12*1000*60, 1);
		new str[128];
		SendClientMessageToAll(-1, "-----------");
		format(str, 128, "%s by Jay has been loaded on the server!", gameTitle);
		SendClientMessageToAll(-1, str);
		SendClientMessageToAll(-1, cmdName);
		SendClientMessageToAll(-1, "----------");
	#else
		printf("----------------------------");
	    printf("Jay's Minigame Filterscript DEBUG BUILD loaded");
	    printf("----------------------------");
	#endif

	
	if(!fexist(db_name))
	{
		initDb();
	}
	
	updateBestPlayersAndTimes();
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
	
	// Load the object map and any specific timers etc for it
	// credits to lr for these:

	SetTimer("e11",1000,0);
	SetTimer("e21",1000,0);
	SetTimer("c11",1000,0);
	SetTimer("c21",5000,0);
	SetTimer("c31",3000,0);

	mapObjects[0] = CreateDynamicObject(4002,3891.865,2013.299,20.300,0.0,0.0,0.0);
	e1=CreateDynamicObject(2669,3984.434,2087.951,127.202,0.0,0.0,88.522);
	e2=CreateDynamicObject(2669,3810.168,2084.527,124.408,0.0,0.0,270.000);
	c1=CreateDynamicObject(3565,3897.563,2101.253,80.464,0.0,0.0,0.0);
	c2=CreateDynamicObject(3565,3897.670,2106.577,80.486,0.0,0.0,0.0);
	c3=CreateDynamicObject(3565,3897.675,2112.000,80.583,0.0,0.0,0.0);
	CreateDynamicObject(18367,3893.207,2046.068,116.156,0.0,0.0,0.0);
	CreateDynamicObject(1428,3893.113,2045.830,117.637,-36.096,0.0,0.0);
	CreateDynamicObject(18367,3893.131,2049.135,119.926,0.0,0.0,180.000);
	CreateDynamicObject(1428,3893.117,2047.865,119.294,-33.518,0.0,0.0);
	CreateDynamicObject(17068,3893.217,2090.855,123.578,0.0,0.0,0.0);
	CreateDynamicObject(17068,3893.224,2112.767,123.572,0.0,0.0,0.0);
	CreateDynamicObject(3632,3891.938,2078.897,124.146,0.0,0.0,0.0);
	CreateDynamicObject(3632,3893.231,2078.904,124.147,0.0,0.0,0.0);
	CreateDynamicObject(3632,3893.845,2078.882,124.144,0.0,0.0,0.0);
	CreateDynamicObject(3632,3892.573,2078.919,124.149,0.0,0.0,0.0);
	CreateDynamicObject(3632,3894.433,2078.876,124.144,0.0,0.0,0.0);
	CreateDynamicObject(980,3892.971,2080.429,126.296,-0.859,-89.381,0.0);
	CreateDynamicObject(3800,3892.858,2079.867,124.533,0.0,0.0,0.0);
	CreateDynamicObject(3800,3895.200,2079.901,127.014,0.0,0.0,0.0);
	CreateDynamicObject(3800,3890.754,2079.876,127.042,0.0,0.0,0.0);
	CreateDynamicObject(3800,3892.990,2079.895,129.952,0.0,0.0,0.0);
	CreateDynamicObject(3800,3892.957,2081.054,130.982,0.0,0.0,0.0);
	CreateDynamicObject(3800,3891.240,2081.093,131.004,0.0,0.0,0.0);
	CreateDynamicObject(3800,3895.010,2081.094,130.936,0.0,0.0,0.0);
	CreateDynamicObject(3502,3893.225,2089.230,132.547,-24.064,1.719,-0.232);
	CreateDynamicObject(9919,3893.687,1916.474,6.990,0.0,0.0,90.000);
	CreateDynamicObject(9766,3894.403,1972.374,89.026,27.502,0.0,0.0);
	CreateDynamicObject(1653,3907.479,2133.804,124.581,-89.381,0.0,0.0);
	CreateDynamicObject(1653,3876.365,2132.839,124.302,-90.241,0.0,0.859);
	CreateDynamicObject(1653,3919.172,2130.843,124.578,-90.241,-10.313,-37.970);
	CreateDynamicObject(1653,3865.161,2136.240,124.328,-90.241,0.0,144.531);
	CreateDynamicObject(13604,3893.671,2126.914,125.425,0.0,0.0,0.0);
	CreateDynamicObject(1653,3859.520,2134.055,124.326,-90.241,-11.173,-109.690);
	CreateDynamicObject(1653,3923.910,2133.732,124.557,-90.241,-17.189,74.453);
	CreateDynamicObject(1653,3919.117,2136.832,124.578,-90.241,-8.594,20.626);
	CreateDynamicObject(1653,3864.315,2130.270,124.325,-89.381,0.0,22.500);
	CreateDynamicObject(16481,3837.345,2133.266,126.392,0.859,7.735,180.000);
	CreateDynamicObject(16481,3798.851,2133.272,134.517,0.0,0.0,180.000);
	CreateDynamicObject(16481,3945.796,2133.991,127.178,0.0,6.016,0.0);
	CreateDynamicObject(16481,3984.141,2134.092,135.767,0.0,0.0,0.0);
	CreateDynamicObject(4106,4003.259,2125.426,151.362,0.859,0.0,-176.108);
	CreateDynamicObject(18553,4001.386,2141.232,144.605,0.0,0.0,2.578);
	CreateDynamicObject(18553,4001.306,2142.823,146.283,0.0,0.0,2.578);
	CreateDynamicObject(4106,3782.671,2123.675,148.765,0.0,0.0,180.000);
	CreateDynamicObject(18553,3781.459,2140.064,142.700,0.0,0.0,0.0);
	CreateDynamicObject(18553,3781.420,2141.282,144.249,2.578,0.0,0.077);
	CreateDynamicObject(3798,3783.680,2092.647,148.250,0.0,0.0,0.0);
	CreateDynamicObject(3798,3783.684,2090.731,146.326,0.0,0.0,0.0);
	CreateDynamicObject(3798,4006.381,2094.526,151.305,0.0,0.0,4.297);
	CreateDynamicObject(3798,4006.576,2092.531,149.356,0.0,0.0,3.438);
	CreateDynamicObject(10009,4007.498,2082.917,139.977,0.0,0.0,92.742);
	CreateDynamicObject(10009,4011.104,2083.542,131.184,0.0,0.0,133.445);
	CreateDynamicObject(1383,3984.386,2089.960,105.082,0.0,0.0,0.0);
	CreateDynamicObject(16318,3966.972,2088.953,90.881,0.0,0.0,2.578);
	CreateDynamicObject(10009,3784.280,2082.033,137.743,0.0,0.0,-270.723);
	CreateDynamicObject(10009,3783.339,2088.013,128.315,0.0,0.0,-45.000);
	CreateDynamicObject(1383,3810.052,2082.515,104.275,0.0,0.0,0.0);
	CreateDynamicObject(16318,3828.514,2083.117,90.994,0.0,0.0,-178.281);
	CreateDynamicObject(16501,3852.474,2083.917,86.037,0.0,0.0,91.719);
	CreateDynamicObject(16501,3859.496,2084.146,86.025,0.0,0.0,91.719);
	CreateDynamicObject(16501,3866.377,2084.353,86.009,0.0,0.0,91.719);
	CreateDynamicObject(16501,3872.436,2084.550,86.866,0.0,-89.381,90.859);
	CreateDynamicObject(16501,3943.018,2087.978,85.943,0.0,0.0,92.578);
	CreateDynamicObject(16501,3935.968,2087.667,85.948,0.0,0.0,92.578);
	CreateDynamicObject(16501,3928.946,2087.345,85.931,0.0,0.0,92.578);
	CreateDynamicObject(16501,3922.959,2087.137,86.811,0.0,-90.241,91.246);
	CreateDynamicObject(1214,4008.041,2086.609,128.564,0.0,0.0,0.0);
	CreateDynamicObject(1214,4003.939,2086.606,129.082,0.0,0.0,0.0);
	CreateDynamicObject(1214,3999.752,2086.605,129.670,0.0,0.0,0.0);
	CreateDynamicObject(1214,3995.376,2086.620,130.151,0.0,0.0,0.0);
	CreateDynamicObject(1214,3991.424,2086.608,130.786,0.0,0.0,0.0);
	CreateDynamicObject(1214,3786.153,2084.786,125.654,0.0,0.0,0.0);
	CreateDynamicObject(1214,3790.359,2084.810,126.335,0.0,0.0,0.0);
	CreateDynamicObject(1214,3794.634,2084.797,127.000,0.0,0.0,0.0);
	CreateDynamicObject(1214,3799.078,2084.784,127.613,0.0,0.0,0.0);
	CreateDynamicObject(1214,3803.177,2084.778,128.192,0.0,0.0,0.0);
	CreateDynamicObject(16501,3878.103,2081.006,83.841,17.189,0.0,56.250);
	CreateDynamicObject(16501,3883.221,2077.602,81.934,17.189,0.0,56.173);
	CreateDynamicObject(16501,3888.874,2073.831,79.845,17.189,0.0,56.250);
	CreateDynamicObject(16501,3894.422,2070.117,77.738,18.048,0.0,56.250);
	CreateDynamicObject(16501,3917.516,2083.142,83.738,18.048,0.0,-48.515);
	CreateDynamicObject(16501,3912.615,2078.798,81.595,18.048,0.0,-48.438);
	CreateDynamicObject(16501,3907.610,2074.365,79.428,18.048,0.0,-48.515);
	CreateDynamicObject(16501,3902.782,2070.091,77.460,15.470,0.0,-48.515);
	CreateDynamicObject(16501,3898.700,2068.369,77.900,0.0,-91.100,0.0);
	CreateDynamicObject(3502,3898.668,2074.936,79.484,0.0,0.0,-180.000);
	CreateDynamicObject(3502,3898.740,2083.128,79.808,-4.297,0.0,179.141);
	CreateDynamicObject(3502,3898.792,2091.243,80.429,-4.297,-0.859,180.000);
	CreateDynamicObject(1228,3892.465,2136.665,127.515,0.0,0.0,92.578);
	CreateDynamicObject(1225,3894.154,2136.677,127.550,0.0,0.0,11.250);
	CreateDynamicObject(1225,3890.719,2136.545,127.550,0.0,0.0,0.0);
	CreateDynamicObject(1318,3890.762,2135.976,127.643,-91.100,0.0,-68.359);
	CreateDynamicObject(1318,3894.251,2136.068,127.643,-90.241,0.0,67.500);
	CreateDynamicObject(1323,3892.439,2136.792,128.204,0.0,0.0,-90.000);
	CreateDynamicObject(18553,3781.546,2137.573,142.755,0.0,-88.522,-0.859);
	CreateDynamicObject(18553,3781.584,2136.337,141.564,0.859,-89.381,88.281);
	CreateDynamicObject(18553,4001.249,2139.573,144.655,-179.623,90.241,2.682);
	CreateDynamicObject(18553,4001.174,2137.633,143.032,0.859,-91.100,273.438);
	CreateDynamicObject(13644,3892.755,2119.930,85.033,0.0,0.0,179.691);
	CreateDynamicObject(13644,3903.010,2119.968,85.020,0.0,0.0,0.0);
	CreateDynamicObject(1660,3901.557,2131.104,88.512,0.0,0.0,90.000);
	CreateDynamicObject(1660,3893.857,2130.736,88.550,-1.719,0.0,-90.000);
	CreateDynamicObject(1271,3898.568,2096.698,80.144,0.0,0.0,0.0);
	CreateDynamicObject(1271,3898.568,2095.987,79.482,0.0,0.0,0.0);
	CreateDynamicObject(944,3898.608,2098.486,81.325,0.0,0.0,90.000);
	CreateDynamicObject(16782,3898.591,2070.301,82.203,0.0,0.0,-90.000);
	CreateDynamicObject(11544,3892.837,2129.849,92.317,17.189,0.0,0.0);
	mapObjects[1] = 	CreateDynamicObject(11544,3902.764,2129.844,92.122,16.329,0.0,0.0);
	
	// add safe points
	addSafePoint(3893.449951, 2013.427612, 121.029891);
	addSafePoint(3892.882812, 2133.415771, 128.151565);
	addSafePoint(3781.525390, 2133.100830, 140.722702);
	addSafePoint(4001.285888, 2133.947265, 142.207702);
	addSafePoint(4006.360107, 2095.140625, 154.308441);
	addSafePoint(3783.977294, 2093.059326, 151.900924);
	addSafePoint(3821.826416, 2082.979980, 95.346641);
	addSafePoint(3973.439453, 2089.391601, 94.753097);
	
	// put all the objects in the correct world.
	for(new i = mapObjects[0]; i < mapObjects[1]+1; i++)
	{
	    Streamer_SetIntData(STREAMER_TYPE_OBJECT, i, E_STREAMER_WORLD_ID, GAME_WORLD_ID);
	}
	return 1;
}

public OnGameModeInit() {
	// re-initialise this when the gamemode restarts
	// todo: remove hardcoded name
	SendRconCommand("reloadfs jay_runaway2");
}

forward promo();
public promo()
{
	SendClientMessageToAll(-1, "---------------------------------");
	new str[128];
	format(str, 128, "Jay's %s - See if you can make the {00FF00}%s!!", gameTitle, top3CmdName);
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
	if(!fexist(db_name))
	    initDb();

	if(UseDatabase == false)
	{
		printf("Unable to save game data for Jay's %s for player: %s with time: %d as the database has an error.", gameTitle, PlayerName, playerTime);
	    return;
	}

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
	// Database doesn't exist - initialise it and stop here
	// since there can't possibly be any data to retrieve at this point
	if(!fexist(db_name)) {
	    initDb();
		return;
	}

	if(UseDatabase == false)
	    return;
	
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

// debug
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
	#if DEBUG_MODE == 0
		new str[128];
		format(str, 128, "Jay's %s has been unloaded from the server.", gameTitle);
		SendClientMessageToAll(-1, str);
		SendClientMessageToAll(-1, "SEE YOU NEXT TIME!");
	#endif

	EndGame();

	for(new i = mapObjects[0]; i < mapObjects[1]; i++)
	{
	    DestroyDynamicObject(i);
	    DestroyDynamicObject(gateObject);
	}
	RemoveSafePointTexts();
}

// Reset some data when the player leaves
public OnPlayerDisconnect(playerid, reason)
{
	if(playerid >= SLOTS) {
		new str[128];
		format(str, 128, "Unloading Jay's Runaway race because the maximum number of slots (%d) have been exceeded.", SLOTS);
		print(str);
		SendClientMessageToAll(-1, str);
		SendRconCommand("unloadfs jay_runaway");
		return 1;
	}

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
	#if DEBUG_MODE == 1
	    if(strcmp(cmdtext,"/savepos",true)==0)
	    {
	        new string[128], string2[64], Float:X, Float:Z, Float:Y, Float:ang;
	        GetPlayerPos(playerid, X, Y, Z);
	        GetPlayerFacingAngle(playerid, ang);
	        format(string, sizeof(string), "%f, %f, %f, %f //%s \r\n", X, Y, Z, ang, cmdtext[9]);
	     	new entry[256];
		    format(entry, sizeof(entry), "%s\r\n",string);
		    new File:hFile;
		    hFile = fopen("SavedPos2.txt", io_append);
		    if (hFile)
		    {
			    fwrite(hFile, entry);
			    fclose(hFile);
	            format(string2, sizeof(string2),"Player Pos Should Be Saved. With comment: %s", cmdtext[9]);
	       	 	SendClientMessage(playerid, -1,string2);
		    }
	        return 1;
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
		else if(!strcmp(cmdtext, "/gotogame", true) && IsPlayerAdmin(playerid))
		{
		    TeleportPlayerToGame(playerid);
		    return 1;
		}
	#endif

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
	
	else if(!strcmp(cmdtext, top3CmdName, true))
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
		new numberOfSignups = 0;
	
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
		
		#if DEBUG_MODE == 0
			new str[128];
			SendClientMessageToAll(-1, "-------------");

			format(str, 128, "Jay's %s is now signing up.", gameTitle);
			SendClientMessageToAll(-1, str);
			format(str, 128, "Use %s to join the game. Starting in 20 seconds.", cmdName);
			SendClientMessageToAll(-1, str);
			SendClientMessageToAll(-1, "------------");

			format(str, 128, "~y~Jay's %s~n~~w~Use ~r~%s~w~!!",gameTitle, cmdName);
			GameTextForAll(str, 5000, 5);
			SetTimer("StartGame", 20*1000, 0);
		#else
			SetTimer("StartGame", 1000, 0);
		#endif
		return;
	}

	// Game is not idle - start it!

	TextDrawHideForAll(signup);

	new numberOfSignups = 0;

	for(new i = 0; i < SLOTS; i++)
	{
	    if(!IsPlayerConnected(i) || IsPlayerNPC(i))
	        continue;
	    
	    if(IsPlayerSignedUp(i) == false)
	        continue;
	    
	    numberOfSignups++;
	}
	#if SINGLE_PLAYER_MODE == 0
		// not enough people signed up.
		if(numberOfSignups < 2)
		{
			new str[128];
			format(str, 128, "Not enough people have signed up for Jay's %s :(", gameTitle);
		    SendClientMessageToAll(-1, str);
		    EndGame();
		    return;
		}
	#endif

	// Ok now loop through the signups again and start this fucker.
	for(new i = 0; i < SLOTS; i++)
	{
	    if(!IsPlayerConnected(i) || IsPlayerNPC(i))
	        continue;

	    if(IsPlayerSignedUp(i) == false)
	        continue;

		ResetPlayerWeapons(i);

		#if !defined CHECKPOINT_RANGE_CHECk
	 		#if USE_RACE_CHECKPOINT == 1
				SetPlayerRaceCheckpoint(i, 1, endPos[0], endPos[1], endPos[2], 0, 0, 0, 5.0);
			#else
				SetPlayerCheckpoint(i, endPos[0], endPos[1], endPos[2], 5.0);
			#endif
	    #endif
	    
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
		#if defined MINIMUM_HEIGHT
			playerHeightCheckTimer[playerid] = SetTimerEx("checkMinimumHeight", 1000, 1, "d", playerid);
		#endif
		#if defined CHECKPOINT_RANGE_CHECK
			playerCheckpointRangeTimer[playerid] = SetTimerEx("checkCheckpointRange", 1000, 1, "d", playerid);
		#endif
		
		if(safePointCount > 0){
		    playerSafePointTimer[playerid] = SetTimerEx("checkSafepointRange", 500, 1, "d", playerid);
		}
		
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


forward checkCheckpointRange(playerid);
public checkCheckpointRange(playerid)
{
	if(!IsPlayerInRangeOfPoint(playerid, 15.0, endPos[0], endPos[1], endPos[2])){
		#if USE_RACE_CHECKPOINT == 1
		    DisablePlayerRaceCheckpoint(playerid);
		#else
		    DisablePlayerCheckpoint(playerid);
		#endif
	}else {
		#if USE_RACE_CHECKPOINT == 1
			SetPlayerRaceCheckpoint(playerid, 1, endPos[0], endPos[1], endPos[2], 0, 0, 0, 5.0);
		#else
			SetPlayerCheckpoint(playerid, endPos[0], endPos[1], endPos[2], 5.0);
		#endif
	}
}

forward updatePlayerTime(playerid);
public updatePlayerTime(playerid)
{
	new str[128];
	format(str, 128, "~y~YOUR TIME:~w~ %s", FormatTime(GetTickCount() - playerStartTimeTicks[playerid]));
	PlayerTextDrawSetString(playerid, yourTime[playerid], str);
}


forward checkMinimumHeight(playerid);
public checkMinimumHeight(playerid) {

	#if defined MINIMUM_HEIGHT
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		if(z < MINIMUM_HEIGHT) {
		    TeleportPlayerToGame(playerid);
		    GameTextForPlayer(playerid, "Hint: use ~r~/leave~w~ to exit game.", 5000, 5);
		}
	#else
	    #pragma unused playerid
	#endif
}


forward startMusic(playerid);
public startMusic(playerid) {
	PlayAudioStreamForPlayer(playerid, musicUrl);
}

forward checkSafepointRange(playerid);
public checkSafepointRange(playerid)
{
	for(new i = 0; i < safePointCount+1; i++)
	{
	    if(IsPlayerInRangeOfPoint(playerid, SAFEPOINT_RANGE, safePoints[i][0], safePoints[i][1], safePoints[i][2]))
	    {
	        if(playerLastSafePoint[playerid] != i)
	        {
	        	PlayerPlaySound(playerid, 1056, 0, 0, 0);
	        	playerLastSafePoint[playerid] = i;
				GameTextForPlayer(playerid, "Safe point", 5000, 5);
			}
			return;
	    }
	}
}
stock addSafePoint(Float:x, Float:y, Float:z)
{
	if(++safePointCount >= MAX_SAFE_POINTS)
	    return;

	safePoints[safePointCount][0] = floatround(x);
	safePoints[safePointCount][1] = floatround(y);
	safePoints[safePointCount][2] = floatround(z);
	
	safePointText[safePointCount] = Create3DTextLabel("SAFE POINT", -1, x, y, z, SAFEPOINT_RANGE, GAME_WORLD_ID, 0);
}

stock RemoveSafePointTexts()
{
	for(new i = 0; i < safePointCount; i++)
	{
		Delete3DTextLabel(safePointText[safePointCount]);
		safePointText[safePointCount] = Text3D:-1;
	}
}


stock TeleportPlayerToGame(playerid)
{
	SetPlayerVirtualWorld(playerid, GAME_WORLD_ID);
	// player has a safe point!
	if(playerLastSafePoint[playerid] != -1) {
		SetPlayerPos(playerid, safePoints[playerLastSafePoint[playerid]][0], safePoints[playerLastSafePoint[playerid]][1], safePoints[playerLastSafePoint[playerid]][2]+2);
	}else {
	   	SetPlayerPos(playerid, startPos[0], startPos[1], startPos[2]);
		SetPlayerFacingAngle(playerid, startPos[3]);
	}
}

forward HandleCheckpointEntry(playerid);
public HandleCheckpointEntry(playerid)
{
	if(IsPlayerSignedUp(playerid) && CurrentGameState == GAME_STATE_RUNNING)
	{
		KillTimer(playerTimeUpdateTimer[playerid]);
		KillTimer(playerHeightCheckTimer[playerid]);
		KillTimer(playerCheckpointRangeTimer[playerid]);
		KillTimer(playerSafePointTimer[playerid]);
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
		#if USE_RACE_CHECKPOINT == 0
		DisablePlayerCheckpoint(playerid);
		#else
		DisablePlayerRaceCheckpoint(playerid);
		#endif
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

public OnPlayerEnterCheckpoint(playerid)
{
	#if USE_RACE_CHECKPOINT == 0
	HandleCheckpointEntry(playerid);
	#endif
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	#if USE_RACE_CHECKPOINT == 1
	HandleCheckpointEntry(playerid);
	#endif
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerSignedUp(playerid) && CurrentGameState == GAME_STATE_RUNNING)
	{
	    new str[128];
	    format(str, 128, "You have been removed from Jay's %s because you have respawned.", gameTitle);
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
	   	KillTimer(playerHeightCheckTimer[playerid]);
	   	KillTimer(playerCheckpointRangeTimer[playerid]);
	   	KillTimer(playerSafePointTimer[playerid]);
	   	playerSafePointTimer[playerid] = -1;
	   	playerCheckpointRangeTimer[playerid] = -1;
	   	playerTimeUpdateTimer[playerid] = -1;
	   	playerHeightCheckTimer[playerid] = -1;
	}
	
	if(playerCountdownTimer[playerid] != -1)
	{
		KillTimer(playerCountdownTimer[playerid]);
		playerCountdownTimer[playerid] = -1;
	}

	playerCountdownSeconds[playerid] = COUNTDOWN_SECONDS;
	HasPlayerSignedUp[playerid] = false;
	playerLastSafePoint[playerid] = -1;
	
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
