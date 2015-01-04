/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Shared Info!
   --- */
AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base 			= "expadv_gate"
ENT.ExpAdv 			= true
ENT.Screen 			= true

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

function EXPADV.SetMonitorMinMax( Mdl, Max, Min )
	if !MonitorMdls[Mdl] then return end

	MonitorMdls[Mdl].Min = Min
	MonitorMdls[Mdl].Max = Max
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

EXPADV.SetMonitorMinMax("models/hunter/plates/plate1x1.mdl", Vector(-23.039999008179, -23.040002822876, 1.7000000476837), Vector(23.039999008179, 23.040002822876, 1.7000000476837))
EXPADV.SetMonitorMinMax("models/kobilica/wiremonitorsmall.mdl", Vector(0.30000039935112, -4.4800000190735, 9.4799995422363), Vector(0.29999962449074, 4.4800000190735, 0.51999998092651))
EXPADV.SetMonitorMinMax("models/hunter/blocks/cube1x1x1.mdl", Vector(24.000001907349, -23.040000915527, 23.040000915527), Vector(23.999998092651, 23.040000915527, -23.040000915527))
EXPADV.SetMonitorMinMax("models/props_lab/workspace002.mdl", Vector(-36.135429382324, -61.599151611328, 57.217697143555), Vector(-48.131019592285, -23.145492553711, 27.004096984863))
EXPADV.SetMonitorMinMax("models/hunter/plates/plate05x05.mdl", Vector(-11.519999504089, -11.520001411438, 1.7000000476837), Vector(11.519999504089, 11.520001411438, 1.7000000476837))
EXPADV.SetMonitorMinMax("models/props_lab/monitor01b.mdl", Vector(6.5300006866455, -5.6556153297424, 5.1859998703003), Vector(6.5299997329712, 3.6556153297424, -4.28600025177))
EXPADV.SetMonitorMinMax("models/blacknecro/tv_plasma_4_3.mdl", Vector(0.10000213980675, -27.952558517456, 20.492000579834), Vector(0.099997863173485, 27.952558517456, -21.492000579834))
EXPADV.SetMonitorMinMax("models/hunter/plates/plate2x2.mdl", Vector(-46.591995239258, -46.592002868652, 1.7000000476837), Vector(46.591995239258, 46.592002868652, 1.7000000476837))
EXPADV.SetMonitorMinMax("models/kobilica/wiremonitorbig.mdl", Vector(0.20000101625919, -11.620611190796, 24.520000457764), Vector(0.19999898970127, 11.620611190796, 1.4799995422363))

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: GetCursor
   --- */

require( "vector2" )

function ENT:GetCursor( Player )
	local Monitor = EXPADV.GetMonitor( self:GetModel( ) )
	if !Monitor or !IsValid( Player ) then return Vector2( 0, 0 ) end

	local Start, Dir = Player:GetShootPos( ),Player:GetAimVector( )
	
	local Ang = self:LocalToWorldAngles( Monitor.Rot )
	local Pos = self:LocalToWorld( Monitor.Off )
	
	local A = Ang:Up( ):Dot( Dir )
	if (A == 0 or A > 0) then return Vector2( 0, 0 ) end

	local B = Ang:Up( ):Dot( Pos - Start ) / A

	local HitPos = WorldToLocal( Start + Dir * B, Angle( ), Pos, Ang )
	local X = (0.5 + HitPos.x / (Monitor.Res * 512 / Monitor.Ratio)) * 512
	local Y = (0.5 - HitPos.y / (Monitor.Res * 512)) * 512
			
	if (X < 0 or X > 512 or Y < 0 or Y > 512) then return Vector2( 0, 0 ) end

	return Vector2( X, Y )
end

function ENT:ScreenToLocalVector( Vec2 )
	local Monitor = EXPADV.GetMonitor( self:GetModel( ) )
	if !Monitor then return Vector( 0, 0, 0) end

	Vec2 = (Vec2 - Vector2( 256, 256 )) * Vector2( Monitor.Res / Monitor.Ratio, Monitor.Res )

	local Vec = Vector( Vec2.x, -Vec2.y, 0 )

	Vec:Rotate( Monitor.Rot )

	return Vec + Monitor.Off
end

function ENT:ScreenToWorld( Vec2 )
	return self:LocalToWorld( self:ScreenToLocalVector( Vec2 ) )
end

if SERVER then return end

function ENT:SetFPS( Value )
	self.__fps = math.Clamp( math.ceil( Value ), 1, 60 )
end

function ENT:GetFPS( )
	return self.__fps or 24
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: We need the Material and an RT
   --- */

function EXPADV.CacheRenderTarget( RenderTarget )
	if RenderTarget and !table.HasValue( EXPADV.RT_Cache, RenderTarget ) then
		table.insert( EXPADV.RT_Cache, RenderTarget )
	end
