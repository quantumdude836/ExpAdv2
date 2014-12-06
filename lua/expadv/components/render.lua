/* -----------------------------------------------------------------------------------
	@: Newer Better Render Library
   --- */

local Component = EXPADV.AddComponent( "render", true )

Component.Author = "Rusketh"
Component.Description = "Allows rendering objects to screens and players HUDs."

require( "Vector2" )

EXPADV.ClientOperators( )

/* -----------------------------------------------------------------------------------
	@: Fonts
   --- */

Component.ValidFonts = {
	["DebugFixed"] = true,
	["DebugFixedSmall"] = true,
	["Default"] = true,
	["Marlett"] = true,
	["Trebuchet18"] = true,
	["Trebuchet24"] = true,
	["HudHintTextLarge"] = true,
	["HudHintTextSmall"] = true,
	["CenterPrintText"] = true,
	["HudSelectionText"] = true,
	["CloseCaption_Normal"] = true,
	["CloseCaption_Bold"] = true,
	["CloseCaption_BoldItalic"] = true,
	["ChatFont"] = true,
	["TargetID"] = true,
	["TargetIDSmall"] = true,
	["HL2MPTypeDeath"] = true,
	["BudgetLabel"] = true
}

Component.CreatedFonts = { }

function Component.CreateFont( Base, Size )
	local FontName = string.format( "expadv_%s_%i", Base, Size )
	if Component.CreatedFonts[FontName] then return FontName end
	
	if !Component.ValidFonts[BaseFont] then
		BaseFont = "default"
		FontName = string.format( "expadv_default_%i", Size )
		if Component.CreatedFonts[FontName] then return FontName end
	end

	Component.CreatedFonts[FontName] = true

	surface.CreateFont( FontName, {
		font = BaseFont,
		size = Size,
		weight = 500,
		antialias = true,
		additive = false,
	} )

	return FontName
end

Component:AddVMFunction( "setFont", "s,n", "s",
	function( Context, Trace, Base, Size )
		surface.SetFont( Component.CreateFont( Base, Size ) )
	end )

Component:AddVMFunction( "setFont", "s,n,c", "s",
	function( Context, Trace, Base, Size, Color )
		surface.SetFont( Component.CreateFont( Base, Size ) )
		surface.SetTextColor( Color )
	end )

Component:AddPreparedFunction( "setFontColor", "c", "", "$surface.SetTextColor( @value 1 )" )

Component:AddInlineFunction( "getTextWidth", "s", "n", "$surface.GetTextSize( @value 1 )" )

Component:AddPreparedFunction( "getTextHeight", "s", "n", "@define _, tall = $surface.GetTextSize( @value 1 )", "@tall" )

Component:AddFunctionHelper( "setFont", "s,n", "Sets the current font and fontsize." )
Component:AddFunctionHelper( "setFont", "s,n,c", "Sets the current font, fontsize and font color." )
Component:AddFunctionHelper(  "setFontColor", "c", "Sets the current font color." )
Component:AddFunctionHelper(  "getTextWidth", "s", "Returns the width of drawing string using the current font." )
Component:AddFunctionHelper(  "getTextHeight", "s", "Returns the width of drawing string using the current font." )

/* -----------------------------------------------------------------------------------
	@: Text
   --- */

Component:AddPreparedFunction( "drawText", "v2,s", "",
	[[$surface.SetTextPos( @value 1.x, @value 1.y )
	$surface.DrawText( @value 2 )
]])

Component:AddPreparedFunction( "drawTextCentered", "v2,s", "",
	[[@define x = @value 1.x - ($surface.GetTextSize( @value 2 ) * 0.5)
	surface.SetTextPos( @x, @value 1.y )
	surface.DrawText( @value 2 )
]])

Component:AddPreparedFunction( "drawTextAlignedRight", "v2,s", "",
	[[@define x = @value 1.x - $surface.GetTextSize( @value 2 )
	surface.SetTextPos( @x, @value 1.y )
	surface.DrawText( @value 2 )
]])

