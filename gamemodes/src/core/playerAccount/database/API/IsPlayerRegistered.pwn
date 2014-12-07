#define this database::API->IsPlayerRegistered
/**
	construct(playerid)
	get(playerid)

	FS API
		IsPlayerRegistered(playerid)
**/

static  bool:isPlayerRegistered[SLOTS];

// Initiaited when the player connects to the server to reset the variable
this.construct(playerid){
	this.set(playerid, false);
}

this.set(playerid, bool:registered) {
	isPlayerRegistered[playerid] = registered;
}

/** 
* Return a boolean: true if the player is registered, otherwise false
*/
this.get(playerid)
{
	return isPlayerRegistered[playerid];
}



/** 
*	Public function for the FS API
*	native IsPlayerLoggedIn(playerid); 
**/

forward IsPlayerRegistered(playerid);
public IsPlayerRegistered(playerid) {
	return this.get(playerid);
}


#undef this