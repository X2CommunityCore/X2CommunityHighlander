// robojumper: issue #1: screen extensions
// this is the default implementation of an external extension screen
class UIScreen_DefaultExtensionScreen extends UIScreen_ExtensionScreen;

var UIPanel m_kContainer;
// todo: one vs. two bg panels?
var UIBGBox m_kBG;
var UIList m_kIconList;
var UITextContainer m_kTextBox;
var UIPanel LeftConnector, UpDownConnector, RightConnector;

var protected UIScreenComponent_ExtensionContainer ExtensionContainer;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	local vector2d centerpoint;
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
	m_kIconList.InitList('', 16, 16, 48, m_kContainer.Height - 32);
	m_kIconList.OnSelectionChanged = SelectedItemChanged;
	m_kIconList.OnItemClicked = OnItemClicked;
	m_kIconList.OnItemDoubleClicked = OnItemClicked;

	m_kTextBox = Spawn(class'UITextContainer', m_kContainer);
	m_kTextBox.InitTextContainer('', "", 80, 16, m_kContainer.Width - 80 - 8, m_kContainer.Height - 32, false, '', true);

	LeftConnector = Spawn(class'UIPanel', m_kContainer).InitPanel('', class'UIUtilities_Controls'.const.MC_GenericPixel);
	LeftConnector.Hide();
	UpDownConnector = Spawn(class'UIPanel', m_kContainer).InitPanel('', class'UIUtilities_Controls'.const.MC_GenericPixel);
	UpDownConnector.Hide();
	RightConnector = Spawn(class'UIPanel', m_kContainer).InitPanel('', class'UIUtilities_Controls'.const.MC_GenericPixel);
	RightConnector.Hide();
	
}

simulated function SelectedItemChanged(UIList ContainerList, int ItemIndex)
{
	local string buildString;
	local UIScreenComponent_Extension Ext;
	if (ItemIndex > INDEX_NONE)
	{
		Ext = GetExtensionForIndex(ItemIndex);
		buildString = "";
		buildString $= class'UIUtilities_Text'.static.AddFontInfo(Ext.displayString, Screen.bIsIn3D, true) $ "\n\n";
		buildString $= class'UIUtilities_Text'.static.AddFontInfo(Ext.tooltipText, Screen.bIsIn3D) $ "\n\n";
		m_kTextBox.text.Hide();
		m_kTextBox.SetHTMLText(buildString);
	}

	RealizeConnectors();
	
}

simulated function RealizeConnectors()
{
	local int idx;
	local UIPanel LeftPanel;

	if (idx > INDEX_NONE)
	{

	}
	else
	{
		LeftConnector.Hide();
		RightConnector.Hide();
		UpDownConnector.Hide();
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
