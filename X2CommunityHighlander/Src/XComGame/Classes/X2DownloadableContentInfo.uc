//---------------------------------------------------------------------------------------
//  FILE:    X2DownloadableContentInfo.uc
//  AUTHOR:  Ryan McFall
//           
//	Mods and DLC derive from this class to define their behavior with respect to 
//  certain in-game activities like loading a saved game. Should the DLC be installed
//  to a campaign that was already started?
//
// LWS :	Added hook to allow AlternateMissionIntroDefinition
//			Added hook to allow removal of weapon upgrades without replacement
//			Added hook to allow overriding if item can be equipped
//			Added hook to allow overriding number of utility slots
//			Added hook to allow overriding of targeting reticle
//          Added hook to allow toggling the display of flare/psi-gate on AI reinforcement.
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo extends Object	
	Config(Game)
	native(Core);

var config string DLCIdentifier; //The directory name that the DLC resides in
var config bool bHasOptionalNarrativeContent; // Does this DLC have optional narrative content, generates a checkbox in pre-campaign menu
var config array<string> AdditionalDLCResources;    // Resource paths for objects the game will load at startup and be synchronously accessible at runtime

var localized string PartContentLabel; // Label for use in the game play options menu allowing users to decide how this content pack is applied to new soldiers
var localized string PartContentSummary; // Tooltip for the part content slider

var localized string NarrativeContentLabel; // Label next to the checkbox in pre-campaign menu
var localized string NarrativeContentSummary; // Longer description of narrative content for pre-campaign menu

var localized string EnableContentLabel;
var localized string EnableContentSummary;
var localized string EnableContentAcceptLabel;
var localized string EnableContentCancelLabel;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{

}

/// <summary>
/// This method is run when the player loads a saved game directly into Strategy while this DLC is installed
/// </summary>
static event OnLoadedSavedGameToStrategy()
{

}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed. When a new campaign is started the initial state of the world
/// is contained in a strategy start state. Never add additional history frames inside of InstallNewCampaign, add new state objects to the start state
/// or directly modify start state objects
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{

}

/// <summary>
/// Called just before the player launches into a tactical a mission while this DLC / Mod is installed.
/// Allows dlcs/mods to modify the start state before launching into the mission
/// </summary>
static event OnPreMission(XComGameState StartGameState, XComGameState_MissionSite MissionState)
{

}

/// <summary>
/// Called when the player completes a mission while this DLC / Mod is installed.
/// </summary>
static event OnPostMission()
{

}

/// <summary>
/// Called when the player is doing a direct tactical->tactical mission transfer. Allows mods to modify the
/// start state of the new transfer mission if needed
/// </summary>
static event ModifyTacticalTransferStartState(XComGameState TransferStartState)
{

}

/// <summary>
/// Called after the player exits the post-mission sequence while this DLC / Mod is installed.
/// </summary>
static event OnExitPostMissionSequence()
{

}

/// <summary>
/// Called after the Templates have been created (but before they are validated) while this DLC / Mod is installed.
/// </summary>
static event OnPostTemplatesCreated()
{

}

/// <summary>
/// Called when the difficulty changes and this DLC is active
/// </summary>
static event OnDifficultyChanged()
{

}

