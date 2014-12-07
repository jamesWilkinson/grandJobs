/**
	Database controller
	This file handles the retriveal of account data from the database upon the player
	account handlers being initialised.
**/

#define this database::API->controller


// Initiaited when the player connects to the server. 
this.construct(playerid)
{
	new query[256];
	mysql_format(core::initialisation->initDatabase.getMySQLHandle(), query, sizeof(query), "SELECT * FROM %s WHERE PlayerName = '%e' LIMIT 1", 
											core::initialisation->initDatabase.getPlayerTableName(), ReturnPlayerName(playerid));

	inline OnAccountDataReceived()
	{
		new
			rows,
			fields,
			fieldString[256];
		
		cache_get_data(rows, fields, core::initialisation->initDatabase.getMySQLHandle());
		if(rows > 0) {
			database::API->IsPlayerRegistered.set(playerid, true);

			// Set the user ID, i.e. the primary key
			database::API->Account.setUserID(playerid, cache_get_field_content_int(0, "ID"));

			// Set the encrypted password
			cache_get_field_content(0, "Password", fieldString);
			database::API->Account.setEncryptedPassword(playerid, fieldString);
			printf("password: %s", fieldString);

			// Set the salt
			cache_get_field_content(0, "Salt", fieldString);
			database::API->Account.setEncryptedPasswordSalt(playerid, fieldString);
			printf("salt: %s", fieldString);

			// Set this players GPCI 
			cache_get_field_content(0, "GPCI", fieldString);
			database::API->Account.setGPCI(playerid, fieldString);
			printf("GPCI: %s", fieldString);

			// need to do the rest here!

		}
		else {
			database::API->IsPlayerRegistered.set(playerid, false);
		}
	}
	mysql_tquery_inline(core::initialisation->initDatabase.getMySQLHandle(), query, using inline OnAccountDataReceived, "i", playerid);

}

this.registerPlayer(playerid, password[], email[]) {
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
	mysql_tquery(core::initialisation->initDatabase.getMySQLHandle(), query, "");
}

this.generateEmailActivationCode() {
	new str[128];
	WP_Hash(str, sizeof(str), randomString(32));
	return str;
}


#undef this