Component:AddFunctionHelper( "drawText", "v,s", "Draws a line of text aligned left of position." )
Component:AddFunctionHelper( "drawTextCentered", "v,s", "Draws a line of text aligned center of position." )
Component:AddFunctionHelper( "drawTextAlignedRight", "v,s", "Draws a line of text aligned right of position." )

/* -----------------------------------------------------------------------------------
	@: Color / Material
   --- */

Component:AddPreparedFunction( "getTextureSize", "s", "n", "$surface.GetTextureSize( $surface.GetTextureID( @value 1 ) )" )
Component:AddPreparedFunction( "setDrawTexture", "s", "", "$surface.SetTexture( $surface.GetTextureID( @value 1 ) )" )
Component:AddPreparedFunction( "setDrawColor", "n,n,n,n", "", "$surface.SetDrawColor( @value 1, @value 2, @value 3, @value 4 )" )
EXPADV.AddFunctionAlias( "setDrawColor", "n,n,n" )
EXPADV.AddFunctionAlias( "setDrawColor", "c" )

Component:AddFunctionHelper( "getTextureSize", "s", "Returns the size of a texture" )
Component:AddFunctionHelper( "setDrawTexture", "s", "Sets the texture used for rendering polys and boxs" )
Component:AddFunctionHelper( "setDrawColor", "n,n,n,n", "Sets the color used for next draw operations" )

/* -----------------------------------------------------------------------------------
	@: Objects Line
   --- */

Component:AddPreparedFunction( "drawLine", "v2,v2", "", [[
	$surface.DrawLine( @value 1.x, @value 1.y, @value 2.x, @value 2.y )
]] )

Component:AddFunctionHelper( "drawLine", "v2,v2", "Draws a line between 2 points" )

/* -----------------------------------------------------------------------------------
	@: Rectangles
   --- */

Component:AddPreparedFunction( "drawBox", "v2,v2", "", "$surface.DrawRect( @value 1.x, @value 1.y, @value 2.x, @value 2.y )" )

Component:AddPreparedFunction( "drawTexturedBox", "v2,v2", "", "$surface.DrawTexturedRect( @value 1.x, @value 1.y, @value 2.x, @value 2.y )" )

Component:AddPreparedFunction( "drawTexturedBox", "v2,v2,n", "", "$surface.DrawTexturedRectRotated( @value 1.x, @value 1.y, @value 2.x, @value 2.y, @value 3 )" )

Component:AddPreparedFunction( "drawTexturedBox", "v2,v2,n,n,n,n", "", "$surface.DrawTexturedRectUV( @value 1.x, @value 1.y, @value 2.x, @value 2.y, @value 3, @value 4, @value 5, @value 6 )" )


Component:AddFunctionHelper( "drawBox", "v2,v2", "Draws a box ( Position, Size )." )
Component:AddFunctionHelper( "drawTexturedBox", "v2,v2", "Draws a textured box ( Position, Size )." )
Component:AddFunctionHelper( "drawTexturedBox", "v2,v2,n", "Draws a rotated textured box ( Position, Size, Angle )." )
Component:AddFunctionHelper( "drawTexturedBox", "v2,v2,n,n,n,n", "Draws a textured box with uv co-ordinates ( Position, Size, U1, V1, U2, V2 )." )

/* -----------------------------------------------------------------------------------
	@: Sprites
   --- */
  
Component:AddPreparedFunction("drawSprite", "v,n,n,c", "", "$render.DrawSprite(@value 1, @value 2, @value 3, @value 4)")
Component:AddFunctionHelper("drawSprite", "", "Creates a sprite at the given position.")


/* -----------------------------------------------------------------------------------
	@: UV Object
   --- */
local Vertex = Component:AddClass( "vertex" , "vt" )

Vertex:MakeClientOnly( )

Vertex:DefaultAsLua( function( ) return {x=0,y=0,u=0,v=0} end )

Vertex:StringBuilder( function( Obj ) return string.format( "vert<%s,%i,%i,%i>", Obj.x, Obj.y, Obj.u, Obj.v) end )

