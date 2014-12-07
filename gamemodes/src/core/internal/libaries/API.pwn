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

 native gpci (playerid, serial [], len);

 /*stock ReturnPlayerName(playerid)
 {
     new playerName[MAX_PLAYER_NAME];
     GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
     return playerName;
 }*/

stock IsNumeric(const string[]) //By Jan "DracoBlue" Schütze (edited by Gabriel "Larcius" Cordes
{
	new length=strlen(string);
	if(length==0)
	{
		return 0;
	}
	for (new i=0; i<length; i++)
	{
		if (!((string[i] <= '9' && string[i] >= '0') || (i==0 && (string[i]=='-' || string[i]=='+'))))
		{
			return false;
		}
	}
	return 0;
}

stock adler32(buf[])
 {
	new length=strlen(buf);
    new s1 = 1;
    new s2 = 0;
    new n;
    for (n=0; n<length; n++) {
       s1 = (s1 + buf[n]) % 65521;
       s2 = (s2 + s1)     % 65521;
    }
    return (s2 << 16) + s1;
 }

// Credits to RyDeR
stock randomString(strLen = 10)
{
	if(strLen > 255)
		strLen = 255;

	new str[256];
    while(strLen--)
        str[strLen] = random(2) ? (random(26) + (random(2) ? 'a' : 'A')) : (random(10) + '0');
    return str;
}


/*
stock strcpy(dest[], const source[], maxlength=sizeof dest)
{
    strcat((dest[0] = EOS, dest), source, maxlength);
}*/