end

EXPADV.RT_ID = 0
EXPADV.RT_Cache = { }
EXPADV.RT_Mat_Cache = { }

function EXPADV.GetRenderTarget( )
	local RenderTarget = table.remove( EXPADV.RT_Cache )
	if RenderTarget then return RenderTarget, table.remove( EXPADV.RT_Mat_Cache ) end

	EXPADV.RT_ID = EXPADV.RT_ID + 1
	if EXPADV.RT_ID > 32 then return end

	return GetRenderTarget( "expadv_rt_" .. EXPADV.RT_ID, 512+16, 512+16 ), CreateMaterial( "expadv_rt_" .. EXPADV.RT_ID, "UnlitGeneric", { ["$vertexcolor"] = 1, ["$vertexalpha"] = 1, ["$ignorez"] = 1, ["$nolod"] = 1, } )
end

function EXPADV.CacheRenderTarget( RenderTarget, Material )
	if RenderTarget and !table.HasValue( EXPADV.RT_Cache, RenderTarget ) then
		table.insert( EXPADV.RT_Cache, RenderTarget )
		table.insert( EXPADV.RT_Mat_Cache, Material )
	end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Render Montior
   --- */

AccessorFunc( ENT, "_pauseRender", "RenderingPaused", FORCE_BOOL )
AccessorFunc( ENT, "_noClear", "NoClearFrame", FORCE_BOOL )

function ENT:Draw( )
	if !self:GetRenderingPaused( ) then
			if !self.NextRender or self.NextRender <= SysTime( ) then
			self:RenderScreen( )
			self.NextRender = SysTime( ) + (1 / self:GetFPS( ) )
		end
	end

	self:DrawModel( )
	self:DrawScreen( )

end

function ENT:DrawScreen( )
	local Monitor = EXPADV.GetMonitor( self:GetModel( ) )
	if !Monitor then return end

	local Position, Angles, Resolution = self:LocalToWorld( Monitor.Off ), self:LocalToWorldAngles( Monitor.Rot ), Monitor.Res
	
	if Monitor.Max and Monitor.Min then Position = self:LocalToWorld( Monitor.Max ) end

	cam.Start3D2D( Position, Angles, Resolution )
		local Aspect = 1 / Monitor.Ratio
		local Offset = (Monitor.Min and Monitor.Max) and 0 or -256 * Aspect
		
		surface.SetDrawColor( 0, 0,0 ,255 )
		surface.DrawRect( Offset, Offset, 512 * Aspect, 512 * Aspect )

		if self.RenderTarget and self.RenderMat then
			local Previous = self.RenderMat:GetTexture( "$basetexture" )
			self.RenderMat:SetTexture( "$basetexture", self.RenderTarget )

			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( self.RenderMat )
			surface.DrawTexturedRect( Offset, Offset, 512 * Aspect, 512 * Aspect )

			self.RenderMat:SetTexture( "$basetexture", Previous )
		end

	cam.End3D2D( )
end

function ENT:RenderScreen( )
	local Context = self.Context

	if !Context or !Context.Online then return end
		
	local Event = Context.event_drawScreen
	if !Event then return end -- No event, so why bother?
	
	if !self.RenderTarget or !self.RenderMat then
		self.ForceClear = true
		self.RenderTarget, self.RenderMat = EXPADV.GetRenderTarget( )
		if !self.RenderTarget or !self.RenderMat then return end
	end --^ No free rt, so no point.

	local _ScrW, _ScrH = ScrW( ), ScrH( )
	local PreviousRT = render.GetRenderTarget( )
	render.SetRenderTarget( self.RenderTarget )
	render.SetViewPort( 8, 8, 512, 512 )
	

	if !self:GetNoClearFrame( ) or self.ForceClear then
		render.Clear( 0, 0, 0, 255 )
		self.ForceClear = nil
	end

	cam.Start2D( )

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetTextColor( 0, 0, 0, 255 )
		
		Context.In2DRender = true
		Context.Matrices = 0

		Context:Execute( "Event drawScreen", Event, 512, 512 )

		for i=1, Context.Matrices do
			cam.PopModelMatrix( )
		end

		Context.In2DRender = false

	cam.End2D( )

	render.SetViewPort( 0, 0, _ScrW, _ScrH )
	render.SetRenderTarget( PreviousRT )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: OnRemove
   --- */

function ENT:OnRemove( )
	EXPADV.CacheRenderTarget( self.RenderTarget, self.RenderMat )
	return self.BaseClass.OnRemove( self )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Overlay
   --- */

function ENT:GetOverlayPos( )
	return self:ScreenToWorld( Vector2( 512, 256 ) )
end