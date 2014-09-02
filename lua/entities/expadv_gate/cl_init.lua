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

	

    /* --- ----------------------------------------------------------------------------------------------------------------------------------------------
            @: Overlay
       --- */
     
       
    local mul = 4
    local Overlay_BG = Material( "omicron/ea2_overlay_bg.png" )
    surface.CreateFont( "ExpAdv_OverlayFont", {
            font = "Default",
            size = 10*mul,
            weight = 500,
            blursize = 0,
            scanlines = 0,
            antialias = true,
            underline = false,
            italic = false,
            strikeout = false,
            symbol = false,
            rotary = false,
            shadow = false,
            additive = false,
            outline = false,
    } )
     
    function ENT:DrawOverlay( Pos )
            cam.Start3D2D( self:LocalToWorld( Pos ), self:LocalToWorldAngles( Angle(0.1,90,0.1) ), 0.05 / mul )
     
                    -- BackGround
                            surface.SetMaterial( Overlay_BG )
                            surface.SetDrawColor( Color( 255, 255, 255, 100 ) )
                            surface.DrawTexturedRect( 0, 0, 200*mul, 100*mul )
     
                    -- Owners Name
                            draw.SimpleText( self:GetPlayerName(), "ExpAdv_OverlayFont", 100*mul, 10*mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
     
                    -- Client Display
                            local CL_Hard = (self.cl_TickQuota / expadv_hardquota) < 0.33 and "" or string.format( "(+%i%%)", math.Round(self.cl_TickQuota / expadv_hardquota * 100) )
                            local CL_TickPer = self.cl_TickQuota > 0 and (self.cl_TickQuota / expadv_tickquota) * 100 or 0
                            local CL_Msg = string.format( "%i us, %i%% %s", self.cl_TickQuota * 1000000, CL_TickPer, CL_Hard )
                            local CL_Avg = string.format( "Average: %i us", self.cl_AvgeQuota * 1000000 )
                            local CL_Status = (self.Context and self.Context.Online) and "Online" or "Offline"
     
                            draw.SimpleText( "Client:", "ExpAdv_OverlayFont", 50*mul, 30*mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                            draw.SimpleText( CL_Msg, "ExpAdv_OverlayFont", 50*mul, 40*mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                            draw.SimpleText( CL_Avg, "ExpAdv_OverlayFont", 50*mul, 50*mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                            draw.SimpleText( CL_Status, "ExpAdv_OverlayFont", 50*mul, 60*mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                           
                    -- Server Display
                            local SV_Hard = (self:GetTickQuota( ) / expadv_hardquota) < 0.33 and "" or string.format( "(+%i%%)", math.Round(self:GetTickQuota( ) / expadv_hardquota * 100) )
                            local SV_TickPer = self:GetTickQuota( ) > 0 and (self:GetTickQuota( ) / expadv_tickquota) * 100 or 0
                            local SV_Msg = string.format( "%i us, %i%% %s", self:GetTickQuota( ) * 1000000, SV_TickPer, SV_Hard )
                            local SV_Avg = string.format( "Average: %i us", self:GetAvgeQuota( ) * 1000000 )
                            local SV_Status = self:GetOnline( ) and "Online" or "Offline"
     
                            draw.SimpleText( "Server:", "ExpAdv_OverlayFont", 150*mul, 30*mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                            draw.SimpleText( SV_Msg, "ExpAdv_OverlayFont", 150*mul, 40*mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                            draw.SimpleText( SV_Avg, "ExpAdv_OverlayFont", 150*mul, 50*mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                            draw.SimpleText( SV_Status, "ExpAdv_OverlayFont", 150*mul, 60*mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                           
     
            cam.End3D2D()
    end