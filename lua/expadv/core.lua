/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Create the Expression Advanced Namespace.
   --- */

EXPADV = { }

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

	MsgN( "ExpAdv: Loaded config file, sucessfully.")

	EXPADV.Config = Config
end

function EXPADV.SaveConfig( )
	-- EXPADV.RunHook( "PreSaveConfig", EXPADV.Config )

	file.Write( "expadv.txt", util.TableToKeyValues( EXPADV.Config ) )
end

function EXPADV.CreateSetting( Name, Default )
	Name = string.lower( Name )

	EXPADV.Config.Settings[ Name ] = Config.Settings[ Name ] or Default
end

function EXPADV.ReadSetting( Name, Default )
	return EXPADV.Config.Settings[ string.lower( Name ) ] or Default
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: We have files to load, lets load them.
   --- */

function EXPADV.IncludeCore( )
	include( "expadv/components.lua" )
	include( "expadv/classes.lua" )
	include( "expadv/operators.lua" )
	include( "expadv/context.lua" )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Lets loads the core.
   --- */

if SERVER then util.AddNetworkString( "expadv.config" ) end

function EXPADV.LoadCore( )
	EXPADV.LoadConfig( )

	EXPADV.IncludeCore( )

	include( "expadv/components/number.lua" )

	EXPADV.LoadComponents( )

	EXPADV.LoadClasses( )

	EXPADV.LoadOperators( )

	EXPADV.LoadFunctions( )

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
		
end

if CLIET then
	net.Receive( "expadv.config", function( )
		EXPADV.Config = net.ReadTable ( )

		EXPADV.LoadCore( )
	end )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Entity Registery.
   --- */

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Test Build.
   --- */

hook.Add( "Initialize", "lemon.babysteps", function( )
	EXPADV.LoadCore( )
end )