Vertex:AddPreparedOperator( "=", "n,vt", "", "Context.Memory[@value 1] = @value 2" )

Component:AddInlineFunction( "vert", "v2,v2", "vt", "{x = @value 1.x, y = @value 1.y, u = @value 2.x, v = @value 2.y }" )

Component:AddInlineFunction( "vert", "v2,n,n", "vt", "{x = @value 1.x, y = @value 1.y, u = @value 2, v = @value 3 }" )

Component:AddInlineFunction( "vert", "n,n,n,n", "vt", "{x = @value 1, y = @value 2, u = @value 3, v = @value 4 }" )

/* --- -------------------------------------------------------------------------------
	@: Polys
   --- */
   
local function Counterclockwise( a, b, c )
	local area = (a.x - c.x) * (b.y - c.y) - (b.x - c.x) * (a.y - c.y)
	return area > 0
end
 
local function DrawPoly(Array)
	render.CullMode(Counterclockwise(unpack(Array)) and MATERIAL_CULLMODE_CCW or MATERIAL_CULLMODE_CW )
	surface.DrawPoly(Array)
	render.CullMode(MATERIAL_CULLMODE_CCW)
end

local function DrawPolyOutline(Array) 
	for i=1, #Array do
		if i==#Array then
			surface.DrawLine( Array[i].x, Array[i].y, Array[1].x, Array[1].y ) 
		else
			surface.DrawLine( Array[i].x, Array[i].y, Array[i+1].x, Array[i+1].y )
		end
	end
end

Component:AddVMFunction( "drawTexturedTriangle", "vt,vt,vt", "", function(Context, Trace, V1, V2, V3) DrawPoly({V1, V2, V3}) end)

Component:AddVMFunction( "drawTexturedTriangle", "v2,v2,v2", "", function(Context, Trace, V1, V2, V3) DrawPoly({V1, V2, V3}) end)

Component:AddVMFunction( "drawTriangle", "v2,v2,v2", "", function(Context, Trace, V1, V2, V3) draw.NoTexture(); DrawPoly({V1, V2, V3}) end)
 
Component:AddVMFunction( "drawPoly", "ar", "", function(Context, Trace, Array)
	if Array.__type ~= "_vt" and Array.__type ~= "_v2" then Context.Throw(Trace, "array", "array type missmatch, vertex expected got " .. EXPADV.TypeName(Array.__type)) end
	draw.NoTexture() 
	DrawPoly(Array)
end)

Component:AddVMFunction( "drawTexturedPoly", "ar", "", function(Context, Trace, Array)
	if Array.__type ~= "_vt" and Array.__type ~= "_v2" then Context.Throw(Trace, "array", "array type missmatch, vertex expected got " .. EXPADV.TypeName(Array.__type)) end
	DrawPoly(Array)
end)

Component:AddVMFunction( "drawPolyOutline", "ar", "", function(Context, Trace, Array)
	if Array.__type ~= "_vt" and Array.__type ~= "_v2" then Context.Throw(Trace, "array", "array type missmatch, vertex expected got " .. EXPADV.TypeName(Array.__type)) end
	DrawPolyOutline(Array)
end)

Component:AddFunctionHelper( "drawTriangle", "v2,v2,v2", "Draws a traingle from 3 points." )
Component:AddFunctionHelper( "drawPoly", "ar", "Draws a polygon using an arry of 2d vectors or vertexs." )
Component:AddFunctionHelper( "drawPolyOutline", "ar", "Draws an outlined polygon using an arry of 2d vectors or vertexs." )
Component:AddFunctionHelper( "drawTexturedTriangle", "v2,v2,v2", "Draws a textured traingle from 3 points." )
Component:AddFunctionHelper( "drawTexturedPoly", "ar", "Draws a textured polygon using an arry of 2d vectors or vertexs." )

/* --- -------------------------------------------------------------------------------
	@: Circles
   --- */
  
