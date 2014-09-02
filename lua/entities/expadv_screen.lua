/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Shared Info!
   --- */
AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base 			= "expadv_gate"
ENT.ExpAdv 			= true

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Monitor Models List
	@: This is havily based of WireMod's GPULib, All credits go to the respected authors!
	@: https://github.com/wiremod/wire/blob/master/lua/wire/gpulib.lua
   --- */

require( "vector2" )

local MonitorMdls = { }

function EXPADV.AddMonitor( Mdl, Off, Rot, Pos, Size, Res )
	local Monitor = {
		Off = Off or Vector( 0, 0, 0 ),
		Rot = Rot or Angle( 0, 90, 90 ),
		Pos = Pos or Vector2( 0, 0 ),
		Size = Size or Vector2( 0, 0 ),
		Res = Res or 1,
	}

	Monitor.Ratio = (Monitor.Size.y-Monitor.Pos.y)/(Monitor.Size.x-Monitor.Pos.x)
	MonitorMdls[Mdl] = Monitor
end

function EXPADV.GetMonitors( )
	return MonitorMdls
end

function EXPADV.GetMonitor( Mdl )
	return MonitorMdls[Mdl]
end

-- Odly, these dont seem to work :D
EXPADV.AddMonitor( "models/props/cs_assault/billboard.mdl", Vector( 1, 0, 0 ), nil, Vector2( -110.512, -57.647 ), Vector2( 110.512, 57.647 ), 0.23 )
EXPADV.AddMonitor( "models/hunter/plates/plate1x1.mdl", Vector( 0, -0, 1.7 ), Angle( 0, 90, 0 ), Vector2( -48, -48 ), Vector2( 48, 48 ), 0.09 )
EXPADV.AddMonitor( "models/blacknecro/tv_plasma_4_3.mdl", Vector( 0.1, 0, -0.5 ), nil, Vector2( -27.87, -20.93 ), Vector2( 27.87, 20.93 ), 0.082 )
EXPADV.AddMonitor( "models/hunter/plates/plate05x05.mdl", Vector( 0, -0, 1.7 ), Angle( 0, 90, 0 ), Vector2( -48, -48 ), Vector2( 48, 48 ), 0.045 )
EXPADV.AddMonitor( "models/hunter/plates/plate2x2.mdl", Vector( 0, -0, 1.7 ), Angle( 0, 90, 0 ), Vector2( -48, -48 ), Vector2( 48, 48 ), 0.182 )
EXPADV.AddMonitor( "models/props/cs_office/tv_plasma.mdl", Vector( 6.1, -0, 18.93 ), nil, Vector2( -28.5, 2 ), Vector2( 28.5, 36 ), 0.065 )
EXPADV.AddMonitor( "models/props/cs_office/computer_monitor.mdl", Vector( 3.3, -0, 16.7 ), nil, Vector2( -10.5, 8.6 ), Vector2( 10.5, 24.7 ), 0.031 )

if WireLib then -- But Wiremods monitors do :D
	for Mdl, Monitor in pairs( WireGPU_Monitors ) do
		--if MonitorMdls[Mdl] then return end
		EXPADV.AddMonitor( Mdl, Monitor.offset, Monitor.rot, Vector2( Monitor.x1, Monitor.y1 ), Vector2( Monitor.x2, Monitor.y2 ), Monitor.RS )
	end
end

if SERVER then return end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: We need the Material and an RT
   --- */

EXPADV.ScreenTexture = CreateMaterial( "ExpAdv.RT", "UnlitGeneric", {
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$ignorez"] = 1,
	["$nolod"] = 1,
} )

local RT_ID = 0
local RT_Cache = { }

function EXPADV.GetRenderTarget( )
	local RenderTarget = table.remove( RT_Cache )
	if RenderTarget then return RenderTarget end

	RT_ID = RT_ID + 1
	if RT_ID > 32 then return end

	return GetRenderTarget( "expadv.rt_" .. RT_ID, 512, 512 ) 
end

function EXPADV.CacheRenderTarget( RenderTarget )
	if RenderTarget and !table.HasValue( RT_Cache, RenderTarget ) then
		table.insert( RT_Cache, RenderTarget )
	end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Render Montior
   --- */

function ENT:Draw( )
	if !self.NextRender or self.NextRender <= SysTime( ) then
		self:RenderScreen( )
		self.NextRender = SysTime( ) + (1/24)
	end

	self:DrawModel( )
	self:DrawScreen( )
end

function ENT:DrawScreen( )
	local Monitor = EXPADV.GetMonitor( self:GetModel( ) )
	if !Monitor then return end

	
	cam.Start3D2D( self:LocalToWorld( Monitor.Off ), self:LocalToWorldAngles( Monitor.Rot ), Monitor.Res )
		local Aspect = 1 / Monitor.Ratio

		surface.SetDrawColor( 0, 0,0 ,255 )
		surface.DrawRect( -256 * Aspect, -256 * Aspect, 512 * Aspect, 512 * Aspect )

		if self.RenderTarget then
			local Previous = EXPADV.ScreenTexture:GetTexture( "$basetexture" )
			EXPADV.ScreenTexture:SetTexture( "$basetexture", self.RenderTarget )

			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( EXPADV.ScreenTexture )
			surface.DrawTexturedRect( -256 * Aspect, -256 * Aspect, 512 * Aspect, 512 * Aspect )

			EXPADV.ScreenTexture:SetTexture( "$basetexture", Previous )
		end

	cam.End3D2D( )

end

function ENT:RenderScreen( )
	local Context = self.Context

	if !Context or !Context.Online then return end
		
	local Event = Context.event_drawScreen
	if !Event then return end -- No event, so why bother?
		
	self.RenderTarget = self.RenderTarget or EXPADV.GetRenderTarget( )
	if !self.RenderTarget then return end -- No free rt, so no point.

	local _ScrW, _ScrH = ScrW( ), ScrH( )
	local PreviousRT = render.GetRenderTarget( )
	render.SetRenderTarget( self.RenderTarget )
	render.SetViewPort( 0, 0, 512, 512 )
	render.Clear( 0, 0, 0, 255 )

	cam.Start2D( )
		Context:Execute( "Event drawScreen", Event, 512, 512 )
	cam.End2D( )

	render.SetViewPort( 0, 0, _ScrW, _ScrH )
	render.SetRenderTarget( PreviousRT )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: OnRemove
   --- */

function ENT:OnRemove( )
	EXPADV.CacheRenderTarget( self.RenderTarget )
	return self.BaseClass.OnRemove( self )
end