/* --- --------------------------------------------------------------------------------
	@: Player Component
   --- */

EXPADV.ServerOperators( )

local Component = EXPADV.AddComponent( "player", true )

/* --- --------------------------------------------------------------------------------
	@: Player Class
   --- */

local PlayerClass = Component:AddClass( "player", "ply" )

PlayerClass:DefaultAsLua( Entity(0) )

PlayerClass:ExtendClass( "e" )

/* --- --------------------------------------------------------------------------------
	@: Casting
   --- */

Component:AddInlineOperator( "player", "e", "ply", "((IsValid(@value 1) and @value 1:IsPlayer( )) and @value 1 or $Entity(0))" )

Component:AddInlineOperator( "entity", "ply", "e", "@value 1" )

/* --- --------------------------------------------------------------------------------
	@: Functions
   --- */

Component:AddInlineFunction( "isPlayer", "e:", "b", "(IsValid(@value 1) and @value 1:IsPlayer( ))")
Component:AddFunctionHelper( "isPlayer", "e:", "Returns true if the entity is a player.")

/* --- --------------------------------------------------------------------------------
	@: 
   --- */

/* --- --------------------------------------------------------------------------------
	@: Player Events
   --- */

EXPADV.SharedEvents( )
Component:AddEvent( "playerNoClip", "ply,b", "" )
Component:AddEvent( "playerEnterVehicle", "ply,e,n", "" )

EXPADV.ServerEvents( )
Component:AddEvent( "playerSpawn", "ply", "" )
Component:AddEvent( "playerJoin", "ply", "" )
Component:AddEvent( "playerQuit", "ply", "" )
Component:AddEvent( "playerChat", "ply,s,b", "s" )
Component:AddEvent( "playerSpray", "ply", "" )
Component:AddEvent( "playerExitVehicle", "ply,e", "" )

/* --- --------------------------------------------------------------------------------
	@: Server Hooks
   --- */

if SERVER then
	hook.Add( "PlayerSpawn", "Expav.Event", function( Player )
		EXPADV.CallEvent( "playerSpawn", Player )
	end )

	hook.Add( "PlayerInitialSpawn", "Expav.Event", function( Player )
		EXPADV.CallEvent( "playerJoin", Player )
	end )

	hook.Add( "PlayerDisconnected", "Expav.Event", function( Player )
		EXPADV.CallEvent( "playerQuit", Player )
	end )

	hook.Add( "PlayerSay", "Expav.Event", function( Player, Text, Team )
		local Result, ResultType = EXPADV.CallPlayerReturnableEvent( "playerChat", Player, Player, Text, Team )
		if Result and ResultType == "s" then return Result end
	end )

	hook.Add( "PlayerSpawn", "Expav.Event", function( Player )
		EXPADV.CallEvent( "playerSpawn", Player )
	end )

	hook.Add( "PlayerSpray", "Expav.Event", function( Player )
		EXPADV.CallEvent( "playerSpray", Player )
	end )

	hook.Add( "PlayerLeaveVehicle", "Expav.Event", function( Player, Car )
		EXPADV.CallEvent( "playerExitVehicle", Player, Car or Entity(0) )
	end )
end

/* --- --------------------------------------------------------------------------------
	@: Client Hooks
   --- */

if CLIENT then

end

/* --- --------------------------------------------------------------------------------
	@: Shared Hooks
   --- */

	hook.Add( "PlayerNoClip", "Expav.Event", function( Player, State )
		EXPADV.CallEvent( "playerNoClip", Player, State )
	end )

	hook.Add( "PlayerEnteredVehicle", "Expav.Event", function( Player, Car, Role )
		EXPADV.CallEvent( "playerEnterVehicle", Player, Car or Entity(0), Role or 0 )
	end )