Component:AddVMFunction( "drawCircle", "v2,n", "", function(Context, Trace, Position, Radius)
	local vertices = { }
	for i=1, 30 do
		vertices[i] = Position + Vector2(math.sin(-math.rad(i/30*360)) * Radius, math.cos(-math.rad(i/30*360)) * Radius)
	end
	draw.NoTexture()
	DrawPoly(vertices)
end)

Component:AddVMFunction( "drawCircleOutline", "v2,n", "", function(Context, Trace, Position, Radius)
	local vertices = { }
	for i=1, 30 do
		vertices[i] = Position + Vector2(math.sin(-math.rad(i/30*360)) * Radius, math.cos(-math.rad(i/30*360)) * Radius)
	end
	draw.NoTexture()
	DrawPolyOutline(vertices)
end)
  
Component:AddFunctionHelper( "drawCircle", "v2,n", "Draws a circle." )
Component:AddFunctionHelper( "drawCircleOutline", "v2,n", "Draws an outlined circle." )

/* -----------------------------------------------------------------------------------
	@: Screen
   --- */

Component:AddPreparedFunction( "traceSurfaceColor", "v,v", "c", "@define Value = $render.GetSurfaceColor( @value 1, @value 2 )", "Color(@Value.x *255, @Value.y * 255, @Value.z *255, 255)" )
Component:AddFunctionHelper( "traceSurfaceColor", "v,v", "Performs a render trace and returns the color of the surface hit, this uses a low res version of the texture." )

Component:AddPreparedFunction( "pauseNextFrame", "b", "", [[
if IsValid( Context.entity ) and Context.entity.Screen then
	Context.entity:SetRenderingPaused( @value 1 )
end]] )

Component:AddFunctionHelper( "pauseNextFrame", "b", "While set to true the screen will not draw the next frame." )

Component:AddInlineFunction( "nextFramePaused", "", "b", "((IsValid( Context.entity ) and Context.entity.Screen) and Context.entity:GetRenderingPaused( ) or false)" )
Component:AddFunctionHelper( "pauseNextFrame", "b", "returns true, if the screens next frame is paused." )

Component:AddPreparedFunction( "noFrameRefresh", "b", "", [[
if IsValid( Context.entity ) and Context.entity.Screen then
	Context.entity:SetNoClearFrame( @value 1 )
end]] )

Component:AddFunctionHelper( "noFrameRefresh", "b", "While set to true the screen will not draw the next frame." )

Component:AddInlineFunction( "frameRefreshDisabled", "", "b", "((IsValid( Context.entity ) and Context.entity.Screen) and Context.entity:GetNoClearFrame( ) or false)" )
Component:AddFunctionHelper( "frameRefreshDisabled", "b", "returns true, if the screens is set not to clear the screen each frame." )

EXPADV.SharedOperators( )

Component:AddPreparedFunction( "getScreenCursor", "ply:", "v2", [[
if IsValid( Context.entity ) and Context.entity.Screen then
	@define value = Context.entity:GetCursor( @value 1 )
else
	@value = Vector2(0,0)
end]], "@value" )

Component:AddFunctionHelper( "getScreenCursor", "ply:", "Returns the cursor psotion of a player, for a screen." )

Component:AddPreparedFunction( "screenToLocal", "v2", "v", [[
if IsValid( Context.entity ) and Context.entity.Screen then
	@define value = Context.entity:ScreenToLocalVector( @value 1 )
else
	@value = Vector(0,0,0)
end]], "@value" )

Component:AddFunctionHelper( "screenToLocal", "v2", "Returns the position on screen as a local vector." )

Component:AddPreparedFunction( "screenToWorld", "v2", "v", [[
if IsValid( Context.entity ) and Context.entity.Screen then
	@define value = Context.entity:LocalToWorld( Context.entity:ScreenToLocalVector( @value 1 ) )
else
	@value = Vector(0,0,0)
end]], "@value" )

Component:AddFunctionHelper( "screenToWorld", "v2", "Returns the position on screen as a world vector." )

Component:AddPreparedFunction( "setFPS", "n", "", [[if IsValid( Context.entity ) and Context.entity.Screen then Context.entity:SetFPS(@value 1) end]] )

