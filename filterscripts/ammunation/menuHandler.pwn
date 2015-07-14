/**
*  Server-side ammunation script by SA-MP BETA Tester Jay_
**/

new Menu:MainMenu;
new Menu:PistolMenu;
new Menu:ShotgunMenu;
new Menu:MicroSMGMenu;
new Menu:ArmorMenu;
new Menu:SMGMenu;
new Menu:AssaultMenu;

// Menu formatting settings
new menuHeader[12] = "Ammu-Nation";
new Float:menuX = 30.0;
new Float:menuY = 140.0;
new Float:menuColumnWidth = 190.0;





InitMenus() {
	MainMenu = CreateMenu(menuHeader, 1, menuX, menuY, menuColumnWidth, menuColumnWidth);
	AddMenuItem(MainMenu, 0, "Pistols");
	AddMenuItem(MainMenu, 0, "Micro SMGs");
	AddMenuItem(MainMenu, 0, "Shotguns");
	AddMenuItem(MainMenu, 0, "Armor");
	AddMenuItem(MainMenu, 0, "SMG");
	AddMenuItem(MainMenu, 0, "Assault");

	PistolMenu = CreateMenu(menuHeader, 1, menuX, menuY, menuColumnWidth, menuColumnWidth);
	AddMenuItem(PistolMenu, 0, "9mm");
	AddMenuItem(PistolMenu, 0, "Silenced 9mm");
	AddMenuItem(PistolMenu, 0, "Desert Eagle");

	MicroSMGMenu = CreateMenu(menuHeader, 1, menuX, menuY, menuColumnWidth, menuColumnWidth);
	AddMenuItem(MicroSMGMenu, 0, "Tec9");
	AddMenuItem(MicroSMGMenu, 0, "Micro SMG");

	ShotgunMenu = CreateMenu(menuHeader, 1, menuX, menuY, menuColumnWidth, menuColumnWidth);
	AddMenuItem(ShotgunMenu, 0, "Shotgun");
	AddMenuItem(ShotgunMenu, 0, "Sawnoff Shotgun");
	AddMenuItem(ShotgunMenu, 0, "Combat Shotgun");

	ArmorMenu = CreateMenu(menuHeader, 1, menuX, menuY, menuColumnWidth, menuColumnWidth);
	AddMenuItem(ArmorMenu, 0, "Body Armor");

	SMGMenu = CreateMenu(menuHeader, 1, menuX, menuY, menuColumnWidth, menuColumnWidth);
	AddMenuItem(SMGMenu, 0, "Tec9");
	AddMenuItem(SMGMenu, 0, "Micro SMG");

	AssaultMenu = CreateMenu(menuHeader, 1, menuX, menuY, menuColumnWidth, menuColumnWidth);
	AddMenuItem(AssaultMenu, 0, "AK47");
	AddMenuItem(AssaultMenu, 0, "M4");
}

public OnPlayerSelectedMenuRow(playerid, row) {
	if(GetPlayerMenu(playerid) == MainMenu) {
		switch(row) {
			case 0: ShowMenuForPlayer(PistolMenu, playerid);
			case 1: ShowMenuForPlayer(MicroSMGMenu, playerid);
			case 2: ShowMenuForPlayer(ShotgunMenu, playerid);
			case 3: ShowMenuForPlayer(ArmorMenu, playerid);
			case 4: ShowMenuForPlayer(SMGMenu, playerid);
			case 5: ShowMenuForPlayer(AssaultMenu, playerid);
		}
	} else if(GetPlayerMenu(playerid) == PistolMenu){
		
	} else if(GetPlayerMenu(playerid) == MicroSMGMenu) {
		
	}
}

public OnPlayerExitedMenu(playerid) {
	if (GetPlayerMenu(playerid) == MainMenu){
		TogglePlayerControllable(playerid, 1);
		SetCameraBehindPlayer(playerid);
		printf("exited main menu");
		CheckToShowAmmuCheckpoint(playerid);
	} else if(GetPlayerMenu(playerid) >= PistolMenu || GetPlayerMenu(playerid) <= AssaultMenu) {
		ShowMenuForPlayer(MainMenu, playerid);
		printf("exited sub menu");
	}
}
