//---------------------------------------------------------------------------------------
//  *********   FIRAXIS SOURCE CODE   ******************
//  FILE:    UIRewardsRecap
//  AUTHOR:  Sam Batista
//  PURPOSE: Shows a list of rewards obtained during last mission.
//           Part of the post mission flow.
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//--------------------------------------------------------------------------------------- 

// LWS Changes:
// Major Changes for Issue #173
// tracktwo - Added configurable reward VIP offsets & support displaying more than one VIP pawn. VIP status
//            info removed to UIInventory_LootRecovered to allow for more to be listed without scrolling or
//            needing to increase the size of the panel.

class UIInventory_VIPRecovered extends UIPanel config(UI); // Add Config for Issue #173

enum EVIPStatus
{
	eVIPStatus_Unknown,
	eVIPStatus_Recovered,
	eVIPStatus_Awarded,
	eVIPStatus_Killed,
	eVIPStatus_Lost
};

var name PawnLocationTag;
var localized string m_strVIPStatus[eVIPStatus.EnumCount]<BoundEnum=eVIPStatus>;
var localized string m_strEnemyVIPStatus[eVIPStatus.EnumCount]<BoundEnum=eVIPStatus>;

// Variables for Issue #173
var array<XComUnitPawn> ActorPawns;
var array<StateObjectReference> RewardUnitRefs;
var config array<int> Vip_X_Offsets;
var config array<int> Vip_Y_Offsets;

simulated function UIInventory_VIPRecovered InitVIPRecovered()
{
	InitPanel();
	PopulateData();
	return self;
}

simulated function PopulateData()
{
	local EVIPStatus VIPStatus;
	local XComGameState_Unit Unit;
	local XComGameState_MissionSite Mission;
	local XComGameState_HeadquartersXCom XComHQ;

	// Variables for Issue #173
	local XComGameState_BattleData BattleData;
	local StateObjectReference RewardUnitRef;
	local int i;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	Mission = XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(XComHQ.MissionRef.ObjectID));

	// Start Issue #173
	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));

	for(i = 0; i < BattleData.RewardUnits.Length; ++i)
	{
		RewardUnitRef = BattleData.RewardUnits[i];

		if(RewardUnitRef.ObjectID <= 0)
		{
			`RedScreen("UIInventory_VIPRecovered did not get a valid Unit Reference.");
			return;
		}

		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(RewardUnitRef.ObjectID));
		VIPStatus = EVIPStatus(Mission.GetRewardVIPStatus(Unit));

		switch(VIPStatus)
		{
		case eVIPStatus_Awarded:
		case eVIPStatus_Recovered:
			if (i == 0 || (i < Vip_X_Offsets.Length && i < Vip_Y_Offsets.Length))
			{
			CreateVIPPawn(Unit, i);
				RewardUnitRefs.AddItem(RewardUnitRef);
			}
			break;
		}
	}
	// End Issue #173
}

simulated function CreateVIPPawn(XComGameState_Unit Unit, int i)
{
	local PointInSpace PlacementActor;

	// Variables for Issue #173
	local Vector Loc;
	local XComUnitPawn ActorPawn;

	// Don't do anything if we don't have a valid UnitReference
	if(Unit == none) return;

	foreach WorldInfo.AllActors(class'PointInSpace', PlacementActor)
	{
		if (PlacementActor != none && PlacementActor.Tag == PawnLocationTag)
			break;
	}

	// Start Issue #173
	loc = PlacementActor.Location;
	loc.X += Vip_X_Offsets[i];
	loc.Y += Vip_Y_Offsets[i];

	ActorPawn = `HQPRES.GetUIPawnMgr().RequestPawnByState(self, Unit, Loc, PlacementActor.Rotation);
	ActorPawn.GotoState('CharacterCustomization'); // vanilla statement
	ActorPawn.EnableFootIK(false); // vanilla statement
	ActorPawns.AddItem(ActorPawn);
	// End Issue #173

	if (Unit.IsSoldier())
	{
		ActorPawn.CreateVisualInventoryAttachments(`HQPRES.GetUIPawnMgr(), Unit);
	}

	if(Unit.UseLargeArmoryScale())
	{
		ActorPawn.Mesh.SetScale(class'UIArmory'.default.LargeUnitScale);
	}
}

simulated function Cleanup()
{
	local XComGameState NewGameState;
	local XComGameState_HeadquartersResistance ResistanceHQ;

	// Variable for Issue #173
	local int i;

	// Start Issue #173
	if (RewardUnitRefs.Length == 0)
		return;

	for( i = 0; i < RewardUnitRefs.Length; ++i)
			`HQPRES.GetUIPawnMgr().ReleasePawn(self, RewardUnitRefs[i].ObjectID);
	// End Issue #173

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Clear VIP Reward Data");
	ResistanceHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();
	ResistanceHQ = XComGameState_HeadquartersResistance(NewGameState.CreateStateObject(class'XComGameState_HeadquartersResistance', ResistanceHQ.ObjectID));
	NewGameState.AddStateObject(ResistanceHQ);
	ResistanceHQ.ClearVIPRewardsData();
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	// Start Issue #173
	RewardUnitRefs.Length = 0;
	ActorPawns.Length = 0;
	// End Issue #173
}

simulated function AS_UpdateData(string Title, string VIPName, string VIPIcon, string VIPReward)
{
	MC.BeginFunctionOp("updateData");
	MC.QueueString(Title);
	MC.QueueString(VIPName);
	MC.QueueString(VIPIcon);
	MC.QueueString(VIPReward);
	MC.EndOp();
}

//------------------------------------------------------

defaultproperties
{
	LibID = "VIPRecovered";
	PawnLocationTag = "UIPawnLocation_VIP_0";
}
