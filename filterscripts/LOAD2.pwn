//0Sprites Editor by Zh3r0

#include <a_samp>
new Text:Sprite0;



public OnFilterScriptInit()
{

    new str[128];
    new num = random(14)+1;
    format(str, 128, "loadsc%d:loadsc%d", num, num);

    Sprite0 = TextDrawCreate(-5.000, -2.000, str);
    TextDrawFont(Sprite0, 4);
    TextDrawTextSize(Sprite0, 872.500, 814.000);
    TextDrawColor(Sprite0, -1);


    TextDrawShowForAll(Sprite0);
    return 1;
}



ShowRandomScreen(playerid) {

    new str[128];
    new num = random(14)+1;
    format(str, 128, "loadsc%d:loadsc%d", num, num);

    Sprite0 = TextDrawCreate(-5.000, -2.000, str);
    TextDrawFont(Sprite0, 4);
    TextDrawTextSize(Sprite0, 872.500, 814.000);
    TextDrawColor(Sprite0, -1);

}


HideRandomScreen(playerid) {

    TextDrawDestroy(Sprite0);
    Sprite0 = Text:INVALID_TEXT_DRAW;

}


public OnFilterScriptExit()
{
    TextDrawHideForAll(Sprite0);
    TextDrawDestroy(Sprite0);
    return 1;
}


public OnPlayerConnect(playerid)
{
    TextDrawShowForPlayer(playerid,Sprite0);
    return 1;
}