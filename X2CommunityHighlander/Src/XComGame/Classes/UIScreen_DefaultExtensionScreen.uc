// robojumper: issue #1: screen extensions
// this is the default implementation of an external extension screen
class UIScreen_DefaultExtensionScreen extends UIScreen_ExtensionScreen;

var UIPanel m_kContainer;
// todo: one vs. two bg panels?
var UIBGBox m_kBG;
var UIList m_kIconList;
var UITextContainer m_kTextBox;
var UIScrollingText m_kTitleText;
var UIPanel m_kTitleSeparator;
// left, middle, right
var array<UIPanel> m_arrConnectors;

var protected UIScreenComponent_ExtensionContainer ExtensionContainer;
var UIPanel LastSelectedIcon;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	local vector2d centerpoint;
	local int i;

	super.InitScreen(InitController, InitMovie, InitName);
	
	ExtensionContainer = GetScreenExtending().GetExtensionContainer();
	centerpoint = Movie.ConvertNormalizedScreenCoordsToUICoords(0.5, 0.5);

	m_kContainer = Spawn(class'UIPanel', self).InitPanel();
	m_kContainer.SetSize(500, 500);
	m_kContainer.SetPosition(centerpoint.X - (m_kContainer.Width / 2), centerpoint.Y - (m_kContainer.Height / 2));

	m_kBG = Spawn(class'UIBGBox', m_kContainer);
	m_kBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	m_kBG.InitBG('', 0, 0, m_kContainer.Width, m_kContainer.Height);

	m_kIconList = Spawn(class'UIList', m_kContainer);
	m_kIconList.ItemPadding = 16;
	m_kIconList.ScrollbarPadding = 16;
	m_kIconList.InitList('', 24, 32, 48, m_kContainer.Height - 64);
	m_kIconList.OnSelectionChanged = SelectedItemChanged;
	m_kIconList.OnItemClicked = OnItemClicked;
	m_kIconList.OnItemDoubleClicked = OnItemClicked;

	m_kTextBox = Spawn(class'UITextContainer', m_kContainer);
	m_kTextBox.InitTextContainer('', "", 80, 64, m_kContainer.Width - 80 - 8, m_kContainer.Height - 96, false, '', true);

	m_kTitleText = Spawn(class'UIScrollingText', m_kContainer).InitScrollingText('', "", m_kContainer.Width - 80 - 8, 80, 16);

	m_kTitleSeparator = Spawn(class'UIPanel', m_kContainer).InitPanel('', class'UIUtilities_Controls'.const.MC_GenericPixel);
	m_kTitleSeparator.SetColor("0xfef4cb").SetAlpha(0.247);
	m_kTitleSeparator.SetPosition(80, 48);
	m_kTitleSeparator.SetSize(m_kContainer.Width - 80 - 8, 1);

	for (i = 0; i < 3; i++)
	{
		m_arrConnectors.AddItem(Spawn(class'UIPanel', m_kContainer).InitPanel('', class'UIUtilities_Controls'.const.MC_GenericPixel));
		m_arrConnectors[i].Hide();
		m_arrConnectors[i].SetColor("0xfef4cb").SetAlpha(0.247);
	}
	m_arrConnectors[0].SetHeight(1);
	m_arrConnectors[0].SetWidth(8);
	m_arrConnectors[0].SetX(64);
	
	m_arrConnectors[1].SetWidth(1);
	m_arrConnectors[1].SetX(72);
	m_arrConnectors[1].SetY(32);
	
	m_arrConnectors[2].SetHeight(1);
	m_arrConnectors[2].SetWidth(8);
	m_arrConnectors[2].SetX(72);
	m_arrConnectors[2].SetY(32);

}

simulated function SelectedItemChanged(UIList ContainerList, int ItemIndex)
{
	local string buildString;
	local UIScreenComponent_Extension Ext;
	if (ItemIndex > INDEX_NONE)
	{
		Ext = GetExtensionForIndex(ItemIndex);
		//buildString $= class'UIUtilities_Text'.static.AddFontInfo(Ext.displayString, Screen.bIsIn3D, true) $ "\n\n";
		//buildString = class'UIUtilities_Text'.static.AddFontInfo(Ext.tooltipText, Screen.bIsIn3D) $ "\n\n";
		buildString = class'UIUtilities_Text'.static.GetColoredText(class'UIUtilities_Text'.static.CapsCheckForGermanScharfesS(Ext.displayString), eUIState_Header, 24);
		m_kTitleText.SetHTMLText(buildString);
		buildString = class'UIUtilities_Text'.static.GetColoredText(Ext.tooltipText, eUIState_Normal, 24);

		m_kTextBox.text.Hide();
		m_kTextBox.SetHTMLText(buildString);
		// flush immediately to prevent 1 frame delay in description which causes flickering
		Movie.ProcessQueuedCommands();
		
		if (LastSelectedIcon != none)
		{
			LastSelectedIcon.MC.FunctionVoid("hideSelectionBrackets");
		}
		LastSelectedIcon = m_kIconList.GetItem(ItemIndex);
		LastSelectedIcon.MC.FunctionVoid("showSelectionBrackets");
	}
	RealizeConnectors();
}

