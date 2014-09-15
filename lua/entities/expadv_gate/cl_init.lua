/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Client
   --- */

include( "shared.lua" )

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
                        surface.DrawTexturedRect( 0, 0, 200 * mul, 100 * mul )
 
                -- Owners Name
                        draw.SimpleText( self:GetPlayerName( ), "ExpAdv_OverlayFont", 100 * mul, 10 * mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
 
                -- Client Display
                        draw.SimpleText( "Client:", "ExpAdv_OverlayFont", 50 * mul, 30 * mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                        
                        local Counter = self:GetTickQuotaCL( )
                        local Line = string.format( "Quota: %i, %i%%", Counter, (Counter / expadv_hardquota) * 100 )
                        draw.SimpleText( Line, "ExpAdv_OverlayFont", 50 * mul, 40 * mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                           
                        local Line2 = string.format( "Usage: %i",  self:GetAverageCL( ) )
                        draw.SimpleText( Line2, "ExpAdv_OverlayFont", 50 * mul, 50 * mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                            
                        local Line3 = string.format( "CPU: %i us",  self:GetStopWatchCL( ) )
                        draw.SimpleText( Line3, "ExpAdv_OverlayFont", 50 * mul, 60 * mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )


                -- Server Display
                        draw.SimpleText( "Server:", "ExpAdv_OverlayFont", 150 * mul, 30 * mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                            
                        local Counter = self:GetTickQuota( )
                        local Line = string.format( "Quota: %i, %i%%", Counter, (Counter / expadv_hardquota) * 100 )
                        draw.SimpleText( Line, "ExpAdv_OverlayFont", 150 * mul, 40 * mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                           
                        local Line2 = string.format( "Usage: %i",  self:GetAverage( ) )
                        draw.SimpleText( Line2, "ExpAdv_OverlayFont", 150 * mul, 50 * mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                            
                        local Line3 = string.format( "CPU: %i us",  self:GetStopWatch( ) )
                        draw.SimpleText( Line3, "ExpAdv_OverlayFont", 150 * mul, 60 * mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

         cam.End3D2D()
end