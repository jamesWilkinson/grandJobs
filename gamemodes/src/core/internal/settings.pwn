/**
 * Copyright (c) 2014 grandJobs
 *
 * This program is free software; you can redistribute it and/or modify it under the terms of the
 * GNU General Public License as published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
 * even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program; if
 * not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301, USA.
 */

#define		SLOTS						50			// Determine the number of players that can connect, max. 
													// This can range from 1-500




/** These settings are for the database connection. They need to be changed accordingly.
	The database used is MySQL	**/
#define		DATABASE_SETTING_CONNECTION_IP			"127.0.0.1"
#define		DATABASE_SETTING_CONNECTION_USERNAME	"root"
#define		DATABASE_SETTING_CONNECTION_PASSWORD	""
#define 	DATABASE_SETTING_DATABASE_NAME			"players"
#define		DATABASE_SETTING_LOGGING				true	// Prints output from the database plugin to a file located in the servers directory called mysql_log.txt

