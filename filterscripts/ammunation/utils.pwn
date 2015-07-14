/**
	SERVER SIDE AMMUN-NATION BY SA-MP BETA TESTER JAY_
	SOME UTILITY FUNCTIONS FOR HOUSEKEEPING
**/




/**
Return the weapon object model id based on the weapon id
*/
stock GetModelFromWeaponID(weaponid) {
	if(weaponid < 1 || weaponid > 46)
		return INVALID_OBJECT_ID;

	switch(weaponid) {
		case WEAPON_BRASSKNUCKLE: return 331;
		case WEAPON_GOLFCLUB: return 333;
		case WEAPON_NITESTICK: return 334;
		case WEAPON_KNIFE: return 335;
		case WEAPON_BAT: return 336;
		case WEAPON_SHOVEL: return 337;
		case WEAPON_POOLSTICK: return 338;
		case WEAPON_KATANA: return 339;
		case WEAPON_CHAINSAW: return 341;
		case WEAPON_DILDO: return 321;
		case WEAPON_DILDO2: return 322;
		case WEAPON_VIBRATOR: return 323;
		case WEAPON_VIBRATOR2: return 324;
		case WEAPON_FLOWER: return 325;
		case WEAPON_CANE: return 326;
		case WEAPON_GRENADE: return 324;
		case WEAPON_TEARGAS: return 343;
		case WEAPON_MOLTOV: return 344;
		case WEAPON_COLT45: return 346;
		case WEAPON_SILENCED: return 347;
		case WEAPON_DEAGLE: return 348;
		case WEAPON_SHOTGUN: return 349;
		case WEAPON_SAWEDOFF: return 350;
		case WEAPON_SHOTGSPA: return 351;
		case WEAPON_UZI: return 352;
		case WEAPON_MP5: return 353;
		case WEAPON_AK47: return 355;
		case WEAPON_M4: return 356;
		case WEAPON_TEC9: return 372;
		case WEAPON_RIFLE: return 357;
		case WEAPON_SNIPER: return 358;
		case WEAPON_ROCKETLAUNCHER: return 359;
		case WEAPON_HEATSEEKER: return 360;
		case WEAPON_FLAMETHROWER: return 361;
		case WEAPON_MINIGUN: return 362;
		case WEAPON_SATCHEL: return 363;
		case WEAPON_BOMB: return 364;
		case WEAPON_SPRAYCAN: return 365;
		case WEAPON_FIREEXTINGUISHER: return 366;
		case WEAPON_CAMERA: return 367;
		case WEAPON_PARACHUTE: return 371;
		default: return INVALID_OBJECT_ID;

	}
	return INVALID_OBJECT_ID;
}


stock ReturnPlayerName(playerid) {
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	return name;
}



stock strtok(const string[], &index,seperator=' ')
{
    new length = strlen(string);
    new offset = index;
    new result[255];
    while ((index < length) && (string[index] != seperator) && ((index - offset) < (sizeof(result) - 1)))
    {
        result[index - offset] = string[index];
        index++;
    }

    result[index - offset] = EOS;
    if ((index < length) && (string[index] == seperator))
    {
        index++;
    }
    return result;
}



stock GetXYInFrontOfActor(actorid, &Float:x, &Float:y, Float:distance)
{
	new Float:a;
	GetActorPos(actorid, x, y, a);
	GetActorFacingAngle(actorid, a);
	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}
