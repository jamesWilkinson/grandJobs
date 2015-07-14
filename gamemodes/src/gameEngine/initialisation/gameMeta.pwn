/**
	Set the meta information for this game, including the filename, the game name, the author and the assembly info
**/
#define this gameEngine::initialisation->Meta



enum GAME_META_DATA {
	metaAuthor[MAX_AUTHOR_STRING],
	metaName[MAX_NAME_STRING],
	metaFilename[MAX_FILENAME_STRING],
	metaVersionMajor,
	metaVersionMinor,
	metaGameType
}

static metaData[GAME_META_DATA];

this.reset() {
	this.setAuthor("");
	this.setName("");
	this.setFilename("");
	this.setVersionMajor(0);
	this.setVersionMinor(0);
	this.setType(GAME_TYPE_NONE);
}

this.setType(type) {
	metaData[metaGameType] = type;
}

this.getType() {
	return metaData[metaGameType];
}

this.setAuthor(author[]) {	
	new str[MAX_AUTHOR_STRING];
	format(str, MAX_AUTHOR_STRING, "%s", author);
	metaData[metaAuthor] = str;
}

this.getAuthor() {
	return metaData[metaAuthor];
}

this.setName(name[]) {
	new str[MAX_NAME_STRING];
	format(str, MAX_NAME_STRING, "%s", name);
	metaData[metaName] = str;
}

this.getName() {
	return metaData[metaName];
}

this.setFilename(filename[]){
	new str[MAX_FILENAME_STRING];
	format(str, MAX_FILENAME_STRING, "%s", filename);
	metaData[metaFilename] = str;
}

this.getFilename() {
	return metaData[metaFilename];
}

this.setVersionMajor(ver) {
	metaData[metaVersionMajor] = ver;
}

this.getVersionMajor() {
	return metaData[metaVersionMajor];
}

this.setVersionMinor(ver) {
	metaData[metaVersionMinor] = ver;
}

this.getVersionMinor() {
	return metaData[metaVersionMinor];
}

this.getVersionString() {
	new versionStr[8];
	format(versionStr, sizeof(versionStr), "%d.%d", this.getVersionMajor(), this.getVersionMinor());
	return versionStr;
}



//-----------------------------
// API CODE
forward GetGameType();
public GetGameType() {
	Log("API Call: GetGameType", LOG_LEVEL_DEBUG);
	return this.getType();
}

forward SetGameType(gametype);
public SetGameType(gametype) {
	this.setType(gametype);
	return 1;
}

forward GetGameAuthor();
public GetGameAuthor() {
	return this.getAuthor();
}

forward SetGameAuthor(author[]);
public SetGameAuthor(author[])
{
	if(!strlen(author) || strlen(author) >= MAX_AUTHOR_STRING)
		return 0;

	this.setAuthor(author);
	return 1;
}

forward SetGameName(name[]);
public SetGameName(name[] ) {
	if(!strlen(name) || strlen(name) >= MAX_NAME_STRING)
		return 0;

	Log("SetGameName: API call", LOG_LEVEL_DEBUG);
	this.setName(name);
	return 1;
}

forward GetGameName();
public GetGameName() {
	return this.getName();
}

forward SetFilename(filename[]);
public SetFilename(filename[]){
	if(!strlen(filename) || strlen(filename) > MAX_FILENAME_STRING)
		return 0;
	this.setFilename(filename);
	return 1;
}

forward GetFilename();
public GetFilename() {
	return this.getFilename();
}

forward SetVersionMinor(ver);
public SetVersionMinor(ver) {
	Log("API CALL: SetVersionMinor", LOG_LEVEL_DEBUG);
	this.setVersionMinor(ver);
	return 1;
}

forward GetVersionMinor();
public GetVersionMinor() {
	return this.getVersionMinor();
}

forward SetVersionMajor(ver);
public SetVersionMajor(ver) {
	Log("API CALL: SetVersionMajor", LOG_LEVEL_DEBUG);
	this.setVersionMajor(ver);
	return 1;
}

forward GetVersionMajor();
public GetVersionMajor() {
	Log("API CALL: GetVersionMajor", LOG_LEVEL_DEBUG);
	return this.getVersionMajor();
}


/*
forward GetVersionString();
public GetVersionString() {
	return this.getVersionString();
}*/

#undef this