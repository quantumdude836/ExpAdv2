/* --- --------------------------------------------------------------------------------
	@: Holo Component
   --- */

EXPADV.ServerOperators( )

local HoloComponent = EXPADV.AddComponent( "hologram" , true )

/* --- --------------------------------------------------------------------------------
	@: Settings
   --- */

HoloComponent:CreateSetting( "max", 250 )
HoloComponent:CreateSetting( "rate", 50 )
HoloComponent:CreateSetting( "clips", 5 )
HoloComponent:CreateSetting( "Size", 50 )
HoloComponent:CreateSetting( "model_any", 1 )

/* --- --------------------------------------------------------------------------------
	@: Settings as inlined functions
   --- */

HoloComponent:AddInlineFunction( "hologramLimit", "", "n", "@setting max" )
HoloComponent:AddInlineFunction( "hologramSpawnRate", "", "n", "@setting rate" )
HoloComponent:AddInlineFunction( "hologramClipLimit", "", "n", "@setting clips" )
HoloComponent:AddInlineFunction( "hologramMaxScale", "", "n", "@setting Size" )
HoloComponent:AddInlineFunction( "hologramAnyModel", "", "b", "@setting model_any" )

/* --- --------------------------------------------------------------------------------
	@: Hologram Handeling
   --- */

local HolosByEntity = { }

local HolosByPlayer = { }

local DeltaPerPlayer = { }

function HoloComponent:OnShutDown( Context )
	MsgN( "HOLOGRAM SHUTDOWN CALL!" )
	if IsValid( Context.player ) then
		local PlyTbl = HolosByPlayer[ Context.player:UniqueID( ) ]

		for _, Holo in pairs( HolosByEntity[ Context.entity ] or { } ) do
			PlyTbl[ Holo ] = nil
			if IsValid( Holo ) then Holo:Remove( ) end
		end
	else
		for _, Holo in pairs( HolosByEntity[ Context.entity ] or { } ) do
			if IsValid( Holo ) then Holo:Remove( ) end
		end
	end
end

function HoloComponent:OnCoreReload( )
	HolosByPlayer = { }

	for Ent, Holos in pairs( HolosByEntity ) do
		for _, Holo in pairs( Holos ) do
			if IsValid( Holo ) then Holo:Remove( ) end
		end
	end
end

timer.Create( "lemon.holograms", 1, 0, function( )
	DeltaPerPlayer = { }
end )

hook.Add( "PlayerInitialSpawn", "lemon.hologram.owners", function( Ply )
	local Holos = HolosByPlayer[ Ply:UniqueID( ) ]
	
	if !Holos then return end

	local Total = 0

	for _, Holo in pairs( Holos ) do Total = Total + 1 end

	Ply:SetNWInt( "lemon.holograms", Total )
end )

/* --- --------------------------------------------------------------------------------
	@: Build Model List
   --- */
   
