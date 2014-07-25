/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Create the Expression Advanced Namespace.
   --- */

EXPADV = { }

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Sometimes We might need to convert objects into native.
   --- */

local Cache, ToLua, ToLuaTable = { }

EXPADV.__Cache = Cache

function ToLua( Value, bNoTables )
	if !Value then return "nil" end
	
	local Type = type(Value)
	
	if Type == "number" then
		return Value
	elseif Type == "string" then
		return string.format( "%q", Value )
	elseif Type == "boolean" then
		return Value and "true" or "false"
	elseif Type == "table" and !bNoTables then
		return ToLuaTable( Value )
	elseif Type == "function" and !NoTables then
		local Index = #Cache + 1
		Cache[Index] = Value
		return "EXPADV.__Cache[" .. Index .. "]"
	end
end

EXPADV.ToLua = ToLua

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: We need config files.
   --- */

function ToLuaTable( Table )
	local Lua = "{"
	
	for Key, Value in pairs(Table) do
		local kLua = ToLua( Key, true )
		local vLua = ToLua( Value )
		
		if !kLua then
			error("TableToLua invalid Key of type " .. type(Key))
		elseif !vLua then
			error("TableToLua invalid Value of type " .. type(Value))
		end
		
		Lua = string.format( "%s[%s] = %s, ", Lua, kLua, vLua )
		
		--Lua .. "[" .. kLua .. "] = " .. vLua .. ", ")
	end
	
	return Lua .. "}"
end

EXPADV.ToLuaTable = ToLuaTable

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: We need config files.
   --- */

EXPADV.Config = { }

function EXPADV.LoadConfig( )
	local Config = { }

	if file.Exists( "expadv.txt", "DATA" ) then
		Config = util.KeyValuesToTable( file.Read( "expadv.txt", "DATA" ) )
	end
	
	Config.EnabledComponents = Config.EnabledComponents or { }

	Config.Components = Config.Components or { }

	Config.Settings = Config.Settings or { }

	MsgN( "ExpAdv: Loaded config file, sucessfully." )

	EXPADV.Config = Config

	EXPADV.CallHook( "PostLoadConfig", Config )
end

-- Saves the config file.
function EXPADV.SaveConfig( )
	EXPADV.CallHook( "PreSaveConfig", EXPADV.Config )

	file.Write( "expadv.txt", util.TableToKeyValues( EXPADV.Config ) )
end

-- Creates a new setting on the config.
function EXPADV.CreateSetting( Name, Default ) -- String, Obj
	Name = string.lower( Name )

	EXPADV.Config.Settings[ Name ] = Config.Settings[ Name ] or Default
end

-- Reads a setting from the config.
function EXPADV.ReadSetting( Name, Default ) -- String, Obj
	return EXPADV.Config.Settings[ string.lower( Name ) ] or Default
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Exceptions
   --- */

local Temp_Exceptions = { }

