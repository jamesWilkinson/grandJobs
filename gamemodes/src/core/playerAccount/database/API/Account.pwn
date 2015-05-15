/**
	Account API - contains getter and setter methods for setting various properties of a users account
**/

#define this database::API->Account 

#define 	INVALID_USER_ID		-1


// A lot of the string sizes are hardcoded throughout this model.
// These defines keep things consistent
#define EMAIL_STRING_SIZE				256
#define ENCRYPTED_PASSWORD_STRING_SIZE 	256
#define PASSWORD_SALT_STRING_SIZE		256 
#define EMAIL_ACTIVATION_STRING_SIZE	256
#define GPCI_STRING_SIZE				256


// Please note: when adding new values please update the construct method which resets them when the player connects.
// In addition, there should be a getter and setter for each entity
enum USER_DATA {
	EncryptedPassword[ENCRYPTED_PASSWORD_STRING_SIZE],
	PasswordSalt[PASSWORD_SALT_STRING_SIZE],
	Email[EMAIL_STRING_SIZE],
	bool:isEmailActivated,
	emailActivationCode[EMAIL_ACTIVATION_STRING_SIZE],
	GPCI[GPCI_STRING_SIZE],
	ID
}

static userData[SLOTS][USER_DATA];

// Called when the player connects to reset all of the
// default values
// TODO: Find a way to automate this -
// Should be possible to loop through the enum and set a string to EOS, int to 0 and boolean to false
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
this.stock getUserID(playerid) {
	userData[playerid][ID];
}

this.setUserID(playerid, userid) {
	userData[playerid][ID] = userid;
}


this.stock getEmail(playerid) {
	return userData[playerid][Email];
}

this.setEmail(playerid, email[]) {
	format(userData[playerid][Email], EMAIL_STRING_SIZE, "%s", email);
}


this.stock isEmailActivated(playerid) {
	return userData[playerid][isEmailActivated[playerid];
}

this.stock setEmailActivated(playerid, bool:activated) {
	userData[playerid][isEmailActivated] = activated;
}

this.stock getEmailActivationCode(playerid) {
	return userData[playerid][emailActivationCode];
}

this.stock setEmailActivationCode(playerid, code[]) {
	userData[playerid][EmailActivationCode] = code;
}

this.getEncryptedPassword(playerid) {
	new str[256];
	format(str, ENCRYPTED_PASSWORD_STRING_SIZE, "%s", userData[playerid][EncryptedPassword]);
	return str;
}

this.setEncryptedPassword(playerid, password[]){
	format(userData[playerid][EncryptedPassword], ENCRYPTED_PASSWORD_STRING_SIZE, "%s", password);
}

this.getEncryptedPasswordSalt(playerid) {
	new str[256];
	format(str, PASSWORD_SALT_STRING_SIZE, "%s", userData[playerid][PasswordSalt]);
	return str;
}


this.setEncryptedPasswordSalt(playerid, salt[]) {
	format(userData[playerid][PasswordSalt], PASSWORD_SALT_STRING_SIZE, "%s", salt);
}


this.stock getGPCI(playerid) {
	return userData[playerid][GPCI];
}


// Based on the gpci native
// More information:  http://forum.sa-mp.com/showpost.php?p=2293942&postcount=9 
this.setGPCI(playerid, gpci[]) {
	format(userData[playerid][GPCI], GPCI_STRING_SIZE, "%s", gpci);
}


// other stuff like e-mail address, skin, weapons, etc 
#undef this