local ModelEmu = {
    ["cone"]              = "cone",
    ["cube"]              = "cube",
    ["cylinder"]          = "cylinder",
    ["hq_cone"]           = "hq_cone",
    ["hq_cylinder"]       = "hq_cylinder",
    ["hq_dome"]           = "hq_dome",
    ["hq_hdome"]          = "hq_hdome",
    ["hq_hdome_thick"]    = "hq_hdome_thick",
    ["hq_hdome_thin"]     = "hq_hdome_thin",
    ["hq_icosphere"]      = "hq_icosphere",
    ["hq_sphere"]         = "hq_sphere",
    ["hq_torus"]          = "hq_torus",
    ["hq_torus_thick"]    = "hq_torus_thick",
    ["hq_torus_thin"]     = "hq_torus_thin",
    ["hq_torus_oldsize"]  = "hq_torus_oldsize",
    ["hq_tube"]           = "hq_tube",
    ["hq_tube_thick"]     = "hq_tube_thick",
    ["hq_tube_thin"]      = "hq_tube_thin",
    ["hq_stube"]           = "hq_stube",
    ["hq_stube_thick"]     = "hq_stube_thick",
    ["hq_stube_thin"]      = "hq_stube_thin",
    ["icosphere"]         = "icosphere",
    ["icosphere2"]        = "icosphere2",
    ["icosphere3"]        = "icosphere3",
    ["plane"]             = "plane",
    ["prism"]             = "prism",
    ["pyramid"]           = "pyramid",
    ["sphere"]            = "sphere",
    ["sphere2"]           = "sphere2",
    ["sphere3"]           = "sphere3",
    ["tetra"]             = "tetra",
    ["torus"]             = "torus",
    ["torus2"]            = "torus2",
    ["torus3"]            = "torus3",

    ["hq_rcube"]          = "hq_rcube",
    ["hq_rcube_thick"]    = "hq_rcube_thick",
    ["hq_rcube_thin"]     = "hq_rcube_thin",
    ["hq_rcylinder"]      = "hq_rcylinder",
    ["hq_rcylinder_thick"]= "hq_rcylinder_thick",
    ["hq_rcylinder_thin"] = "hq_rcylinder_thin",
    ["hq_cubinder"]       = "hq_cubinder",
    ["hexagon"]           = "hexagon",
    ["octagon"]           = "octagon",
    ["right_prism"]       = "right_prism",

    // Removed models with their replacements

    ["dome"]             = "hq_dome",
    ["dome2"]            = "hq_hdome",
    ["hqcone"]           = "hq_cone",
    ["hqcylinder"]       = "hq_cylinder",
    ["hqcylinder2"]      = "hq_cylinder",
    ["hqicosphere"]      = "hq_icosphere",
    ["hqicosphere2"]     = "hq_icosphere",
    ["hqsphere"]         = "hq_sphere",
    ["hqsphere2"]        = "hq_sphere",
    ["hqtorus"]          = "hq_torus_oldsize",
    ["hqtorus2"]         = "hq_torus_oldsize",

    // HQ models with their short names

    ["hqhdome"]          = "hq_hdome",
    ["hqhdome2"]         = "hq_hdome_thin",
    ["hqhdome3"]         = "hq_hdome_thick",
    ["hqtorus3"]         = "hq_torus_thick",
    ["hqtube"]           = "hq_tube",
    ["hqtube2"]          = "hq_tube_thin",
    ["hqtube3"]          = "hq_tube_thick",
    ["hqstube"]          = "hq_stube",
    ["hqstube2"]         = "hq_stube_thin",
    ["hqstube3"]         = "hq_stube_thick",
    ["hqrcube"]          = "hq_rcube",
    ["hqrcube2"]         = "hq_rcube_thick",
    ["hqrcube3"]         = "hq_rcube_thin",
    ["hqrcylinder"]      = "hq_rcylinder",
    ["hqrcylinder2"]     = "hq_rcylinder_thin",
    ["hqrcylinder3"]     = "hq_rcylinder_thick",
    ["hqcubinder"]       = "hq_cubinder"
}

EXPADV.CallHook( "BuildHologramModels", ModelEmu )

/* --- --------------------------------------------------------------------------------
	@: Model list functions
   --- */

HoloComponent:AddVMFunction( "asGameModel", "s", "s",
	function( Context, Trace, Model )
		return ModelEmu[Model] or ""
	end )

HoloComponent:AddFunctionHelper( "asGameModel", "s", "Gets the full model path of a wire hologram model." )

/* --- --------------------------------------------------------------------------------
	@: Class
   --- */

local Hologram = HoloComponent:AddClass( "hologram", "h" )

Hologram:MakeServerOnly( )

Hologram:DefaultAsLua( Entity(0) )

Hologram:ExtendClass( "e" )

Hologram:AddAlias( "holo" )

/* --- --------------------------------------------------------------------------------
	@: Casting
   --- */

HoloComponent:AddPreparedOperator( "hologram", "e", "h", [[
if !IsValid( @value 1 ) or !@value 1.IsHologram then
	Context:Throw( %trace, "hologram", "casted none hologram from entity.")
end ]], "@value 1" )

