//  *********   FIRAXIS SOURCE CODE   ******************
//  FILE:    UIStrategyMap_MissionIcon.uc
//  AUTHOR:  Joe Cortese 7/13/2015
//  PURPOSE: UIPanel to load a dynamic image icon and set background coloring. 
//
//  Issue #185: Extending to allow modding of click functionality and tooltip info
//----------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//----------------------------------------------------------------------------
class UIStrategyMap_MissionIcon extends UIIcon
	config(UI);

var XComGameState_ScanningSite ScanSite;
var XComGameState_MissionSite MissionSite;
var UIStrategyMapItem MapItem;
var UIStrategyMap_MissionIconTooltip Tooltip;

var config float ZoomLevel;

var int idNum;

var bool bFocused;
var bool bMoveCamera;
simulated function UIStrategyMap_MissionIcon InitMissionIcon( optional int iD)
{
	local name IconInitName;

	idNum = iD;

	IconInitName = name("StrategyIcon"$iD);
	Super.InitIcon(IconInitName, , true, false, iD == 0? 96 : 64);
	
	mc.FunctionNum("SetIDNum", iD);

	return self;
}

simulated function SetSortedPosition(int numScanSites, int numMissions)
{
	mc.BeginFunctionOp("SetSortedPosition");
	mc.QueueNumber(numScanSites);
	mc.QueueNumber(numMissions);
	mc.EndOp();
}

simulated function SetScanSite(XComGameState_ScanningSite Scanner)
{
	local XComGameState_BlackMarket BlackMarket;

	MapItem = `HQPRES.StrategyMap2D.GetMapItem(Scanner);
	ScanSite = Scanner;
	MissionSite = none;
	OnClickedDelegate = ScanSite.AttemptSelectionCheckInterruption;
	LoadIcon(ScanSite.GetUIButtonIcon());
	HideTooltip();
	SetMissionIconTooltip(ScanSite.GetUIButtonTooltipTitle(), ScanSite.GetUIButtonTooltipBody());
	Show();

	BlackMarket = XComGameState_BlackMarket(Scanner);
	if (BlackMarket != None)
		AS_SetLock(BlackMarket.CanBeScanned()); // Black market icon is opposite, locked when it needs a scan
	else
		AS_SetLock(!ScanSite.CanBeScanned());

	AS_SetGoldenPath(false);

	// For Issue #185
	TriggerEvent('OverrideMissionIcon_SetScanSite');
}

simulated function SetMissionSite(XComGameState_MissionSite Mission)
{
	local bool bMissionLocked, bIsGoldenPath;

	MapItem = `HQPRES.StrategyMap2D.GetMapItem(Mission);
	MissionSite = Mission;
	ScanSite = none;
	OnClickedDelegate = MissionSite.AttemptSelectionCheckInterruption;
	LoadIcon(MissionSite.GetUIButtonIcon());
	HideTooltip();
	SetMissionIconTooltip(MissionSite.GetUIButtonTooltipTitle(), MissionSite.GetUIButtonTooltipBody());
	Show();

	bMissionLocked = (!MissionSite.GetWorldRegion().HaveMadeContact() && MissionSite.bNotAtThreshold);
	bIsGoldenPath = (MissionSite.GetMissionSource().bGoldenPath);

	if(MissionSite.Source == 'MissionSource_Broadcast')
		AS_SetLock(false); //Broadcast the Truth cannot be locked
	else
		AS_SetLock(bMissionLocked);

	AS_SetGoldenPath(bIsGoldenPath);

	// For Issue #185
	TriggerEvent('OverrideMissionIcon_SetMissionSite');
}

