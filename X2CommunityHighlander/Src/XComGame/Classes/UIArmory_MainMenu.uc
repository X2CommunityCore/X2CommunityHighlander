// Issue #164 - Major Rewrite. Diff with vanilla to understand the changes
// fully.
// LWS : class modified to provide support for DLC/mod insertable elements into the ArmoryList

class UIArmory_MainMenu 
	extends UIArmory
	dependson(UIDialogueBox)
	dependson(UIUtilities_Strategy);

var localized string m_strTitle;
var localized string m_strCustomizeSoldier;
var localized string m_strCustomizeWeapon;
var localized string m_strAbilities;
var localized string m_strPromote;
var localized string m_strImplants;
var localized string m_strLoadout;
var localized string m_strDismiss;
var localized string m_strPromoteDesc;
var localized string m_strImplantsDesc;
var localized string m_strLoadoutDesc;
var localized string m_strDismissDesc;
var localized string m_strCustomizeWeaponDesc;
var localized string m_strCustomizeSoldierDesc;

var localized string m_strDismissDialogTitle;
var localized string m_strDismissDialogDescription;

var localized string m_strRookiePromoteTooltip;
var localized string m_strNoImplantsTooltip;
var localized string m_strNoGTSTooltip;
var localized string m_strCantEquiqPCSTooltip;
var localized string m_strNoModularWeaponsTooltip;
var localized string m_strCannotUpgradeWeaponTooltip;
var localized string m_strNoWeaponUpgradesTooltip;
var localized string m_strInsufficientRankForImplantsTooltip;
var localized string m_strCombatSimsSlotsFull;

// set to true to prevent spawning popups when cycling soldiers
var bool bIsHotlinking;

var UIList List;
var UIListItemString PromoteItem;

// Variables for Issue #164
var UIPanel BGPanel;
var UIListItemString CustomizeButton, LoadoutButton, PCSButton, WeaponUpgradeButton, PromotionButton, DismissButton;

simulated function InitArmory(StateObjectReference UnitRef, optional name DispEvent, optional name SoldSpawnEvent, optional name NavBackEvent, optional name HideEvent, optional name RemoveEvent, optional bool bInstant = false, optional XComGameState InitCheckGameState)
{
	bUseNavHelp = class'XComGameState_HeadquartersXCom'.static.IsObjectiveCompleted('T0_M2_WelcomeToArmory');
	super.InitArmory(UnitRef, DispEvent, SoldSpawnEvent, NavBackEvent, HideEvent, RemoveEvent, bInstant, CheckGameState);

	// Start Issue #164
	List = Spawn(class'UIList', self).InitList(); // LWS Initialize a new list so it can be positions
	//List.OnItemClicked = OnItemClicked;  // LWS: remove this and let each button handle its own callbacks, so that mod buttons can change order/insert without breaking stuff
	List.OnSelectionChanged = OnSelectionChanged;
	//LWS : Adjust position slightly for larger list
	List.SetPosition(113, 143);
	List.SetSize(401, 360); // Should I reduce width to leave room for scrollbar on background?

	//LWS : create background BGPanel so can make some changes and move the existing panel
	BGPanel = Spawn(class'UIPanel', self).InitPanel('armoryMenuBG');
	BGPanel.SetPosition(101, 126);
	BGPanel.SetSize(425, 499);
	BGPanel.bShouldPlayGenericUIAudioEvents = false;  
	BGPanel.ProcessMouseEvents(List.OnChildMouseEvent); // hook mousewheel to scroll MainMenu list instead of rotating soldier
	// End Issue #164

	CreateSoldierPawn();
	PopulateData();
	CheckForCustomizationPopup();
}

