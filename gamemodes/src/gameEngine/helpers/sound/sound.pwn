/**
	Plays some sound affects which can be used in games
**/

#define this gameEngine::helpers->sound

#define 	SOUND_AFFECT_WASTED		0


this.wastedSoundAffect(playerid) {
	PlayAudioStreamForPlayer(playerid, "https://dl.dropboxusercontent.com/u/45389967/grandjobs/sounds/wasted.mp3");
}


forward PlaySoundAffect(playerid, soundaffect);

public PlaySoundAffect(playerid, soundaffect) {
	switch(soundaffect) {
		case SOUND_AFFECT_WASTED: this.wastedSoundAffect(playerid);
	}
}

#undef this