/// <summary>
/// A dialogue popup used for players to confirm or deny whether new gameplay content should be installed for this DLC / Mod.
/// </summary>
static function EnableDLCContentPopup()
{
	local TDialogueBoxData kDialogData;

	kDialogData.eType = eDialog_Normal;
	kDialogData.strTitle = default.EnableContentLabel;
	kDialogData.strText = default.EnableContentSummary;
	kDialogData.strAccept = default.EnableContentAcceptLabel;
	kDialogData.strCancel = default.EnableContentCancelLabel;

	kDialogData.fnCallback = EnableDLCContentPopupCallback;
	`HQPRES.UIRaiseDialog(kDialogData);
}

simulated function EnableDLCContentPopupCallback(eUIAction eAction)
{

}

/// <summary>
/// Called when viewing mission blades with the Shadow Chamber panel, used primarily to modify tactical tags for spawning
/// Returns true when the mission's spawning info needs to be updated
/// </summary>
static function bool UpdateShadowChamberMissionInfo(StateObjectReference MissionRef)
{
	return false;
}

/// <summary>
/// Called from X2AbilityTag:ExpandHandler after processing the base game tags. Return true (and fill OutString correctly)
/// to indicate the tag has been expanded properly and no further processing is needed.
/// </summary>
static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
	return false;
}
/// <summary>
/// Called from XComGameState_Unit:GatherUnitAbilitiesForInit after the game has built what it believes is the full list of
/// abilities for the unit based on character, class, equipment, et cetera. You can add or remove abilities in SetupData.
/// </summary>
static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{

}

/////////////////////////////////
///////// LWS ADDITIONS /////////
/////////////////////////////////


/// Start Issue #106
/// <summary>
/// Called from XComGameState_Unit::ModifyEarnedSoldierAbilities
/// Allows DLC/Mods to adjust add to the EarnedSoldierAbilities
/// no return, just modify the EarnedAbilities out variable array
static function ModifyEarnedSoldierAbilities(out array<SoldierClassAbilityType> EarnedAbilities, XComGameState_Unit UnitState)
{
    
}
/// End Issue #106

/// Start Issue #140
/// <summary>
/// Called from XComTacticalMissionManager:GetActiveMissionIntroDefinition before it returns the Default (but after any arrMission-specific override)
//  Return true to use 
/// </summary>
static function bool UseAlternateMissionIntroDefinition(MissionDefinition ActiveMission, out MissionIntroDefinition MissionIntro)
{
	return false;
}
/// End Issue #140

/// Start Issue #88
/// <summary>
/// Called from UIArmory_WeaponUpgradeItem:UpdateDropItemButton 
//  Return true to allow removal of the weapon upgrade without replacement 
/// </summary>
static function bool CanRemoveWeaponUpgrade(XComGameState_Item Weapon, X2WeaponUpgradeTemplate UpgradeTemplate, int SlotIndex)
{
	return false;
}
/// End Issue #88

/// Start Issue #124
/// <summary>
/// Called from XComGameState_Unit:CanAddItemToInventory 
//  Return true to override the default with the out parameter
/// </summary>
static function bool CanAddItemToInventory(out int bCanAddItem, const EInventorySlot Slot, const X2ItemTemplate ItemTemplate, int Quantity, XComGameState_Unit UnitState, XComGameState CheckGameState)
{
	return false;
}
/// End Issue #124

/// Start Issue #118
/// <summary>
/// Called from XComGameState_Unit:DLCCanRemoveItemFromInventory 
//  Return true to override the default with the out parameter
//	Used only in XComGameState_Unit:MakeItemAvailable
/// </summary>
static function bool CanRemoveItemFromInventory(out int bCanRemoveItem,  XComGameState_Item Item, XComGameState_Unit UnitState, XComGameState CheckGameState)
{
	return false;
}
/// End Issue #118

/// Start Issue #114
/// <summary>
/// Called from XComGameState_Unit:GetNumUtilitySlots 
//  Return true to immediately override the default with the out parameter (skipping any further DLCInfo checks)
/// </summary> 
static function bool GetNumUtilitySlotsOverride(out int NumSlots, XComGameState_Item Item, XComGameState_Unit UnitState, XComGameState CheckGameState)
{
	return false;
}
/// End Issue #114

/// Start Issue #115
/// <summary>
/// Called from XComGameState_Unit:ValidateLoadout
//  Allows DLC/Mods to override the minimum number of utility slots to be set during validate loadout
// modify the out parameter Value to make change
/// </summary> 
static function GetMinimumRequiredUtilityItems(out int Value, XComGameState_Unit UnitState, XComGameState NewGameState);
/// End Issue #115

/// Start Issue #60
/// <summary>
/// Called from XComGameState_Ability:GetUIReticleIndex 
//  Return true to immediately override the default with the out parameter (skipping any further DLCInfo checks)
/// </summary> 
static function bool SelectTargetingReticle(out int ReturnReticleIndex, XComGameState_Ability Ability, X2AbilityTemplate AbilityTemplate, XComGameState_Item Weapon)
{
	return false;
}
/// End Issue #60

/// Start Issue #77
/// <summary>
/// Called from XComGameState_HeadquartersAlien:GetCurrentDoom 
//  Return true to immediately override the default with the out parameter (skipping any further DLCInfo checks)
/// </summary> 
static function int AddDoomModifier(XComGameState_HeadquartersAlien AlienHQ, bool bIgnorePending)
{
	return 0;
}
/// End Issue #77

/// Start Issue #68
/// <summary>
/// Called from XComGameState_MissionSite:CacheSelectedMissionData
//  Encounter Data is modified immediately prior to being added to the SelectedMissionData
/// </summary> 
static function PostEncounterCreation(out name EncounterName, out PodSpawnInfo Encounter, int ForceLevel, int AlertLevel, optional XComGameState_BaseObject SourceObject);
/// End Issue #68

/// Start Issue #104
/// <summary>
/// Called from XComGroupSpawn:GetValidFloorLocations
//  Allows DLC/Mods to override valid spawnable floor locations -- return true use FloorPoints and skip the defaults
/// </summary> 
static function bool GetValidFloorSpawnLocations(out array<Vector> FloorPoints, XComGroupSpawn SpawnPoint)
{
	return false;
}
/// End Issue #104

/// Start Issue #31
/// <summary>
/// Called from X2TacticalGameRuleset:state'CreateTacticalGame':UpdateTransitionMap
//  Allows DLC/Mods to override the transition map used for loading screens pre/post tactical missions
// return true if soldiers should be equipped with inventory items
/// </summary> 
static function bool LoadingScreenOverrideTransitionMap(optional out string OverrideMapName, optional X2TacticalGameRuleset Ruleset, optional XComGameState_Unit UnitState)
{
	return false;
}
/// End Issue #31

/// Start Issue #134
/// <summary>
/// Called from XComParcelManager:ChooseSoldierSpawn
//  Allows DLC/Mods to override the soldier spawn point selection logic
// return the selected spawn point, or none to use default logic
/// </summary> 
static function XComGroupSpawn OverrideSoldierSpawn(vector ObjectiveLocation, array<XComGroupSpawn> arrSpawns)
{
	return none;
}
/// End Issue #134

/// Start Issue #142
/// <summary>
/// Called from XComTacticalMissionManager:SelectObjectiveSpawns
//  Allows DLC/Mods to override the the number of objective spawns in a mission
// return -1 to use default logic for selecting number, of value >= 0 to use that value
/// </summary> 
static function int GetNumObjectivesToSpawn(XComGameState_BattleData BattleData)
{
	return -1;
}
/// End Issue #142

/// Start Issue #69
/// <summary>
/// Called from XComGameState_AIReinforcementSpawner::BuildVisualizationForSpawnerCreation.
/// Allows DLC/Mods to disable the visualization of the reinforcement flare/psi-gate indicator.
/// Return 'true' to disable the visualization. If any callee returns true, the visualization
/// will be disabled.
static function bool DisableAIReinforcementFlare(XComGameState_AIReinforcementSpawner SpawnerState)
{
    return false;
}
/// End Issue #69

/// Start Issue #54
/// <summary>
/// Called from XComGameState_Destructible::OverrideDestructibleInitialHealth. (new helper)
/// Allows DLC/Mods to override the initial health of destructible objects
/// Return true to override the existing health, returning new value in the out NewHealth
/// will be disabled.
static function bool OverrideDestructibleInitialHealth(out int NewHealth, XComGameState_Destructible DestructibleState, XComDestructibleActor Visualizer)
{
    return false;
}
/// End Issue #54

/// Start Issue #136
/// <summary>
///
/// Called from XComTacticalController::DrawDebugLabels.
/// Allows mods to draw debug information to the screen.
function DrawDebugLabel(Canvas kCanvas)
{
}
/// End Issue #136

/// Start Issue #180
/// <summary>
/// Called from UIShellDifficulty::DLCDisableTutorial. (new helper)
/// Allows DLC/Mods to disable the tutorial (similar to how difficulty does in base game)
/// Return true to disable tutorial from being active
/// will be disabled.
static function bool DLCDisableTutorial(UIShellDifficulty Screen)
{
    return false;
}
/// End Issue #180

/// Start Issue #126
/// <summary>
/// Called from XComGameState_Unit::OnAbilityActivated
/// Allows DLC/Mods to modify the sound range of abilities. Only called for abilities that make sound.
/// Return an additive modifier to the sound range. 
static function int ModifySoundRange(XComGameState_Unit SourceUnit, XComGameState_Item Weapon, XComGameState_Ability Ability, XComGameState GameState)
{
    return 0;
}
/// End Issue #126

/// Start Issue #137
/// <summary>
/// Called from XComTacticalController::Visualizer_SelectNextUnit and XComTacticalController::Visualizer_SelectPrevUnit.
/// Allows DLC/Mods to sort the array of units for tab order purposes.
/// The Units array should be sorted in-place. This should be a stable sort to reduce the risk of tab order changing as you
/// tab. 
static function SortTabOrder(out array<XComGameState_Unit> Units, XComGameState_Unit CurrentUnit, bool TabbingForward)
{
}
/// End Issue #137

/// Start Issue #132
/// <summary>
/// Called from XComUnitPawn::CreateDefaultAttachments
/// Allows DLC/Mods to append sockets to an existing pawn type
/// return the string name of a SkeletalMesh component whose sockets will be appended to the calling pawn
static function string DLCAppendSockets(XComUnitPawn Pawn)
{
	return "";
}
/// End Issue #132

/// Start Issue #83
/// <summary>
/// Called from XComGameState_HeadquartersXCom::GetScienceScore
/// Allows DLC/Mods to adjust the science score
/// return the value by which to modify the science score, or 0 for no effect. The bAddLabBonus value is 'true' if
// we are computing the science research rate, and 'false' if we're checking a science gate.
static function int GetScienceScoreMod(bool bAddLabBonus)
{
    return 0;
}
/// End Issue #83

/// Start Issue #64
/// <summary>
/// Called from XComGameState_Ability::GetItemEnvironmentDamagePreview
/// Allows DLC/Mods to dynamically adjust environment damage for an item
/// Return the environment damage as a non-negative value to override
static function int OverrideItemEnvironmentDamagePreview(XComGameState_Ability AbilityState)
{
    return -1;
}
/// End Issue #64

/// Start Issue #23
/// <summary>
/// Called from X2Effect_ApplyFireToWorld::AddWorldEffectTickEvents
/// Allows DLC/Mods to override the world fire environment damage effects of fire
/// Return true to override the base effect (which destroys all indestructible actors, ignoring toughness)
static function bool OverrideWorldFireTickEvent(X2Effect_ApplyFireToWorld Effect, XComGameState_WorldEffectTileData TickingWorldEffect, XComGameState NewGameState)
{
    return false;
}
/// End Issue #23

/// Start Issue #230
/// <summary>
/// Called from XComGameState_HeadquartersAlien::AddDoomToFortress
/// Allows DLC/Mods to override the doom addition behavior.
/// Return the amount of doom this mod has processed.
static function int AddDoomToFortress(XComGameState_HeadquartersAlien AlienHQ, XComGameState NewGameState, int DoomToAdd, String DoomMessage, bool bCreatePendingDoom)
{
	return 0;
}

/// <summary>
/// Called from XComGameState_HeadquartersAlien::RemoveDoomFromFortress
/// Allows DLC/Mods to override the doom removal behavior.
/// Return the amount of doom this mod has processed.
static function int RemoveDoomFromFortress(XComGameState_HeadquartersAlien AlienHQ, XComGameState NewGameState, int DoomToRemove, String DoomMessage, bool bCreatePendingDoom)
{
	return 0;
}
/// End Issue #230

/// Start Issue #271
/// <summary>
/// Called from XComUnitPawn:UpdateAnimations 
/// CustomAnimSets will be added to the pawns animsets
/// </summary>
static function UpdateAnimations(out array<AnimSet> CustomAnimSets, XComGameState_Unit UnitState, XComUnitPawn Pawn)
{

}
/// End Issue #271