// LWS Spawn each button with its own handler, moving a lot of this functionality into separate functions
simulated function PopulateData()
{
	local bool bInTutorialPromote;
	// Variables removed for Issue #164

	super.PopulateData();

	List.ClearItems();

	bInTutorialPromote = !class'XComGameState_HeadquartersXCom'.static.IsObjectiveCompleted('T0_M2_WelcomeToArmory');

	// Start Issue #164
	// -------------------------------------------------------------------------------
	// Customize soldier: 
	CustomizeButton = Spawn(class'UIListItemString', List.ItemContainer).InitListItem(m_strCustomizeSoldier).SetDisabled(bInTutorialPromote, "");
	CustomizeButton.MCName = 'ArmoryMainMenu_CustomizeButton';
	CustomizeButton.ButtonBG.OnClickedDelegate = OnCustomize;

	// -------------------------------------------------------------------------------
	// Loadout:
	LoadoutButton = Spawn(class'UIListItemString', List.ItemContainer).InitListItem(m_strLoadout).SetDisabled(bInTutorialPromote, "");
	LoadoutButton.MCName = 'ArmoryMainMenu_LoadoutButton';
	LoadoutButton.ButtonBG.OnClickedDelegate = OnLoadout;

	// -------------------------------------------------------------------------------
	// PCS:
	PCSButton = Spawn(class'UIListItemString', List.ItemContainer).InitListItem(m_strImplants); 
	PCSButton.MCName = 'ArmoryMainMenu_PCSButton';
	PCSButton.ButtonBG.OnClickedDelegate = OnPCS;

	// -------------------------------------------------------------------------------
	// Customize Weapons:
	WeaponUpgradeButton = Spawn(class'UIListItemString', List.ItemContainer).InitListItem(m_strCustomizeWeapon);  
	WeaponUpgradeButton.MCName = 'ArmoryMainMenu_WeaponUpgradeButton';
	WeaponUpgradeButton.ButtonBG.OnClickedDelegate = OnWeaponUpgrade;

	// -------------------------------------------------------------------------------
	// Promotion:
	PromotionButton = Spawn(class'UIListItemString', List.ItemContainer).InitListItem();
	PromotionButton.MCName = 'ArmoryMainMenu_PromotionButton';
	PromotionButton.ButtonBG.OnClickedDelegate = OnPromote;

	// -------------------------------------------------------------------------------
	// Dismiss: 
	DismissButton = Spawn(class'UIListItemString', List.ItemContainer).InitListItem(m_strDismiss).SetDisabled((bInTutorialPromote || class'XComGameState_HeadquartersXCom'.static.AnyTutorialObjectivesInProgress()), "");
	DismissButton.MCName = 'ArmoryMainMenu_DismissButton';
	DismissButton.ButtonBG.OnClickedDelegate = OnDismiss;

	UpdateData();

	List.Navigator.SelectFirstAvailable();
}

simulated function UpdatePromoteItem()
{
	if(GetUnit().GetRank() < 1 && !GetUnit().CanRankUpSoldier())
	{
		PromoteItem.SetDisabled(true, m_strRookiePromoteTooltip);
	}
}

