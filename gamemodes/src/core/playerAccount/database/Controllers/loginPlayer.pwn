/**
	This file handles the login command for the player
**/

#define this database::Controllers->loginPlayer

this.showDialog(playerid) {

	// If the player isn't registered don't show the dialog
	if(!database::API->IsPlayerRegistered.get(playerid)) {
		return;
	}

	new str[256];
   	
	inline Response_Step1(pid, dialogid, response, listitem, string:inputtext[])
    {
        #pragma unused pid, dialogid, listitem

        if(!response) {
        	// Player has clicked on help.
        	inline Response_Help(pid2, dialogid2, response2, listitem2, string:inputtext2[])
        	{
                OnPlayerExitAccountDialog(playerid);
        		// The user wishes to quit - kick them here.
        		if(!response2) {
        			SendClientMessage(playerid, -1, "Kicked.");
        			//Kick(playerid);
        		}
        		else {
					switch(listitem2) {
						case 0: {
							// "I did not register this accounnt" - show a name change dialog.
							SendClientMessage(playerid, -1, "Name change dialog would show here.");
						}
						case 1: {
							SendClientMessage(playerid, -1, "Forgotten your password link sent to email address");
						}
						case 2: {
							SendClientMessage(playerid, -1, "Enter your e-mail address dialog would show now.");
						}
						case 3: {
							SendClientMessage(playerid, -1, "Go to our forums blabla.");
						}
					}
        		}
				#pragma unused pid2, dialogid2, inputtext2
        	}
        	format(str, sizeof(str), "I have not registered this name\nI have forgotten my password\nI have forgotten my player name\nI need more help");
        	Dialog_ShowCallback(playerid, using inline Response_Help, DIALOG_STYLE_LIST, "Account Help", str, " Select ", " Quit ");
        	return; 
        }

        // Player has attempted to enter a password - lets check if its right.
        if(!database::API->AccountPassword.validate(playerid, inputtext)) {
        	SendClientMessage(playerid, -1, "Invalid password.");
			goto l_Login;
        }else {
    		database::API->IsPlayerLoggedIn.set(playerid, true);
    		SendClientMessage(playerid, -1, "Login successful!");
            OnPlayerExitAccountDialog(playerid);
        }

	}
	l_Login:
   	format(str, sizeof(str), "{FF00FF}Grand Jobs Account Login\n\n\
    	{FFFFFF}Welcome {FF00FF}%s{FFFFFF} to Grand Jobs.\n\n\
    				 This player name is registered. Please enter your password below\n\n\
    				 to continue. Otherwise, click on Help if you need help.", ReturnPlayerName(playerid));

    Dialog_ShowCallback(playerid, using inline Response_Step1, DIALOG_STYLE_PASSWORD, "Account Login", str, " Login > ", " Help ");
}


#undef this 
