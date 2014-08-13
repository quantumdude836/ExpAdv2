/* --- --------------------------------------------------------------------------------
	@: Entity Component
   --- */

EXPADV.ServerOperators( )

local Component = EXPADV.AddComponent( "entity", true )

/* --- --------------------------------------------------------------------------------
	@: Entity Class
   --- */

local EntityClass = Component:AddClass( "entity", "e" )

EntityClass:DefaultAsLua( Entity(0) )

/* --- --------------------------------------------------------------------------------
	@: Entity Events
   --- */

EXPADV.ServerEvents( )
Component:AddEvent( "onKill", "e,e,e", "" )
Component:AddEvent( "onDamage", "e,e,n,v", "" )
Component:AddEvent( "propBreak", "e,e", "" )

/* --- --------------------------------------------------------------------------------
	@: Server Hooks
   --- */

if SERVER then

   hook.Add( "PlayerDeath", "Expav.Event", function( Killed, Inflictor, Attacker )
		Attacker = Attacker or Entity( 0 )
		EXPADV.CallEvent( "onKill", Killed, Attacker, Inflictor or Attacker )
	end)

	hook.Add( "OnNPCKilled", "Expav.Event", function( Killed, Attacker, Inflictor )
		Attacker = Attacker or Entity( 0 )
		EXPADV.CallEvent( "onKill", Killed, Attacker, Inflictor or Attacker )
	end)

	hook.Add("EntityTakeDamage", "Expav.Event", function( Ent, Damage )
		local Attacker = Damage:GetAttacker( ) or Entity( 0 )
		local Num = Damage:GetDamage( ) or 0
		local Pos = Damage:GetDamagePosition( ) or Vector( 0, 0, 0 )
		EXPADV.CallEvent( "onDamage", Ent, Attacker, Num, Pos )
	end)

	hook.Add("PropBreak", "Expav.Event", function( Attacker, Ent )
		local Attacker = Attacker or Entity( 0 )
		EXPADV.CallEvent( "propBreak", Ent, Attacker )
	end)
	
end