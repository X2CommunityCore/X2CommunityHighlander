//---------------------------------------------------------------------------------------
//  FILE:    X2TacticalGameRuleset_MovementObserver.uc
//  AUTHOR:  Ryan McFall  --  1/15/2013
//  PURPOSE: Examines contexts and game state changes for unit movement and activates
//           interrupt actions based on movement. Additionally does post-movement processing
//           such as setting location based properties on units like cover, concealment, etc.
//
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class X2TacticalGameRuleset_MovementObserver extends Object implements(X2GameRulesetEventObserverInterface);

var private array<StateObjectReference> InterruptAbilityList;
var private array<StateObjectReference> PostBuildAbilityList;
var private array<MovedObjectStatePair> MovedStateObjects;

//A core assumption of this method is that new ability state objects cannot be created by abilities running. If this assumption does not
//hold true, the lists below will be incomplete
event CacheGameStateInformation()
{
	local XComGameState_Ability AbilityStateObject;
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityTrigger_Event EventTrigger;
	local int Index;

	InterruptAbilityList.Length = 0;
	PostBuildAbilityList.Length = 0;
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Ability', AbilityStateObject)
	{
		AbilityTemplate = AbilityStateObject.GetMyTemplate();
		if (AbilityTemplate != None)
		{
			for( Index = 0; Index < AbilityTemplate.AbilityTriggers.Length; ++Index )
			{
				EventTrigger = X2AbilityTrigger_Event(AbilityTemplate.AbilityTriggers[Index]);
				if( EventTrigger != none )
				{
					if( EventTrigger.EventObserverClass == Class )
					{
						if( EventTrigger.MethodName == nameof(InterruptGameState) )
						{
							InterruptAbilityList.AddItem(AbilityStateObject.GetReference());
						}

						if( EventTrigger.MethodName == nameof(PostBuildGameState) )
						{
							PostBuildAbilityList.AddItem(AbilityStateObject.GetReference());
						}
					}
				}
			}
		}
	}
}

event Initialize()
{
}

event PreBuildGameStateFromContext(XComGameStateContext NewGameStateContext)
{

}

