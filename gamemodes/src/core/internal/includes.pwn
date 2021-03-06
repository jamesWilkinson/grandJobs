#include <a_samp>


/** Naming convention **/
#include "core\internal\namingConventionDefines.pwn"

/** LIBRARIES **/
#include "core\internal\libaries\third_party\YSI\y_dialog.inc"
#include "core\internal\libaries\third_party\zcmd.inc"
#include "core\internal\libaries\third_party\translate\translate.inc"
#include "core\internal\libaries\third_party\screenfade.inc"
#include "core\internal\libaries\third_party\sscanf2.inc"
#include "core\internal\libaries\third_party\a_mysql.inc"
#include "core\internal\libaries\third_party\YSF.inc"
#include "core\internal\libaries\third_party\execute.inc"
#include "core\internal\libaries\third_party\whirlpool.inc"



#include "core\internal\libaries\API.pwn"

/** SETTINGS **/
#include "core\internal\settings.pwn"

/** DATABASE **/
#include "core\initialisation\initialiseDatabase\initialiseDatabase.pwn"

/** INTERNAL **/
#include "core\internal\globals.pwn"
#include "core\internal\callbackHooks.pwn"
#include "core\internal\Logger.pwn"

/** PLAYER CONNECTION **/
#include "core\playerConnection/handleWelcomeMessage.pwn"

/** MISC **/
#include "core\initialisation\initialiseGamemode.pwn"
#include "core\initialisation\initialiseLanguage.pwn"

/**
 Player account stuff
**/
#include "core\playerAccount\database\API\IsPlayerRegistered.pwn"
#include "core\playerAccount\database\API\IsPlayerLoggedIn.pwn"
#include "core\playerAccount\database\API\AccountPassword.pwn"
#include "core\playerAccount\database\API\Account.pwn"
#include "core\playerAccount\database\Controllers\retrieveData.pwn"
#include "core\playerAccount\database\Controllers\registerPlayer.pwn"
#include "core\playerAccount\database\Controllers\loginPlayer.pwn"
#include "core\playerAccount\database\Controllers\activationEmail.pwn"
#include "core\playerAccount\playerAccountCheckLogin.pwn"

/** Language and chatbox **/
#include "core\playerAccount\playerAccountSettings\playerLanguageSettings.pwn"
#include "core\playerAccount\playerAccountChatBoxMessageHandling.pwn"

/** Other misc player related **/
#include "core\player\death.pwn"
#include "core\player\kill.pwn"

/** Misc commands **/
#include "core\playerAccount\playerAccountMiscCommands.pwn"
/** Game Engine **/
// global
#include "gameEngine\API.pwn"
#include "gameEngine\initialisation\game\gameMeta.pwn"
#include "gameEngine\initialisation\global\globalGameLoader.pwn"
#include "gameEngine\initialisation\global\gamePicker.pwn"
#include "gameEngine\initialisation\global\gameUnloader.pwn"
#include "gameEngine\initialisation\global\gameLoader.pwn"
#include "gameEngine\initialisation\global\game.pwn"
#include "gameEngine\initialisation\global\gameChanger.pwn"
 // helpers
 #include "gameEngine\helpers\sound\sound.pwn"
 #include "gameEngine\helpers\spawn\spawn.pwn"
 #include "gameEngine\helpers\race\race.pwn"