//---------------------------------------------------------------------------------------
//  FILE:    Helpers_LW
//  AUTHOR:  tracktwo / Pavonis Interactive
//
//  PURPOSE: Extra helper functions/data. Cannot add new data to native classes (e.g. Helpers)
//           so we need a new one.
//--------------------------------------------------------------------------------------- 

class Helpers_LW extends Object config(GameCore) dependson(Engine);

struct ProjectileSoundMapping
{
	var string ProjectileName;
	var string FireSoundPath;
	var string DeathSoundPath;
};

// Issue #26
// The list of mission types to enable the radius manager to display rescue rings.
var config const array<string> RadiusManagerMissionTypes;       

// Issue #125
// If true, enable the yellow alert movement system.
var config const bool EnableYellowAlert;

// Issue #75
// If true, hide havens on the geoscape
var config const bool HideHavens;

// Variable for Issue #52
// If true, encounter zones will not be updated based XCOM's current position.
var config bool DisableDynamicEncounterZones;

// Start Issue #53
var config bool EnableAvengerCameraSpeedControl;
var config float AvengerCameraSpeedControlModifier;
// End Issue #53

// The radius (in meters) for which a civilian noise alert can be heard.
var config int NoiseAlertSoundRange;

// Start Issue #147
// Enable/disable the use of the 'Yell' ability before every civilian BT evaluation. Enabled by default.
var config bool EnableCivilianYellOnPreMove;
// End Issue #147

// Start Issue #122
// If this flag is set, units in yellow alert will not peek around cover to determine LoS - similar to green units.
// This is useful when yellow alert is enabled because you can be in a situation where a soldier is only a single tile
// out of LoS from a green unit, and that neighboring tile that they would have LoS from is the tile they will use to
// peek. The unit will appear to be out of LoS of any unit, but any action that alerts that nearby pod will suddenly
// bring you into LoS and activate the pod when it begins peeking. Examples are a nearby out-of-los pod activating when you
// shoot at another pod you can see from concealment, or a nearby pod activating despite no aliens being in LoS when you 
// break concealment by hacking an objective (which alerts all pods).
var config bool NoPeekInYellowAlert;
// End Issue #122

// Start Issue #128
// this int controls how low the deployable soldier count has to get in order to trigger the low manpower warning
// if it is not set (at 0), then the game will default to GetMaxSoldiersAllowedOnMission
var config int LowStrengthTriggerCount;
// End Issue #128

// Start Issue #24
// these variables control various world effects, to prevent additional voxel check that can cause mismatch between preview and effect
var config bool bWorldPoisonShouldDisableExtraLOSCheck;
var config bool bWorldSmokeShouldDisableExtraLOSCheck;
var config bool bWorldSmokeGrenadeShouldDisableExtraLOSCheck;
// End Issue #24

// Start Issue #48
// This is to double check in grenade targeting that the affected unit is actually in a tile that will get the world effect, not just that it is occupying such a tile.
// This can occur because tiles are only 1 meter high, so many unit occupy multiple vertical tiles, but only really count as occupying the one at their feet in other places.
var config array<name> GrenadeRequiresWorldEffectToAffectUnit;
// End Issue #48

// Returns 'true' if the given mission type should enable the radius manager (e.g. the thingy
// that controls rescue rings on civvies). This is done through a config var that lists the 
// desired mission types for extensibility.

// Start Issue #176
var config bool EnableRestartMissionButtonInNonIronman;
var config bool EnableRestartMissionButtonInIronman;
// End Issue #176

// Start Issue #49
// A list of replacement projectile sound effects mapping a projectile element to a sound cue name.
// The 'ProjectileName' must be of the form ProjectileName_Index where ProjectileName is the name of the
// projectile archetype, and Index is the index into the projectile array for the element that should have
// the sound associated with it. e.g. "PJ_Shotgun_CV_15" to set index 15 in the conventional shotgun (the
// one with the fire sound). Note that the index counts individual projectile elements, and may not exactly
// match what is present in the editor. For example, the conventional shotgun has only two elements in the array,
// but the first one is a volley of 15 projectiles. So the sound attached to index 1 in the array is
// actually index 15 at runtime.
//
// The fire or death sound is the name of a sound cue loaded into the sound manager system. See the SoundCuePaths
// array in XComSoundManager.
var config array<ProjectileSoundMapping> ProjectileSounds;
// End Issue #49

// Start Issue #197
//This is referenced in XCGS_Unit and must be true to run some code that ensures a powerful psi ability can be trained
var config bool EnablePsiTreeOrganization;
// End Issue #197

// Start Issue #130
//allow certain classes to be overridden recursively, so the override can be overridden
var config array<ModClassOverrideEntry> UIDynamicClassOverrides;

