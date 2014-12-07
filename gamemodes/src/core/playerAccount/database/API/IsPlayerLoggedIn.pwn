#define this database::API->IsPlayerLoggedIn

/**
	Login API

		construct
		set(playerid, bool:logged_in)
		get(playerid)

	FS API
		public IsPlayerLoggedIn
**/

static bool:bPlayerLoggedIn[SLOTS];

// Called when the player connects - reset the flag
this.construct(playerid) {
	this.set(playerid, false);
}


this.get(playerid) {
	return bPlayerLoggedIn[playerid];
}


// Setter method for setting the login value
this.set(playerid, bool:logged_in) { 
	bPlayerLoggedIn[playerid] = logged_in;
}

// API for the FS
forward IsPlayerLoggedIn(playerid);
public IsPlayerLoggedIn(playerid) {
	this.get(playerid);
}

#undef this 