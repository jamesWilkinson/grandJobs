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

 // Handles the showing of various chatbo0x messages in a specific syntax / format
 // depending on the circumstances

 forward SendClientCommandUse(playerid, usage[]);
 public SendClientCommandUse(playerid, usage[])
 {
     return SendClientMessage(playerid, -1, sprintf("{9AC6DB}* [COMMAND USAGE]:{5DA9CF} %s", usage));
 }

 forward SendClientCommandError(playerid, errorMessage[]);
 public SendClientCommandError(playerid, errorMessage[])
 {
    return SendClientMessage(playerid, -1, sprintf("{FF0000}* [COMMAND ERROR]:{FC6565} %s", errorMessage));
 }

 forward SendClientCommandSuccess(playerid, successMessage[]);
 public SendClientCommandSuccess(playerid, successMessage[])
 {
     return SendClientMessage(playerid, -1, sprintf("{00FF00}* [COMMAND SUCCESS]:{39B839} %s", successMessage));
 }

 forward SendClientInfoMessage(playerid, message[]);
 public SendClientInfoMessage(playerid, message[]) {
     return SendClientMessage(playerid, -1, sprintf("[INFORMATION]: %s", message));
 }