simulated function CheckForCustomizationPopup()
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Unit UnitState;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ(true);
	if(XComHQ != none)
	{
		UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitReference.ObjectID));
		if (!XComHQ.bHasSeenCustomizationsPopup && UnitState.IsVeteran())
		{
			`HQPRES.UISoldierCustomizationsAvailable();
		}
	}
}

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();
	PopulateData();
	CreateSoldierPawn();
	//UpdatePromoteItem();
	if(!bIsHotlinking)
		CheckForCustomizationPopup();
	Header.PopulateData();
}


// Issue #164
// most behaviour transplanted from old PopulateData function
//new helper method to update button status
simulated function UpdateData()
{
	local bool bEnableImplantsOption, bEnableWeaponUpgradeOption, bInTutorialPromote;
	local TWeaponUpgradeAvailabilityData WeaponUpgradeAvailabilityData;
	local TPCSAvailabilityData PCSAvailabilityData;
	local string ImplantsTooltip, WeaponUpgradeTooltip, PromoteIcon;
	local XComGameState_Unit Unit;

	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitReference.ObjectID));

	bInTutorialPromote = !class'XComGameState_HeadquartersXCom'.static.IsObjectiveCompleted('T0_M2_WelcomeToArmory');

	// -------------------------------------------------------------------------------
	// PCS:
	class'UIUtilities_Strategy'.static.GetPCSAvailability(Unit, PCSAvailabilityData);

	if( !PCSAvailabilityData.bHasAchievedCombatSimsRank ) 
		ImplantsTooltip = m_strInsufficientRankForImplantsTooltip;
	else if(!PCSAvailabilityData.bCanEquipCombatSims)
		ImplantsTooltip = m_strCantEquiqPCSTooltip;
	else if( !PCSAvailabilityData.bHasCombatSimsSlotsAvailable )
		ImplantsTooltip = m_strCombatSimsSlotsFull;
	else if( !PCSAvailabilityData.bHasNeurochipImplantsInInventory )
		ImplantsTooltip = m_strNoImplantsTooltip;
	else if( !PCSAvailabilityData.bHasGTS )
		ImplantsTooltip = m_strNoGTSTooltip;

	bEnableImplantsOption = PCSAvailabilityData.bCanEquipCombatSims && PCSAvailabilityData.bHasAchievedCombatSimsRank && PCSAvailabilityData.bHasGTS && !bInTutorialPromote;
	PCSButton.SetDisabled(!bEnableImplantsOption, ImplantsTooltip);
	if( bEnableImplantsOption )
	{
		if( PCSAvailabilityData.bHasNeurochipImplantsInInventory && PCSAvailabilityData.bHasCombatSimsSlotsAvailable)
			PCSButton.NeedsAttention(true);
		else
			PCSButton.NeedsAttention(false);
	} 
	else
	{
		PCSButton.NeedsAttention(false);
	}

	// -------------------------------------------------------------------------------
	// Customize Weapons:
	class'UIUtilities_Strategy'.static.GetWeaponUpgradeAvailability(Unit, WeaponUpgradeAvailabilityData);

	if( !WeaponUpgradeAvailabilityData.bHasModularWeapons )
		WeaponUpgradeTooltip = m_strNoModularWeaponsTooltip;
	else if( !WeaponUpgradeAvailabilityData.bCanWeaponBeUpgraded )
		WeaponUpgradeTooltip = m_strCannotUpgradeWeaponTooltip;
	else if( !WeaponUpgradeAvailabilityData.bHasWeaponUpgrades )
		WeaponUpgradeTooltip = m_strNoWeaponUpgradesTooltip;
	
	bEnableWeaponUpgradeOption = WeaponUpgradeAvailabilityData.bHasModularWeapons && WeaponUpgradeAvailabilityData.bCanWeaponBeUpgraded && !bInTutorialPromote;
	WeaponUpgradeButton.SetDisabled(!bEnableWeaponUpgradeOption, WeaponUpgradeTooltip);

	if( WeaponUpgradeAvailabilityData.bHasWeaponUpgrades && WeaponUpgradeAvailabilityData.bHasWeaponUpgradeSlotsAvailable && WeaponUpgradeAvailabilityData.bHasModularWeapons)
		WeaponUpgradeButton.NeedsAttention(true);
	else
		WeaponUpgradeButton.NeedsAttention(false);

	// -------------------------------------------------------------------------------
	// Promotion:
	if(Unit.ShowPromoteIcon())
	{
		if (Unit.IsPsiOperative())
		{
			PromoteIcon = class'UIUtilities_Text'.static.InjectImage(class'UIUtilities_Image'.const.PsiMarkUpIcon, 20, 20, 0) $ " ";
			PromotionButton.SetText(PromoteIcon $ m_strAbilities);
		}
		else
		{
			PromoteIcon = class'UIUtilities_Text'.static.InjectImage(class'UIUtilities_Image'.const.HTML_PromotionIcon, 20, 20, 0) $ " ";
			PromotionButton.SetText(PromoteIcon $ m_strPromote);
		}
	}
	else
	{
		PromotionButton.SetText(m_strAbilities);
	}
	if(GetUnit().GetRank() < 1 && !GetUnit().CanRankUpSoldier())
	{
		PromotionButton.SetDisabled(true, m_strRookiePromoteTooltip);
	}
	
	// trigger now to allow inserting new buttons
	`XEVENTMGR.TriggerEvent('OnArmoryMainMenuUpdate', List, self);

	class'UIUtilities_Strategy'.static.PopulateAbilitySummary(self, Unit);

}

