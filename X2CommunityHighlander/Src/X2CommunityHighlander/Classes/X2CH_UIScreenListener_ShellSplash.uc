class X2CH_UIScreenListener_ShellSplash extends UIScreenListener;

var UIText VersionText;

event OnInit(UIScreen Screen)
{
	local UIShell ShellScreen;
	local X2StrategyElementTemplateManager Manager;
	local X2StrategyElementTemplate LWElem, CHElem;
	local CHXComGameVersionTemplate CHVersion;
	local LWXComGameVersionTemplate LWVersion;
	local String VersionString;

	if(UIShell(Screen) == none)  // this captures UIShell and UIFinalShell
		return;

	ShellScreen = UIShell(Screen);

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	CHElem = Manager.FindStrategyElementTemplate('CHXComGameVersion');
	LWElem = Manager.FindStrategyElementTemplate('LWXComGameVersion');

	VersionString = "";
	
	if (CHElem != none)
	{
		CHVersion = CHXComGameVersionTemplate(CHElem);
		VersionString = VersionString $ "X2CommunityHighlander Version " $ CHVersion.MajorVersion $ "." $ CHVersion.MinorVersion $ ". ";
	}

	if (LWElem != none)
	{
		LWVersion = LWXComGameVersionTemplate(LWElem);
		VersionString = VersionString $ "Long War Highlander Version " $ LWVersion.MajorVersion $ "." $ LWVersion.MinorVersion $ ". ";
	}

	`log("X2CH SCREEN LISTENER ON SPLASH");
	VersionText = ShellScreen.Spawn(class'UIText', ShellScreen);
	VersionText.InitText();
	VersionText.SetText(VersionString);
	VersionText.AnchorTopRight();
	VersionText.SetPosition(10,10);
	VersionText.SetSize(400,32);
	VersionText.Show();
}

defaultProperties
{
    ScreenClass = none
}
