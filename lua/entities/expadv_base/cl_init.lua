/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Base Class
   --- */

include( "shared.lua" )
include( "vars.lua" )
require("vnet")

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: [vNet] Receive Code
   --- */

function ENT:ReceivePackage( Package )
	self.player = Package:Entity( )

	self.root = Package:String( )
	
	self.files = Package:Table( )

	self:CompileScript( self.root, self.files )

	-- self:SetGateName( Package:String( ) )
end
/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Render
   --- */

function ENT:Draw( )
	self:DrawModel( )
end

function ENT:GetOverlayPos( )
	return self:GetPos( )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Vnet
   --- */
require( "vnet" )

vnet.Watch( "expadv.cl_script", function( Package )

	local ID = Package:Short( )
	local ExpAdv = Entity( ID )

	if !IsValid( ExpAdv ) then return end

	ExpAdv:ReceivePackage( Package )
end, vnet.OPTION_WATCH_OVERRIDE )




