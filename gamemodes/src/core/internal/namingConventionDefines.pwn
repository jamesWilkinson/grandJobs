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

// Player related, misc
#define player->%0( %0x(

#define kill.%0( %0a(
#define death.%0( %0g(


#define initialisation->%0( %0b(
#define initDatabase.%0( %0o(

#define playerAccount->%0( %0l(
#define playerAccountCheckLogin.%0( %0o(

// patabase::playerAccount->IsPlayerRegistered
// playerAccount::database->API.IsPlayerRegisteredConstruct(playerid)
// playerAccount::database->controller.construct

#define database::%0( %0m(
#define API->%0( %0l(
#define IsPlayerRegistered.%0( %0a(
#define IsPlayerLoggedIn.%0( %0b(
#define AccountPassword.%0( %0c(
#define Account.%0( %0d(
#define Controllers->%0( %0l(
#define retrieveData.%0( %0e(
#define registerPlayer.%0( %0f(
#define loginPlayer.%0( %0g(
#define activationEmail.%0( %0h(

// GAME Engine 
#define gameEngine::%0( %0i(
// meta 
#define Meta.%0( %0k(


// gameEngine::initialisation->gameChanger
// global
#define globalGameLoader.%0( %0l(
#define gameUnloader.%0( %0m(
#define gameLoader.%0( %0n(
#define gamePicker.%0( %0o(
#define game.%0( %0p(
#define gameChanger.%0( %0q(

//gameEngine::helpers->sound
// helpers 
#define helpers->%0( %0l(

// sound helper
#define sound.%0( %0x(
#define spawn.%0( %0a(
#define race.%0( %0c(
