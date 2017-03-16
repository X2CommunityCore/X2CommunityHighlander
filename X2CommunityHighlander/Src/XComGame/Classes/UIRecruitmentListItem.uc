class UIRecruitmentListItem extends UIListItemString;

var localized string RecruitConfirmLabel; 

simulated function InitRecruitItem(XComGameState_Unit Recruit)
{
	local string ColoredName;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_HeadquartersResistance ResistanceHQ;

	InitPanel(); // must do this before adding children or setting data

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	ResistanceHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();

	if(XComHQ.GetSupplies() < ResistanceHQ.GetRecruitSupplyCost())
		SetDisabled(true);

	ColoredName = class'UIUtilities_Text'.static.GetColoredText(Recruit.GetName(eNameType_Full), bDisabled ? eUIState_Disabled : eUIState_Normal);
	AS_PopulateData(Recruit.GetCountryTemplate().FlagImage, ColoredName);

	SetConfirmButtonStyle(eUIConfirmButtonStyle_Default, RecruitConfirmLabel, 5, 4);

	// HAX: Undo the height override set by UIListItemString
	MC.ChildSetNum("theButton", "_height", 40);

	//LWS :		 Adding hooks to enable DLC/Mods to alter list item
	// Issue #178: trigger now to allow overriding disabled status, and to add background elements
	`XEVENTMGR.TriggerEvent('OnRecruitmentListItemInit', Recruit, self);
}		

// Start Issue #178
// Add triggers to allow updating on receiving/losing focus
simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();
	`XEVENTMGR.TriggerEvent('OnRecruitmentListItemUpdateFocus', self, self);
}

simulated function OnLoseFocus()
{
	super.OnLoseFocus();
	`XEVENTMGR.TriggerEvent('OnRecruitmentListItemUpdateFocus', self, self);
}
// End Issue #178

simulated function OnClickedConfirmButton(UIButton Button)
{
	local UIRecruitSoldiers RecruitScreen;
	RecruitScreen = UIRecruitSoldiers(Screen);
	RecruitScreen.OnRecruitSelected(RecruitScreen.List, RecruitScreen.List.GetItemIndex(self));
}

simulated function AS_PopulateData( string flagIcon, string recruitName )
{
	MC.BeginFunctionOp("populateData");
	MC.QueueString(flagIcon);
	MC.QueueString(recruitName);
	MC.EndOp();
}

defaultproperties
{
	width = 540;
	height = 40;
	LibID = "NewRecruitItem";
}