//follows is a series of handlers for each individual button
simulated function OnCustomize(UIButton kButton)
{
	local XComGameState_Unit UnitState;

	if(CheckForDisabledListItem(kButton)) return;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitReference.ObjectID));
	Movie.Pres.UICustomize_Menu(UnitState, ActorPawn);
	`XSTRATEGYSOUNDMGR.PlaySoundEvent("Play_MenuSelect");
}

simulated function OnLoadout(UIButton kButton)
{
	local XComHQPresentationLayer HQPres;

	if(CheckForDisabledListItem(kButton)) return;

	HQPres = XComHQPresentationLayer(Movie.Pres);
	if( HQPres != none )    
		HQPres.UIArmory_Loadout(UnitReference);
	`XSTRATEGYSOUNDMGR.PlaySoundEvent("Play_MenuSelect");
}

simulated function OnPCS(UIButton kButton)
{
	local XComHQPresentationLayer HQPres;

	if(CheckForDisabledListItem(kButton)) return;

	HQPres = XComHQPresentationLayer(Movie.Pres);
	if( HQPres != none && `XCOMHQ.HasCombatSimsInInventory() )		
		`HQPRES.UIInventory_Implants();
	`XSTRATEGYSOUNDMGR.PlaySoundEvent("Play_MenuSelect");
}

simulated function OnWeaponUpgrade(UIButton kButton)
{
	local XComHQPresentationLayer HQPres;

	if(CheckForDisabledListItem(kButton)) return;

	HQPres = XComHQPresentationLayer(Movie.Pres);
	ReleasePawn();
	if( HQPres != none && `XCOMHQ.bModularWeapons )
		HQPres.UIArmory_WeaponUpgrade(UnitReference);
	`XSTRATEGYSOUNDMGR.PlaySoundEvent("Play_MenuSelect");
}

simulated function OnPromote(UIButton kButton)
{
	local XComHQPresentationLayer HQPres;

	if(CheckForDisabledListItem(kButton)) return;

	HQPres = XComHQPresentationLayer(Movie.Pres);
	if( HQPres != none && GetUnit().GetRank() >= 1 || GetUnit().CanRankUpSoldier() || GetUnit().HasAvailablePerksToAssign() )
		HQPres.UIArmory_Promotion(UnitReference);
	`XSTRATEGYSOUNDMGR.PlaySoundEvent("Play_MenuSelect");
}

simulated function OnDismiss(UIButton kButton)
{
	if(CheckForDisabledListItem(kButton)) return;

	OnDismissUnit();
	`XSTRATEGYSOUNDMGR.PlaySoundEvent("Play_MenuSelect");
}

//LWS - helper to check whether a button is disabled
simulated function bool CheckForDisabledListItem(UIButton kButton)
{
	local UIListItemString Parent;

	Parent = UIListItemString(kButton.ParentPanel);
	if( Parent != none && Parent.bDisabled )
	{
		`XSTRATEGYSOUNDMGR.PlaySoundEvent("Play_MenuClickNegative");
		return true;
	}
	return false;
}

