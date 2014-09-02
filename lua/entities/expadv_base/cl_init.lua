/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Base Class
   --- */

include( "shared.lua" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: [vNet] Receive Code
   --- */

function ENT:ReceivePackage( Package )
	self.player = Package:Entity( )

	self.root = Package:String( )
	
	self.files = Package:Table( )

	self:CompileScript( self.root, self.files )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Render
   --- */

function ENT:Draw( )
	self:DrawModel( )
	
	if self:BeingLookedAtByLocalPlayer( ) then
		self:DrawOverlay( Vector(-6,-2, 2 ) )
	end
end

function ENT:DrawOverlay( Pos )

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
end )


