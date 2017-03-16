//---------------------------------------------------------------------------------------
//  *********   FIRAXIS SOURCE CODE   ******************
//  FILE:    UIArmory_WeaponUpgradeItem
//  AUTHOR:  Sam Batista
//  PURPOSE: UI that represents an upgrade item, largely based off of UIArmory_LoadoutItem
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class UIArmory_WeaponUpgradeItem extends UIPanel;

var string title;
var string subTitle;
var string disabledText;
var array<string> Images;
var string PrototypeIcon;
var string SlotType;
var int    Count;

var bool bIsLocked;
var bool bIsInfinite;
var bool bIsDisabled;

var X2WeaponUpgradeTemplate UpgradeTemplate;
var XComGameState_Item Weapon;
var int SlotIndex;

// Variables for Issue #88
var UIButton DropItemButton; 
var int TooltipID;
var localized string m_strRemoveUpgrade;

simulated function UIArmory_WeaponUpgradeItem InitUpgradeItem(XComGameState_Item InitWeapon, optional X2WeaponUpgradeTemplate InitUpgrade, optional int SlotNum = -1, optional string InitDisabledReason)
{
	Weapon = InitWeapon;
	UpgradeTemplate = InitUpgrade;
	SlotIndex = SlotNum;

	InitPanel();

	// Start Issue #88
	// Adding DropItemButton and tooltip for drop button
	UpdateDropItemButton();
	if(!bIsDisabled)
	{
		// add a custom text box since the flash component reports back with from the bg subcomponent
		TooltipID = Movie.Pres.m_kTooltipMgr.AddNewTooltipTextBox(default.m_strRemoveUpgrade, 0, 0, MCPath $ ".DropItemButton.bg");
	}
	// End Issue #88

	UpdateImage();
	UpdateCategoryIcons();

	if(UpgradeTemplate != none)
	{
		SetTitle(UpgradeTemplate.GetItemFriendlyName());
		SetSubTitle(Weapon.GetUpgradeEffectForUI(UpgradeTemplate));
	}
	else
	{
		SetTitle(class'UIArmory_WeaponUpgrade'.default.m_strEmptySlot);
		if(InitDisabledReason != "")
			SetSubTitle(class'UIArmory_WeaponUpgrade'.default.m_strUpgradeAvailable);
	}

	if(InitDisabledReason != "")
		SetDisabled(true, InitDisabledReason);

	return self;
}



simulated function UIArmory_WeaponUpgradeItem SetTitle(string txt)
{
	if(title != txt)
	{
		title = txt;
		MC.FunctionString("setTitle", title);
	}
	return self;
}

simulated function UIArmory_WeaponUpgradeItem SetSubTitle(string txt)
{
	if(subTitle != txt)
	{
		subTitle = txt;
		MC.FunctionString("setSlotType", subTitle);
	}
	return self;
}

simulated function UIArmory_WeaponUpgradeItem UpdateImage()
{
	if(UpgradeTemplate == none)
	{
		MC.FunctionVoid("setImages");
		return self;
	}

	MC.BeginFunctionOp("setImages");
	MC.QueueBoolean(false); // remnant of UIArmory_LoadoutItem, corresponds to "needsMask" param
	MC.QueueString(UpgradeTemplate.GetAttachmentInventoryImage(Weapon));
	MC.EndOp();
	return self;
}

