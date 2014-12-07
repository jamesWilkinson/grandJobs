/**
	This file contains a lot of "hacky" defines which are necessary for the naming convention
**/

// Global Modes define
#define Modes::%0( %0m(
#define LVDM->%0( %0l(
#define Objects.%0( %0o(
// Can be used as Modes::LVDM->Objects.SomeFunctionName


// welcome message
#define core::%0( %0m(
#define playerConnection->%0( %0a(
#define handleWelcomeMessage.%0( %0o(

#define initialisation->%0( %0b(
#define initDatabase.%0( %0o(

#define playerAccount->%0( %0l(
#define playerAccountCheckLogin.%0( %0o(

//atabase::playerAccount->IsPlayerRegistered
// playerAccount::database->API.IsPlayerRegisteredConstruct(playerid)
// playerAccount::database->controller.construct

#define database::%0( %0m(
#define API->%0( %0l(
#define IsPlayerRegistered.%0( %0a(
#define IsPlayerLoggedIn.%0( %0b(
#define AccountPassword.%0( %0c(
#define Account.%0( %0d(
#define controller.%0( %0e(