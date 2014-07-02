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

if SERVER then util.AddNetworkString( "expadv.config" ) end

function EXPADV.LoadCore( )
	EXPADV.LoadConfig( )

	EXPADV.IncludeCore( )

	include( "expadv/components/core.lua" )
	include( "expadv/components/number.lua" )
	include( "expadv/components/string.lua" )
	include( "expadv/components/color.lua" )

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
		net.Start( "expadv.config")
			net.WriteTable( EXPADV.Config )
		net.Broadcast( )

		hook.Add( "PlayerInitialSpawn", "lemon.config", function( Player )
			net.Start( "expadv.config")
				net.WriteTable( EXPADV.Config )
			net.Send( Player )
		end )
	end
	
	EXPADV.IsLoaded = true

	EXPADV.CallHook( "PostLoadCore" )
end

if CLIET then
	net.Receive( "expadv.config", function( )
		EXPADV.Config = net.ReadTable ( )

		EXPADV.LoadCore( )
	end )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Hooks.
   --- */

   -- Think( )							| Void | Called once per think, this is for convenience.
   -- PostLoadCore( )					| Void | Called after the core has finished loading.
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

   --  function Component:OnPostLoadAliases( ) end
   --  hook.Add( "Expadv.PostLoadAliases", ... )
   -- *Also avaible on Context -> function Context:OnScriptError( Result ) end

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
	@: Convenience hooks.
   --- */
   
hook.Add( "Think", "ExpAdv2.Hook", function( )
	local Ok, Msg = pcall( EXPADV.CallHook, "Think" )
	if !Ok then MsgN( "ExpAdv2 - Error in main Think hook: ", Msg ) end
end )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: API.
   --- */

if CLIENT then
	hook.Add( "GComputeLoaded", "ExpAdv.GCompute", function( )
		include( "expadv/api/gcompute.lua")
	end )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Test Build.
   --- */

hook.Add( "Initialize", "lemon.babysteps", function( )
	EXPADV.LoadCore( )
end )