simulated function UIArmory_WeaponUpgradeItem SetCount(int newCount) // -1 for infinite
{
	local XGParamTag kTag;
	
	if(Count != newCount)
	{
		Count = newCount;
		if(Count < 0)
		{
			MC.FunctionBool("setInfinite", true);
		}
		else
		{
			kTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
			kTag.IntValue0 = Count;
			
			MC.FunctionString("setCount", `XEXPAND.ExpandString(class'UIArmory_LoadoutItem'.default.m_strCount));
			MC.FunctionBool("setInfinite", false);
		}
	}
	return self;
}

simulated function UIArmory_WeaponUpgradeItem SetSlotType(string NewSlotType)
{
	if(NewSlotType != SlotType)
	{
		SlotType = NewSlotType;
		MC.FunctionString("setSlotType", SlotType);
	}
	return self;
}

simulated function UIArmory_WeaponUpgradeItem SetLocked(bool Locked)
{
	if(bIsLocked != Locked)
	{
		bIsLocked = Locked;
		MC.FunctionBool("setLocked", bIsLocked);

		if(!bIsLocked)
			OnLoseFocus();
	}
	return self;
}

simulated function UIArmory_WeaponUpgradeItem SetDisabled(bool bDisabled, optional string Reason)
{
	if(bIsDisabled != bDisabled)
	{
		bIsDisabled = bDisabled;
		MC.BeginFunctionOp("setDisabled");
		MC.QueueBoolean(bDisabled);
		MC.QueueString(Reason);
		MC.EndOp();
	}
	return self;
}

simulated function UIArmory_WeaponUpgradeItem SetInfinite(bool infinite)
{
	if(bIsInfinite != infinite)
	{
		bIsInfinite = infinite;
		MC.FunctionBool("setInfinite", bIsInfinite);
	}
	return self;
}

simulated function UIArmory_WeaponUpgradeItem SetPrototypeIcon(optional string icon) // pass empty string to hide PrototypeIcon
{
	if(PrototypeIcon != icon)
	{
		PrototypeIcon = icon;
		MC.FunctionString("setPrototype", icon);
	}
	return self;
}

simulated function UpdateCategoryIcons()
{
	local int Index;
	local array<string> Icons; 

	if( UpgradeTemplate == none )
	{
		ClearIcons();
		return;
	}

	Icons = UpgradeTemplate.GetAttachmentInventoryCategoryImages(Weapon);

	if( Icons.Length == 0 )
	{
		ClearIcons();
	}
	else
	{
		for( Index = 0; Index < Icons.Length; Index++ )
		{
			AddIcon(Index, Icons[Index]);
		}
	}
}

simulated function AddIcon(int index, string path)
{
	MC.BeginFunctionOp("addIcon");
	MC.QueueNumber(index);
	MC.QueueString(path);
	MC.EndOp();
}

simulated function ClearIcons()
{
	MC.FunctionVoid("clearIcons");
}

simulated function OnReceiveFocus()
{
	if( !bIsLocked && !bIsFocused )
	{
		bIsFocused = true;
		MC.FunctionVoid("onReceiveFocus");
	}
}

simulated function OnLoseFocus()
{
	if( bIsFocused )
	{
		bIsFocused = false;
		MC.FunctionVoid("onLoseFocus");
	}
}

// Start Issue #88
// LWS:		 Adding capability for a DropItem Button for weapon upgrades, activatable only by mods
// LWS: Adding functionality for "dropping" weapon upgrades without replacing them with anything else
simulated function UpdateDropItemButton()
{
	local bool bShowClearButton;
	local UIPanel Container;
	local UIList OwnerList;
	local array<X2DownloadableContentInfo> DLCInfos;
	local int i;

	if(bIsLocked || bIsDisabled || ParentPanel == UIArmory_WeaponUpgrade(Screen).UpgradesList)
		return;

	Container = ParentPanel;
	OwnerList = UIList(Container.ParentPanel);
	if (OwnerList != none && OwnerList == UIArmory_WeaponUpgrade(Screen).UpgradesList)
		return;

	bShowClearButton = false; 
	DLCInfos = `ONLINEEVENTMGR.GetDLCInfos(false);
	for(i = 0; i < DLCInfos.Length; ++i)
	{
		if(DLCInfos[i].CanRemoveWeaponUpgrade(Weapon, UpgradeTemplate, SlotIndex))
		{
			bShowClearButton = true; 
		}
	}

	MC.SetBool("showClearButton", bShowClearButton);
	MC.FunctionVoid("realize");

	if(!bShowClearButton)
		Movie.Pres.m_kTooltipMgr.DeactivateTooltipByID(TooltipID);
}

function OnDropItemClicked(UIButton kButton)
{
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Item UpdatedWeapon;
	local UIArmory_WeaponUpgrade UpgradeScreen;
	local XComGameState_Item UpgradeItem;
	local X2WeaponUpgradeTemplate OldUpgradeTemplate;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Drop Upgrade From Weapon");
	
	// Remove upgrade frome weapon
	UpdatedWeapon = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', Weapon.ObjectID));
	OldUpgradeTemplate = UpdatedWeapon.DeleteWeaponUpgradeTemplate(SlotIndex);
	NewGameState.AddStateObject(UpdatedWeapon);
			
	// Possibly add to HQ inventory
	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	NewGameState.AddStateObject(XComHQ);

	// If reusing upgrades Continent Bonus is active, create an item for the old upgrade template and add it to the inventory
	if (XComHQ.bReuseUpgrades && OldUpgradeTemplate != none)
	{
		UpgradeItem = OldUpgradeTemplate.CreateInstanceFromTemplate(NewGameState);
		NewGameState.AddStateObject(UpgradeItem);
		XComHQ.PutItemInInventory(NewGameState, UpgradeItem);
	}
			
	`XEVENTMGR.TriggerEvent('WeaponUpgradeRemoved', UpdatedWeapon, OldUpgradeTemplate, NewGameState);
	`GAMERULES.SubmitGameState(NewGameState);

	Weapon = UpdatedWeapon; // refresh the weapon gamestate

	UpgradeScreen = UIArmory_WeaponUpgrade(Screen);

	UpgradeScreen.UpdateSlots();
	UpgradeScreen.WeaponStats.PopulateData(Weapon);

	`XSTRATEGYSOUNDMGR.PlaySoundEvent("SoundUnreal3DSounds.Unreal3DSounds_SectoidUnequipGrenade");
}

simulated function OnCommand(string cmd, string arg)
{
	if(cmd == "DropItemClicked")
		OnDropItemClicked(DropItemButton);
}

// END LWS CHANGES
// End Issue #88

defaultproperties
{
	Width = 342;
	Height = 145;
	bAnimateOnInit = false;
	bProcessesMouseEvents = false; // Issue #88: changed from false to true to enable the DropItem button to function
	LibID = "LoadoutListItem";
}
