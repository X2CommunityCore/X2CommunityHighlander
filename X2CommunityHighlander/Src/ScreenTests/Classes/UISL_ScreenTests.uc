class UISL_ScreenTests extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UIShell Shell;
	local UIScreenComponent_Extension TheExtension;
	local UIScreenComponent_ExtensionContainer TheExtensionContainer;

	Shell = UIShell(Screen);
	
	if (Shell != none)
	{
		TheExtensionContainer = Shell.GetExtensionContainer();
		TheExtension = new (TheExtensionContainer) class'UIScreenComponent_Extension';
		TheExtension.iconPath = "img:///UILibrary_PerkIcons.UIPerk_evac";
		TheExtension.displayString = "Fancy Dancy Title";
		TheExtension.tooltipText = "doodledidoodledo";
		TheExtensionContainer.AddExtension(TheExtension);

		TheExtension = new (TheExtensionContainer) class'UIScreenComponent_Extension';
		TheExtension.iconPath = "img:///UILibrary_PerkIcons.UIPerk_locked";
		TheExtension.displayString = "Fancy Dancy Title 2";
		TheExtension.tooltipText = "something something boogaloo";
		TheExtension.uiState = eUIState_Disabled;
		TheExtensionContainer.AddExtension(TheExtension);
	}
}
