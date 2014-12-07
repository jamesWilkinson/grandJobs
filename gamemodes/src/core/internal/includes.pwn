#include <a_samp>

/** Naming convention **/
#include "core\internal\namingConventionDefines.pwn"

/** LIBRARIES **/
#include "core\internal\libaries\third_party\zcmd.inc"
#include "core\internal\libaries\third_party\translate\translate.inc"
#include "core\internal\libaries\third_party\screenfade.inc"
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
#include "core\internal\callbackHooks.pwn"


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
#include "core\playerAccount\database\controller.pwn"
#include "core\playerAccount\playerAccountCheckLogin.pwn"

/** Language and chatbox **/
#include "core\playerAccount\playerAccountSettings\playerLanguageSettings.pwn"
#include "core\playerAccount\playerAccountChatBoxMessageHandling.pwn"

/** Misc commands **/
 #include "core\playerAccount\playerAccountMiscCommands.pwn"