simulated static function class<object> LWCheckForRecursiveOverride(class<object> ClassToCheck)
{
	local int idx;
	local class<object> CurrentBestClass, TestClass;
	local bool NeedsCheck;
	local name BestClassName;

	BestClassName = name(string(ClassToCheck)); 
	CurrentBestClass = ClassToCheck;
	NeedsCheck = true;

	while (NeedsCheck)
	{
		NeedsCheck = false;
		idx = class'Helpers_LW'.default.UIDynamicClassOverrides.Find('BaseGameClass', BestClassName);
		if (idx != -1)
		{
			TestClass = class<object>(DynamicLoadObject(string(class'Helpers_LW'.default.UIDynamicClassOverrides[idx].ModClass), class'Class'));
			if (TestClass != none) // && TestClass.IsA(BestClassName))
			{
				BestClassName = name(string(TestClass));
				CurrentBestClass = TestClass;
				NeedsCheck = true;
			}
		}
	}
	`LOG("LWCheckForRecursiveOverride : Overrode " $ string(ClassToCheck) $ " to " $ CurrentBestClass);
	return CurrentBestClass;
}
// End Issue #130

// Start Issue #26 - allow radius manager to be usable on more than just 'Terror' missions
static function bool ShouldUseRadiusManagerForMission(String MissionName)
{
    return default.RadiusManagerMissionTypes.Find(MissionName) >= 0;
}
// End Issue #26

// Start Issue #125
static function bool YellowAlertEnabled()
{
    return default.EnableYellowAlert;
}
// End Issue #125

// Start Issue #52
// Disable the line of play based on local config
static function bool DynamicEncounterZonesDisabled()
{
	return default.DisableDynamicEncounterZones;
}
// End Issue #52

// Dependant Issues - Issue #21 (configurable sound range for DoNoiseAlert)
// Copied from XComGameState_Unit::GetEnemiesInRange, except will retrieve all units on the alien team within
// the specified range.
static function GetAlienUnitsInRange(TTile kLocation, int nMeters, out array<StateObjectReference> OutEnemies)
{
	local vector vCenter, vLoc;
	local float fDistSq;
	local XComGameState_Unit kUnit;
	local XComGameStateHistory History;
	local float AudioDistanceRadius, UnitHearingRadius, RadiiSumSquared;

	History = `XCOMHISTORY;
	vCenter = `XWORLD.GetPositionFromTileCoordinates(kLocation);
	AudioDistanceRadius = `METERSTOUNITS(nMeters);
	fDistSq = Square(AudioDistanceRadius);

	foreach History.IterateByClassType(class'XComGameState_Unit', kUnit)
	{
		if( kUnit.GetTeam() == eTeam_Alien && kUnit.IsAlive() )
		{
			vLoc = `XWORLD.GetPositionFromTileCoordinates(kUnit.TileLocation);
			UnitHearingRadius = kUnit.GetCurrentStat(eStat_HearingRadius);

			RadiiSumSquared = fDistSq;
			if( UnitHearingRadius != 0 )
			{
				RadiiSumSquared = Square(AudioDistanceRadius + UnitHearingRadius);
			}

			if( VSizeSq(vLoc - vCenter) < RadiiSumSquared )
			{
				OutEnemies.AddItem(kUnit.GetReference());
			}
		}
	}
}


// Start Issue #49
// Used by hooks added to X2UnifiedProjectile
function static SoundCue FindFireSound(String ObjectArchetypeName, int Index)
{
	local String strKey;
	local int SoundIdx;
	local XComSoundManager SoundMgr;

	strKey = ObjectArchetypeName $ "_" $ String(Index);

	SoundIdx = default.ProjectileSounds.Find('ProjectileName', strKey);
	if (SoundIdx >= 0 && default.ProjectileSounds[SoundIdx].FireSoundPath != "")
	{
		SoundMgr = `SOUNDMGR;
		SoundIdx = SoundMgr.SoundCues.Find('strKey', default.ProjectileSounds[SoundIdx].FireSoundPath);
		if (SoundIdx >= 0)
		{
			return SoundMgr.SoundCues[SoundIdx].Cue;
		}
	}

	return none;
}

function static SoundCue FindDeathSound(String ObjectArchetypeName, int Index)
{
	local string strKey;
	local int SoundIdx;
	local XComSoundManager SoundMgr;

	strKey = ObjectArchetypeName $ "_" $ String(Index);

	SoundIdx = default.ProjectileSounds.Find('ProjectileName', strKey);
	if (SoundIdx >= 0 && default.ProjectileSounds[SoundIdx].DeathSoundPath != "")
	{
		SoundMgr = `SOUNDMGR;
		SoundIdx = SoundMgr.SoundCues.Find('strKey', default.ProjectileSounds[SoundIdx].DeathSoundPath);
		if (SoundIdx >= 0)
		{
			return SoundMgr.SoundCues[SoundIdx].Cue;
		}
	}

	return none;
}
// End Issue #49
