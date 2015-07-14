/**
	Database controller
	This file handles the retriveal of account data from the database upon the player
	account handlers being initialised.
**/

#define this database::Controllers->retrieveData


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

			// E-mail address
			cache_get_field_content(0, "Email", fieldString);
			database::API->Account.setEmail(playerid, fieldString);
			printf("Email: %s", fieldString);

			// need to do the rest here!

		}
		else {
			database::API->IsPlayerRegistered.set(playerid, false);
		}
	}
	mysql_tquery_inline(core::initialisation->initDatabase.getMySQLHandle(), query, using inline OnAccountDataReceived, "i", playerid);

}


#undef this