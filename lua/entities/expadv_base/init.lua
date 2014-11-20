/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Base Class
   --- */

include( "shared.lua" )
include( "wiremod.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: vNet
   --- */

require( "vnet" ) -- Nope, You may not have this is yet :D

util.AddNetworkString( "expadv.cl_script" )
util.AddNetworkString( "expadv.cl_loaded" )

vnet.Watch( "expadv.cl_loaded", function( Package )
	local Ent = Package:Entity( )
	local Ply = Package:Entity( )

	if !IsValid( Ent ) or !IsValid( Ply ) then return end

	EXPADV.CallHook( "ClientLoaded", Ent, Ply )

	Ent:OnClientLoaded( Ply )
end, vnet.OPTION_WATCH_OVERRIDE )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Receive Code
   --- */

function ENT:LoadCodeFromPackage( Root, Files )
	self.root = Root

	self.files = Files

	if self.root == "" then return end
	
	self:CompileScript( self.root, self.files )

	self:SendClientPackage( nil, self.root, self.files )
	
	hook.Add( "PlayerConnect", self, function( self, Ply )
		self:SendClientPackage( Ply, self.root, self.files )
	end )
end

function ENT:ReceivePackage( Package )
	self:LoadCodeFromPackage( Package:String( ),  Package:Table( ) or { } )
	self:SetGateName( Package:String( ) )
end

function ENT:SendClientPackage( Player, Root, Files )
	local Package = vnet.CreatePacket( "expadv.cl_script" )

	Package:Short( self:EntIndex( ) )

	Package:Entity( self.player )

	Package:String( Root )

	Package:Table( Files )

	-- Package:String( self:GetGateName( ) )

	if IsValid(Player) then
		Package:AddTargets( { Player } ) 

		Package:Send( )

		return
	end

	Package:Broadcast( )
end

function ENT:OnClientLoaded( Ent, Ply )
	-- To be used by derived classes
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Duplicator Support
	@: To make it compatable with wirelib we need to borrow one of there functions.
	@: https://github.com/wiremod/wire/blob/master/lua/entities/base_wire_entity.lua#L386
   --- */

local function EntityLookup(CreatedEntities)
	return function(id, default)
		if id == nil then return default end
		if id == 0 then return game.GetWorld() end
		local ent = CreatedEntities[id] or (isnumber(id) and ents.GetByIndex(id))
		if IsValid(ent) then return ent else return default end
	end
end

local __CONTEXT

function ENT:PreEntityCopy( )
	local DupeTable = WireLib and WireLib.BuildDupeInfo( self ) or { }
	
	DupeTable.GateName = self:GetGateName( )
	DupeTable.Root = self.root or ""
	DupeTable.Files = self.files or { }
	
	EXPADV.CallHook( "BuildDupeInfo", self, DupeTable )
	
	duplicator.StoreEntityModifier(self, "ExpAdvDupeInfo", DupeTable)

	__CONTEXT = self.Context
	
	self.Context = nil
end

function ENT:PostEntityCopy( )
	self.Context = __CONTEXT
end

function ENT:PostEntityPaste( Player, Entity, CreatedEntities  )
	if !Entity.EntityMods then return end 
	
	local DupeTable = Entity.EntityMods.ExpAdvDupeInfo
	if !DupeTable then return end

	self.player = Player
	self.PastedFromDupe = true
	self:SetGateName( DupeTable.GateName )
	self:LoadCodeFromPackage( DupeTable.Root, DupeTable.Files )

	local FromID = EntityLookup(CreatedEntities)

	if WireLib then
		WireLib.ApplyDupeInfo( Player, Entity, DupeTable, FromID )
	end
	
	EXPADV.CallHook( "PasteDupeInfo", self, DupeTable, FromID )
end

function ENT:ApplyDupePorts( InPorts, OutPorts )
	if !WireLib then return end

	if InPorts then
		self.DupeInPorts = OutPorts
		self.Inputs = WireLib.AdjustSpecialInputs( self, InPorts[1], InPorts[2] )
	end
	
	if OutPorts then
		self.DupeOutPorts = OutPorts
		self.Outputs = WireLib.AdjustSpecialOutputs( self, OutPorts[1], OutPorts[2] )
	end
end