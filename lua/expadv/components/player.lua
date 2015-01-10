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

Component:AddInlineFunction( "isAdmin", "e:", "b", "(IsValid(@value 1) and @value 1:IsPlayer( ) and @value 1:IsAdmin( ))" )
Component:AddFunctionHelper( "isAdmin", "e:", "Returns true if the player is admin.")
Component:AddInlineFunction( "isSuperAdmin", "e:", "b", "(IsValid(@value 1) and @value 1:IsPlayer( ) and @value 1:IsSuperAdmin( ))" )
Component:AddFunctionHelper( "isSuperAdmin", "e:", "Returns true if the player is super admin.")

Component:AddInlineFunction("team", "ply:", "n", "( (IsValid(@value 1) and @value 1:IsPlayer( )) and @value 1:Team( ) or 0 )" )
Component:AddFunctionHelper("team", "ply:", "Returns the ID of player's team.")
Component:AddInlineFunction("teamName", "n", "s", "($team.GetName(@value 1) or \"\")" )
Component:AddFunctionHelper("teamName", "n", "Returns the name of given team ID.")
Component:AddInlineFunction("teamScore", "n", "n", "($team.GetScore(@value 1) or 0)" )
Component:AddFunctionHelper("teamScore", "n", "Returns the score of online players from the given team.")
Component:AddInlineFunction("playersInTeam", "n", "n", "($team.NumPlayers(@value 1) or 0)" )
Component:AddFunctionHelper("playersInTeam", "n", "Returns how many players from given team are online.")
Component:AddInlineFunction("teamDeaths", "n", "n", "($team.TotalDeaths(@value 1) or 0)" )
Component:AddFunctionHelper("teamDeaths", "n", "Returns deaths count of online players from the given team.")
Component:AddInlineFunction("teamFrags", "n", "n", "($team.TotalFrags(@value 1) or 0)" )
Component:AddFunctionHelper("teamFrags", "n", "Returns frags count of online players from the given team.")
Component:AddInlineFunction("teamColor", "n", "c", "$team.GetColor(@value 1)" )
Component:AddFunctionHelper("teamColor", "n", "Returns the color of given team ID.")

Component:AddInlineFunction("shootPos", "ply:", "v", "( IsValid(@value 1) and @value 1:GetShootPos() or Vector(0,0,0) )" )
Component:AddFunctionHelper("shootPos", "ply:", "Returns the player's head position.")
Component:AddInlineFunction("eye", "ply:", "v", "( IsValid(@value 1) and @value 1:GetAimVector() or @value 1:GetForward() or Vector(0,0,0)  )" )
Component:AddFunctionHelper("eye", "ply:", "Returns the player's view direction or forward direction.")
Component:AddInlineFunction("eyeAngles", "ply:", "a", "(IsValid(@value 1) and @value 1:EyeAngles() or Angle(0, 0, 0))" ) 
Component:AddFunctionHelper("eyeAngles", "ply:", "Returns the player's eye's angle.")
Component:AddInlineFunction("aimEntity", "ply:", "e", "( IsValid(@value 1) and @value 1:GetEyeTraceNoCursor().Entity or Entity(0))" )
Component:AddFunctionHelper("aimEntity", "ply:", "Returns the player's aim entity.")
Component:AddInlineFunction("aimNormal", "ply:", "v", "( IsValid(@value 1) and @value 1:GetEyeTraceNoCursor().HitNormal or Vector(0,0,0) )" )
Component:AddInlineFunction("aimPos", "ply:", "v", "( IsValid(@value 1) and @value 1:GetEyeTraceNoCursor().HitPos or Vector(0,0,0) )" )
Component:AddFunctionHelper("aimPos", "ply:", "Returns the player's aim position.")

Component:AddInlineFunction("steamID", "ply:", "s", "( IsValid(@value 1) and @value 1:SteamID() or \"\" )" )
Component:AddFunctionHelper("steamID", "ply:", "Returns the player's steamID.")
Component:AddInlineFunction("armor", "ply:", "n", "( IsValid(@value 1) and @value 1:Armor() or 0 )" )
Component:AddFunctionHelper("armor", "ply:", "Returns the player's armor.")
Component:AddInlineFunction("ping", "ply:", "n", "( IsValid(@value 1) and @value 1:Ping() or 0 )" )
Component:AddFunctionHelper("ping", "ply:", "Returns the player's ping.")
Component:AddInlineFunction("frags", "ply:", "n", "( IsValid(@value 1) and @value 1:Frags() or 0 )" )
Component:AddFunctionHelper("frags", "ply:", "Returns the player's frags.")
Component:AddInlineFunction("deaths", "ply:", "n", "( IsValid(@value 1) and @value 1:Deaths() or 0 )" )
Component:AddFunctionHelper("deaths", "ply:", "Returns the player's deaths.")
Component:AddInlineFunction("timeConnected", "ply:", "n", "( IsValid(@value 1) and @value 1:TimeConnected() or 0 )" )
Component:AddFunctionHelper("timeConnected", "ply:", "Returns the player's current session time.")
Component:AddInlineFunction("vehicle", "ply:", "e", "( IsValid(@value 1) and @value 1:GetVehicle() or Entity(0))" )
Component:AddFunctionHelper("vehicle", "ply:", "Returns the player's vehicle or null entity.")
Component:AddInlineFunction("inNoclip", "ply:", "b", "( IsValid(@value 1) and (@value 1:GetMoveType() == $MOVETYPE_NOCLIP) )" )
Component:AddFunctionHelper("inNoclip", "ply:", "Returns true if the player is in noclip.")
Component:AddInlineFunction("flashLight", "ply:", "b", "(IsValid(@value 1) and @value 1:FlashlightIsOn( ))" )
Component:AddFunctionHelper("flashLight", "ply:", "Returns true if the player's flash light is on.")

Component:AddInlineFunction("getEquipped", "ply:", "e", "(IsValid(@value 1) and (@value 1:GetActiveWeapon() or Entity(0)) or Entity(0) )" )
Component:AddFunctionHelper("getEquipped", "ply:", "Returns the player's current weapon or null entity.")

local FuncKeys = {
	["leftClick"] = {IN_ATTACK, "left mouse button"},
	["rightClick"] = {IN_ATTACK2, "right mouse button"},
	["keyForward"] = {IN_FORWARD, "forward key"},
	["keyLeft"] = {IN_MOVELEFT, "left key"},
	["keyBack"] = {IN_BACK, "backward key"},
	["keyRight"] = {IN_MOVERIGHT, "right key"},
	["keyJump"] = {IN_JUMP, "jump key"},
	["keyUse"] = {IN_USE, "use key"},
	["keyReload"] = {IN_RELOAD, "reload key"},
	["keyZoom"] = {IN_ZOOM, "zoom key"},
	["keyWalk"] = {IN_WALK, "walk key"},
	["keySprint"] = {IN_SPEED, "sprint key"},
	["keyDuck"] = {IN_DUCK, "duck key"},
	["keyLeftTurn"] = {IN_LEFT, "left turn key"},
	["keyRightTurn"] = {IN_RIGHT, "right turn key"}
}

for Name, Enum in pairs( FuncKeys ) do
	Component:AddInlineFunction( Name, "ply:", "b", "(IsValid(@value 1) and @value 1:KeyDown( " .. Enum[1] .. " ) )" )
	Component:AddFunctionHelper( Name, "ply:", "Returns true if the player's " .. Enum[2] .. " is pressed." )
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

Component:AddInlineFunction("voiceVolume", "ply:", "n", "@value 1:VoiceVolume()")
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