simulated function RealizeConnectors()
{
	local int idx;
	local UIPanel currPanel;
	local float fTime;
	idx = m_kIconList.SelectedIndex;

	if (idx > INDEX_NONE)
	{
		fTime = m_arrConnectors[0].bIsVisible ? 0.2 : 0.0;
		m_arrConnectors[0].Show(); // internally guarded
		m_arrConnectors[1].Show();
		m_arrConnectors[2].Show();

		// left connector
		currPanel = m_kIconList.GetItem(idx);
		m_arrConnectors[0].AddTween("_y", currPanel.Y + m_kIconList.Y + (currPanel.Height / 2), fTime, , "easeoutquad");
		m_arrConnectors[1].AddTween("_height", currPanel.Y + m_kIconList.Y + (currPanel.Height / 2) - 32, fTime, , "easeoutquad");
		
	}
	else
	{
		m_arrConnectors[0].Hide();
		m_arrConnectors[1].Hide();
		m_arrConnectors[2].Hide();
	}
}


simulated function OnItemClicked(UIList ContainerList, int ItemIndex)
{
	// call the extension handler for that
	GetExtensionForIndex(ItemIndex).DoClick();
}


simulated function RealizeExtensions()
{
	local int i;
	
	while (m_kIconList.GetItemCount() < ExtensionContainer.Extensions.Length)
	{
		CreateIcon();
	}
	while (ExtensionContainer.Extensions.Length < m_kIconList.GetItemCount())
	{
		// redundant? don't want it to clob up the navigator
		m_kIconList.GetItem(m_kIconList.GetItemCount() - 1).DisableNavigation();
		m_kIconList.ItemContainer.RemoveChild(m_kIconList.GetItem(m_kIconList.GetItemCount() - 1));
	}
	for (i = 0; i < ExtensionContainer.Extensions.Length; i++)
	{
		ConfigureIcon(UIIcon(m_kIconList.GetItem(i)), i);
	}
}

simulated function ConfigureIcon(UIIcon Icon, int index)
{
	local UIScreenComponent_Extension Ext;
	Ext = GetExtensionForIndex(index);
	Icon.LoadIcon(Ext.iconPath);
	Icon.SetBGColorState(Ext.uiState);
}

simulated function CreateIcon()
{
	Spawn(class'UIIcon', m_kIconList.ItemContainer).InitIcon('', "", true, true, 32);
}

simulated function UIScreenComponent_Extension GetExtensionForIndex(int index)
{
	if (index >= 0 && index < ExtensionContainer.Extensions.Length)
	{
		return ExtensionContainer.Extensions[index];
	}
	return none;
}


simulated function bool OnUnrealCommand(int cmd, int arg)
{
	local bool bHandled;

	// for the purpose of this screen, more than the default keys are considered directional
	// we kinda want it to be intuitive
	switch (cmd)
	{
		case class'UIUtilities_Input'.const.FXS_BUTTON_LBUMPER:
		case class'UIUtilities_Input'.const.FXS_BUTTON_LTRIGGER:
		case class'UIUtilities_Input'.const.FXS_DPAD_LEFT:
			cmd = class'UIUtilities_Input'.const.FXS_ARROW_UP;
			break;
		case class'UIUtilities_Input'.const.FXS_BUTTON_RBUMPER:
		case class'UIUtilities_Input'.const.FXS_BUTTON_RTRIGGER:
		case class'UIUtilities_Input'.const.FXS_DPAD_RIGHT:
			cmd = class'UIUtilities_Input'.const.FXS_ARROW_DOWN;
			break;
		default:
			break;
	}

	// Only pay attention to presses or repeats; ignoring other input types
	// NOTE: Ensure repeats only occur with arrow keys
	if ( !CheckInputIsReleaseOrDirectionRepeat(cmd, arg) )
		return false;

	bHandled = true;
	switch( cmd )
	{
		case class'UIUtilities_Input'.const.FXS_BUTTON_B:
		case class'UIUtilities_Input'.const.FXS_KEY_ESCAPE:
		case class'UIUtilities_Input'.const.FXS_R_MOUSE_DOWN:
			CloseScreen();
			break;
		default:
			bHandled = false;
			break;
	}

	return bHandled || super.OnUnrealCommand(cmd, arg);
}


defaultproperties
{
	bConsumeMouseEvents = true;
}
