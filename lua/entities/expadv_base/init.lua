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
end )

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
end

function ENT:SendClientPackage( Player, Root, Files )
	local Package = vnet.CreatePacket( "expadv.cl_script" )

	Package:Short( self:EntIndex( ) )

	Package:Entity( self.player )

	Package:String( Root )

	Package:Table( Files )

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