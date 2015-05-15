/**
	When the player spawns, its important to check that they are logged into their account to prevent
	any forgories etc
**/

#define this core::playerAccount->playerAccountCheckLogin 

// Called when the player respawns - if the player is registered
// and they are not logged in then we'll have to show the login box for the player
this.main(playerid)
{
	if(IsPlayerNPC(playerid)){
		return; 
	}

	if(database::API->IsPlayerLoggedIn.get(playerid)){
		return;
	}

	if(!database::API->IsPlayerRegistered.get(playerid)) {
		SendClientInfoMessage(playerid, "You are using an unregistered account.");
	} else {
		SendClientInfoMessage(playerid, "You need to login to your account. Use {00FF00}/login{FFFFFF}.");
		database::Controllers->loginPlayer.showDialog(playerid);
	}
}


#undef this 