/*==============================================================================================
    Section: Set Model
==============================================================================================*/

local function SetModel( Context, Trace, Entity, Model )
	local ValidModel = ModelEmu[ Model or "sphere" ]

	if ValidModel then
		if Entity.IsHologram and Entity.player == Context.player then
			Entity:SetModel( "models/holograms/" .. ValidModel .. ".mdl" )
		end

	elseif !HoloComponent:ReadSetting( "model_any", true ) or !util.IsValidModel( Model ) then
		Context:Throw( Trace, "hologram", "Invalid model set " .. Model )
	elseif Entity.IsHologram and Entity.player == Context.player then
		Entity:SetModel( ValidModel or Model )
	end
end

HoloComponent:AddVMFunction( "setModel", "h:s", "", SetModel )

/*==============================================================================================
    Section: ID Emulation
    	-- Don't worry, they are still objects!
==============================================================================================*/

local function SetID( Context, Trace, Entity, ID )
	if ID < 1 or !Entity.IsHologram then return end

	Context.Data.Holograms[ Entity.ID or -1 ] = nil

	Context.Data.Holograms[ ID ] = Entity

	Entity.ID = ID
end

HoloComponent:AddVMFunction( "setID", "h:n", "", SetID )
HoloComponent:AddInlineFunction( "getID", "h:", "n", "(@value 1.ID or -1)" )
HoloComponent:AddInlineFunction( "hologram", "n", "h", "(Context.Data.Holograms[ @value 1] or $Entity(0))" )

HoloComponent:AddFunctionHelper( "setID", "h:n", "Sets the id of a hologram for use with hologram(N), the ID is specific to the Gate." )
HoloComponent:AddFunctionHelper( "getID", "h:", "Returns the current ID of hologram H." )
HoloComponent:AddFunctionHelper( "hologram", "n", "Returns the hologram with the id set to N." )

/*==============================================================================================
    Section: Creation
==============================================================================================*/

local function NewHolo( Context, Trace, Model, Position, Angle )
	local UID = Context.player:UniqueID( )

	if Context.player:GetNWInt( "lemon.holograms", 0 ) >= HoloComponent:ReadSetting( "max", 0 ) then
		Context:Throw( Trace, "hologram", "Hologram limit reached." )
	elseif ( DeltaPerPlayer[ UID ] or 0 ) >= HoloComponent:ReadSetting( "rate", 0 ) then
		Context:Throw( Trace, "hologram", "Hologram cooldown reached." )
	end

	local Entity = ents.Create( "lemon_holo" )

	if !IsValid( Entity ) then
		Context:Throw( Trace, "hologram", "Failed to create hologram." )
	end

	Context.player:SetNWInt( "lemon.holograms", Context.player:GetNWInt( "lemon.holograms", 0 ) + 1 )

	Entity.player = Context.player

	Entity:Spawn( )

	Entity:Activate( )
	
	if CPPI then Entity:CPPISetOwner( Context.player ) end

	HolosByEntity[ Context.entity ] = HolosByEntity[ Context.entity ] or { }

	HolosByEntity[ Context.entity ][ Entity ] = Entity

	HolosByPlayer[ UID ] = HolosByPlayer[ UID ] or { }

	HolosByPlayer[ UID ][ Entity ] = Entity

	DeltaPerPlayer[ UID ] = ( DeltaPerPlayer[ UID ] or 0 ) + 1

	Context.Data.Holograms = Context.Data.Holograms or { }

	local ID = #Context.Data.Holograms + 1
	Context.Data.Holograms[ ID ] = ID

	--if !Model then return Entity end
	SetModel( Context, Trace, Entity, Model or "sphere" )

	if !Position then
		Entity:SetPos( Context.entity:GetPos( ) )
	else
		Entity:SetPos( Position )
	end

	if !Angle then
		Entity:SetAngles( Context.entity:GetAngles( ) )
	else
		Entity:SetAngles( Angle )
	end

	return Entity
