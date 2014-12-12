/* --- --------------------------------------------------------------------------------
	@: Player Component
   --- */

EXPADV.SharedOperators( )

local Component = EXPADV.AddComponent( "player", true )

Component.Author = "Rusketh"
Component.Description = "Allows for player interaction."

/* --- --------------------------------------------------------------------------------
	@: Player Class
   --- */

local PlayerClass = Component:AddClass( "player", "ply" )

PlayerClass:DefaultAsLua( Entity(0) )

PlayerClass:ExtendClass( "e" )

/* --- --------------------------------------------------------------------------------
	@: Logical and Comparison
   --- */

EXPADV.SharedOperators( )

Component:AddInlineOperator( "==", "ply,ply", "b", "(@value 1 == @value 2)" )
Component:AddInlineOperator( "!=", "ply,ply", "b", "(@value 1 ~= @value 2)" )

Component:AddInlineOperator( "==", "ply,e", "b", "(@value 1 == @value 2)" )
Component:AddInlineOperator( "!=", "ply,e", "b", "(@value 1 ~= @value 2)" )

Component:AddInlineOperator( "==", "e,ply", "b", "(@value 1 == @value 2)" )
Component:AddInlineOperator( "!=", "e,ply", "b", "(@value 1 ~= @value 2)" )

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

Component:AddInlineFunction( "owner", "", "ply", "Context.player")
Component:AddFunctionHelper( "owner", "", "Returns the owner of the gate.")

Component:AddInlineFunction("isAdmin", "e:", "b", "(IsValid(@value 1) and @value 1:IsPlayer( ) and @value 1:IsAdmin( ))" )
Component:AddInlineFunction("isSuperAdmin", "e:", "b", "(IsValid(@value 1) and @value 1:IsPlayer( ) and @value 1:IsSuperAdmin( ))" )

Component:AddInlineFunction("team", "ply:", "n", "( (IsValid(@value 1) and @value 1:IsPlayer( )) and @value 1:Team( ) or 0 )" )
Component:AddInlineFunction("teamName", "n", "s", "($team.GetName(@value 1) or \"\")" )
Component:AddInlineFunction("teamScore", "n", "n", "($team.GetScore(@value 1) or 0)" )
Component:AddInlineFunction("playersInTeam", "n", "n", "($team.NumPlayers(@value 1) or 0)" )
Component:AddInlineFunction("teamDeaths", "n", "n", "($team.TotalDeaths(@value 1) or 0)" )
Component:AddInlineFunction("teamFrags", "n", "n", "($team.TotalFrags(@value 1) or 0)" )
Component:AddInlineFunction("teamColor", "n", "c", "$team.GetColor(@value 1)" )

Component:AddInlineFunction("shootPos", "ply:", "v", "( IsValid(@value 1) and @value 1:GetShootPos() or Vector(0,0,0) )" )
Component:AddInlineFunction("eye", "ply:", "v", "( IsValid(@value 1) and @value 1:GetAimVector() or @value 1:GetForward() or Vector(0,0,0)  )" )
Component:AddInlineFunction("eyeAngles", "ply:", "a", "(IsValid(@value 1) and @value 1:EyeAngles() or Angle(0, 0, 0))" ) 
Component:AddInlineFunction("aimEntity", "ply:", "e", "( IsValid(@value 1) and @value 1:GetEyeTraceNoCursor().Entity or Entity(0))" )
Component:AddInlineFunction("aimNormal", "ply:", "v", "( IsValid(@value 1) and @value 1:GetEyeTraceNoCursor().HitNormal or Vector(0,0,0) )" )
Component:AddInlineFunction("aimPos", "ply:", "v", "( IsValid(@value 1) and @value 1:GetEyeTraceNoCursor().HitPos or Vector(0,0,0) )" )

Component:AddInlineFunction("steamID", "ply:", "s", "( IsValid(@value 1) and @value 1:SteamID() or \"\" )" )
Component:AddInlineFunction("armor", "ply:", "n", "( IsValid(@value 1) and @value 1:Armor() or 0 )" )
Component:AddInlineFunction("ping", "ply:", "n", "( IsValid(@value 1) and @value 1:Ping() or 0 )" )
Component:AddInlineFunction("frags", "ply:", "n", "( IsValid(@value 1) and @value 1:Frags() or 0 )" )
Component:AddInlineFunction("deaths", "ply:", "n", "( IsValid(@value 1) and @value 1:Deaths() or 0 )" )
Component:AddInlineFunction("timeConnected", "ply:", "n", "( IsValid(@value 1) and @value 1:TimeConnected() or 0 )" )
Component:AddInlineFunction("vehicle", "ply:", "e", "( IsValid(@value 1) and @value 1:GetVehicle() or Entity(0))" )
Component:AddInlineFunction("inNoclip", "ply:", "b", "( IsValid(@value 1) and (@value 1:GetMoveType() == $MOVETYPE_NOCLIP) )" )
Component:AddInlineFunction("flashLight", "ply:", "b", "(IsValid(@value 1) and @value 1:FlashlightIsOn( ))" )

Component:AddInlineFunction("getEquipped", "ply:", "e", "(IsValid(@value 1) and (@value 1:GetActiveWeapon() or Entity(0)) or Entity(0) )" )

local FuncKeys = {
	["leftClick"] = IN_ATTACK,
	["rightClick"] = IN_ATTACK2,
	["keyForward"] = IN_FORWARD,
	["keyLeft"] = IN_MOVELEFT,
	["keyBack"] = IN_BACK,
	["keyRight"] = IN_MOVERIGHT,
	["keyJump"] = IN_JUMP,
	["keyUse"] = IN_USE,
	["keyReload"] = IN_RELOAD,
	["keyZoom"] = IN_ZOOM,
	["keyWalk"] = IN_WALK,
	["keySprint"] = IN_SPEED,
	["keyDuck"] = IN_DUCK,
	["keyLeftTurn"] = IN_LEFT,
	["keyRightTurn"] = IN_RIGHT,
}

for Name, Enum in pairs( FuncKeys ) do
	Component:AddInlineFunction( Name, "ply:", "b", "(IsValid(@value 1) and @value 1:KeyDown( " .. Enum .. " ) )" )
end

Component:AddVMFunction( "players", "", "ar", 
	function( Context, Trace )
		local Array = { __type = "_ply" }

		for _, Player in pairs( player.GetAll( ) ) do
			Array[#Array +1] = Player
		end

		return Array
	end )

Component:AddFunctionHelper( "players", "", "Returns an array of players.")

EXPADV.ClientOperators( )

Component:AddInlineFunction( "localPlayer", "", "ply", "$LocalPlayer()")
Component:AddFunctionHelper( "localPlayer", "", "Returns the clientside player.")

Component:AddInlineFunction("voiceVolume", "ply:", "", "@value 1:VoiceVolume()")
Component:AddFunctionHelper("voiceVolume", "ply:", "Returns the volume of the player's voice")

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
		local Result, ResultType = EXPADV.CallPlayerReturnableEvent( Player, "playerChat", Player, Text, Team )
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