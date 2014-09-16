/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Client
   --- */

include( "shared.lua" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Overlay
   --- */
   
local mul = 4

local Overlay_BG = Material( "omicron/ea2_overlay_bg.png" )
local Overlay_ServerRed = Material( "omicron/overlay_serverred.png" )
local Overlay_ServerGreen = Material( "omicron/overlay_servergreen.png" )
local Overlay_ClientRed = Material( "omicron/overlay_clientred.png" )
local Overlay_ClientGreen = Material( "omicron/overlay_clientgreen.png" )

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
 
function ENT:DrawOverlay( Pos, Ang )
        cam.Start3D2D( self:LocalToWorld( Pos ), self:LocalToWorldAngles( Ang or Angle(0.1,90,0.1) ), 0.05 / mul )
 
                -- BackGround
                        surface.SetMaterial( Overlay_BG )
                        surface.SetDrawColor( Color( 255, 255, 255, 100 ) )
                        surface.DrawTexturedRect( 0, 0, 200 * mul, 100 * mul )
                
                -- Client Panel
                        local CLState = self:GetStateCL( ) or 0

                        if CLState == EXPADV_STATE_ONLINE then
                            surface.SetMaterial( Overlay_ClientGreen )
                            surface.DrawTexturedRect( 0, 0, 200 * mul, 100 * mul )
                        elseif CLState >= EXPADV_STATE_CRASHED then
                            surface.SetMaterial( Overlay_ClientRed )
                            surface.DrawTexturedRect( 0, 0, 200 * mul, 100 * mul )
                        end

                -- Server Panel
                        local SVState = self:GetStateSV( ) or 0

                        if SVState == EXPADV_STATE_ONLINE then
                            surface.SetMaterial( Overlay_ServerGreen )
                            surface.DrawTexturedRect( 0, 0, 200 * mul, 100 * mul )
                        elseif SVState >= EXPADV_STATE_CRASHED then
                            surface.SetMaterial( Overlay_ServerRed )
                            surface.DrawTexturedRect( 0, 0, 200 * mul, 100 * mul )
                        end

                -- Owners Name
                        draw.SimpleText( self:GetPlayerName( ), "ExpAdv_OverlayFont", 100 * mul, 10 * mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
 
                -- Client Display
                        draw.SimpleText( "Client:", "ExpAdv_OverlayFont", 50 * mul, 30 * mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                        
                        local Counter = self:GetTickQuotaCL( ) or 0
                        local Line = string.format( "Quota: %i, %i%%", Counter, (Counter / expadv_hardquota) * 100 )
                        draw.SimpleText( Line, "ExpAdv_OverlayFont", 50 * mul, 40 * mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                           
                        local Line2 = string.format( "Usage: %i",  self:GetAverageCL( ) or 0 )
                        draw.SimpleText( Line2, "ExpAdv_OverlayFont", 50 * mul, 50 * mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                            
                        local Line3 = string.format( "CPU: %i us",  self:GetStopWatchCL( ) or 0 )
                        draw.SimpleText( Line3, "ExpAdv_OverlayFont", 50 * mul, 60 * mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )


                -- Server Display
                        draw.SimpleText( "Server:", "ExpAdv_OverlayFont", 150 * mul, 30 * mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                            
                        local Counter = self:GetTickQuota( ) or 0
                        local Line = string.format( "Quota: %i, %i%%", Counter, (Counter / expadv_hardquota) * 100 )
                        draw.SimpleText( Line, "ExpAdv_OverlayFont", 150 * mul, 40 * mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                           
                        local Line2 = string.format( "Usage: %i",  self:GetAverage( ) or 0 )
                        draw.SimpleText( Line2, "ExpAdv_OverlayFont", 150 * mul, 50 * mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                            
                        local Line3 = string.format( "CPU: %i us",  self:GetStopWatch( ) or 0 )
                        draw.SimpleText( Line3, "ExpAdv_OverlayFont", 150 * mul, 60 * mul, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

         cam.End3D2D()
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
    @: Effects
   --- */

-- Does not work Sad Face :(

    --[[
        if State == EXPADV_STATE_ALERT then
            local Pos = Attachment.Pos

            if !self.NextSpark or self.NextSpark < CurTime() then
                local fx_dat = EffectData()
                fx_dat:SetMagnitude(math.random(0.1,0.3))
                fx_dat:SetScale(math.random(0.5,1.5))
                fx_dat:SetRadius(2)
                fx_dat:SetOrigin(Pos)
                util.Effect("sparks",fx_dat)
                self.NextSpark = CurTime() + math.Rand(0.2,1)
            end
        end
    ]]