end

HoloComponent:AddVMFunction( "hologram", "", "h", NewHolo )
HoloComponent:AddFunctionHelper( "hologram", "", "Creates a hologram." )

HoloComponent:AddVMFunction( "hologram", "s", "h", NewHolo )
HoloComponent:AddFunctionHelper( "hologram", "s", "Creates a hologram with (string model)." )

HoloComponent:AddVMFunction( "hologram", "s,v", "h", NewHolo )
HoloComponent:AddFunctionHelper( "hologram", "s,v", "Creates a hologram with (string model) at (vector position)." )

HoloComponent:AddVMFunction( "hologram", "s,v,a", "h", NewHolo )
HoloComponent:AddFunctionHelper( "hologram", "s,v,a", "Creates a hologram with (string model) at (vector position) with (angle rotation)." )

/*==============================================================================================
    Section: Can Hologram
==============================================================================================*/
local function CanHolo( Context )
	local UID = Context.player:UniqueID( )
	
	if Context.player:GetNWInt( "lemon.holograms", 0 ) >= HoloComponent:ReadSetting( "max", 0 )  then
		return false
	elseif ( DeltaPerPlayer[ UID ] or 0 ) >= HoloComponent:ReadSetting( "rate", 0 )  then
		return false
	end

	return true
end

HoloComponent:AddVMFunction( "canMakeHologram", "", "b", CanHolo )
HoloComponent:AddFunctionHelper( "canMakeHologram", "", "Returns true if a hologram can be made this tick." )

/*==============================================================================================
    Position
==============================================================================================*/
HoloComponent:AddPreparedFunction("setPos", "h:v", "",[[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetPos( @value 2 )
end]] )

HoloComponent:AddPreparedFunction("moveTo", "h:v,n", "",[[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:MoveTo( @value 2, @value 3 )
end]] )

HoloComponent:AddPreparedFunction("stopMove", "h:", "",[[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:StopMove( )
end]] )


HoloComponent:AddFunctionHelper( "setPos", "h:v", "Sets the postion of the hologram." )
HoloComponent:AddFunctionHelper( "moveTo", "h:v,n", "Moves the hologram to position V at speed N" )
HoloComponent:AddFunctionHelper( "stopMove", "h:", "If a hologram is being moved, by a call to h:moveTo(v,) this stops it." )

/*==============================================================================================
    Angles
==============================================================================================*/
HoloComponent:AddPreparedFunction("setAng", "h:a", "",[[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetAngles( @value 2 )
end]] )

HoloComponent:AddPreparedFunction("rotateTo", "h:a,n", "",[[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:RotateTo( @value 2, @value 3 )
end]] )

HoloComponent:AddPreparedFunction("stopRotate", "h:", "",[[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:StopRotate( )
end]] )

HoloComponent:AddFunctionHelper( "setAng", "h:a", "Sets the angle of a hologram." )
HoloComponent:AddFunctionHelper( "rotateTo", "h:a,n", "Animates a hologram to move to rotation A, N is speed." )
HoloComponent:AddFunctionHelper( "stopRotate", "h:", "Stops the rotation animation of a hologram." )

/*==============================================================================================
    Scale
==============================================================================================*/
HoloComponent:AddPreparedFunction("setScale", "h:v", "",[[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetScale( @value 2 )
end]] )

HoloComponent:AddPreparedFunction("setScaleUnits", "h:v", "",[[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetScaleUnits( @value 2 )
end]] )

HoloComponent:AddPreparedFunction("scaleTo", "h:v,n", "",[[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:ScaleTo( @value 2, @value 3 )
end]] )

HoloComponent:AddPreparedFunction("scaleToUnits", "h:v,n", "",[[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:ScaleToUnits( @value 2, @value 3 )
end]] )

HoloComponent:AddPreparedFunction("stopScale", "h:", "",[[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:StopScale( )
end]] )

