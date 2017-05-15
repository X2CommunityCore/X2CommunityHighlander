//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class X2Condition_BerserkerDevastatingPunch extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{ 
	local XComGameState_Unit TargetUnit;

	TargetUnit = XComGameState_Unit(kTarget);

	if( TargetUnit == none )
	{
		return 'AA_NotAUnit';
	}

	if( TargetUnit.IsBleedingOut() )
	{
		return 'AA_UnitIsBleedingOut';
	}

	if( TargetUnit.IsUnconscious() )
	{
		return 'AA_UnitIsUnconscious';
	}

	if( TargetUnit.IsDead() || TargetUnit.IsStasisLanced() )
	{
		return 'AA_UnitIsDead';
	}

	if( TargetUnit.IsInStasis())
	{
		return 'AA_UnitIsInStasis';
	}

	if( TargetUnit.GetMyTemplate().bIsCosmetic)
	{
		return 'AA_UnitIsCosmetic';
	}

	return 'AA_Success';
}

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
	local XComGameState_Unit SourceUnit, TargetUnit;
	
	SourceUnit = XComGameState_Unit(kSource);
	TargetUnit = XComGameState_Unit(kTarget);
	
	if( (SourceUnit == none) || (TargetUnit == none) )
	{
		return 'AA_NotAUnit';
	}

	if( SourceUnit.IsPlayerControlled() && TargetUnit.IsPlayerControlled() )
	{
		return 'AA_UnitIsFriendly';
	}

	// Start Issue #245
	// PI Mods: No punching friendly units unless enraaged. This can occur when the BT is looking for
	// priority targets while in yellow: if there is a device to destroy on the mission, it'll check all available targets
	// to melee, and we don't want friendlies to appear here.
	if (!SourceUnit.IsEnemyUnit(TargetUnit) && 
		!SourceUnit.IsUnitAffectedByEffectName(class'X2Ability_Berserker'.default.RageTriggeredEffectName))
	{
		return 'AA_UnitIsFriendly';
	}
	// End Issue #245
	
	return 'AA_Success';
}
