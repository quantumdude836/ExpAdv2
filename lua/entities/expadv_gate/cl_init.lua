/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Client
   --- */

include( "shared.lua" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Print Outs
   --- */

function ENT:OnLuaError( Context, Msg )
	chat.AddText( Color( 150, 150, 0 ), "[" .. self.player:Name( ) .. "] ", Color( 255, 0, 0 ), "Expresion Advanced - Error: ", Color( 255, 255, 255 ), Msg )
end

function ENT:OnScriptError( Context, Msg )
	chat.AddText( Color( 150, 150, 0 ), "[" .. self.player:Name( ) .. "] ", Color( 255, 0, 0 ), "Expresion Advanced - Script Error: ", Color( 255, 255, 255 ), Msg )
end

function ENT:OnUncatchedException( Context, Exception )
	chat.AddText( Color( 150, 150, 0 ), "[" .. self.player:Name( ) .. "] ", Color( 255, 0, 0 ), "Expresion Advanced - Uncatched exception: ", Color( 255, 255, 255 ), Exception.Exception, " -> ", Exception.Msg )
end

function ENT:OnCompileError( ErMsg, Compiler )
	chat.AddText( Color( 150, 150, 0 ), "[" .. self.player:Name( ) .. "] ", Color( 255, 0, 0 ), "Expresion Advanced - Validate Error: ", Color( 255, 255, 255 ), ErMsg )
end

function ENT:OnShutDown( Context )
	chat.AddText( Color( 255, 0, 0 ), "Expresion Advanced - ShutDown: ", Color( 255, 255, 255 ), tostring( self ) )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Overlay
   --- */

local Overlay_BG = Material( "omicron/ea2_overlay_bg.png" )

function ENT:DrawOverlay( )
	cam.Start3D2D( self:GetPos( ) + (self:GetUp( ) * 2), self:LocalToWorldAngles( Angle(0.1,90,0.1) ), 0.05 )

		-- BackGround
			surface.SetMaterial( Overlay_BG )
			surface.SetDrawColor( Color( 255, 255, 255, 100 ) )
			surface.DrawTexturedRect( 0, 0, 200, 100 )

		-- Owners Name
			draw.SimpleText( self:GetPlayerName(), "defaultsmall", 100, 10, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		-- Client Display
			local CL_Hard = (self.cl_TickQuota / expadv_hardquota) < 0.33 and "" or string.format( "(+%i%%)", math.Round(self.cl_TickQuota / expadv_hardquota * 100) )
			local CL_TickPer = self.cl_TickQuota > 0 and (self.cl_TickQuota / expadv_tickquota) * 100 or 0
			local CL_Msg = string.format( "%i us, %i%% %s", self.cl_TickQuota * 1000000, CL_TickPer, CL_Hard )
			local CL_Avg = string.format( "Average: %i us", self.cl_AvgeQuota * 1000000 )
			local CL_Status = (self.Context and self.Context.Online) and "Online" or "Offline"

			draw.SimpleText( "Client:", "defaultsmall", 50, 30, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( CL_Msg, "defaultsmall", 50, 40, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( CL_Avg, "defaultsmall", 50, 50, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( CL_Status, "defaultsmall", 50, 60, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			
		-- Server Display
			local SV_Hard = (self:GetTickQuota( ) / expadv_hardquota) < 0.33 and "" or string.format( "(+%i%%)", math.Round(self:GetTickQuota( ) / expadv_hardquota * 100) )
			local SV_TickPer = self:GetTickQuota( ) > 0 and (self:GetTickQuota( ) / expadv_tickquota) * 100 or 0
			local SV_Msg = string.format( "%i us, %i%% %s", self:GetTickQuota( ) * 1000000, SV_TickPer, SV_Hard )
			local SV_Avg = string.format( "Average: %i us", self:GetAvgeQuota( ) * 1000000 )
			local SV_Status = self:GetOnline( ) and "Online" or "Offline"

			draw.SimpleText( "Server:", "defaultsmall", 150, 30, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( SV_Msg, "defaultsmall", 150, 40, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( SV_Avg, "defaultsmall", 150, 50, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( SV_Status, "defaultsmall", 150, 60, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			

	cam.End3D2D()
end