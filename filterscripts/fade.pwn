



//=================================================================
//
// TEXT DRAW FADE
//
// Creado por Bruno da Silva
//
//
// ips-team.tk/forum/
// brunodasilva.com
//
//=================================================================



#if defined _textfade_included
        #endinput
#endif

#define _textfade_included

stock fade__TextDrawDestroy(Text:draw) {

    deleteproperty( _: draw,  "fade_textColor");

    return TextDrawDestroy (draw);
}

stock fade__TextDrawColor(Text:draw, color) {

    setproperty( _: draw,  "fade_textColor", color );

    return TextDrawColor(draw,color);
}

#define TextDrawDestroy \
            fade__TextDrawDestroy

#define TextDrawColor \
            fade__TextDrawColor

forward FadeTextDrawTimer (  playerid,  textdraw, cor,  tempo );
public FadeTextDrawTimer  (  playerid,  textdraw, cor, tempo ) {


    static alpha ;

    alpha = 1+ ((cor)  & 0xFF);

    cor = ( ((cor >> 24) & 0xFF) << 24 |((cor >> 16) & 0xFF) << 16 | ((cor >> 08) & 0xFF) << 8 | alpha);

    if(alpha != 255)
    {
        SetTimerEx ( "FadeTextDrawTimer", tempo, false,
            "dddd",
            // playerid
            // textdraw
            // redbluegreenalpha
            // tempo

            playerid, _: textdraw, cor, tempo
        );
    }

    TextDrawColor( Text: textdraw, cor );
    TextDrawShowForPlayer( playerid, Text: textdraw);

    return true;

}

stock TextDrawFade( playerid,   Text:textdraw, tempo)
{

    static cor;

    cor = getproperty( _: textdraw,  "fade_textColor" );

    // essa parte do código remove a transparência
    cor =  (((cor >> 24) & 0xFF)<<24|((cor >> 16) & 0xFF)<<16|((cor >> 08) & 0xFF)<<8);

    // coloca a cor do textdraw para transparência zero
    TextDrawColor(textdraw, 0);
    TextDrawShowForPlayer( playerid, textdraw);

    // inicia a contagem para ir mudando a transparencia gradativamente
    tempo /= 0xff;

    if( tempo == 0 ) {

        printf("Para o uso correto da função use um valor maior que 255 em \"tempo\"");
        return false;
    }

    SetTimerEx ( "FadeTextDrawTimer", tempo , false,
        "dddd",

        // playerid
        // textdraw
        // redbluegreenalpha
        // tempo

        playerid, _: textdraw, cor, tempo
    );

    return true;
}