event InterruptGameState(XComGameState NewGameState)
{
	local XComTacticalCheatManager CheatManager;
	local int StateObjectIndex;
	local StateObjectReference CheckAbilityRef;
	local XComGameState_Ability CheckAbility;
	local XComGameStateContext AbilityContext;
	local MovedObjectStatePair MovedStateObj;
	local array<Vector> TargetLocs;
	local XComGameStateHistory History;
	local XComGameState_Unit TargetUnit;
	local AvailableTarget AvailTarget;
	local array<int> AdditionalTargets;
	local int i;

	MovedStateObjects.Length = 0;
	class'X2TacticalGameRulesetDataStructures'.static.GetMovedStateObjectList(NewGameState, MovedStateObjects);
	History = `XCOMHISTORY;

	CheatManager = `CHEATMGR;

	for( StateObjectIndex = 0; StateObjectIndex < MovedStateObjects.Length; ++StateObjectIndex )
	{
		MovedStateObj = MovedStateObjects[StateObjectIndex]; // Cache this because it apparently can be removed from the array mid-loop.

		// Start Issue #284
		// PI Added: If we are looking at an interrupt game state for the interruption step of the final
		// movement tile along the movement path for the given unit, ignore this unit for the purposes of
		// movement observation. Normal movement does not generate an interrupt state for this final
		// tile of movement, just the previous tiles. But TypicalMoveEndAbility_BuildInterruptGameState
		// generates an interrupt state for all the movement tiles as well as a final interrupt for the
		// ability itself. This final interrupt is also considered a movement because the unit position
		// will be different in this state than the previous submitted one.
		//
		// The end result of this is that a regular move along a path that is entirely hidden from an
		// overwatching unit except for the very last tile will not trigger overwatch. But a melee-move
		// ability such as sword slice *will* trigger overwatch, due to that final interrupt state.
		//
		// We still need that interrupt state to be present so other interrupting abilities such as
		// covering fire work on the sword slice. But we want it to be ignored for regular movement
		// watching purposes.
		if (IgnoreLastMovementTile(NewGameState, MovedStateObj.PostMoveState.ObjectID))
		{
			continue;
		}
		// End Issue #284

		// check if we are cheating the target. If so, wait until they are available to consume any abilities
		if(CheatManager != none && CheatManager.ForcedOverwatchTarget.ObjectID > 0)
		{
			if(CheatManager.ForcedOverwatchTarget.ObjectID != MovedStateObj.PostMoveState.ObjectID)
			{
				// wait until we find the target we want to shoot
				continue;
			}
			else
			{
				// got'em! Clear the cheat so that further attacks behave normally
				CheatManager.ForcedOverwatchTarget.ObjectID = 0;
			}
		}

		foreach InterruptAbilityList(CheckAbilityRef)
		{
			CheckAbility = XComGameState_Ability(History.GetGameStateForObjectID(CheckAbilityRef.ObjectID));
			if( CheckAbility.CanActivateAbilityForObserverEvent( MovedStateObj.PostMoveState ) == 'AA_Success' )
			{
				if (CheckAbility.GetMyTemplate().AbilityMultiTargetStyle != none)
				{
					TargetUnit = XComGameState_Unit(MovedStateObj.PostMoveState);
					if (TargetUnit != none)
					{
						AvailTarget.PrimaryTarget = TargetUnit.GetReference();
						TargetLocs.AddItem(`XWORLD.GetPositionFromTileCoordinates(TargetUnit.TileLocation));
						CheckAbility.GatherAdditionalAbilityTargetsForLocation(TargetLocs[0], AvailTarget);
						for (i = 0; i < AvailTarget.AdditionalTargets.Length; ++i)
						{
							AdditionalTargets.AddItem(AvailTarget.AdditionalTargets[i].ObjectID);
						}
						AbilityContext = class'XComGameStateContext_Ability'.static.BuildContextFromAbility(CheckAbility, TargetUnit.ObjectID, AdditionalTargets, TargetLocs);
					}
				}
				else
				{
					AbilityContext = class'XComGameStateContext_Ability'.static.BuildContextFromAbility(CheckAbility, MovedStateObj.PostMoveState.ObjectID);
				}
				if( AbilityContext != none && AbilityContext.Validate() )
				{
					`XCOMGAME.GameRuleset.SubmitGameStateContext(AbilityContext);
				}
			}
		}
	}
}

// Start Issue #284
// PI Added: Returns true if this is an interrupt game state where the interrupt step is for the
// last tile of the movement path of the given unit ref.
function bool IgnoreLastMovementTile(XComGameState GameState, int UnitObjectID)
{
	local XComGameStateContext_Ability AbilityContext;
	local int MovePathIndex;

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	if (AbilityContext == none || AbilityContext.InterruptionStatus != eInterruptionStatus_Interrupt)
		return false;

	for (MovePathIndex = 0; MovePathIndex < AbilityContext.InputContext.MovementPaths.Length; ++MovePathIndex)
	{
		if (AbilityContext.InputContext.MovementPaths[MovePathIndex].MovingUnitRef.ObjectID == UnitObjectID)
		{
			if (AbilityContext.ResultContext.InterruptionStep == (AbilityContext.InputContext.MovementPaths[MovePathIndex].MovementTiles.Length - 1))
			{
				return true;
			}

			return false;
		}
	}

	return false;
}
// End Issue #284

event PostBuildGameState(XComGameState NewGameState)
{
	local int StateObjectIndex;
	local StateObjectReference CheckAbilityRef;
	local XComGameState_Ability CheckAbility;
	local XComGameStateContext AbilityContext;
	local MovedObjectStatePair MovedStateObj;

	if (!`TACTICALRULES.TacticalGameIsInPlay()) // Tactical no longer actually running
	{
		return;
	}

	MovedStateObjects.Length = 0;
	class'X2TacticalGameRulesetDataStructures'.static.GetMovedStateObjectList(NewGameState, MovedStateObjects);

	for( StateObjectIndex = 0; StateObjectIndex < MovedStateObjects.Length; ++StateObjectIndex )
	{
		MovedStateObj = MovedStateObjects[StateObjectIndex]; // Cache this because it apparently can be removed from the array mid-loop.
		foreach PostBuildAbilityList(CheckAbilityRef)
		{
			CheckAbility = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(CheckAbilityRef.ObjectID));
			if (CheckAbility.CanActivateAbilityForObserverEvent(MovedStateObj.PostMoveState) == 'AA_Success')
			{
				//This only feeds in a primary target right now. If we need to start supporting locational targets or multi-target interrupts, extend this
				AbilityContext = class'XComGameStateContext_Ability'.static.BuildContextFromAbility(CheckAbility, MovedStateObj.PostMoveState.ObjectID);
				if( AbilityContext.Validate() )
				{
					`XCOMGAME.GameRuleset.SubmitGameStateContext(AbilityContext);
				}
			}
		}
	}
}