-- Registers a new exception type.
function EXPADV.AddException( Component, Exception ) -- Table, String
	Temp_Exceptions[ #Temp_Exceptions + 1 ] = { Component = Component, Exception = Exception }
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: We have files to load, lets load them.
   --- */

function EXPADV.IncludeCore( )
	include( "expadv/components.lua" )
	include( "expadv/classes.lua" )
	include( "expadv/operators.lua" )
	include( "expadv/events.lua" )
	include( "expadv/context.lua" )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Lets loads the core.
   --- */

function EXPADV.AddComponentFile( FileName )
	EXPADV.SharedOperators( )
	MsgN( "Loading Component: " .. FileName )
	include( "expadv/components/" .. FileName .. ".lua" )
end

function EXPADV.LoadCore( )
	if EXPADV.IsLoaded then
		EXPADV.CallHook( "UnloadCore" )
		EXPADV.IsLoaded = nil
	end

	EXPADV.LoadConfig( )

	EXPADV.IncludeCore( )

	EXPADV.AddComponentFile( "core" )
	EXPADV.AddComponentFile( "number" )
	EXPADV.AddComponentFile( "string" )
	EXPADV.AddComponentFile( "color" )
	EXPADV.AddComponentFile( "vector" )

	EXPADV.LoadComponents( )

	EXPADV.LoadClasses( )

	EXPADV.LoadOperators( )

	EXPADV.LoadFunctions( )

	EXPADV.LoadEvents( )

	EXPADV.Exceptions = { stack = "stack" }

	for I = 1, #Temp_Exceptions do
		local Exception = Temp_Exceptions[I]

		if Exception.Component and !Exception.Component.Enabled then
			continue
		end

		EXPADV.Exceptions[ Exception.Exception ] = Exception.Exception
	end
	
	include( "expadv/compiler/main.lua" )

	EXPADV.SaveConfig( )

	if SERVER then
		EXPADV.SendInitalDataStream( )

		hook.Add( "PlayerInitialSpawn", "expadv.initaldatastream", function( Player )
			EXPADV.SendInitalDataStream( Player )
		end )
	end
	
	EXPADV.IsLoaded = true

	EXPADV.CallHook( "PostLoadCore" )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Hooks.
   --- */

   -- Think( )							| Void | Called once per think, this is for convenience.
   -- PostLoadCore( )					| Void | Called after the core has finished loading.
   -- UnloadCore( )						| Void | Called before the core reloads.
   -- PostLoadConfig( Config )			| Void | Called after the main config has loaded.
   -- PreSaveConfig( Config )			| Void | Called before saving the main config file.
   -- PostLoadComponents( ) 			| Void | Called once all components have been loaded.
   -- EnableComponent( Component ) 		| Void | Called after a component enables.
   -- PreLoadOperators( )				| Void | Called before operators are loaded.
   -- PostLoadOperators( )				| Void | Called after operators are loaded.
   -- PreLoadFunctions( )				| Void | Called before functions are loaded.
   -- PostLoadFunctions( )				| Void | Called after functions are loaded.
   -- PreLoadAliases( )					| Void | Called before function aliases are loaded.
   -- PostLoadAliases( )				| Void | Called after function aliases are loaded.
   -- PreLoadClasses( )					| Void | Called before classes are loaded.
   -- PostLoadClasses( )				| Void | Called after classes are loaded.
   -- PostLoadClassAliases( )			| Void | Called after classes and class aliases are loaded.
   -- PreRegisterClass( Short, Class )	| Void | Called once per class, before class loading begins (classes can be created here).
   -- PostRegisterClass( Name, Class )	| Void | Called after each class has been registered and loaded.
   -- PreLoadCompiler( BaseCompiler )	| Void | Called before the compiler is loaded.
   -- PostLoadCompiler( BaseCompiler )	| Void | Called after the compiler is loaded.
   -- BuildCompilerTokens( TokenArray )	| Void | Called before the compiler builds it token list.
   -- RegisterContext( Context )*		| Void | Called when a context is registered to the core.
   -- UnregisterContext( Context )*		| Void | Called when a context is unregistered from the core.
   -- LuaError( Context, Error )*		| Void | Called when an executing context throws a lua error.
   -- ScriptError( Context, Error )*	| Void | Called when an executing context throws a script error.
   -- Exception( Context, Exception )*	| Void | Called when an executing context receives an uncatched exception.
   -- StartUp( Context )*				| Void | Called before the initial root execution.
   -- ShutDown( Context )*				| Void | Called after the context has shutdown.
   -- Update( Context )*				| Void | Called every tick, when a context has ran that tick.
   -- ClientLoaded( Entity, Player )	| Void | Called server side once a client confirms an entity has loaded its script.
   -- BuildHologramModels( Table )		| Void | Called when the hologram model look up is made.
   -- GetDataStream( DataTable )		| Void | Called clientside when data needs to be sent.

   --  function Component:OnPostLoadAliases( ) end
   --  hook.Add( "Expadv.PostLoadAliases", ... )
   -- *Also avaible on Context -> function Context:OnScriptError( Result ) end
   -- @GitHub: Please request hooks, and return behavours via issue page.

function EXPADV.CallHook( Name, ... )
	
	if EXPADV.Components then
		for _, Component in pairs( EXPADV.Components ) do
			if !Component.Enabled then continue end -- Shouldn't be possible!

			local Hook = Component["On" .. Name]
			
			if !Hook then continue end

			local Results = { Hook( Component, ... ) }
			if Results[1] ~= nil then return unpack( ... ) end
		end
	end
	
	return hook.Run( "Expadv." .. Name, ... )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: We need a data stream, this will use vnet.
   --- */

   -- Usage:
   -- hook.Add -> "Expadv.PreBuildDataStream" -> ( DataTable, Inital Send )
   -- hook.Add -> "Expadv.PostBuildDataStream" -> ( DataTable, Inital Send )
   -- Component:BuildDataStream( Inital Send ) -> return Key, Value
   -- Will sync clients via 1 data stream per tick, 

require( "vnet" )

if SERVER then

	util.AddNetworkString( "expadv.stream" )

	function EXPADV.BuildDataStream( Data, Force )
		local SendCount = 0

		hook.Run( "Expadv.PreBuildDataStream", Data, Force )

		if EXPADV.Components then
			for _, Component in pairs( EXPADV.Components ) do

				if !Component.Enabled then continue end

				local Func = Component["BuildDataStream"]
				
				if !Func then continue end

				local Key, Value = Func( Force )

				if Key and Key ~= "" and key ~="config" and Value then
					Data[Key] = Value

					SendCount = SendCount + 1
				end
			end
		end

		hook.Run( "Expadv.PostBuildDataStream", Data, Force )

		return SendCount
	end

	function EXPADV.SendInitalDataStream( Player )
		
		if !IsValid( Player ) and #player.GetAll( ) == 0 then return end

		local DataStream = { }

		DataStream.config = EXPADV.Config

		EXPADV.BuildDataStream( DataStream, true )

		local Package = vnet.CreatePacket( "expadv.stream" )

		Package:Table( DataStream )

		Package:AddTargets( IsValid( Player ) and { Player } or player.GetAll( ) )

		Package:Send( )
	end

	function EXPADV.SendDataStream( )
		if #player.GetAll( ) == 0 then return end

		local DataStream = { }

		if EXPADV.BuildDataStream( DataStream, false ) > 0 then

			local Package = vnet.CreatePacket( "expadv.stream" )

			Package:Table( DataStream )

			Package:AddTargets( player.GetAll( ) )

			Package:Send( )

		end
	end

	hook.Add( "Thick", "expadv.Stream", function( )
		local Ok, Msg = pcall( EXPADV.SendDataStream )
		
		if !Ok then
			MsgN( "ExpAdv2 - Error in main Data stream: ", Msg )
		end
	end )

else

	vnet.Watch( "expadv.stream", function( Package )
		local Data = Package:Table( )

		if Data.config then
			EXPADV.Config = Data.config 
			
			Data.config = nil

			EXPADV.LoadCore( )
		end

		EXPADV.CallHook( "GetDataStream", Data )
	end )

end
/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Convenience hooks.
   --- */
   
hook.Add( "Think", "expadv.Hook", function( )
	local Ok, Msg = pcall( EXPADV.CallHook, "Think" )
	
	if !Ok then
		MsgN( "ExpAdv2 - Error in main Think hook: ", Msg )
	end
end )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: API.
   --- */

if CLIENT then
	hook.Add( "GComputeLoaded", "expadv.GCompute", function( )
		include( "expadv/api/gcompute.lua")
	end )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Load Core.
   --- */

if SERVER then
	hook.Add( "Initialize", "expadv.Loadcore", function( )
		EXPADV.LoadCore( )
	end )

	concommand.Add( "expadv_reload", function( Player )
		EXPADV.LoadCore( )
	end )
end