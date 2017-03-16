// XCom Sound manager
// 
// Manages common sound and music related tasks for XCOM

// LWS Mods:
// 
// tracktwo - Added support for SoundCues in the PlaySoundEvent() function.
// tracktwo - Added sound aliases.

class XComSoundManager extends Actor config(GameData);

struct native AkEventMapping
{
	var string strKey;
	var AkEvent TriggeredEvent;
};

// Start Issue #135
// LWS: Equivalent to AkEventMapping but for sound cues.
struct SoundCueMapping
{
    var string strKey;
    var SoundCue Cue;
};

// LWS: Alias structure for mapping a standard sound event to an alternative.
struct SoundAlias
{
    var string strKey;
    var string strValue;
};
// End Issue #135

// Sound Mappings
var config array<string> SoundEventPaths;
var config array<AkEventMapping> SoundEvents;

// Start Issue #135
// LWS: Add a configurable sound event path mapping allowing mods
// to replace any standard sound path with a custom version.
var config array<SoundAlias> SoundAliases;

// LWS: Add sound-cue based sounds
var config array<string> SoundCuePaths;
var config array<SoundCueMapping> SoundCues;
// End Issue #135

struct AmbientChannel
{
	var SoundCue Cue;
	var AudioComponent Component;
	var bool bHasPlayRequestPending;
};

//------------------------------------------------------------------------------
// AmbientChannel Management
//------------------------------------------------------------------------------
protected function SetAmbientCue(out AmbientChannel Ambience, SoundCue NewCue)
{
	if (NewCue != Ambience.Cue)
	{
		if (Ambience.Component != none && Ambience.Component.IsPlaying())
		{
			Ambience.Component.FadeOut(0.5f, 0.0f);
			Ambience.Component = none;
		}

		Ambience.Cue = NewCue;
		Ambience.Component = CreateAudioComponent(NewCue, false, true);

		if (Ambience.bHasPlayRequestPending)
			StartAmbience(Ambience);
	}
}

protected function StartAmbience(out AmbientChannel Ambience, optional float FadeInTime=0.5f)
{
	if (Ambience.Cue == none)
	{
		Ambience.bHasPlayRequestPending = true;
		return;
	}

	if (Ambience.Cue != none && Ambience.Component != none && ( !Ambience.Component.IsPlaying() || Ambience.Component.IsFadingOut() ) )
	{
		Ambience.Component.bIsMusic = (Ambience.Cue.SoundClass == 'Music'); // Make sure the music flag is correct
		Ambience.Component.FadeIn(FadeInTime, 1.0f);
	}
}

protected function StopAmbience(out AmbientChannel Ambience, optional float FadeOutTime=1.0f)
{
	Ambience.bHasPlayRequestPending = false;

	if (Ambience.Component != none && Ambience.Component.IsPlaying())
	{
		Ambience.Component.FadeOut(FadeOutTime, 0.0f);
	}
}

//------------------------------------------------------------------------------
// Music management
//------------------------------------------------------------------------------
function PlayMusic( SoundCue NewMusicCue, optional float FadeInTime=0.0f )
{
	local MusicTrackStruct MusicTrack;

	MusicTrack.TheSoundCue = NewMusicCue;
	MusicTrack.FadeInTime = FadeInTime;
	MusicTrack.FadeOutTime = 1.0f;
	MusicTrack.FadeInVolumeLevel = 1.0f;
	MusicTrack.bAutoPlay = true;

	`log("XComSoundManager.PlayMusic: Starting" @ NewMusicCue,,'DevSound');

	WorldInfo.UpdateMusicTrack(MusicTrack);
}

function StopMusic(optional float FadeOutTime=1.0f)
{
	local MusicTrackStruct MusicTrack;

	`log("XComSoundManager.StopMusic: Stopping" @ WorldInfo.CurrentMusicTrack.TheSoundCue,,'DevSound');

	MusicTrack.TheSoundCue = none;

	WorldInfo.CurrentMusicTrack.FadeOutTime = FadeOutTime;
	WorldInfo.UpdateMusicTrack(MusicTrack);
}

//---------------------------------------------------------------------------------------
function PlaySoundEvent(string strKey)
{
	local int Index;

	// Start Issue #135
	// LWS: Look for a sound alias first.
	Index = SoundAliases.Find('strKey', strKey);
	if (Index >= 0)
			strKey = SoundAliases[Index].strValue;
	// End Issue #135

	Index = SoundEvents.Find('strKey', strKey);

	if(Index != INDEX_NONE)
	{
		WorldInfo.PlayAkEvent(SoundEvents[Index].TriggeredEvent);
	}
	// Start Issue #135
	else
	{
		Index = SoundCues.Find('strKey', strKey);
		if (Index != INDEX_NONE)
		{
			PlaySound(SoundCues[Index].Cue);
		}
	}
	// End Issue #135
}

//---------------------------------------------------------------------------------------
function Init()
{
	local int idx;
	local XComContentManager ContentMgr;

	ContentMgr = `CONTENT;

	// Load Events
	for( idx = 0; idx < SoundEventPaths.Length; idx++ )
	{
		ContentMgr.RequestObjectAsync(SoundEventPaths[idx], self, OnAkEventMappingLoaded);
	}

	// Start Issue #135
	// LWS: Load sound cues
	for (idx = 0; idx < SoundCuePaths.Length; idx++ )
	{
		ContentMgr.RequestObjectAsync(SoundCuePaths[idx], self, OnSoundCueMappingLoaded);
	}
	// End Issue #135
}

//---------------------------------------------------------------------------------------
function OnAkEventMappingLoaded(object LoadedArchetype)
{
	local AkEvent TempEvent;
	local AkEventMapping EventMapping;

	TempEvent = AkEvent(LoadedArchetype);
	if( TempEvent != none )
	{
		EventMapping.strKey = string(TempEvent.name);
		EventMapping.TriggeredEvent = TempEvent;

		SoundEvents.AddItem(EventMapping);
	}
}

// Start Issue #135
// LWS
function OnSoundCueMappingLoaded(object LoadedArchetype)
{
    local SoundCue TempCue;
    local SoundCueMapping CueMapping;

    TempCue = SoundCue(LoadedArchetype);
    if (TempCue != none)
    {
        CueMapping.strKey = string(TempCue.name);
        CueMapping.Cue = TempCue;
        SoundCues.AddItem(CueMapping);
    }
}
// End Issue #135

//---------------------------------------------------------------------------------------
