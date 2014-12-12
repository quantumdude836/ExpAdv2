/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Client
   --- */

include( "shared.lua" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
    @: Utility func
   --- */

local function Shorten( Num )
    if Num < 1000 then return math.ceil(Num) end
    if Num < 1000000 then return math.Round(Num / 1000, 3) .. "k" end
    if Num < 1000000000 then return math.Round(Num / 1000000, 3) .. "m" end
    return math.Round(Num / 1000000000, 3) .. "b" -- Lets hope we never reach the billions :D
end

EXPADV.Shorten = Shorten

local Mult = 1.25
local TextColor = Color( 0, 0, 0 )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
    @: Font
   --- */

surface.CreateFont( "ExpAdv_OverlayFont", {
        font = "Default",
        size = 10 * Mult,
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

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
    @: Derma Overlay
    @: Images - Omicron
   --- */

local function PaintClient( X, Y, Entity )

    local LoadStatus = Entity:GetClientCompletion( ) or 0
    
    if LoadStatus < 100 then
        draw.SimpleText( "Client:", "ExpAdv_OverlayFont", X + (50 * Mult), Y + (30 * Mult), TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        
        draw.SimpleText( "Loading: " .. LoadStatus .. "%", "ExpAdv_OverlayFont", X + (50 * Mult), Y + (40 * Mult), TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        
        return
    end

    local CLState = Entity:GetClientState( ) or 0

    if CLState >= EXPADV_STATE_CRASHED then
        surface.SetMaterial( Material( "omicron/overlay_clientred.png" ) )
        surface.DrawTexturedRect( X, Y, 200 * Mult, 100 * Mult )
    elseif CLState >= EXPADV_STATE_ONLINE then
        surface.SetMaterial( Material( "omicron/overlay_clientgreen.png" ) )
        surface.DrawTexturedRect( X, Y, 200 * Mult, 100 * Mult )
    end

    draw.SimpleText( "Client:", "ExpAdv_OverlayFont", X + (50 * Mult), Y + (30 * Mult), TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        
    local Counter = Entity.ClientTickQuota or 0
    local Line = string.format( "Quota: %s, %i%%", Shorten( Counter ), (Counter / expadv_hardquota) * 100 )
    draw.SimpleText( Line, "ExpAdv_OverlayFont", X + (50 * Mult), Y + (40 * Mult), TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
       
    local Line2 = string.format( "Usage: %s",  Shorten(Entity.ClientAverage or 0 ))
    draw.SimpleText( Line2, "ExpAdv_OverlayFont", X + (50 * Mult), Y + (50 * Mult), TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        
    local Line3 = string.format( "CPU: %i us",  Entity.ClientStopWatch or 0 )
    draw.SimpleText( Line3, "ExpAdv_OverlayFont", X + (50 * Mult), Y + (60 * Mult), TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

local function PaintServer( X, Y, Entity )
    
    local LoadStatus = Entity:GetServerCompletion( ) or 0
    
    if LoadStatus < 100 then
        draw.SimpleText( "Server:", "ExpAdv_OverlayFont", X + (150 * Mult), Y + (30 * Mult), TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        
        draw.SimpleText( "Loading: " .. LoadStatus .. "%", "ExpAdv_OverlayFont", X + (150 * Mult), Y + (40 * Mult), TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    
        return
    end

    local SVState = Entity:GetServerState( ) or 0

    if SVState >= EXPADV_STATE_CRASHED then
        surface.SetMaterial( Material( "omicron/overlay_serverred.png" ) )
        surface.DrawTexturedRect( X, Y, 200 * Mult, 100 * Mult )
    elseif SVState >= EXPADV_STATE_ONLINE then
        surface.SetMaterial( Material( "omicron/overlay_servergreen.png" ) )
        surface.DrawTexturedRect( X, Y, 200 * Mult, 100 * Mult )
    end

    draw.SimpleText( "Server:", "ExpAdv_OverlayFont", X + (150 * Mult), Y + (30 * Mult), TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            
    local Counter = Entity:GetTickQuota( ) or 0
    local Line = string.format( "Quota: %s, %i%%", Shorten( Counter ), (Counter / expadv_hardquota) * 100 )
    draw.SimpleText( Line, "ExpAdv_OverlayFont", X + (150 * Mult), Y + (40 * Mult), TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
       
    local Line2 = string.format( "Usage: %s",  Shorten(Entity:GetAverage( ) or 0 ))
    draw.SimpleText( Line2, "ExpAdv_OverlayFont", X + (150 * Mult), Y + (50 * Mult), TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        
    local Line3 = string.format( "CPU: %i us",  Entity:GetStopWatch( ) or 0 )
    draw.SimpleText( Line3, "ExpAdv_OverlayFont", X + (150 * Mult), Y + (60 * Mult), TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

end

local function PaintOverlay( X, Y, Entity )

    surface.SetMaterial( Material( "omicron/ea2_overlay_bg.png" ) )
    surface.SetDrawColor( Color( 255, 255, 255, 200 ) )
    surface.DrawTexturedRect( X, Y, 200 * Mult, 100 * Mult )

    draw.SimpleText( Entity:GetPlayerName( ), "ExpAdv_OverlayFont", X + (100 * Mult), Y + (10 * Mult), TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    local Name = Entity:GetGateName( )
    if !Name or Name == "" then Name = "LemonGate #2" end
    draw.SimpleText( "Current Script: " .. Name, "ExpAdv_OverlayFont", X + (5 * Mult), Y + (92 * Mult), TextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

    PaintClient( X, Y, Entity )
    PaintServer( X, Y, Entity )
end

hook.Add( "HUDPaint", "Expadv.overlay", function( )
    local Entity = LocalPlayer():GetEyeTrace( ).Entity

    if !IsValid(Entity) or !Entity.ExpAdv then return end

    if ( EyePos():Distance( Entity:GetPos() ) > 156 ) then return end

    local DrawPos = Entity:GetOverlayPos( ):ToScreen( )

    PaintOverlay( DrawPos.x, DrawPos.y, Entity )
end )

function ENT:GetOverlayPos( )
    return self:LocalToWorld( Vector( -6,-2, 2 ) )
end
