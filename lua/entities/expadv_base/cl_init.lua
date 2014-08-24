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
	self:DrawOverlay( )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Overlay
   --- */

local Overlay_BG = Material( "omicron/ea2_overlay_bg.png" )

function ENT:DrawOverlay( )
	cam.Start3D2D( self:GetPos( ) + (self:GetUp( ) * 2), self:LocalToWorldAngles( Angle(0.1,90,0.1) ), 0.05 )

			surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
			surface.SetMaterial( Overlay_BG )

			surface.DrawTexturedRect( 0, 0, 200, 100 )

			draw.SimpleText( self:GetPlayerName(), "default", 100, 10, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	cam.End3D2D()

	--[[ OLD SCHOOL!
	surface.SetDrawColor( Color(255,255,255,50) )
	surface.DrawRect( 0, 0, 200, 100 )

	draw.SimpleText( "CLIENT:", "default", 100, 5, Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	draw.SimpleText( "Tick Quota:", "default", 5, 15, Color( 0, 0, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText( self.cl_TickQuota or 0, "default", 195, 15, Color( 0, 0, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
	
	draw.SimpleText( "Soft Quota:", "default", 5, 25, Color( 0, 0, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText( self.cl_SoftQuota or 0, "default", 195, 25, Color( 0, 0, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

	draw.SimpleText( "Average Quota:", "default", 5, 35, Color( 0, 0, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText( self.cl_AvgeQuota or 0, "default", 195, 35, Color( 0, 0, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

	draw.SimpleText( "SERVER:", "default", 100, 55, Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	draw.SimpleText( "Tick Quota:", "default", 5, 65, Color( 0, 0, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText( self:GetTickQuota( ) or 0, "default", 195, 65, Color( 0, 0, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
	
	draw.SimpleText( "Soft Quota:", "default", 5, 75, Color( 0, 0, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText( self:GetSoftQuota( ) or 0, "default", 195, 75, Color( 0, 0, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

	draw.SimpleText( "Average Quota:", "default", 5, 85, Color( 0, 0, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText( self:GetAvgeQuota( ) or 0, "default", 195, 85, Color( 0, 0, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )


	cam.End3D2D()]]
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

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Fake Entity
		-- Because entitys out of pvs don't exist!
   --- */

--[[This is retarded :D
local __ENT = ENT

function EXPADV.GetVirtualEntity( ID )
	local Context = EXPADV.GetEntityContext( ID )

	if !Context then return end

	if IsValid( Context.Entity ) then return Context.Entity end

	return setmetatable( { 
		IsValid = function( ) return true end,
		EntIndex = function( ) return ID end,
		GetOwner = function( ) return Context.player end,

		Context = Context,
		player = Context.player

	}, __ENT )
end]]

