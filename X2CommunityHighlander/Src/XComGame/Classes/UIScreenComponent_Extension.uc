class UIScreenComponent_Extension extends Object within UIScreenComponent_ExtensionContainer;

enum EClickCloseBehavior
{
	eCCB_Normal,
	eCCB_ClosePreClick,
	eCCB_ClosePostClick
};

var name ID;              // this ID will probably be used somewhere
var string displayString; // these five will be used as appropriate for the flash control
var string tooltipText;   // the UIIcon won't have a displaystring,
var string iconPath;      // the UIListItemString won't have an icon etc etc
var bool bDisabled;       // can't trigger click behavior. consider pairing with eUIState_Disabled for proper grey-out
var eUIState uiState;     //

var int iPriority;

// TODO: GC considerations: If I have an ActorComponent that has a delegate stored,
// and I call DetachComponent, what happens to the
	// 1: delegate,
	// 2: delegate owning object,
	// 3: component?
var delegate<OnClickedCallback> OnClick;
var string consolecommand; // ConsoleCommand
var name EventName; // TriggerEvent, will trigger with self as data and screen as source

// if we use a dedicated screen, whether to pop prior or after the click or do nothing
// i.e. use eCCB_ClosePreClick if you want to push another screen
var EClickCloseBehavior ClickCloseBehavior;

// this allows internal systems to store some data that could be required
var XComLWTuple InternalTuple;

// this allows systems to store arbitrary data on the item, which allows them to do more stuff (tm) on callbacks
var XComLWTuple DataTuple;

delegate OnClickedCallback(UIScreenComponent_Extension AssociatedExtension);

function DoClick()
{
	local UIScreen_ExtensionScreen ExtScreen;
	if (bDisabled)
	{
		return;
	}
	ExtScreen = GetScreen().GetActiveExtensionScreen();
	if (ClickCloseBehavior == eCCB_ClosePreClick && ExtScreen != none)
	{
		ExtScreen.CloseScreen();
	}
	TriggerCBs();
	if (ClickCloseBehavior == eCCB_ClosePostClick && ExtScreen != none)
	{
		ExtScreen.CloseScreen();
	}
}

protected function TriggerCBs()
{
	if (OnClickedCallback != none)
	{
		OnClick(self);
	}
	if (consolecommand != "")
	{
		GetScreen().ConsoleCommand(consolecommand);
	}
	if (EventName != '')
	{
		`XEVENTMGR.TriggerEvent(EventName, self, GetScreen(), none);
	}
}


function UIScreen GetScreen()
{
	return UIScreen(Outer.Owner);	
}

defaultproperties
{
	iPriority=50
	uiState=eUIState_Normal
}