HoloComponent:AddPreparedFunction("getScale", "h:", "v",[[
if IsValid( @value 1 ) and @value 1.GetScale then
	%util = @value 1:GetScale( )
end]], "Vector3( %util or Vector( 0, 0, 0 ) )" )

HoloComponent:AddPreparedFunction("getScaleUnits", "h:", "v",[[
@define pos
if IsValid( @value 1 ) and @value 1.GetScale then
	@pos = @value 1:GetScaleUnits( )
end]], "( @pos or Vector( 0, 0, 0 ) )" )

HoloComponent:AddFunctionHelper( "stopRotate", "h:", "Stops the rotation animation of a hologram." )
HoloComponent:AddFunctionHelper("setScale", "h:v", "Sets the scale of a hologram." )
HoloComponent:AddFunctionHelper("setScaleUnits", "h:v", "Sets the scale of a hologram in units." )
HoloComponent:AddFunctionHelper("scaleTo", "h:v,n", "Animates a hologram to rescale to size V, N is speed." )
HoloComponent:AddFunctionHelper("scaleToUnits", "h:v,n", "Animates a hologram to rescale to size V in units, N is speed." )
HoloComponent:AddFunctionHelper("stopScale", "h:", "Stops the rescale animation of a hologram." )
HoloComponent:AddFunctionHelper("getScale", "h:", "Returns the scale of a hologram." )
HoloComponent:AddFunctionHelper("getScaleUnits", "h:", "Returns the scale of a hologram in units." )

/*==============================================================================================
    Visible and Shading
==============================================================================================*/
HoloComponent:AddPreparedFunction("shading", "h:b", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetShading(@value 2)
end]] )

HoloComponent:AddPreparedFunction("shadow", "h:b", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:DrawShadow(@value 2)
end]] )

HoloComponent:AddPreparedFunction("visible", "h:b", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetVisible(@value 2)
end]] )

HoloComponent:AddInlineFunction("isVisible", "h:", "b", "(IsValid( @value 1 ) and @value 1.INFO.VISIBLE or false )" )

HoloComponent:AddInlineFunction("hasShading", "h:", "b", "(IsValid( @value 1 ) and @value 1.INFO.SHADING or false )" )

HoloComponent:AddFunctionHelper("shading", "h:b", "Enables or disables shading of a hologram." )
HoloComponent:AddFunctionHelper("shadow", "h:b", "Set to true to make a hologram cast a shadow." )
HoloComponent:AddFunctionHelper("visible", "h:b", "Enables or disables visibility of a hologram." )
HoloComponent:AddFunctionHelper("isVisible", "h:", "Returns true of the hologram is visible." )
HoloComponent:AddFunctionHelper("hasShading", "h:", "Returns true if a hologram has shading enabled." )

/*==============================================================================================
    Section: Clipping
==============================================================================================*/


HoloComponent:AddPreparedFunction("pushClip", "h:n,v,v", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:PushClip( @value 2, @value 3, value %4 )
end]] )

/*HoloComponent:AddPreparedFunction("removeClip", "h:n", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player and @value 1:RemoveClip( @value 2 ) then
	%HoloLib.QueueHologram( @value 1 )
end]] ) Not supported yet*/

HoloComponent:AddPreparedFunction("enableClip", "h:n,b", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetClipEnabled( @value 2, @value 3 )
end]] )

HoloComponent:AddPreparedFunction( "setClipOrigin", "h:n,v", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetClipOrigin( @value 2, @value 3 )
end]] )

HoloComponent:AddPreparedFunction( "setClipNormal", "h:n,v", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetClipNormal( @value 2, @value 3 )
end]] )

HoloComponent:AddFunctionHelper( "pushClip", "h:n,v,v", "Clip a hologram, (number clip index) at (vector position) across (vector axis)." )
HoloComponent:AddFunctionHelper( "removeClip", "h:n", "Removes a clip from the hologram." )
HoloComponent:AddFunctionHelper( "enableClip", "h:n,b", "Enables clip (number) on the hologram if (boolean) is true." )
HoloComponent:AddFunctionHelper( "setClipOrigin", "h:n,v", "Set the origin of clip N on hologram." )
HoloComponent:AddFunctionHelper( "setClipNormal", "h:n,v", "Set the normal of clip N on hologram." )

