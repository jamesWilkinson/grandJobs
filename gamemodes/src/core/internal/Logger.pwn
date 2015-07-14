/**
	The purpose of this file is to handle logging of errors, warnings, debug messages, etc
	THIS IS A STATIC FILE
**/



// setting for which log messages should be shown
// if this is a production environment, it should be set to warning or error
#define		GLOBAL_LOG_LEVEL	LOG_LEVEL_MESSAGE 
#define		LOG_WRITE_TO_FILE	true


stock Log(msg[], level = LOG_LEVEL_DEBUG)
{
	// First of all print it to the main console
//	if(level >= GLOBAL_LOG_LEVEL) {
		printf("%s%s", GetLoggerPrefixFromType(level), msg);
//	}

	#if LOG_WRITE_TO_FILE == true
		// Now we'll store it in a seperate logs file
		// Retrieve the log current timestamp 
		new
			day, month, year, hour, minute, second;
		getdate(year, month, day);
		gettime(hour, minute, second);

		// Build the log file based on todays date
		new logfile[64];
		format(logfile, sizeof(logfile), "Logger\\logs_%d_%d_%d.txt", day, month, year);
		new File:log = fopen(logfile, io_append);
		if(log == File:0) {
			printf("[LOGGING ERROR: Unable to write to log file. Cannot open file: %s", logfile);
		}

		new logEntry[512];
		format(logEntry, sizeof(logEntry), "[%d/%d/%d] [%d:%d:%d] [%d]: %s\r\n", day, month, year, hour, minute, second, level, msg);
		fwrite(log, logEntry);
		fclose(log);
	#endif
	return 1;
}

stock GetLoggerPrefixFromType(type) {
	new prefix[32];
	switch(type)
	{
		case LOG_LEVEL_MESSAGE: 	prefix = "[Log] ";
		case LOG_LEVEL_DEBUG: 		prefix = "[Debug] ";
		case LOG_LEVEL_WARNING: 	prefix = "[Warning] ";
		case LOG_LEVEL_ERROR:		prefix = "[Error] ";
		case LOG_LEVEL_CRITICAL:	prefix = "[CRITICAL ERROR] ";
	}
	return prefix;
}