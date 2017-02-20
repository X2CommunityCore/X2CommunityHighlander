// robojumper: issue #1: screen extensions
// this is a separate type to provide more info to the screenstack
// about whether this is an extension screen
                                            
// extension screens exist on the stack and get their info from the first screen after it that isn't a UIMouseGuard

// robojumper: issue #1: screen extensions
// this screen is an extension screen for a generic screen
class UIScreen_ExtensionScreen extends UIScreen abstract;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);
}

// Override in child classes
// We always update all the things. Most panels are guarded against unneccessary calls across the wire
simulated function RealizeExtensions()
{

}


simulated function UIScreen GetScreenExtending()
{
	local UIScreenStack Stack;
	local int i;

	Stack = `SCREENSTACK;

	for (i = 0; i < Stack.Screens.Length; i++)
	{
		if (Stack.Screens[i] == self)
		{
			for (i = i+1; i < Stack.Screens.Length; i++)
			{
				if (Stack.Screens[i] != none && UIMouseGuard(Stack.Screens[i]) == none && UIScreen_ExtensionScreen(Stack.Screens[i]) == none)
				{
					return Stack.Screens[i];
				}
			}
			break;
		}
	}
	// should never be reached unless we aren't on the stack
	`REDSCREEN("UIScreen_ExtensionScreen without Base Screen or not on stack, \n" @ GetScriptTrace());
	return none;
}




simulated function bool CanShowExtensionScreen()
{
	return false;
}