/*==============================================================================================
    Section: Color
==============================================================================================*/
HoloComponent:AddPreparedFunction("setColor", "h:c", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetColor( @value 2 )
	@value 1:SetRenderMode(@value 2.a == 255 and 0 or 4)
end]] )

HoloComponent:AddPreparedFunction("getColor", "h:", "c", [[
if IsValid( @value 1 ) then
	@define val = @value 1:GetColor( )
end]], "(@val or Color(0, 0, 0))" )


HoloComponent:AddFunctionHelper( "setColor", "h:c", "Sets the color of a hologram." )
HoloComponent:AddFunctionHelper( "getColor", "h:", "Returns the color RGBA of hologram." )

/*==============================================================================================
	Section: Material / Skin / Bodygroup
==============================================================================================*/
HoloComponent:AddPreparedFunction( "setMaterial", "h:s", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetMaterial(@value 2)
end]] )

HoloComponent:AddPreparedFunction( "getMaterial", "h:", "s", [[
if IsValid( @value 1 ) then
	@define val = @value 1:GetMaterial( ) or ""
end]], "(@val or \"\")" )

HoloComponent:AddPreparedFunction( "getSkin", "h:", "n", [[
if IsValid( @value 1 ) then
	@define val = @value 1:GetSkin( ) or 0
end]], "(@val or \"\")" )

HoloComponent:AddPreparedFunction( "getSkinCount", "h:", "n", [[
if IsValid( @value 1 ) then
	@define val = @value 1:SkinCount( ) or 0
end]], "(@val or \"\")" )

HoloComponent:AddPreparedFunction( "setSkin", "h:n", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetSkin(@value 2)
end]] )

HoloComponent:AddPreparedFunction( "setBodygroup", "h:n,n", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetBodygroup(@value 2, @value 3)
end]] )


HoloComponent:AddFunctionHelper( "setMaterial", "h:s", "Sets the material of a hologram." )
HoloComponent:AddFunctionHelper( "getMaterial", "h:", "Returns the material of a hologram." )
HoloComponent:AddFunctionHelper( "getSkin", "h:", "Returns the current skin number of hologram." )
HoloComponent:AddFunctionHelper( "getSkinCount", "h:", "Returns the amount of skins a hologram has." )
HoloComponent:AddFunctionHelper( "setSkin", "h:n", "Sets the skin of a hologram." )
HoloComponent:AddFunctionHelper( "setBodygroup", "h:n,n", "Sets the bodygroup of a hologram (number groupID) (number subID)." )

/*==============================================================================================
    Section: Parent
==============================================================================================*/


HoloComponent:AddPreparedFunction( "parent", "h:e", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player and IsValid( @value 2 )then
	@value 1:SetParent(@value 2)
end]] )

HoloComponent:AddPreparedFunction( "parent", "h:h", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player and IsValid( @value 2 )then
	@value 1:SetParent(@value 2)
end]] )

HoloComponent:AddPreparedFunction( "parent", "h:p", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player and IsValid( @value 2 )then
	@value 1:SetParent(@value 2)
end]] )

HoloComponent:AddPreparedFunction( "unParent", "h:", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetParent( nil )
end]] )

HoloComponent:AddPreparedFunction( "getParentHolo", "h:", "h", [[
@define val = $Entity(0)

if IsValid( @value 1 ) then
	local Parent = @value 1:GetParent( )
	
	if Parent and Parent:IsValid( ) and Parent.IsHologram then
		@val = Parent
	end
end]], "@val" )

HoloComponent:AddPreparedFunction( "getParent", "h:", "e", [[
if IsValid( @value 1 ) then
	local Parent = @value 1:GetParent( )
	
	if Parent and Parent:IsValid( ) then
		@define val = Parent
	end
end]], "(@val or $Entity(0))" )

