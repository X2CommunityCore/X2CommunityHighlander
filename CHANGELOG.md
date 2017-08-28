# Change Log
All notable changes to Vanilla Behaviour will be documented in this file.



## Strategy

### Mod/DLC Hooks
- 'CanRemoveItemFromInventory': override ability to unequip item (#118)
- 'GetScienceScoreMod': adjust the science score (#83)
- 'CanRemoveWeaponUpgrade': true allows removal of upgrade without replace (#88)
- 'ModifyEarnedSoldierAbilities': change the list of abilities (#106)
- 'GetNumUtilitySlotsOverride': override a unit's utility slots (#114)
- 'GetMinimumRequiredUtilityItems': override a unit's minimum utility slots
  (#114)
- 'AddDoomToFortress': override adding doom to fortress (#230)
- 'RemoveDoomToFortress': override adding doom to fortress (#230)

### Event Hooks
- 'OverrideBlackMarketGoods': customise goods for sale (#71)
- 'PostPsiProjectCompleted': after psi training completes (#78)
- 'SoldierRespecced': allow alteration of project points for respec (#79)
- 'HasAvailablePerksToAssign': allow override of XGCS_Unit method (#33)
- 'PreEndOfMonth': allow mods to process before vanilla processing (#81)
- 'OnClosedMonthlyReportAlert': allow mod processing after month report (#179)
- 'OnMonthlySuppliesReward': override supply reward (#82)
- 'OnMonthlyNegativeSupplies': override supply penalties (#82)
- 'GetSupplyDropDecreaseStrings': override supply display (#82)
- 'OverrideItemCanBeUnequipped': override whether an item is locked (#89)
- 'MissionSite_OverrideLaunchTacticalBattle': override the entire process of
  starting a tactical battle (#93)
- 'MissionSite_GetUIClass': offer a replacement class for Mission Site (#94)
- 'PostUFOSetInterceptionTime': override interception time afterwards (#99)
- 'OnDistributeTacticalGameEndXP': modify distribution of XP post mission (#100)
- 'PreRollForAWCAbility': override RollForAWCAbility (#105)
- 'OnMissionSelectedUI': call new UI for alternate mission sources (#131)
- 'OnDismissSoldier': when unit is dismissed (#165)
- 'OnSoldierListItemUpdateDisabled': enable or modify disabled slot on
  SquadSelect UI (#177)
- 'OnRecruitmentListItemInit': alter recruit list item UI on init (#178)
- 'OnRecruitmentListItemUpdateFocus': alter recruit list item UI on focus (#178)
- 'OnInsertFirstMissionIcon': override resistanceHQ icon (#182)
- 'OverridePersonnelStatusSeparate': override personnel strategy state (#192)
- 'ArmoryLoadout_PostUpdateNavHelp': after loadout nav help updates (#195)
- 'WeaponUpgradeListChanged': listener for altering the nav help on
  UIArmory_WeaponUpgrade (#236)
- 'OverrideInitialPsiTraining': override initial psi training cost (#255)

### Modding Exposures
- remove private from XGCS_BlackMarket.OnUnitHeadCaptureFinished (#72)
- remove private from XGCS_Unit.GetCompleteDefaultLoadout (#117)
- SignalOnReceiveFocus when switching from pending to active dark events on
  UIAdventOperations (#156)
- when checking for utility items skip over AmmoPocket (#241)
- Allow mods to add items UIAvengerShortcuts (#166)
- Support overrides of UISquadSelect by ensuring dependants look for
  subclasses too (#196)
- Support overrides of UIArmory_MainMenu by ensuring dependants look for
  subclasses too (#169)

### Configuration
- allow havens to be hidden on the geoscape (#75)
- Allow modification of AvengerCameraSpeed (#53)
- Allow config of CrosssContinentStartRegionLinks, will prevent removal of non
  continent links if used (#85)
- hide income on BuildOutpost alert (#158)
- override PCSRemovalContinentBonus (#170)
- Optimise and add configurable Doom display, with greater maximums (#184)
- allow config of extra Squad Select auto remove functionality (#240)
- Add PsiTreeOrganisation, to force a capstone ability early to ensure it is
  achievable (#197)
- allow config override of BlackMarket 'Interested' multipliers (#254)

### Improvements
- Prevent Secondary Weapons contributing to stat markups on Loadout/Stats
  screen for soldiers (#51)
- Add parameter to include unavailable missions when getting current doom (#76)
- Add GetDisplayName for ProjectTrainRookie for the Event Log (#80)
- Deduplicate completed research techs so they can't spam Research Log (#84)
- Exclude deployed soldiers from `XCOMHQ.GetSoldiers method (#86)
- Prevent cycling of deployed soldiers in ArmoryUI (#160)
- Prevent Loadout Strip on ArmoryUI page storing old items so it behaves just
  like when used on SquadSelect, and also skip over deployed soldiers when
  stripping (#161)
- Deduct soldiers on mission when checking for MissionSiteAvengerDefense's
  automatic loss condition (#95)
- Alter WorldRegion.HandleResistanceLevelChange tto only trigger Contact Made
  event if changing up to Contact status, not down (#101)
- Allow infinite equipment items to be considered when getting 'best' utility
  item (#116)
- Add UtilitySlot Pistol to unit pawn during loadout process if equipped (#143)
- Add UI support for PCSs which augment dodge (#172)
- Support Multiple VIP rewards in loot recovered view (#173)
- GPIntelOptions now functions properly when a mission is locked (#174)
- Always show DarkEvents toggle on UIAdventOperations (#155)
- Remove hardcoded false to Unit.IsPsiOperative for AfterAction_ListItem (#157)
- Sort UIInventory_Implants partially by name so order is predictable (#234)
- Sort UIBlackMarket_Sell partially by name so order is predictable (#238)

### Fixes
- log spam fix in UITacticalHUD (#186)
- clamp max doom removal to the total current doom, not just the Fortress doom
  (#247)
- avoid recursion of GetMapItem and GetRandomLocationInRegion (#183)
- Bugfix for Insight Hack Reward, where project completion only applies on
  a staffing change, rather than when reward is applied (#38)
- Controller/Keyboard usage works with UISkyrangerArrives (#181)
- Fix displayed count of Primary Weapons on LoadoutItem (#162)
- Controller Fixes on Strategy UI (#87) (#129)
- Fix bug where XGCS_PointOfInterest weight could drop to zero, rendering it
  unselectable (#98)
- Fix bug in UIInventory_Implants where PCSs disappear (#233)
- Fix bug in UIArmory_WeaponUpgrade where select nav help would fail to refresh
  (#237)







## Tactical

### Mod/DLC Hooks
- 'OverrideWorldFireTickEvent': override base effect of Fire Damage. (#23)
- 'GetNumObjectivesToSpawn': override objective count on mission (#142)
- 'UseAlternateMissionIntroDefinition': override default mission intro
  definition for mission (#140)
- 'LoadingScreenOverrideTransitionMap': override transition pre/post tactical
  missions (#31)
- 'SelectTargetingReticle': override targeting reticle for an ability (#60)
- 'OverrideItemEnvironmentDamagePreview': dynamic adjustment of environment
  damage for an item/ability (#64)
- 'PostEncounterCreation': for altering EncounterName & PodSpawnInfo (#68)
- 'DisableAIReinforcementFlare': override showing flare (#69)
- 'GetValidFloorSpawnLocations': override spawn locations (#104)
- 'OverrideSoldierSpawn': override spawn point for a soldier (#134)
- 'ModifySoundRange': alter sound range based on unit/weapon/ability (#126)
- 'DrawDebugLabel': draw debug info on screen (#136)
- 'SortTabOrder': alter tab order of XCOM Units (#137)

### Event Hooks
- 'AlterMissionConcealStatus': override mission start concealment (#226)
- 'GetCameraRotationAngle': override camera behavior (#138)
- 'GetNumCiviliansKilled': used by UIMissionSummary (#6)
- 'GetNumEnemiesKilled': used by UIMissionSummary (#206)
- 'GetNumSoldiersKilled': used by UIMissionSummary (#206)
- 'GetNumSoldiersInjured': used by UIMissionSummary (#206)
- 'OnFinalizeHitChance': used by X2AbilityToHitCalc (#14)
- 'CleanupTacticalMisssion': fire at misssion end (#29)
- 'PreAcquiredHackReward': for overriding Hack Rewards (#39)
- 'OverrideBleedoutChange': for altering bleedout change (#45)
- 'ProcessReflexMove': do extra work before scamper triggers (#65)
- 'ShouldMoveToIntercept': override patrol to direct pod elsewhere (#66)
- 'IsCauseAllowedForNonvisibleUnits': override result in AIUnitData (#70)
- 'OnGetItemRange': override an item's range (#90)
- 'KilledByExplosion': notify mods when unit killed by explosion (#110)
- 'ShouldShowPromoteIcon': override showing the promote icon (#120)
- 'GetRewardVIPStatus': add support for multiple VIP rewards, determining their
  status through this event call (default rescued if mission completed) (#92)
- 'GetNumKillForRankUpSoldier': alter number of effective kills required for
  a rank up (#119)
- 'ShouldUnitPatrolUnderway': override result of XGAIPlayer.ShouldUnitPatrol
  (#151)
- 'OverrideObjectiveAbilityIconColor': override objective ability color (#187)
- 'OverrideAbilityIconColor': override non objective ability color (#187)
- 'IgnoreReinforcementsAlert': used by XComGameState_AIReinforcementSpawner
  (#251)
- 'OnSetUnitAlert': used to override a unit's alert level on mission start
  (#256)

### Configuration
- Configure poison, smoke and smoke grenades to regard/disregard cover when
  choosing tiles to affect (#24)
- Allow determination of missions that need RadiusManager (ring around civs) to
  use configuration rather than hardcode 'Terror' (#26)
- Configurable list of missions that use CivilianRescue display (#175)
- Bronzeman Style restart for Pause Menu (#176)
- Configure smoke cancelling flank crit bonus - default off (#36)
- Projectile Sound mappings to override fire and death sounds (#49)
- Disable peeking in LoS calculations for Yellow Alert Units (#122)
- Civilian 'Yell' ability in AI (#147)
- Allow usage of HeavyWeapon inventory slot for soldier class (#42)
- Optionally apply rupture damage cumulatively (#228)
- Optionally clamp graze damage to 1 (#229)
- allow overrides of evac animations for specific character templates (#243)
- Add config to disable test that hides Radius Rings when cursor is near Unit
  (#249)
- Add config for reinforcement patrol zones when not in scamper/red alert (#252)
- Add config for AI behaviour regarding AOE Targeting and Visibility (#260)
- Add config for Ever Vigilant being excluded when unit burning or impaired
  (#276)

### Modding Exposures
- Remove const from plot and parcel definition arrays (#199)
- Change Hazard, Noise & Concealment Markers to protectedwrite on
  XComPathingPawn (#259)
- Remove protections of AbilityTemplate Effects for easier runtime alteration
  (#12)
- Remove private of EventLabel on AnimNotify_CinescriptEvent (#262)
- Remove protection of ShotBreakdown on X2AbilityToHitCalc (#13)
- Remove protection of Behaviors on X2AIBTBehaviorTree (#13)
- Remove protection of LootTables on X2LootTable (#41)
- Remove private from vars on X2TargetingMethod_EvacZone (#46)
- add delegate for reinforcement countdown that allows mods to override the
  reinforcement display (#239)
- allow subclassses of X2Effect_Suppression to be counted as suppressor (#121)
- Created LWVisualisedInterface to allow for same visualisations as
  X2VisualisedInterface without needing native class (#103)
- Remove protection of LootMarkerMesh for LootDropActor (#133)
- Remove const and private declarations from XComTacticalMissionManager (#139)
- Create XCGS_Unit.UnitAGainsKnowledgeOfUnitB with extra argument to allow for
  provision of an AlertTile (#198)
- Move CameraAction for X2Effect_MindControl and into the OnRemovedFn so mods
  can decide on the visualization (#246)
- Move contents of FinalizeHackAbility_BuildGameState into a static helper
  function so it can be called from other hack abilities. (#282)

### Improvements
- Flying Enemies path searching improved to use unlimited search depth on
  movement. (#5)
- Modify X2Effect Target Condition to be consistent with how X2AbilityTemplate
  does it (#209)
- Prevent grenades affectting units not in the tiles getting the world effect
  (for flying enemies) (#48)
- Prevent SpawnUnitFromAvenger using units with eStatus_OnMission (#7)
- Prevent ATT loading more than 4 units in animation to prevent TPose, allows
  for larger reinforcement pods (#15)
- Add Configurable sound range to DoNoiseAlert AI behavior (#21)
- Scampering units afflicted with fire/poison/etc given temporary immunity to
  allow their AI to path out of the danger rather than stand still (#22)
- Add mechanism for reapplication of PersistentStatChangeEffect, so
  disorientation cancels overwatch even if Effect in place already (#25)
- Prevent Civilians fleeing ADVENT if not being fired upon (#28)
- Add configurable Shred value to weapons via X2Effect_Shredder (#35)
- Prevent Overfilling Dropship Matinee (#16)
- Allow ItemTemplate to actually use GetItemUnknownUtilityCategory (#40)
- Add flexibility to EverVigilant TurnEnd Listener, with respects to primary and
  secondary weapons (#61)
- GatherAbilityTargets in Ability GameState made non native to allow for
  MultiTargetStyle abilities (#63)
- Add MultiTargetEffects check to DoesAbilityCauseSound Handler (#62)
- Copy bRemovedFromPlay settings to original units to make it easier to check
  which units escaped the tactical battlefield (#102)
- Improve AI Handling of hit chances by differentiating between terrible shot
  chances and not actually having targets (#145)
- Don't skip a group's turn if one unit skips its' turn and then is unrevealed,
  we may need to award reflex actions - LW (#146)
- Alter test gathering units to move for AI, so units that still have APs but
  have moved aren't excluded (#152)
- Sort UnitsToMove by AIJob rather than just order of list addition (#153)
- Allow Green Patrol style movement for pods in YellowAlert so they can go to
  a specified destination (#148)
- Track LastResortUnits but keep them in the target list, scored differently, so
  the AI doesn't take very bad moves to reach far away non-LastResort targets
  (#150)
- Improve SoldierInfoTooltip, show defense + hide psi if not psiop (#189)
- Empty out pending loot for units killed by explosives (#112)
- Visualization Fixes for Hacking to accomodate effect addition/removal better
  than vanilla does (#242)
- Fix rescued soldier VIPs becoming wounded because the VIP proxy unit had less
  max HP than actual soldier. (#277)
- Show Defense stat on UISoldierHeader, hiding hack stat for PsiOps to prevent
  overflow. (#280)
- Alter Tactical Interrupt Handling for Movement. (#284)
- Improve handling of event ticking when units change team. (#286)

### Fixes
- Fix for Restart Mission (#227)
- Fix X2Condition_BeserkerDevastatingPunch allowing friendly targets when not
  enraged (#245)
- Fix X2Action_ExitCover breaking step back location when called while already
  out of cover, resulting in unit reentering wrong tile on EnterCover (#244)
- Remove exploit causing enemy units to enter RedAlert without scamper (#123)
- Validate and reject EvacZones that are partially out of bounds (#264)
- Fix XCGS_LootDrop when multiple drops active (#91)
- Ensure Patrol Locations are within map bounds to ensure they are set (#67)
- Fix Acid & Burn Effect disappearing when the source of the effect dies (#44)
- Fix Bound Effect not unapplying at end of mission (#43)
- Fix issue where unit death from bleeding out would be marked as Friendly Fire
  (#111)
- Fix bug where unit stun penalty persists til next mission (#37)
- RevivalProtocol now cures 'StunnedEffect' (#9)
- Bleeding Out units that are recovered are cleaned up properly (#30)
- GameplayVisibilityCondition fix for ChainShot & RapidShot (#10)
- Fix rare movement bug that could cause teleporting of a unit within a pod
  (#11)
- Ensure 'UnitTakeEffectDamage' only triggers if Damage > 0 (#109)
- Ensure wound times are correct for when unit starts bleeding out (#108)
- Fix bug where Gremlin is LoS checked when cancelling a hack or moving where
  the Gremlin is seen but the controlling unit is not (#97)
- Only AI score tiles for cover if that Unit type is able to use cover (#144)
- Fix vertical scrolling in Tactical Shot Wings (#188)
- Fix X2Effect_MindControl bug where ticking effects when reverted would tick on
  wrong playerstate (#194)
- Fix X2RadiusManager using Pawn and not Unit as source of truth for a unit's
  team. (#248)
- Fix incorrect GameplayVisibility Filter for reinforcements spawning (#250)
- Fix showing rupture damage in damage previews for non rupturing abilities
  (#253)
- Bug fix for previously units carried out while bleeding/KOed not having
  bBodyRecovered reset, meaning they will not be able to be picked up in a
  future mission. (#257)
- Fix issue where wounded units could recover health permanently when deployed
  in an Avenger mission, resulting in a bad UnitState. (#258)
- Allow Escape key to cancel hacks. (#278)
- Fix Divide by Zero errors in hacking UI. (#279)
- Fix GetHackDefenseForTarget when hack defense drops below zero. (#281)
- Fix Grapple not resetting bSteppingOutOfCover. (#283)
- When handling loot, check for existing BattleDataState and HQState on the
  current state object. (#285)
- Ensure max objective count correctly spawns in SelectObjectiveSpawns (#287)



## Miscellaneous

### Mod/DLC Hooks
- 'DLCAppendSockets': append skeleton sockets to a UnitPawn (#132)
- 'DLCDisableTutorial': mod can disable tutorial (#180)
- 'UpdateAnimations': mod can add new animation sets to Pawns, as well as
  gaining access to the UnitState and Pawn itself for other modifications (to be
  used with care, modders!) (#271)


### Event Hooks
- 'GetRankName': override rank name (#107)
- 'GetShortRankName': override abbreviated rank name (#107)
- 'GetRankIcon': override rank icon (#107)
- 'RefreshCrewPhotographs': queue extra mugshots (#149)
- 'OnGetPCSImage': override PCS Images (#191)

### Modding Exposures
- SignalOnReceiveFocus on UIViewObjectives so listeners can detect change events
  (#193)
- UIArmory.NeedsSelectHelp allows subclasses to determine whether SelectNavHelp
  should be displayed (#235)
- UIPanel.AS_SetMCColor allows setting colors of arbitrary MCs within UIPanel
  (#232)
- Dynamic Override system added to some UI classes, to allow mods to share
  overrides more safely: (#130)
  - UISquadSelect
  - UIAfterAction
  - UIPersonnel_SoldierListItem
  - UIStrategyMapItem & Children Classes
  - UIOptionsPCScreen

### Improvements
- Improve handling of localisation for Mod/DLC additional weapon categories
  (#50)
- Fix XGCS_Objective.OnNarrativeEventTrigger to return properly and avoid log
  spam (#96)
- Add support for SoundCues in XComSoundManager, including aliases (#135)
- Use strInventoryImage when available for better item images (#159)
- Expose flash control XComButtonIconPC (#167)

### Fixes
- CharacterPoolManager.CreateCharacter now uses ForceCountry correctly (#4)
- Fix 'OnCreateCinematicPawn' to only be called inside games, not in the shell
  (#113)
- Fix Vertical Autoscrolling in UITextContainer (#190)
- Fix tooltips (#2)
- Swap controls in UIPanel and UINavigator navigator to ensure
  controller/keyboard nav stays in sync (#231)
