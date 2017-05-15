class UITacticalHUD_Countdown extends UIPanel
	implements(X2VisualizationMgrObserverInterface); 

var localized string m_strReinforcementsTitle;
var localized string m_strReinforcementsBody;

// Start Issue #239
// PI Added: The ReinforcementOverride delegate is a function that is called when refreshing the 
// reinforcement counter display if it is set to a non-none value. It takes three out parameters
// of the strings to use for the reinforcements title (m_strReinforcementsTitle = REINFORCEMENTS),
// body (m_strReinforcementsBody = INCOMING) and color (BAD_HTML_COLOR = red) and returns a bool
// value. If the function returns true, the reinforcement UI is forced to be shown even if there
// is no pending reinforcement, and uses the strings returned in the out params for the text to
// display and the color for the animated diagonal lines. If the function returns false, or if there
// is no delegate set, the standard logic is used to either show or hide the UI. Note that the
// function calling this delegate does not reset the strings to their default values so mods
// need to be careful when returning 'false' if there is a reinforcement pending.
//
// Note that an event+tuple can't be used to implement this due to crashing issues on campaign
// start from stale event manager entries, and a DLCInfo hook may be too slow because this
// function is invoked on every visualization sync, so a delegate is used instead.
var delegate<ReinforcementOverrideFn> ReinforcementOverride;
delegate bool ReinforcementOverrideFn(out string sTitle, out string sBody, out string sColor);
// End Issue #239

simulated function UITacticalHUD_Countdown InitCountdown()
{
	InitPanel();
	return self;
}

simulated function OnInit()
{
	local XComGameState_AIReinforcementSpawner AISpawnerState;

	super.OnInit();

	AS_SetCounterText(m_strReinforcementsTitle, m_strReinforcementsBody);

	// Initialize at the correct values 
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_AIReinforcementSpawner', AISpawnerState)
	{
		RefreshCounter(AISpawnerState);
		break;
	}

	//And subscribe to any future changes 
	`XCOMVISUALIZATIONMGR.RegisterObserver(self);
}

// --------------------------------------

event OnActiveUnitChanged(XComGameState_Unit NewActiveUnit);
event OnVisualizationIdle();

event OnVisualizationBlockComplete(XComGameState AssociatedGameState)
{
	local XComGameState_AIReinforcementSpawner AISpawnerState;
	local string title, body, clr; // Variables for Issue #239

	// Start Issue #239
	// Allow mods to control the counter visualization. The delegate should return a bool flag and if the flag
	// is true, the out params hold strings to use to update the UI. The first two strings are the title and body strings
	// respectively (REINFORCEMENTS and INCOMING in vanilla). The third string is the color to use for the dags control.
	if (ReinforcementOverride != none && ReinforcementOverride(title, body, clr))
	{
		AS_SetCounterText(title, body);
		AS_SetMCColor( MCPath$".dags", clr);
		Show();
		return;
	}
	// End Issue #239

	foreach AssociatedGameState.IterateByClassType(class'XComGameState_AIReinforcementSpawner', AISpawnerState)
	{
		RefreshCounter(AISpawnerState);
		break;
	}
}

// Start Issue #239
// Returns true if a mod is overriding the countdown UI.
simulated function bool ReinforcementOverrideEnabled()
{
	local string title, body, clr;
	return ReinforcementOverride != none && ReinforcementOverride(title, body, clr);
}
// End Issue #239

simulated function RefreshCounter(XComGameState_AIReinforcementSpawner AISpawnerState)
{
	if( AISpawnerState.Countdown > 0 )
	{
		AS_SetCounterTimer(AISpawnerState.Countdown);
		Show(); 
	}
	else
	{
		Hide();
	}
}

simulated function AS_SetCounterText( string title, string label )
{ Movie.ActionScriptVoid( MCPath $ ".SetCounterText" ); }

simulated function AS_SetCounterTimer( int iTurns )
{ Movie.ActionScriptVoid( MCPath $ ".SetCounterTimer" ); }


// --------------------------------------
defaultproperties
{
	MCName = "theCountdown";
	bAnimateOnInit = false;
	bIsVisible = false; // only show when gameplay needs it
	Height = 80; // used for objectives placement beneath this element as well. 
}
