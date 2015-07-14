
#define this database::Controllers->registerPlayer


/**
 Register the player with the specified parameters passed
 */
this.construct(playerid, password[], email[]) {
	new query[512];
	new gpciStr[128];

	new salt[128]; 
	format(salt, sizeof(salt), "%s", database::API->AccountPassword.generateRandomSalt());

	gpci(playerid, gpciStr, sizeof(gpciStr));


	mysql_format(core::initialisation->initDatabase.getMySQLHandle(), query, sizeof(query),
		"INSERT INTO `%s` (`PlayerName`, `GPCI`, `EmailAddress`, `EmailActivationCode`, `Password`, `Salt`) VALUES ('%s', '%e', '%s', '%s', '%s', '%s');", 
				core::initialisation->initDatabase.getPlayerTableName(), 
				ReturnPlayerName(playerid),
				gpciStr,
				email,
				this.generateEmailActivationCode(),
				database::API->AccountPassword.encrypt(password, salt),
				salt

	);
	mysql_tquery(core::initialisation->initDatabase.getMySQLHandle(), query, "OnRegisterComplete", "ds", playerid, email);
}

forward OnRegisterComplete(playerid, email[]);
public OnRegisterComplete(playerid, email[]) {

	printf("OnRegisterComplete: %d, %s", playerid, email);
	database::API->IsPlayerRegistered.set(playerid, true);
	database::API->IsPlayerLoggedIn.set(playerid, true);
	database::Controllers->activationEmail.send(email);

	inline Register_Confirm(pid2, dialogid2, response2, listitem2, string:inputtext2[])
	{
		#pragma unused pid2, dialogid2, response2, listitem2, inputtext2
		GameTextForPlayer(playerid, "~g~Registered!", 5000, 5);
		FadePlayerScreen(playerid, true);
	}

	new str[512];
	format(str, sizeof(str), "{FFFFFF} Your account has been successfully registered.\n\
		Your data for this session has been saved to your account. \n\
		An activation e-mail has been sent to {00FFFF}%s{FFFFFF}.\n\
		Please activate your account by going to your e-mail inbox and opening the message before logging in again.\n\
		If you cannot see the e-mail, please check your junk folder. You can rejoin the server to resend it.", email);

	Dialog_ShowCallback(playerid, using inline Register_Confirm, DIALOG_STYLE_MSGBOX, "Registration Complete", str, "Close");	
}

this.generateEmailActivationCode() {
	new str[256];
	WP_Hash(str, sizeof(str), randomString(32));
	return str;
}



