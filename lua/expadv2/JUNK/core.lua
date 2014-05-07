/* ---
	@: Expression Advanced 2.
	@: Because the old one was shit.
	@: Team SpaceTown -> Rusketh, Oskar_
   --- */

/* ---
	@: Create the API.
   --- */

EXPADV = { }

/* ---
	@: The api needs a event system.
   --- */

function EXPADV.APICall( Event, ... )

	for _, Component in pairs( Components ) do
		if !Component.Enabled then continue end

		local handeler = Component[ Event ]
		if !handeler then continue end

		local _1, _2, _3 =  handeler( Component, ... )
		if _1 ~= nil then continue end

		return _1, _2, _3 -- Looks nicer like this :D
	end

	return hook.Run( "ExpAdv." .. Event, ... )
end

/* ---
	@: We need a way to sync to the client, we make a datapack to od this.
   --- */

require( "von")

EXPADV.DataPack = { }

if Server then

	local CompDataPack, CompDataSize

	function EXPADV.CreateDataPack( )
		EXPADV.APICall( "PreBuildDataPack", DataPack )

		CompDataPack = util.Compress( von.serialize( DataPack ) )
		CompDataSize = #CompDataPack

		EXPADV.APICall( "PostBuildDataPack", CompDataPack )
	end

	function SendDataPack( ePlayer )
		net.Start( "ExpAdv.DataPack" )
			net.WriteUInt( CompDataSize, 32 ) -- Full Int
			net.WriteData( CompDataPack, CompDataSize )
		net.Send( ePlayer )
	end

	function BoradCastDataPack( )
		net.Start( "ExpAdv.DataPack" )
			net.WriteUInt( CompDataSize, 32 ) -- Full Int
			net.WriteData( CompDataPack, CompDataSize )
		net.Broadcast( )
	end

end

/* ------------------------------------------------------------------------ */

if CLIENT then

	net.Receive( "ExpAdv.DataPack", function( nBytes )
		MsgN( "ExpAdv: Received data pack from server." )

		EXPADV.DataPack = von.deserialize( net.ReadData( net.ReadUInt( 32 ) ) )

		MsgN( "ExpAdv: Sucessfully decompressed data pack." )

		EXPADV.APICall( "LoadDataPack", EXPADV.DataPack )
	end )

end

/* ---
	@: Config System.
   --- */

EXPADV.Config = { }

function EXPADV.LoadConfig( )
	local Config

	if file.Exists( "expadv.txt", "DATA" ) then
		Config = util.KeyValuesToTable( file.Read( "expadv.txt", "DATA" ) )
	end

	if !Config then error( "ExpAdv: Failed to load config file.", 0 ) end

	Config.Components = Config.Components or { }

	Config.Settings = Config.Settings or { }

	MsgN( "ExpAdv: Loaded config file, sucessfully.")

	EXPADV.Config = Config
end

function EXPADV.SaveConfig( )
	EXPADV.APICall( "PreSaveConfig", EXPADV.Config )

	file.Write( "expadv.txt", util.TableToKeyValues( EXPADV.Config ) )
end

function EXPADV.CreateSetting( Name, Default )
	Name = string.lower( Name )

	EXPADV.Config.Settings[ Name ] = Config.Settings[ Name ] or Default
end

function EXPADV.ReadSetting( Name, Default )
	return EXPADV.Config.Settings[ string.lower( Name ) ] or Default
end


function BuildComponents( )
	MsgN( "ExpAdv: Loading components:")

	for Name, Component in pairs( Components ) do
		local Enabled = tobool( Config.Components[ Name ] ) or Component.Enabled

		Config.Components[ Name ] = Enabled and 1 or 0

		Component.Enabled = Enabled

		if !Enabled then continue end

		if Component.OnEnable then Component:OnEnable( ) end

		MsgN( "-> " .. Component.Name .. ".")
	end

	APICall( "PostBuildComponents" )
end

/* ---
	@: TODO - Port Interface.
   --- */

/* ---
	@: TODO - Load Core.
   --- */

/* ---
	@: We to add some network strings, for our net messages.
   --- */

if SERVER then
	util.AddNetworkString( "ExpAdv.DataPack" )
end

/* ---
	@: We also need some hooks.
   --- */

if SERVER then
	hook.Add( "PlayerInitalSpawn", "ExpAdv.DataPack", SendDataPack )
end