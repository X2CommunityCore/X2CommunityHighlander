// robojumper: #1 screen extensions
// Actor Components are the easiest way of adding data to Actors
// we do lazy initialization, DO NOT add that component in defaultproperties anywhere
// components break with subclasses
class UIScreenComponent_ExtensionContainer extends ActorComponent;

var array<UIScreenComponent_Extension> Extensions;
