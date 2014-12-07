/**
 Check if a password is valid for the users account by encrypting it  
 **/

#define this database::API->AccountPassword

// Encrypt the password string matching the encryption convention
// in the database 
this.encrypt(password[], salt[])
{
	new encryptedPassword[256];
	WP_Hash(encryptedPassword, sizeof(encryptedPassword), sprintf("%s%s", salt, password));
	return encryptedPassword;
}

/**
 Validate a given string against the encrypted password
 stored in the players account
*/
this.validate(playerid, passwordToValidate[])
{
	new hashedPassword[256];
	WP_Hash(hashedPassword, sizeof(hashedPassword), sprintf("%s%s",  database::API->Account.getEncryptedPasswordSalt(playerid), passwordToValidate));

	if(!strcmp(hashedPassword, database::API->Account.getEncryptedPassword(playerid), false))
	{
		return 1;
	}

	return 0;
}


/**
	Return a salt based on some player data for the given ID
*/
this.generateRandomSalt()
{
	new salt[256];
	format(salt, 256, "salt_%s", randomString(32));
	return salt;
}

#undef this 