HoloComponent:AddFunctionHelper( "parent", "h:e", "Sets the parent entity of a hologram." )
HoloComponent:AddFunctionHelper( "parent", "h:h", "Sets the parent hologram of a hologram." )
HoloComponent:AddFunctionHelper( "parent", "h:p", "Sets the parent physics object of a hologram." )
HoloComponent:AddFunctionHelper( "unParent", "h:", "Unparents H from its parent." )
HoloComponent:AddFunctionHelper( "getParentHolo", "h:", "Returns the parent hologram of a hologram." )
HoloComponent:AddFunctionHelper( "getParent", "h:", "Returns the parent entity of a hologram." )

/*==============================================================================================
    Section: Bones
==============================================================================================*/
HoloComponent:AddPreparedFunction( "setBonePos", "h:n,v", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetBonePos( @value 2, @value 3 )
end]] )

HoloComponent:AddPreparedFunction( "setBoneAngle", "h:n,a", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetBoneAng( @value 2, @value 3 )
end]] )

HoloComponent:AddPreparedFunction( "setBoneScale", "h:n,v", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetBoneScale( @value 2, @value 3 )
end]] )

HoloComponent:AddPreparedFunction( "jiggleBone", "h:n,b", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetBoneJiggle( @value 2, @value 3 )
end]] )

HoloComponent:AddPreparedFunction( "getBonePos", "h:n", "v", [[
if IsValid( @value 1 ) then
	@define val = @value 1:GetBonePos( @value 2 )
end]], "( @val or Vector( 0, 0, 0 ) )" )

HoloComponent:AddPreparedFunction( "getBoneAng", "h:n", "v", [[
if IsValid( @value 1 ) then
	@define val = @value 1:GetBoneAngle( @value 2 )
end]], "( @val or Angle( 0, 0, 0 ) )" )

HoloComponent:AddPreparedFunction( "getBoneScale", "h:n", "v", [[
if IsValid( @value 1 ) then
	@define val = @value 1:GetBoneScale( @value 2 )
end]], "( @val or Vector( 0, 0, 0 ) )" )

HoloComponent:AddPreparedFunction( "boneCount", "h:", "n", [[
if IsValid( @value 1 ) then
	@define val = @value 1:GetBoneCount( )
end]], "( @val or 0 )" )

HoloComponent:AddFunctionHelper( "setBonePos", "h:n,v", "Sets the position of bone N on the hologram." )
HoloComponent:AddFunctionHelper( "setBoneAngle", "h:n,a", "Sets the angle of bone N on the hologram." )
HoloComponent:AddFunctionHelper( "setBoneScale", "h:n,v", "Sets the scale of bone N on the hologram." )
HoloComponent:AddFunctionHelper( "jiggleBone", "h:n,b", "Makes the bone N on the hologram jiggle about when B is true." )
HoloComponent:AddFunctionHelper( "getBonePos", "h:n", "Gets the position of bone N on hologram." )
HoloComponent:AddFunctionHelper( "getBoneAng", "h:n", "Gets the angle of bone N on hologram." )
HoloComponent:AddFunctionHelper( "getBoneScale", "h:n", "Gets the scale of bone N on hologram." )
HoloComponent:AddFunctionHelper( "boneCount", "h:", "Returns the ammount of bones of a hologram." )

/*==============================================================================================
    Section: Animation
==============================================================================================*/

HoloComponent:AddPreparedFunction("setAnimation", "h:n,n,n", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetHoloAnimation(@value 2, @value 3, value %4)
end]] )

EXPADV.AddFunctionAlias( "setAnimation", "h:n,n" )
EXPADV.AddFunctionAlias( "setAnimation", "h:n" )

HoloComponent:AddPreparedFunction("setAnimation", "h:s,n,n", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetHoloAnimation(@value 1:LookupSequence( @value 2 ), @value 3, value %4)
end]] )

