/**
	Account API - contains getter and setter methods for setting various properties of a users account
**/

#define this database::API->Account 

#define 	INVALID_USER_ID		-1


enum USER_DATA {
	EncryptedPassword[256],
	PasswordSalt[256],
	Email[256],
	bool:isEmailActivated,
	emailActivationCode[256],
	GPCI[256],
	ID
}

static userData[SLOTS][USER_DATA];

// Called when the player connects to reset all of the
// default values
this.construct(playerid) {
	userData[playerid][EncryptedPassword] = EOS;
	userData[playerid][PasswordSalt] = EOS;
	userData[playerid][Email] = EOS;
	userData[playerid][isEmailActivated] = false;
	userData[playerid][emailActivationCode] = EOS;
	userData[playerid][GPCI] = EOS;
	userData[playerid][ID] = INVALID_USER_ID;
}


// This is an exception for the naming convention - the word "user" is present
// because ID is a special keyword which may cause some confusion
this.getUserID(playerid) {
	userData[playerid][ID];
}

this.setUserID(playerid, userid) {
	userData[playerid][ID] = userid;
}


this.getEmail(playerid) {
	return userData[playerid][Email];
}

this.setEmail(playerid, email[]) {
	userData[playerid][Email] = email;
}


this.isEmailActivated(playerid) {
	return userData[playerid][isEmailActivated[playerid];
}

this.setEmailActivated(playerid, bool:activated) {
	userData[playerid][isEmailActivated] = activated;
}

this.getEmailActivationCode(playerid) {
	return userData[playerid][emailActivationCode];
}

this.setEmailActivationCode(playerid, code[]) {
	userData[playerid][EmailActivationCode] = code;
}

this.getEncryptedPassword(playerid) {
	new str[256];
	format(str, 256, "%s", userData[playerid][EncryptedPassword]);
	return str;
}

this.setEncryptedPassword(playerid, password[]){
	format(userData[playerid][EncryptedPassword], 256, "%s", password);
}

this.getEncryptedPasswordSalt(playerid) {
	new str[256];
	format(str, 256, "%s", userData[playerid][PasswordSalt]);
	return str;
}


this.setEncryptedPasswordSalt(playerid, salt[]) {
	format(userData[playerid][PasswordSalt], 256, "%s", salt);
}


this.getGPCI(playerid) {
	return userData[playerid][GPCI];
}


// Based on the gpci native
// More information:  http://forum.sa-mp.com/showpost.php?p=2293942&postcount=9 
this.setGPCI(playerid, gpci[]) {
	format(userData[playerid][GPCI], 256, "%s", gpci);
}


// other stuff like e-mail address, skin, weapons, etc 
#undef this