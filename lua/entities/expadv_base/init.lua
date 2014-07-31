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

	Ent:OnClientLoaded( Ent, Ply )
end )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Receive Code
   --- */

function ENT:ReceivePackage( Package )
	local Received = Package:Table( )

	self.root = Package:String( )

	self.files = Package:Table( ) or { }

	if self.root == "" then return end
	
	self:CompileScript( self.root, self.files )

	self:SendClientPackage( nil, self.root, self.files )
	
	hook.Add( "PlayerConnect", self, function( self, Ply )
		self:SendClientPackage( Ply, self.root, self.files )
	end )
end

function ENT:SendClientPackage( Player, Root, Files )
	local Package = vnet.CreatePacket( "expadv.cl_script" )

	Package:Short( self:EntIndex( ) )

	Package:Entity( self.Player )

	Package:String( Root )

	Package:Table( Files )

	Package:AddTargets( Player and { Player } or player.GetAll( ) )

	Package:Send( )
end

function ENT:OnClientLoaded( Ent, Ply )
	-- To be used by derived classes
end