EXPADV.AddFunctionAlias( "setAnimation", "h:s,n" )
EXPADV.AddFunctionAlias( "setAnimation", "h:s" )

HoloComponent:AddInlineFunction("animationLength", "h:", "n", "( IsValid( @value 1 ) and @value 1:SequenceDuration( ) or 0 )" )

HoloComponent:AddPreparedFunction("setPose", "h:s,n", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetPoseParameter(@value 2, @value 3 )
end]], "" )

HoloComponent:AddInlineFunction("getPose", "h:s", "n", "( IsValid( @value 1 ) and @value 1:GetPoseParameter( @value 2 ) or 0 )" )

HoloComponent:AddPreparedFunction("animation", "h:s", "n", [[
if IsValid( @value 1 ) then
	@define val = @value 1:LookupSequence(@value 2)
end]], "(@val or 0)" )

HoloComponent:AddInlineFunction( "getAnimation", "h:", "n", "( IsValid( @value 1 ) and @value 1:GetSequence( ) or 0 )" )

HoloComponent:AddInlineFunction( "getAnimationName", "h:n", "s", "( IsValid( @value 1 ) and @value 1:GetSequenceName( @value 2 ) or \"\" )" )

HoloComponent:AddPreparedFunction( "setAnimationRate", "h:n", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:SetPlaybackRate(@value 2)
end]] )

HoloComponent:AddFunctionHelper( "setAnimation", "h:n,n,n", "Sets the animation of a hologram." )
HoloComponent:AddFunctionHelper( "setAnimation", "h:s,n,n", "Sets the animation of a hologram." )
HoloComponent:AddFunctionHelper( "animationLength", "h:", "Gets the lengh of the animation running on H." )
HoloComponent:AddFunctionHelper( "setPose", "h:s,n", "Sets the pose of a hologram." )
HoloComponent:AddFunctionHelper( "getPose", "h:s", "Gets the pose of a hologram." )
HoloComponent:AddFunctionHelper( "animation", "h:s", "Gets lookup number of an animation." )
HoloComponent:AddFunctionHelper( "getAnimation", "h:", "Returns the current animation of a hologram." )
HoloComponent:AddFunctionHelper( "getAnimationName", "h:n", "Returns the name of the current animation of a hologram." )
HoloComponent:AddFunctionHelper( "setAnimationRate", "h:n", "Sets the animation rate of a hologram." )

/*==============================================================================================
    Section: Remove
==============================================================================================*/
HoloComponent:AddPreparedFunction( "remove", "h:", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	@value 1:Remove( )
end]] )

HoloComponent:AddFunctionHelper( "remove", "h:", "Removes the hologram." )

/*==============================================================================================
    Section: Player Blocking, Does not work on the entity.
==============================================================================================*/
HoloComponent:AddPreparedFunction( "blockPlayer", "h:e", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	if IsValid( @value 2 ) and @value 2:IsPlayer( ) then
		@value 1:BlockPlayer( @value 2 )
	end
end]] )

HoloComponent:AddPreparedFunction( "unblockPlayer", "h:e", "", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	if IsValid( @value 2 ) and @value 2:IsPlayer( ) then
		@value 1:UnblockPlayer( @value 2 )
	end
end]] )

HoloComponent:AddPreparedFunction( "isBlocked", "h:e", "b", [[
if IsValid( @value 1 ) and @value 1.player == Context.player then
	if IsValid( @value 2 ) and @value 2:IsPlayer( ) then
		@define val = @value 1:IsBlocked( @value 2 )
	end
end]], "(@val or false)" )

HoloComponent:AddFunctionHelper( "blockPlayer", "h:e", "Blocks a player from seeing the hologram." )
HoloComponent:AddFunctionHelper( "unblockPlayer", "h:e", "Unblocks a player from seeing the hologram, allow them to see it again." )
HoloComponent:AddFunctionHelper( "isBlocked", "h:e", "Returns true is a player is blocked from seeing the hologram." )