// /register command
COMMAND:register(playerid, params[]) {

	if(database::API->IsPlayerRegistered.get(playerid)) {
		return SendClientCommandError(playerid, "You are already registered.");
	}

	new str[512];

	inline Response_Step1(pid, dialogid, response, listitem, string:inputtext[])
    {
        #pragma unused pid, dialogid, response, listitem, inputtext
		if(response) {
        	registerEnterEmail:
	        format(str, sizeof(str), "{FF00FF}Grand Jobs Registration Wizard 2 / 6\n\n\
	        	{FFFFFF}Please enter a {00FF00}VALID{FFFFFF} e-mail address below.\n\n\
	        	You will need to activate your e-mail address before being able to use \n\
	        	the full features of this account. Valid e-mail format is email@host.com ");

	    	inline Response_Step2(pid2, dialogid2, response2, listitem2, string:inputtext2[])
	    	{
		        #pragma unused pid2, dialogid2, listitem2
	    		if(response2) 
	    		{
	    			if(strlen(inputtext2) < 3)
	    				goto registerEnterEmail;

	    			// Email address isn't valid 
	    			// Show the user an error dialog box and make them go back to re enter it
					if(!IsValidEmail(inputtext2)) 
					{
						inline Response_InvalidEmail(pidIE, dialogidIE, responseIE, listitemIE, string:inputtextIE[])
						{
							#pragma unused pidIE, dialogidIE, listitemIE, inputtextIE
							if(responseIE)
							{
								goto registerEnterEmail;
							}
						}
						format(str, 256, "{FF0000}The e-mail address entered: {FFFFFF}%s\n\
							{FF0000} is not valid. Please go back and try again. \n\
							{FFFFFF}NOTE: A valid e-mail is necessary to be able to register on Grand Jobs.", inputtext2);
						Dialog_ShowCallback(playerid, using inline Response_InvalidEmail, DIALOG_STYLE_MSGBOX, "Register New Account", str, "< Back", "Cancel");
					}
					// Phew e-mail address is valid
					// Now we need to make them re-enter it to confirm it! D:
					else 
					{
						inline Response_Step3(pid3, dialogid3, response3, listitem3, string:inputtext3[])
						{
							#pragma unused pid3, dialogid3, listitem3
							if(!response3) {
								goto registerEnterEmail;
							}

							// They dont match for fuck sake! 
							if(strlen(inputtext3) < 3 || strcmp(inputtext3, inputtext2, false)) 
							{
								inline Response_EmailMM(pidMM, dialogidMM, responseMM, listitemMM, string:inputtextMM[])
								{
									#pragma unused pidMM, dialogidMM, listitemMM, inputtextMM
									if(responseMM)
										goto registerEnterEmail;
								}
								format(str, 256, "{FFFFFF}The e-mails do not match! Please Try again.");
								Dialog_ShowCallback(playerid, using inline Response_EmailMM, DIALOG_STYLE_MSGBOX, "Register New Account", str, "Back <", "Cancel");
								continue;
							}

							// WOHOO We have a valid e-mail. Next step: Password!!
							inline Response_Step4(pid4, dialogid4, response4, listitem4, string:inputtext4[])
							{
								#pragma unused pid4, dialogid4, listitem4
								// If they press the back button go back to the e-mail step.
								if(!response4) {
									goto registerEnterEmail;
								}

								// Has the password been correctly entered? Should be 5 chars long at least!
								if(strlen(inputtext4) < 5) {
									goto RegisterEnterPassword;
								}

								// We have a valid password entered at this point. Now we just need them to re enter it again!
								inline Response_Step5(pid5, dialogid5, response5, listitem5, string:inputtext5[])
								{
									#pragma unused pid5, dialogid5, listitem5

									// User wants to go back
									if(!response5) {
										goto RegisterEnterPassword;
									}
									// Has the user entered anything?
									if(strlen(inputtext5) < 2) {
										goto RegisterReEnterPassword;
									}
									// Check the strings match
									// If not, we need to show a message that the password entered is not valid!
									if(strcmp(inputtext5, inputtext4, false)) {
										inline Response_PasswordMM(pidPMM, dialogidPMM, responsePMM, listitemPMM, string:inputtextPMM[])
										{
											#pragma unused pidPMM, dialogidPMM, inputtextPMM, listitemPMM
											// The user wants to try again
											if(responsePMM) {
												goto RegisterReEnterPassword;
											} 
											// They want to go back and re-enter their initial password
											else {
												goto RegisterEnterPassword;
											}
										}
										format(str, 256, "{FFFFFF}The password entered does not match! Please try again.");
										Dialog_ShowCallback(playerid, using inline Response_PasswordMM, DIALOG_STYLE_MSGBOX, "Register New Account", str, " Try Again ", " Back ");
									}
									// Wohoo the passwords match - show a final confirmation and we're done!
									else {
										inline Response_Step6(pid6, dialogid6, response6, listitem6, string:inputtext6[])
										{
											#pragma unused pid6, dialogid6, listitem6, inputtext6
											if(response6) {
												this.construct(playerid, inputtext5, inputtext3);
											}
											else {
												goto RegisterReEnterPassword;
											}
										}
										format(str, 256, "{FF00FF}Grand Jobs Registration Wizard 6 / 6\n\n\
											{FFFFFF}Account: {FF00FF} %s\n\
											{FFFFFF}E-mail: {FF00FF} %s\n\
											{FFFFFF}Password: {FF00FF} ********\n\n\
											{FFFFFF}Do you wish to register this account on Grand Jobs?", ReturnPlayerName(playerid), inputtext3);
										Dialog_ShowCallback(playerid, using inline Response_Step6, DIALOG_STYLE_MSGBOX, "Confirm Registration", str, "Register", "Back");
									}
								}

								RegisterReEnterPassword:
								format(str, 256, "{FF00FF}Grand Jobs Registration Wizard 5 / 6\n\n\
									{FFFFFF}Please re-enter your password to validate it:");
								Dialog_ShowCallback(playerid, using inline Response_Step5, DIALOG_STYLE_PASSWORD, "Register New Account", str, "Next >", "Back");


							}
							RegisterEnterPassword:
							format(str, 256, "{FF00FF}Grand Jobs Registration Wizard 4 / 6\n\n\
								{FFFFFF}Please enter a password to continue. Your password should be at least\n\
								5 characters long. Try to make your password strong by including symbols and numbers.");
							Dialog_ShowCallback(playerid, using inline Response_Step4, DIALOG_STYLE_PASSWORD, "Register New Account", str, "Next >", "Back");

						}
					   	format(str, 256, "{FF00FF}Grand Jobs Registration Wizard 3 / 6\n\n\
				        	{FFFFFF}Please re-enter your e-mail address to validate it:");
						Dialog_ShowCallback(playerid, using inline Response_Step3, DIALOG_STYLE_INPUT, "Register New Account", str, "Next >", "Back");
					}
	    		}
	    	}
	    	Dialog_ShowCallback(playerid, using inline Response_Step2, DIALOG_STYLE_INPUT, "Register New Account", str, "Next >", "Cancel");
		} else {
			FadePlayerScreen(playerid, true);
		}

    }
    format(str, 256, "{FF00FF}Grand Jobs Registration Wizard 1 / 6\n\n\
    	{FFFFFF}Welcome {FF00FF}%s{FFFFFF} to the Grand Jobs Registration Process.\n\n\
    				 This wizard will guide you through the registration steps to register on Grand Jobs.\n\n\
    				 Note: You need a valid e-mail address to register here. Press Next to continue", ReturnPlayerName(playerid));
    Dialog_ShowCallback(playerid, using inline Response_Step1, DIALOG_STYLE_MSGBOX, "Register New Account", str, "Next >", "Cancel");
	FadePlayerScreen(playerid);
	return 1;
}

#undef this