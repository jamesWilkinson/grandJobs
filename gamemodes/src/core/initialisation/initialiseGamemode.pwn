/**
* Called when the gamemode initialises to set a few SA-MP related settings
*/

initialiseGamemode()
{
	// Start the MySQL database on my local windows machine (Jay)
	// You can configure this to point to your mysql server exe location - or you can just
	// start your mysql server manually when the server starts. Its up to you
	// http://stackoverflow.com/questions/698914/how-can-i-access-the-mysql-command-line-with-xampp-for-windows
	//exec("C:\xampp\\mysql\\bin\\mysql.exe -u root");

	SetGameModeText("Grand Missions");
	UsePlayerPedAnims();
	//DisableInteriorEnterExits();
	SetWorldTime(19);
	SetModeRestartTime(1);

	initScreenFade();

	// Load the games from the text file
	gameEngine::initialisation->globalGameLoader.init();
	// Choose any random game to start
//	gameEngine::initialisation->gameLoader.init();

	// Initialise the game changer screen when the gamemode is initialised
	gameEngine::initialisation->gameChanger.construct();
	// and show it for all players since no game is currently loaded, too
	gameEngine::initialisation->gameChanger.init();
}

