/* -----------------------------------------------------------------------------------
	@: Render Component
   --- */

local Component = EXPADV.AddComponent( "render", true )

/* -----------------------------------------------------------------------------------
	@: Draw Functions
   --- */

EXPADV.ClientOperators( )

Component:AddPreparedFunction( "drawLine", "v2,v2,c", "", [[
	$surface.SetDrawColor( @value 3 )
	$surface.DrawLine( @value 1.x, @value 1.y, @value 2.x, @value 2.y )
]] )
Component:AddFunctionHelper( "drawLine", "v2,v2,c", "Draws a line between 2 points." )

Component:AddPreparedFunction( "drawBox", "v2,v2,c", "", [[
	$surface.SetDrawColor( @value 3 )
	$surface.DrawRect( @value 1.x, @value 1.y, @value 2.x, @value 2.y )
]] )
Component:AddFunctionHelper( "drawBox", "v2,v2,c", "Draws a box ( Position, Size )." )

Component:AddPreparedFunction( "drawTriangle", "v2,v2,v2,c", "", [[
	$surface.SetDrawColor( @value 4 )
	$surface.DrawPoly( {@value 1, @value 2, @value 3} )
]] )
Component:AddFunctionHelper( "drawTriangle", "v2,v2,v2,c", "Draws a traingle from 3 points." )

Component:AddPreparedFunction( "drawPoly", "c,...", "", [[
	$surface.SetDrawColor( @value 4 )
	@define polygon = { }

	for _, Variant in pairs( { @... } ) do
		if Variant[2] == "_v2" then
			@polygon[#@polygon + 1] = Variant[1]
		end
	end

	$surface.DrawPoly( @polygon )
]] )
Component:AddFunctionHelper( "drawPoly", "c,...", "Draws a polygon using 2d vectors." )

/* -----------------------------------------------------------------------------------
	@: Text
   --- */

Component:AddPreparedFunction( "textSize", "s,s", "v2", [[
	$surface.SetFont( @value 1 )
	@define Size = Vector2( $surface.GetTextSize( @value 2 ) )
]], "@Size" )
Component:AddFunctionHelper( "getTextSize", "s,s", "Gets the render size of a string, where first argument is the font and the second is the string." )

Component:AddPreparedFunction( "drawTextCentered", "v2,c,s,s", "", "$draw.SimpleText( @value 4, @value 3, @value 1.x, @value 1.y, @value 2, $TEXT_ALIGN_CENTER, $TEXT_ALIGN_CENTER)" )
Component:AddFunctionHelper( "drawTextCentered", "v2,c,s,s", "Draws a string centered to its position (Position, Color, font, Text)." )

Component:AddPreparedFunction( "drawTextAlignedLeft", "v2,c,s,s", "", "$draw.SimpleText( @value 4, @value 3, @value 1.x, @value 1.y, @value 2, $TEXT_ALIGN_LEFT, $TEXT_ALIGN_CENTER)" )
Component:AddFunctionHelper( "drawTextAlignedLeft", "v2,c,s,s", "Draws a string alighed left of its position (Position, Color, font, Text)." )

Component:AddPreparedFunction( "drawTextAlignedRight", "v2,c,s,s", "", "$draw.SimpleText( @value 4, @value 3, @value 1.x, @value 1.y, @value 2, $TEXT_ALIGN_RIGHT, $TEXT_ALIGN_CENTER)" )
Component:AddFunctionHelper( "drawTextAlignedRight", "v2,c,s,s", "Draws a string alighed right of its position (Position, Color, font, Text)." )

/* -----------------------------------------------------------------------------------
	@: Hud Event
   --- */

EXPADV.ClientEvents( )

Component:AddEvent( "drawScreen", "n,n", "" )
Component:AddEvent( "drawHUD", "n,n", "" )

hook.Add( "HUDPaint", "expadv.hudpaint", function( )
	if !EXPADV.IsLoaded then return end

	local W, H = ScrW( ), ScrH( )

	for _, Context in pairs( EXPADV.CONTEXT_REGISTERY ) do
		if !Context.Online then continue end
		
		local Event = Context.event_drawHUD
		
		if !Event or !Context.EnableHUD then continue end
		
		Context:Execute( "Event drawHUD", Event, W, H )
	end
end )

/* -----------------------------------------------------------------------------------
	@: Enable Hud Rendering
   --- */

function Component:OnOpenContextMenu( Entity, Menu, Trace, Option )
	if !Entity.Context or !Entity.Context.event_drawHUD then return end

	if Entity.Context.EnableHUD then
		Menu:AddOption( "Disable HUD Rendering", function( ) Entity.Context.EnableHUD = false end )
	else
		Menu:AddOption( "Enable HUD Rendering", function( ) Entity.Context.EnableHUD = true end )
	end
end