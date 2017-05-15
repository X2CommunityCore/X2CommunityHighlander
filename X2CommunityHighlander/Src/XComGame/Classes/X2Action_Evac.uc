class X2Action_Evac extends X2Action config(GameData);

var private CustomAnimParams AnimParams;
var private XComWeapon Rope;
var private Actor RopeTemplate;

var bool bIsVisualizingGremlin;

// Start Issue #243
var AnimNodeSequence	PlayingSequence;

struct AnimOverride
{
	var name CharacterTemplate;
	var name PreAnim;
	var name AnimName;
};

var config array<AnimOverride> AnimOverrides; // PI added
var int AnimOverrideIdx;
var BoneAtom	StartingAtom;
// End Issue #243

//------------------------------------------------------------------------------------------------

event bool BlocksAbilityActivation()
{
	return false;
}

//------------------------------------------------------------------------------------------------
simulated state Executing
{
	simulated event EndState(name NextStateName)
	{
		super.EndState(NextStateName);

		if( Rope != None )
		{
			Rope.Destroy();
		}
	}

	function RopeLoaded(Object LoadedArchetype)
	{
		RopeTemplate = Actor(LoadedArchetype);
	}

	function RequestRopeArchetype()
	{
		`CONTENT.RequestGameArchetype("WP_EvacRope.WP_EvacRope", self, RopeLoaded, true);
	}

	function SpawnAndPlayRopeAnim()
	{
		local CustomAnimParams Params;
		local Vector RopeLocation;
		
		RopeLocation = UnitPawn.Location;
		RopeLocation.Z += UnitPawn.Mesh.Translation.Z;
		Rope = Spawn(class'XComWeapon', self, 'EvacRope', RopeLocation, UnitPawn.Rotation, RopeTemplate);
		Rope.SetHidden(false);

		if( UnitPawn.CarryingUnit != None )
		{
			Params.AnimName = 'HL_CarryEvacStartA';
		}
		else
		{
			Params.AnimName = 'HL_EvacStartA';
		}

		Params.BlendTime = 0.0f;
		Params.PlayRate = GetNonCriticalAnimationSpeed();

		Rope.DynamicNode.PlayDynamicAnim(Params);
	}

	// Start Issue #243
	function int GetAnimOverride()
	{
		local XComGameState_Unit UnitState;
		local int Idx;

		UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Unit.ObjectID));
		if (UnitState != none)
		{
			Idx = AnimOverrides.Find('CharacterTemplate', UnitState.GetMyTemplateName());
			if (Idx >= 0)
			{
				return Idx;
			}
		}

		// Use the default anim
		return -1;
	}
	// End Issue #243
	
Begin:
	if (bIsVisualizingGremlin)
	{
		AnimParams.AnimName = 'HL_EvacStart';
		AnimParams.PlayRate = GetNonCriticalAnimationSpeed();

		FinishAnim(UnitPawn.GetAnimTreeController().PlayFullBodyDynamicAnim(AnimParams));
		UnitPawn.UpdatePawnVisibility();
		CompleteAction();
	}
	else
	{
		// Start Issue #243
		// Let mods override evac anims for particular units
		AnimOverrideIdx = GetAnimOverride();
		if (AnimOverrideIdx >= 0)
		{
			if (AnimOverrides[AnimOverrideIdx].PreAnim != '')
			{
				AnimParams.AnimName = AnimOverrides[AnimOverrideIdx].PreAnim;
				AnimParams.PlayRate = GetNonCriticalAnimationSpeed();
				FinishAnim(UnitPawn.GetAnimTreeController().PlayFullBodyDynamicAnim(AnimParams));
			}

			UnitPawn.bSkipIK = true;
			UnitPawn.EnableRMA(true, true);
			UnitPawn.EnableRMAInteractPhysics(true);

			AnimParams.AnimName = AnimOverrides[AnimOverrideIdx].AnimName;
			AnimParams.PlayRate = GetNonCriticalAnimationSpeed();
			StartingAtom.Rotation = QuatFromRotator(UnitPawn.Rotation);
			StartingAtom.Translation = UnitPawn.Location;
			StartingAtom.Scale = 1.0f;
			UnitPawn.GetAnimTreeController().GetDesiredEndingAtomFromStartingAtom(AnimParams, StartingAtom);
			FinishAnim(UnitPawn.GetAnimTreeController().PlayFullBodyDynamicAnim(AnimParams));
		}
		else
		{
			// vanilla behaviour
			if( UnitPawn.EvacWithRope )
			{
				RequestRopeArchetype();

				while( RopeTemplate == None )
				{
					Sleep(0.0f);
				}

				SpawnAndPlayRopeAnim();
			}

			AnimParams.AnimName = 'HL_EvacStart';
			AnimParams.PlayRate = GetNonCriticalAnimationSpeed();
			FinishAnim(UnitPawn.GetAnimTreeController().PlayFullBodyDynamicAnim(AnimParams));
		}
		// End Issue #243

		CompleteAction();

	}
}

event HandleNewUnitSelection()
{
	// we don't currently have a good way to continue execution of this action without blocking 
	// and also wait for this action to finish to kick off the remove unit action that follows
	// so instead we just remove both the evacing unit and the rope right now
	ForceImmediateTimeout();
}

defaultproperties
{
}
