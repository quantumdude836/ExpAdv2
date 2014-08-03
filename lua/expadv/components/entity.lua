/* --- --------------------------------------------------------------------------------
	@: Player Component
   --- */

EXPADV.ServerOperators( )

local EntityComponent = EXPADV.AddComponent( "entity", true )

/* --- --------------------------------------------------------------------------------
	@: Entity Class
   --- */

local EntityClass = EntityComponent:AddClass( "entity", "e" )

EntityClass:DefaultAsLua( Entity(0) )

/* --- --------------------------------------------------------------------------------
	@: Player Class
   --- */

local PlayerClass = EntityComponent:AddClass( "player", "ply" )

PlayerClass:DefaultAsLua( Entity(0) )

PlayerClass:ExtendClass( "e" )

