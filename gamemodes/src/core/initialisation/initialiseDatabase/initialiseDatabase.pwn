/**
	Grand Jobs v0.1
	
	Database initialisation
**/

#define this core::initialisation->initDatabase

static	databaseTableName[] = "players";
static	mysqlConnection;

// Called from OnGameModeInit to connect to the database and check that its connected
this.construct()
{
	printf("[Database] Initialising...");
	
	#if DATABASE_SETTING_LOGGING == true 
		mysql_log(LOG_ALL);
		printf("[Database] Logging enabled.");
	#endif
		
	this.connect();
	if(this.wasConnectionSuccessful())
	{
		this.constructTable();
	}
}

// Connect to the database
this.connect()
{
	printf("[Database] Connecting to %s ....", DATABASE_SETTING_CONNECTION_IP);
	mysqlConnection = mysql_connect(DATABASE_SETTING_CONNECTION_IP, 
									DATABASE_SETTING_CONNECTION_USERNAME, 
									DATABASE_SETTING_DATABASE_NAME, 
									DATABASE_SETTING_CONNECTION_PASSWORD);
}
// Called when the gamemode shuts down 
this.terminate()
{
	mysql_close(mysqlConnection);
}

this.wasConnectionSuccessful()
{
	// The number of errors is not 0 - the server could not connect to the database.
	if(mysql_errno() != 0)
	{
		printf("[Database] Error connecting to %s.", DATABASE_SETTING_CONNECTION_IP);
		printf("[Database] Server shutting down");
		SendRconCommand("exit");
		return 0;
	}
	
	// The server has connected!
	printf("[Database] Established database connection successfully.");
	return 1;
}

this.getMySQLHandle() {
	return mysqlConnection;
}

stock this.getPlayerTableName() {
	return databaseTableName;
}

this.constructTable() {

	new queryString[2048];

	format(queryString, sizeof(queryString),
		"CREATE TABLE IF NOT EXISTS `%s`.`%s` \
		( `ID` INT NOT NULL AUTO_INCREMENT, \
 		`PlayerName` varchar(25) NOT NULL UNIQUE, \
  		`GPCI` TEXT NOT NULL ,  \
  		`EmailAddress` varchar(255) UNIQUE, \
   		`EmailActivated` BOOLEAN NOT NULL DEFAULT FALSE , \
    	`EmailActivationCode` TEXT NOT NULL ,  \
    	`Password` TEXT NOT NULL ,   \
    	`Salt` TEXT NOT NULL, \
    	`RegistrationDate` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \
    	 PRIMARY KEY  (`ID`) ) ENGINE = InnoDB", DATABASE_SETTING_DATABASE_NAME, databaseTableName);

	mysql_query(this.getMySQLHandle(), queryString, false);
}

#undef this