simulated function OnAccept()
{
	local XComGameState_Unit UnitState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComHQPresentationLayer HQPres;

	if( UIListItemString(List.GetSelectedItem()).bDisabled )
	{
		`XSTRATEGYSOUNDMGR.PlaySoundEvent("Play_MenuClickNegative");
		return;
	}

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	HQPres = XComHQPresentationLayer(Movie.Pres);

	// Index order matches order that elements get added in 'PopulateData'
	switch( List.selectedIndex )
	{
	case 0: // CUSTOMIZE
		UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitReference.ObjectID));
		Movie.Pres.UICustomize_Menu(UnitState, ActorPawn);
		break;
	case 1: // LOADOUT
		if( HQPres != none )    
			HQPres.UIArmory_Loadout(UnitReference);
		break;
	case 2: // NEUROCHIP IMPLANTS
		if( HQPres != none && XComHQ.HasCombatSimsInInventory() )		
			`HQPRES.UIInventory_Implants();
		break;
	case 3: // WEAPON UPGRADE
		// Release pawn so it can get recreated when the screen receives focus
		ReleasePawn();
		if( HQPres != none && XComHQ.bModularWeapons )
			HQPres.UIArmory_WeaponUpgrade(UnitReference);
		break;
	case 4: // PROMOTE
		if( HQPres != none && GetUnit().GetRank() >= 1 || GetUnit().CanRankUpSoldier() || GetUnit().HasAvailablePerksToAssign() )
			HQPres.UIArmory_Promotion(UnitReference);
		break;
	case 5: // DISMISS
		OnDismissUnit();
		break;
	}
	`XSTRATEGYSOUNDMGR.PlaySoundEvent("Play_MenuSelect");
}

simulated function OnItemClicked(UIList ContainerList, int ItemIndex)
{
	OnAccept();
}

//reworked to switch off button instead of list index
simulated function OnSelectionChanged(UIList ContainerList, int ItemIndex)
{
	local string Description;

	switch(ContainerList.GetItem(ItemIndex))
	{
	case CustomizeButton:
		Description = m_strCustomizeSoldierDesc;
		break;
	case LoadoutButton:
		Description = m_strLoadoutDesc;
		break;
	case PCSButton:
		Description = m_strImplantsDesc;
		break;
	case WeaponUpgradeButton:
		Description = m_strCustomizeWeaponDesc;
		break;
	case PromotionButton:
		Description = m_strPromoteDesc;
		break;
	case DismissButton:
		Description = m_strDismissDesc;
		break;
	}

	MC.ChildSetString("descriptionText", "htmlText", class'UIUtilities_Text'.static.AddFontInfo(Description, bIsIn3D));
}

simulated function OnDismissUnit()
{
	local XGParamTag        kTag;
	local TDialogueBoxData  DialogData;

	kTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	kTag.StrValue0 = GetUnit().GetName(eNameType_Full);
	
	DialogData.eType       = eDialog_Warning;
	DialogData.strTitle	= m_strDismissDialogTitle;
	DialogData.strText     = `XEXPAND.ExpandString(m_strDismissDialogDescription); 
	DialogData.fnCallback  = OnDismissUnitCallback;

	DialogData.strAccept = class'UIUtilities_Text'.default.m_strGenericYes;
	DialogData.strCancel = class'UIUtilities_Text'.default.m_strGenericNo;

	Movie.Pres.UIRaiseDialog(DialogData);
}

simulated public function OnDismissUnitCallback(eUIAction eAction)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Unit Unit; // Variable for Issue #165

	if( eAction == eUIAction_Accept )
	{
		// Start Issue #165
		// LWS: trigger now to allow triggers when dismissing a unit (e.g. cleaning up component gamestates)
		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitReference.ObjectID));
		`XEVENTMGR.TriggerEvent('OnDismissSoldier', Unit, self);
		// End Issue #165

		XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
		XComHQ.FireStaff(UnitReference);
		OnCancel();
	}
}

//==============================================================================

simulated function OnCancel()
{
	if(class'XComGameState_HeadquartersXCom'.static.IsObjectiveCompleted('T0_M2_WelcomeToArmory'))
	{
		super.OnCancel();
	}
}

simulated function OnRemoved()
{
	super.OnRemoved();
	`HQPRES.m_kAvengerHUD.NavHelp.ClearButtonHelp();
}

defaultproperties
{
	LibID = "ArmoryMenuScreenMC";
	DisplayTag = "UIBlueprint_ArmoryMenu";
	CameraTag = "UIBlueprint_ArmoryMenu";
}
