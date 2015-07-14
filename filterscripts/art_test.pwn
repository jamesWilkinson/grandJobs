#include <a_samp>
#include <s-art>

new art;

public OnFilterScriptInit() {
	art = CreateArt("C:\\Users\\James\\Desktop\\gta.png", 958.302185, -92.375831, 18.952981,   45, 45, 45, 100, 2); 
}

// native CreateArt(text[], Float:sX, Float:sY, Float:sZ, Float:aX, Float:aY, Float:aZ, Float:dist, type);

public OnFilterScriptExit() {
	DestroyArt(art);
}