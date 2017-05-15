
class X2UnitRadiusManager extends Actor config(GameCore);

// PI Added: Config control of the test to be within N tiles of the civilian to display.
var config bool IgnoreCursorLocation;

var private transient TTile LastCursorTile; // the last tile the cursor was in
var private transient bool Enabled;

simulated event Tick( float DeltaTime )
{
	local XComWorldData WorldData;
	local vector CursorLocation;
	local TTile CursorTile, TileDiff;
	local XComGameState_Unit Unit;
	local XComUnitPawn UnitPawn;
	local bool ShouldDraw;
	local int CivReactionTileRadius;
	local float CivReactionWorldRadius;

	if (!Enabled)
	{
		return;
	}

	WorldData = `XWORLD;
	CivReactionTileRadius = class'XGAIBehavior_Civilian'.default.CIVILIAN_NEAR_TERROR_REACT_RADIUS;
	CivReactionWorldRadius = CivReactionTileRadius * class'XComWorldData'.const.WORLD_StepSize;

	// default case, we just pick to the normal cursor location
	CursorLocation = `Cursor.Location;

	// snap the location to the ground
	CursorLocation.Z = WorldData.GetFloorZForPosition( CursorLocation );
	CursorTile = WorldData.GetTileCoordinatesFromPosition( CursorLocation );

	if (LastCursorTile == CursorTile)
	{
		return;
	}

	LastCursorTile = CursorTile;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', Unit)
	{
		UnitPawn = XGUnit( Unit.GetVisualizer( ) ).GetPawn( );

		// Conditional for ISsue #248
		// use the team from the unit state not the pawn: the pawn's
		// team does not update when teams are swapped.
		if ((UnitPawn == none) || (Unit.GetTeam() != eTeam_Neutral))
		{
			continue;
		}

		if( Unit.bRemovedFromPlay )
		{
			UnitPawn.DetachRangeIndicator();
			continue;
		}

		TileDiff.X = abs(CursorTile.X - Unit.TileLocation.X);
		TileDiff.Y = abs(CursorTile.Y - Unit.TileLocation.Y);
		TileDiff.Z = abs(CursorTile.Z - Unit.TileLocation.Z);

		ShouldDraw = UnitPawn.IsVisibleToTeam( eTeam_XCom ) &&
						!Unit.IsDead( ) && 
						// PI Added
						(IgnoreCursorLocation ||
							((TileDiff.X <= CivReactionTileRadius * 2) &&
							 (TileDiff.Y <= CivReactionTileRadius * 2) &&
							 (TileDiff.Z <= CivReactionTileRadius * 2)));

		if (ShouldDraw)
		{
			UnitPawn.AttachRangeIndicator( 2 * CivReactionWorldRadius, UnitPawn.CivilianRescueRing );
		}
		else
		{
			UnitPawn.DetachRangeIndicator( );
		}
	}
}

function SetEnabled( bool BeEnabled )
{
	Enabled = BeEnabled;
}