Component:AddFunctionHelper( "setFPS", "n", "sets the fps of the screen, between 1 - 60 frames per second." )

Component:AddPreparedFunction( "getFPS", "", "n", [[if IsValid( Context.entity ) and Context.entity.Screen then 
	@define fps = Context.entity:GetFPS() 
end]], "(@fps or 0)" )

Component:AddFunctionHelper( "getFPS", "", "returns the fps of the screen." )

/* -----------------------------------------------------------------------------------
	@: Time functions
   --- */

Component:AddInlineFunction( "frameTime", "", "n", "$FrameTime( )" )
Component:AddFunctionHelper( "frameTime", "", "Returns the time in seconds it took to render the games last frame." )

EXPADV.ClientOperators()

Component:AddInlineFunction( "realFrameTime", "", "n", "$RealFrameTime( )" )
Component:AddFunctionHelper( "realFrameTime", "", "Returns the real frame-time which is unaffected by host_timescale." )

/* -----------------------------------------------------------------------------------
	@: Hud functions
   --- */

Component:AddPreparedFunction( "toScreen", "v", "v2", "@define T = @value 1:ToScreen( )", "Vector2( @T.x, @T.y )" )
Component:AddFunctionHelper( "toScreen", "v", "Translates the vectors position into 2D client screen coordinates." )

Component:AddInlineFunction( "isVisible", "v", "b", "@value 1:ToScreen( ).visible" )
Component:AddFunctionHelper( "isVisible", "v", "Returns true if the vectors position is in clients view." )

Component:AddInlineFunction( "canRenderToHUD", "", "b", "(IsValid(Context.entity) and Context.entity.EnableHUD)" )
Component:AddFunctionHelper( "canRenderToHUD", "", "Returns true if this entity can render to clientside HUD." )

/* --- --------------------------------------------------------------------------------
	@: 3D
	@: Author: Ripmax
   --- */
   
EXPADV.ClientOperators()

Component:AddInlineFunction("fov", "", "n", "$LocalPlayer():GetFOV()")
Component:AddFunctionHelper("fov", "n", "Gets FOV of local player.")

Component:AddPreparedFunction("setRenderMat", "s", "", [[$render.SetMaterial($Material(@value 1))]])
Component:AddFunctionHelper("setRenderMat", "", "Sets the material of the rendered objects.")

Component:AddPreparedFunction("draw3DLine", "v,v,c", "", "$render.DrawLine(@value 1, @value 2, @value 3, true)")
Component:AddFunctionHelper("draw3DLine", "", "Draws 3D line (start, end, color).")

Component:AddPreparedFunction("draw3DBox", "v,a,v,v,c", "", "$render.DrawBox(@value 1, @value 2, @value 3, @value 4, @value 5, true)")
Component:AddFunctionHelper("draw3DBox", "", "Draws 3D box (position, angle, mins, maxs, color).")

Component:AddPreparedFunction("draw3DSphere", "v,n,n,n,c", "", "$render.DrawSphere(@value 1, @value 2, @value 3, @value 4, @value 5)")
Component:AddFunctionHelper("draw3DSphere", "", "Draws 3D sphere.")

Component:AddPreparedFunction("draw3DQuadEasy", "v,v,n,n,c,n", "", "$render.DrawQuadEasy(@value 1, @value 2, @value 3, @value 4, @value 5, @value 6)")
Component:AddFunctionHelper("draw3DQuadEasy", "", "Draws 3D quad.")

Component:AddPreparedFunction("draw3DQuad", "v,v,v,v,c", "", "$render.DrawQuad(@value 1, @value 2, @value 3, @value 4, @value 5)")
Component:AddFunctionHelper("draw3DQuad", "", "Draws 3D quad.")

Component:AddPreparedFunction("draw3DBeam", "v,v,n,n,n,c", "", "$render.DrawBeam(@value 1, @value 2, @value 3, @value 4, @value 5, @value 6)")
Component:AddFunctionHelper("draw3DBeam", "", "Draws 3D beam.")

