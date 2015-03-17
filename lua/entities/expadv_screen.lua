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
	@: Resolution to get table
   --- */

function ENT:SetupDataTables( )
	self.BaseClass.SetupDataTables(self)
	self:AddExpVar("FLOAT", 6, "Resolution")
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: GetCursor
   --- */

require( "vector2" )

function ENT:GetCursor( Player )

	local Monitor = EXPADV.GetMonitor( self:GetModel( ) )
	if !Monitor or !IsValid( Player ) then return nil end

	if Player:EyePos():Distance( self:GetPos() ) > 156 then return end

	local Start, Dir = Player:GetShootPos( ), Player:GetAimVector( )
	
	local Ang = self:LocalToWorldAngles( Monitor.Rot )
	local Pos = self:LocalToWorld( Monitor.Off )
	
	local A = Ang:Up( ):Dot( Dir )
	if (A == 0 or A > 0) then return nil end

	local B = Ang:Up( ):Dot( Pos - Start ) / A

	local HitPos = WorldToLocal( Start + Dir * B, Angle( ), Pos, Ang )
	local X = (0.5 + HitPos.x / (Monitor.Res * self:GetResolution(512) / Monitor.Ratio)) * self:GetResolution(512)
	local Y = (0.5 - HitPos.y / (Monitor.Res * self:GetResolution(512))) * self:GetResolution(512)
			
	if (X < 0 or X > self:GetResolution(512) or Y < 0 or Y > self:GetResolution(512)) then return nil end

	return Vector2( X, Y )
end

function ENT:ScreenToLocalVector( Vec2 )
	local Monitor = EXPADV.GetMonitor( self:GetModel( ) )
	if !Monitor then return Vector( 0, 0, 0) end

	Vec2 = (Vec2 - Vector2(self:GetResolution(512) * 0.5, self:GetResolution(512) * 0.5)) * Vector2( Monitor.Res / Monitor.Ratio, Monitor.Res )

	local Vec = Vector( Vec2.x, -Vec2.y, 0 )

	Vec:Rotate( Monitor.Rot )

	return Vec + Monitor.Off
end

function ENT:ScreenToWorld( Vec2 )
	return self:LocalToWorld( self:ScreenToLocalVector( Vec2 ) )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Duplicator
   --- */

if SERVER then
	--Vars now save themselfs!
	return
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: FPS / BG
   --- */

function ENT:SetFPS( Value )
	self.__fps = math.Clamp( math.ceil( Value ), 1, 60 )
end

function ENT:GetFPS( )
	return self.__fps or 24
end

function ENT:SetBackGround(Color)
	self.__bg = Color
end

function ENT:GetBackGround( )
	return self.__bg or Color(50, 50, 50, 255)
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: We need a render target and material
   --- */

EXPADV.RenderTargets = EXPADV.RenderTargets or {}
local MaterialInfo = { ["$vertexcolor"] = 1, ["$vertexalpha"] = 1, ["$ignorez"] = 1, ["$nolod"] = 1, }

function EXPADV.GetRenderTarget(Res)
	Res = 1024 --Resolution or 512

	for id, data in pairs(EXPADV.RenderTargets) do

		if data.CACHED then --and data.RES == Res then
			data.CACHED = false
			data.CLEAR = true
			return data
		end
	end

	local ID = #EXPADV.RenderTargets + 1

	if ID <= 32 then
		local Data = {
			ID = ID,
			RES = Res,
			CLEAR = true,
			CACHED = false,
			RT = GetRenderTarget( "expadv_rt_" .. ID, Res, Res ),
			MAT = CreateMaterial( "expadv_rt_" .. ID, "UnlitGeneric", MaterialInfo ),
		}

		EXPADV.RenderTargets[ID] = Data

		return Data
	end

	return nil
end


function EXPADV.CacheRenderTarget(ID)
	local Data = EXPADV.RenderTargets[ID]
	if Data then Data.CACHED = true end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Render Montior
   --- */

AccessorFunc( ENT, "_pauseRender", "RenderingPaused", FORCE_BOOL )
AccessorFunc( ENT, "_noClear", "NoClearFrame", FORCE_BOOL )

function ENT:PreDrawScreen(scrAspect, scrSize) return false end
function ENT:PostDrawScreen(scrAspect, scrSize) return false end

function ENT:Draw()
	local time = SysTime()
	local context = self.Context

	self.RT_Data = self.RT_Data or EXPADV.GetRenderTarget(self:GetResolution(512))

	if !context or !context.Online then
		if !self.IsErrorScreen then
			--self:CreateErrorScreen(context)
			self.IsErrorScreen = true
		end
	elseif !self:GetRenderingPaused() and (!self.NextRender or self.NextRender <= time) then
		self:DoScreenUpdate(context)
		self.IsErrorScreen = false
		self.NextRender = time + (1 / self:GetFPS())
	end

	self:DrawModel( )

	local monitor = EXPADV.GetMonitor(self:GetModel())
	
	if monitor then
			local scrSize = self:GetResolution(512)
			local pos, ang, res = self:LocalToWorld(monitor.Off), self:LocalToWorldAngles(monitor.Rot), monitor.Res

			if monitor.Max and monitor.Min then
				pos = self:LocalToWorld(monitor.Max)
			end

			if scrSize == 256 then
				res = res * 2
			elseif scrSize == 1024 then
				res = res * 0.5
			end
			
			local rtData = self.RT_Data
			local aspect = 1 / monitor.Ratio
			local offset = (monitor.Min and monitor.Max) and 0 or -(scrSize*0.5) * aspect
			
			local scrAspect = scrSize * aspect
			local endUV = scrSize / rtData.RES

			cam.Start3D2D(pos, ang, res)
				surface.SetDrawColor(self:GetBackGround())
				surface.DrawRect(offset, offset, scrAspect, scrAspect)

				if !self:PreDrawScreen(scrAspect, scrSize) and rtData then
					-- If our predrawscreen returns false, we render the screen.

					local prev = rtData.MAT:GetTexture("$basetexture")
								 rtData.MAT:SetTexture("$basetexture", rtData.RT)

					surface.SetDrawColor(255, 255, 255, 255)
					surface.SetMaterial(rtData.MAT)
					surface.DrawTexturedRectUV(offset, offset, scrAspect, scrAspect, 0, 0, endUV, endUV)

					rtData.MAT:SetTexture("$basetexture", prev)
				end

				self:PostDrawScreen(scrAspect, scrSize)

			cam.End3D2D( )
	end
end

function ENT:DoScreenUpdate(context)
	local rtData = self.RT_Data
	local scrSize = self:GetResolution(512)
	local event = context.event_drawScreen

	if event and rtData then
		render.PushRenderTarget(rtData.RT, 0, 0, scrSize + 16, scrSize + 16)
		render.OverrideAlphaWriteEnable(true, true)

		if rtData.CLEAR or !self:GetNoClearFrame() then
			render.ClearDepth()
			render.Clear(0, 0, 0, 0)
			rtData.CLEAR = false
		end

		cam.Start2D( )

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetTextColor(0, 0, 0, 255)
			
			context.In2DRender = true
			context.Matrices = 0

			context:Execute("Event drawScreen", event, scrSize, scrSize)

			if context.Matrices > 0 then
				for i=1, context.Matrices do cam.PopModelMatrix() end
			end
			
			context.In2DRender = false

		cam.End2D( )

		render.OverrideAlphaWriteEnable(false)
		render.PopRenderTarget()
	end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Overlay
   --- */

function ENT:GetOverlayPos( )
	return self:ScreenToWorld( Vector2( 512, 256 ) )
end