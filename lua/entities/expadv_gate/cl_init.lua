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
                            draw.SimpleText( "Client:", "ExpAdv_OverlayFont", 50*mul, 30*mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                            
                    -- Server Display
                            draw.SimpleText( "Server:", "ExpAdv_OverlayFont", 150*mul, 30*mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                                
                            local Counter = self:GetTickQuota( )
                            local Line = string.format( "ops: %i, %i%%", Counter, (Counter / expadv_hardquota) * 100 )
                            draw.SimpleText( Line, "ExpAdv_OverlayFont", 150*mul, 40*mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                               
                            local Line2 = string.format( "average: %iops, %ius",  self:GetAverage( ), self:GetStopWatch( ) * 100000 )
                            draw.SimpleText( Line2, "ExpAdv_OverlayFont", 150*mul, 50*mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                                
             cam.End3D2D()
    end