Component:AddPreparedFunction("draw3DModel", "s,v,a", "", "$render.Model({['model'] = @value 1, ['pos'] = @value 2, ['angle'] = @value 3})")
Component:AddFunctionHelper("draw3DModel", "", "Draws 3D model.")

Component:AddPreparedFunction("start3D2D", "v,a", "", "$cam.Start3D2D(@value 1, @value 2, 1)")
Component:AddPreparedFunction("start3D2D", "v,a,n", "", "$cam.Start3D2D(@value 1, @value 2, @value 3)")

Component:AddPreparedFunction("end3D2D", "", "", "$cam.End3D2D()")

/* -----------------------------------------------------------------------------------
	@: Hud Event
   --- */

EXPADV.ClientEvents( )

Component:AddEvent( "drawScreen", "n,n", "" )
Component:AddEvent( "drawHUD", "n,n", "" )
Component:AddEvent( "enableHUDRendering", "", "" )
Component:AddEvent( "disableHUDRendering", "", "" )

Component:AddEvent( "draw3DOverlay", "", "" )
Component:AddEvent( "draw3D", "", "" )
Component:AddEvent( "enable3DRendering", "", "" )
Component:AddEvent( "disable3DRendering", "", "" )


if CLIENT then
	hook.Add( "HUDPaint", "expadv.hudpaint", function( )
		if !EXPADV.IsLoaded then return end

		local W, H = ScrW( ), ScrH( )

		for _, Context in pairs( EXPADV.CONTEXT_REGISTERY ) do
			if !Context.Online then continue end
			
			if !IsValid(Context.entity) then continue end
			
			if(Context.entity.EnableHUD && Context.event_drawHUD) then
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetTextColor( 0, 0, 0, 255 )
				
				Context:Execute( "Event drawHUD", Context.event_drawHUD, W, H )
			end
			
			if(Context.entity.Enable3D && Context.event_draw3DOverlay) then
				cam.Start3D(EyePos(), EyeAngles())
					Context:Execute("Event draw3DOverlay", Context.event_draw3DOverlay)
				cam.End3D()
			end
		end
	end )
	
	hook.Add( "PostDrawOpaqueRenderables", "expadv.postdraw", function( DrawingDepth, DrawingSkybox )
		if !EXPADV.IsLoaded or bDrawingDepth or bDrawingSkybox then return end

		for _, Context in pairs( EXPADV.CONTEXT_REGISTERY ) do
			if !Context.Online then continue end
			
			if !IsValid( Context.entity ) then continue end
			
			if(Context.entity.Enable3D && Context.event_draw3D) then
				Context:Execute( "Event draw3D", Context.event_draw3D )
			end
		end
	end)
	
	/* -----------------------------------------------------------------------------------
		@: Enable HUD/3D Rendering
	   --- */
	
	function Component:OnOpenContextMenu( Entity, Menu, Trace, Option )
		if !Entity.Context then return end

		if(Entity.Context.event_drawHUD) then
			if(Entity.EnableHUD) then
				Menu:AddOption( "Disable HUD Rendering", function( )
					Entity.EnableHUD = false
					Entity:CallEvent( "disableHUDRendering" )
				end )
			else
				Menu:AddOption( "Enable HUD Rendering", function( )
					Entity.EnableHUD = true
					Entity:CallEvent( "enableHUDRendering" )
				end )
			end
		end
		
		if(Entity.Context.event_draw3D || Entity.Context.event_draw3DOverlay) then
			if(Entity.Enable3D) then
				Menu:AddOption( "Disable 3D Rendering", function( )
					Entity.Enable3D = false
					Entity:CallEvent( "disable3DRendering" )
				end )
			else
				Menu:AddOption( "Enable 3D Rendering", function( )
					Entity.Enable3D = true
					Entity:CallEvent( "enable3DRendering" )
				end )
			end
		end
	end
end

/* -----------------------------------------------------------------------------------
	@: WIP Features.
   --- */

Component:AddFeature( "HUD rendering", "Drawing directly onto your heads up display." )
Component:AddFeature( "3d rendering", "Rendering 3d objects such as sprites in world." )