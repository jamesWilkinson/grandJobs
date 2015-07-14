//0Sprites Editor by Zh3r0

#include <a_samp>
new Text:Sprite0;



public OnFilterScriptInit()
{
    Sprite0 = TextDrawCreate(245.500, 7.000, "outro:outro");
    TextDrawFont(Sprite0, 4);
    TextDrawTextSize(Sprite0, 100.000, 100.000);
    TextDrawColor(Sprite0, -1);

    return 1;
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