simulated function OnMouseEvent(int cmd, array<string> args)
{
	// Variable for Issue #185
	local XComLWTuple Tuple;

	super.OnMouseEvent(cmd, args);

	switch(cmd)
	{
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_IN:
		if (bMoveCamera || `ISCONTROLLERACTIVE == false)
		{
			XComHQPresentationLayer(Movie.Pres).CAMSaveCurrentLocation();
		}
		if(MapItem != none) // Issue #185: Added spam reduction
			MapItem.OnMouseIn();
		if(ScanSite != none)
		{
			ScanSite = XComGameState_ScanningSite(`XCOMHISTORY.GetGameStateForObjectID(ScanSite.ObjectID)); // Force an update of Scan Site game state
			// Start Issue #185
			//LWS: Adding override for MissionSite Tooltip
			Tuple = TriggerEvent('OverrideMissionIcon_ScanSiteTooltip');
			if (Tuple.Data.Length == 3 && Tuple.Data[0].Kind == XComLWTVBool && Tuple.Data[0].b)
			{
				SetMissionIconTooltip(Tuple.Data[1].s, Tuple.Data[2].s);
			}
			else
			{
				SetMissionIconTooltip(ScanSite.GetUIButtonTooltipTitle(), ScanSite.GetUIButtonTooltipBody());
			}
			// End Issue #185
			if (bMoveCamera || `ISCONTROLLERACTIVE == false)
			{
				XComHQPresentationLayer(Movie.Pres).CAMLookAtEarth(ScanSite.Get2DLocation(), ZoomLevel);
			}
		}
		else if( MissionSite != none )
		{
			// Start Issue #185
			//LWS: Adding override for MissionSite Tooltip
			Tuple = TriggerEvent('OverrideMissionIcon_MissionTooltip');
			if (Tuple.Data.Length == 3 && Tuple.Data[0].Kind == XComLWTVBool && Tuple.Data[0].b)
			{
				SetMissionIconTooltip(Tuple.Data[1].s, Tuple.Data[2].s);
			}
			else
			{
				SetMissionIconTooltip(MissionSite.GetUIButtonTooltipTitle(), MissionSite.GetUIButtonTooltipBody());
			}
			// End Issue #185
			if (bMoveCamera || `ISCONTROLLERACTIVE == false)
			{
				XComHQPresentationLayer(Movie.Pres).CAMLookAtEarth(MissionSite.Get2DLocation(), ZoomLevel);
			}
		}
		else
		{
			if (bMoveCamera || `ISCONTROLLERACTIVE == false)
			{
				XComHQPresentationLayer(Movie.Pres).CAMLookAtEarth(MissionSite.Get2DLocation(), ZoomLevel);
			}
		}
		break;
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_OUT:
		if(MapItem != none) // Issue #185: Added spam reduction
			MapItem.OnMouseOut();
		if (bMoveCamera || `ISCONTROLLERACTIVE == false)
		{
			XComHQPresentationLayer(Movie.Pres).CAMRestoreSavedLocation();
		}
		break;
	};
}

simulated function HideTooltip()
{
	if( Tooltip != none )
	{
		Tooltip.HideTooltip();
	}
}

simulated function SetMissionIconTooltip(string Title, string Body)
{
	if( Tooltip == none )
	{
		Tooltip = Spawn(class'UIStrategyMap_MissionIconTooltip', Movie.Pres.m_kTooltipMgr);
		Tooltip.InitMissionIconTooltip(Title, Body);

		//Tooltip.SetAnchor(class'UIUtilities'.const.ANCHOR_BOTTOM_CENTER); 
		Tooltip.bFollowMouse = true;

		Tooltip.targetPath = string(MCPath);
		Tooltip.bUsePartialPath = true;
		Tooltip.tDelay = 0.0;

		Tooltip.ID = Movie.Pres.m_kTooltipMgr.AddPreformedTooltip(Tooltip);
	}
	else
	{
		Tooltip.SetText(Title, Body);
	}
}

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	local array<string> EmptyArray;

	if (!CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
	{
		return true;
	}

	switch(cmd)
	{
	case class'UIUtilities_Input'.const.FXS_BUTTON_A:
		if (`HQPRES.StrategyMap2D.XComHQ().GetCurrentScanningSite().ObjectID == ScanSite.ObjectID &&
			ScanSite.CanBeScanned())
		{
			`HQPRES.StrategyMap2D.ToggleScan();
		}
		else
		{
			EmptyArray.Length = 0;
			OnMouseEvent(class'UIUtilities_Input'.const.FXS_L_MOUSE_UP, EmptyArray);
		}

		return true;
	}

	return super.OnUnrealCommand(cmd, arg);
}

simulated function OnReceiveFocus()
{
	local array<string> EmptyArray;
	EmptyArray.Length = 0;

	if (Movie.IsMouseActive())
	{
		return;
	}

	if (bFocused)
	{
		return;
	}

	bFocused = true;

	OnMouseEvent(class'UIUtilities_Input'.const.FXS_L_MOUSE_IN, EmptyArray);
}

simulated function OnLoseFocus()
{
	local array<string> EmptyArray;
	EmptyArray.Length = 0;

	if (Movie.IsMouseActive())
	{
		return;
	}

	if (!bFocused)
	{
		return;
	}
	
	bFocused = false;

	OnMouseEvent(class'UIUtilities_Input'.const.FXS_L_MOUSE_OUT, EmptyArray);
}

// Start Issue #185
//LWS: Adding generic TriggerEvent for various modding hooks to MissionIcon
simulated function XComLWTuple TriggerEvent(name ID)
{
	local XComLWTuple Tuple;

	Tuple = new class'XComLWTuple';
	Tuple.Id = ID;
	`XEVENTMGR.TriggerEvent('OverrideMissionIcon', Tuple, self);

	return Tuple;
}
// End Issue #185

simulated function AS_SetLock(bool isLocked)
{
	MC.FunctionBool("SetLock", isLocked);
}

simulated function AS_SetAlert(bool bShow)
{
	MC.FunctionBool("SetAlert", bShow);
}

simulated function AS_SetGoldenPath(bool bShow)
{
	MC.FunctionBool("SetGoldenPath", bShow);
}

simulated function Remove()
{
	Movie.Pres.m_kTooltipMgr.RemoveTooltipByTarget(string(MCPath));
	super.Remove();
}

defaultproperties
{
	LibID = "StrategyMapMissionIcon";
}
