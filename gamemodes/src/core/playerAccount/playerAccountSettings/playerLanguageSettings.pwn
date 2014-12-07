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


 stock accountSetPlayerLanguage(playerid, Language:Language)
 {
     SetPlayerLanguage(playerid, _:Language);
 }

 /**
 * Framework for the player language chooser dialog
 */
 stock ShowPlayerLanguageChooser(playerid)
 {
     #pragma unused playerid

 }

CMD:language(playerid, params[])
{

	SendClientMessage(playerid, -1, __("Welcome to Grand Missions!", playerid));
    if(!strlen(params)) {
        l_ShowUsage:
        SendClientCommandUse(playerid, "/language [English/Spanish]");
        return 1;
    }
    if(!strcmp(params, "English", true)) {
        accountSetPlayerLanguage(playerid, English);
		SendClientCommandSuccess(playerid, "Language set to English.");
        return 1;
    }

    if(!strcmp(params, "Spanish", true)) {
        accountSetPlayerLanguage(playerid, Spanish);
        SendClientCommandSuccess(playerid, "Done.");
        return 1;
    }
    else {
        goto l_ShowUsage;
    }
    return 1;
}

