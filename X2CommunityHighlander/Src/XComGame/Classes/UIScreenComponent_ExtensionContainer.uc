// robojumper: #1 screen extensions
// Actor Components are the easiest way of adding data to Actors
// we do lazy initialization, DO NOT add that component in defaultproperties anywhere
// components break with subclasses
class UIScreenComponent_ExtensionContainer extends ActorComponent;

var protectedwrite array<UIScreenComponent_Extension> Extensions;


function AddExtension(UIScreenComponent_Extension Ext)
{
	if (Extensions.Find(Ext) == INDEX_NONE)
	{
		Extensions.AddItem(Ext);
		Extensions.Sort(ByPriority);
	}
}

function RemoveExtension(UIScreenComponent_Extension Ext)
{
	if (Extensions.Find(Ext) != INDEX_NONE)
	{
		Extensions.RemoveItem(Ext);
	}
}

// lower number = higher position
function int ByPriority(UIScreenComponent_Extension A, UIScreenComponent_Extension B)
{
	return B.iPriority - A.iPriority;
}