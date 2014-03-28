/* ---
	@: Expression Advanced 2.
	@: Because the old one was shit.
	@: Team SpaceTown -> Rusketh, Oskar_
   --- */

/* ---
	@: The Language's core, is now officaly a package.
   --- */

module( "expadv", package.seeall )

/* ---
	@: First lets add some simple util packages.
   --- */

__cache, toLua = { }

function toLua( Value, bNoTables )
	if !Value then return "nil" end
	
	local Type = type(Value)
	
	if Type == "number" then
		return Value
	elseif Type == "string" then
		return string.Format( "%q", Value )
	elseif Type == "boolean" then
		return Value and "true" or "false"
	elseif Type == "table" and !bNoTables then
		return toLuaTable( Value )
	elseif Type == "function" and !NoTables then
		local Index = #__cache + 1
		Util.__cache[Index] = Value
		return "expadv.__cache[" .. Index .. "]"
	end
end

function toLuaTable( Table )
	local Lua = "{"
	
	for Key, Value in pairs(Table) do
		local kLua = toLua( Key, true )
		local vLua = toLua( Value )
		
		if !kLua then
			error("TableToLua invalid Key of type " .. type(Key))
		elseif !vLua then
			error("TableToLua invalid Value of type " .. type(Value))
		end
		
		Lua = Lua .. "[" .. kLua .. "] = " .. vLua .. ", "
	end
	
	return Lua .. "}"
end

/* ---
	@: We need a basic component system.
	@: This will be improved further down.
   --- */

local Components = { }

local BaseComponent = { Name = "BASE", Enabled = false }

BaseComponent.__index = BaseComponent

function GetBaseComponent( )
	return BaseClass
end

function NewComponent( Name, bEnabled )
	local New = setmetatable( { Name = Name, Enabled = bEnabled or false }, BaseComponent )
	
	Components[ string.lower( Name ) ] = New

	return New
end

/* ---
	@: The api needs a event system.
   --- */

function APICall( Event, ... )

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

DataPack = { }

if Server then

	local CompDataPack, CompDataSize

	function CreateDataPack( )
		APICall( "PreBuildDataPack", DataPack )

		CompDataPack = util.Compress( von.serialize( DataPack ) )
		CompDataSize = #CompDataPack

		APICall( "PostBuildDataPack", CompDataPack )
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

elseif CLIENT then

	net.Receive( "ExpAdv.DataPack", function( nBytes )
		MsgN( "ExpAdv: Received data pack from server." )

		DataPack = von.deserialize( net.ReadData( net.ReadUInt( 32 ) ) )

		MsgN( "ExpAdv: Sucessfully decompressed data pack." )

		APICall( "PostBuildDataPack", CompDataPack )
	end )

end

/* ---
	@: Config System.
   --- */

Config

function LoadConfig( )
	if !file.Exists( "expadv.txt", "DATA" ) then
		Config = { }
	else
		Config = util.KeyValuesToTable( file.Read( "expadv.txt", "DATA" ) )
	end

	if !Config then error( "ExpAdv: Failed to load config file.", 0 ) end

	Config.Components = Config.Components or { }

	Config.Settings = Config.Settings or { }

	MsgN( "ExpAdv: Loaded config file, sucessfully.")
end

function SaveConfig( )
	APICall( "PreSaveConfig", Config )

	file.Write( "expadv.txt", util.TableToKeyValues( Config ) )
end

function CreateSetting( Name, Default )
	Name = string.lower( Name )

	Config.Settings[ Name ] = Config.Settings[ Name ] or Default
end

function ReadSetting( Name, Default )
	return Config.Settings[ string.lower( Name ) ] or Default
end

/* ---
	@: Class system.
   --- */

ClassTable = { }

local ClassID, ClassName = { }, { }

local BaseClass = { Name = "BASE", ID = "#" }

BaseClass.__index = BaseClass

function GetBaseClass( )
	return BaseClass
end

function NewClass( Name, ID )
	ID = string.lower( ID )
	Name = string.lower( Name )

	local Class = setmetatable( { Name = Name, ID = ID }, BaseClass )
	
	if #ID >= 2 then ID = "_" .. ID end

	table.insert( ClassTable, Class )

	return Class
end

function GetClass( _Name , bNameOnly, bNoError )
	Name = string.lower( _Name )

	local Class = ClassName[ Name ]
	if Class or !bNameOnly then return Class end

	if #Name >= 2 and Name[1] ~= "_" then
		Name = "_" .. Name
	end
	
	Class = ClassID[ Name ]

	if Class then return Class end

	if bNoError then
		error( "ExprAdv: Could not find class " .. _Name )
	end
end


function BaseClass:Extends( ClassName )
	self.Extends = ClassName
end

function BaseClass:Default( Value )
	self.asNative = toLua( Value, false )
end

function BuildClasses( )

	ClassID = { }
	ClassName  = { }

	APICall( "PreBuildClass" )

	for _, Class in pairs( ClassTable ) do

		if Class.Component and !Class.Component.Enabled then
			continue -- We wont load any disabled class.
		elseif Class.Component then
			Class.Component = Class.Component.Name
		end

		ClassID[ Class.ID ] = Class
		ClassName[ Class.Name ] = Class

	end

	for _, Class in pairs( ClassTable ) do
		if Class.Extends then
			local Extends = GetClass( Class.Extends, false, true )

			if !Extends then
				ClassID[ Class.ID ] = nil
				ClassName[ Class.Name ] = nil
				MsgN( string.format( "ExpAdv: Failed to load %q, extends invalid class %q", Class.Name, Class.Extends )
				continue
			end

			Class.Extends = Extends
		end

		if !Class.asNative and self.Extends then
			Class.asNative = self.Extends.asNative
		end
	end

	APICall( "PostBuildClass" )
end

/* ---
	@: Expanded Component system.
   --- */

function BaseComponent:CreateSetting( Name, Default )
	Name = string.lower( string.format( "%s.%s", self.Name, Name ) )

	Config.Settings[ Name ] = Config.Settings[ Name ] or Default
end

function ReadSetting( Name, Default )
	Name = string.lower( string.format( "%s.%s", self.Name, Name ) )

	return Config.Settings[ Name ] or Default
end

function BaseComponent:NewClass( ... )
	local Class = NewClass( ... )

	Class.Copmonent = self

	return Class
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