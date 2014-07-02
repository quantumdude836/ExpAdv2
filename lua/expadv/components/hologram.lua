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

function Component:OnShutDown( Context )
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

function Component:APIReload( )
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
if !$IsValid( @value 1 ) or !@value 1.IsHologram then
	Context:Throw( %trace, "hologram", "casted none hologram from entity.")
end ]], "@value 1" )

/*==============================================================================================
    Section: Set Model
==============================================================================================*/

local function SetModel( Context, Trace, Entity, Model )
	local ValidModel = ModelEmu[ Model or "sphere" ]

	if ValidModel then
		if Entity.IsHologram and Entity.Player == Context.player then
			Entity:SetModel( "models/holograms/" .. ValidModel .. ".mdl" )
		end

	elseif !HoloComponent:ReadSetting( "model_any", true ) or !util.IsValidModel( Model ) then
		Context:Throw( Trace, "hologram", "Invalid model set " .. Model )
	elseif Entity.IsHologram and Entity.Player == Context.player then
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

HoloComponent:AddVMFunction( "setID", SetID )
HoloComponent:AddInlineFunction( "getID", "h:", "n", "(@value 1.ID or -1)" )
HoloComponent:AddInlineFunction( "hologram", "n", "h", "(Context.Data.Holograms[ @value 1] or $Entity(0))" )

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

	Entity.Player = Context.player

	Entity:Spawn( )

	Entity:Activate( )
	
	if CPPI then Entity:CPPISetOwner( Context.player ) end

	HolosByEntity[ Context.Entity ] = HolosByEntity[ Context.Entity ] or { }

	HolosByEntity[ Context.Entity ][ Entity ] = Entity

	HolosByPlayer[ UID ] = HolosByPlayer[ UID ] or { }

	HolosByPlayer[ UID ][ Entity ] = Entity

	DeltaPerPlayer[ UID ] = ( DeltaPerPlayer[ UID ] or 0 ) + 1

	Context.Data.Holograms = Context.Data.Holograms or { }

	local ID = #Context.Data.Holograms + 1
	Context.Data.Holograms[ ID ] = ID

	--if !Model then return Entity end
	SetModel( Context, Trace, Entity, Model or "sphere" )

	if !Position then
		Entity:SetPos( Context.Entity:GetPos( ) )
	else
		Entity:SetPos( Position )
	end

	if !Angle then
		Entity:SetAngles( Context.Entity:GetAngles( ) )
	else
		Entity:SetAngles( Angle )
	end

	return Entity
end

HoloComponent:AddVMFunction( "hologram", "", "h", NewHolo )

HoloComponent:AddVMFunction( "hologram", "s", "h", NewHolo )

HoloComponent:AddVMFunction( "hologram", "s,v", "h", NewHolo )

HoloComponent:AddVMFunction( "hologram", "s,v,a", "h", NewHolo )

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

/*==============================================================================================
    Position
==============================================================================================*/
HoloComponent:AddPreparedFunction("setPos", "h:v", "",[[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetPos( @value 2 )
end]] )

HoloComponent:AddPreparedFunction("moveTo", "h:v,n", "",[[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:MoveTo( @value 2, @value 3 )
end]] )

HoloComponent:AddPreparedFunction("stopMove", "h:", "",[[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:StopMove( )
end]] )

/*==============================================================================================
    Angles
==============================================================================================*/
HoloComponent:AddPreparedFunction("setAng", "h:a", "",[[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetAngles( @value 2 )
end]] )

HoloComponent:AddPreparedFunction("rotateTo", "h:a,n", "",[[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:RotateTo( @value 2, @value 3 )
end]] )

HoloComponent:AddPreparedFunction("stopRotate", "h:", "",[[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:StopRotate( )
end]] )

/*==============================================================================================
    Scale
==============================================================================================*/
HoloComponent:AddPreparedFunction("setScale", "h:v", "",[[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetScale( @value 2 )
end]] )

HoloComponent:AddPreparedFunction("setScaleUnits", "h:v", "",[[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetScaleUnits( @value 2 )
end]] )

HoloComponent:AddPreparedFunction("scaleTo", "h:v,n", "",[[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:ScaleTo( @value 2, @value 3 )
end]] )

HoloComponent:AddPreparedFunction("scaleToUnits", "h:v,n", "",[[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:ScaleToUnits( @value 2, @value 3 )
end]] )

HoloComponent:AddPreparedFunction("stopScale", "h:", "",[[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:StopScale( )
end]] )

HoloComponent:AddPreparedFunction("getScale", "h:", "v",[[
if $IsValid( @value 1 ) and @value 1.GetScale then
	%util = @value 1:GetScale( )
end]], "Vector3( %util or Vector( 0, 0, 0 ) )" )

HoloComponent:AddPreparedFunction("getScaleUnits", "h:", "v",[[
@define pos
if $IsValid( @value 1 ) and @value 1.GetScale then
	@pos = @value 1:GetScaleUnits( )
end]], "( @pos or Vector( 0, 0, 0 ) )" )


/*==============================================================================================
    Visible and Shading
==============================================================================================*/
HoloComponent:AddPreparedFunction("shading", "h:b", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetShading(@value 2)
end]] )

HoloComponent:AddPreparedFunction("shadow", "h:b", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:DrawShadow(@value 2)
end]] )

HoloComponent:AddPreparedFunction("visible", "h:b", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetVisible(@value 2)
end]] )

HoloComponent:AddInlineFunction("isVisible", "h:", "b", "($IsValid( @value 1 ) and @value 1.INFO.VISIBLE or false )" )

HoloComponent:AddInlineFunction("hasShading", "h:", "b", "($IsValid( @value 1 ) and @value 1.INFO.SHADING or false )" )

/*==============================================================================================
    Section: Clipping
==============================================================================================*/
Component:SetPerf( LEMON_PERF_NORMAL )

HoloComponent:AddPreparedFunction("pushClip", "h:n,v,v", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:PushClip( @value 2, @value 3, value %4 )
end]] )

/*HoloComponent:AddPreparedFunction("removeClip", "h:n", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player and @value 1:RemoveClip( @value 2 ) then
	%HoloLib.QueueHologram( @value 1 )
end]] ) Not supported yet*/

HoloComponent:AddPreparedFunction("enableClip", "h:n,b", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetClipEnabled( @value 2, @value 3 )
end]] )

HoloComponent:AddPreparedFunction( "setClipOrigin", "h:n,v", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetClipOrigin( @value 2, @value 3 )
end]] )

HoloComponent:AddPreparedFunction( "setClipNormal", "h:n,v", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetClipNormal( @value 2, @value 3 )
end]] )

/*==============================================================================================
    Section: Color
==============================================================================================*/
HoloComponent:AddPreparedFunction("setColor", "h:c", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetColor( @value 2 )
	@value 1:SetRenderMode(@value 2.a == 255 and 0 or 4)
end]] )

HoloComponent:AddPreparedFunction("getColor", "h:", "c", [[
@define val
if $IsValid( @value 1 ) then
	@val = @value 1:GetColor( )
end]], "(@val or Color(0, 0, 0))" )

/*==============================================================================================
	Section: Material / Skin / Bodygroup
==============================================================================================*/
HoloComponent:AddPreparedFunction "setMaterial", "h:s", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetMaterial(@value 2)
end]] )

error( "CBA to finish moving over the hologram component", 0 )

Component:AddFunction( "getMaterial", "h:", "s", [[
local %Val = ""
if $IsValid( @value 1 ) then
	%Val = @value 1:GetMaterial( ) or ""
end]], "%Val" )

Component:AddFunction( "getSkin", "h:", "n", [[
local %Val = ""
if $IsValid( @value 1 ) then
	%Val = @value 1:GetSkin( ) or 0
end]], "%Val" )

Component:AddFunction( "getSkinCount", "h:", "n", [[
local %Val = ""
if $IsValid( @value 1 ) then
	%Val = @value 1:SkinCount( ) or 0
end]], "%Val" )

Component:AddFunction( "setSkin", "h:n", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetSkin(@value 2)
end]], "" )

Component:AddFunction( "setBodygroup", "h:n,n", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetBodygroup(@value 2, @value 3)
end]], "" )

/*==============================================================================================
    Section: Parent
==============================================================================================*/
Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction("parent", "h:e", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player and $IsValid( @value 2 )then
	@value 1:SetParent(@value 2)
end]], "" )

Component:AddFunction("parent", "h:h", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player and $IsValid( @value 2 )then
	@value 1:SetParent(@value 2)
end]], "" )

Component:AddFunction("parent", "h:p", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player and $IsValid( @value 2 )then
	@value 1:SetParent(@value 2)
end]], "" )

Component:AddFunction("unParent", "h:", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetParent( nil )
end]], "" )

Component:AddFunction("getParentHolo", "h:", "h", [[
local %Val = %NULL_ENTITY

if $IsValid( @value 1 ) then
	local %Parent = @value 1:GetParent( )
	
	if %Parent and %Parent:IsValid( ) and %Parent.IsHologram then
		%Val = %Parent
	end
end]], "%Val" )

Component:AddFunction("getParent", "h:", "e", [[
local %Val = %NULL_ENTITY
if $IsValid( @value 1 ) then
	local %Parent = @value 1:GetParent( )
	
	if %Parent and %Parent:IsValid( ) then
		%Val = %Parent
	end
end]], "%Val" )

/*==============================================================================================
    Section: Bones
==============================================================================================*/
Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddFunction("setBonePos", "h:n,v", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetBonePos( @value 2, @value 3 )
end]], "" )

Component:AddFunction("setBoneAngle", "h:n,a", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetBoneAng( @value 2, @value 3 )
end]], "" )

Component:AddFunction("setBoneScale", "h:n,v", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetBoneScale( @value 2, @value 3 )
end]], "" )

Component:AddFunction("jiggleBone", "h:n,b", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetBoneJiggle( @value 2, @value 3 )
end]], "" )

Component:AddFunction("getBonePos", "h:n", "v", [[
if $IsValid( @value 1 ) then
	%util = @value 1:GetBonePos( @value 2 )
end]], "Vector3( %util or Vector( 0, 0, 0 ) )" )

Component:AddFunction("getBoneAng", "h:n", "v", [[
if $IsValid( @value 1 ) then
	%util = @value 1:GetBoneAngle( @value 2 )
end]], "( %util or Angle( 0, 0, 0 ) )" )

Component:AddFunction("getBoneScale", "h:n", "v", [[
if $IsValid( @value 1 ) then
	%util = @value 1:GetBoneScale( @value 2 )
end]], "Vector3( %util or Vector( 0, 0, 0 ) )" )

Component:AddFunction("boneCount", "h:", "n", [[
if $IsValid( @value 1 ) then
	%util = @value 1:GetBoneCount( )
end]], "( %util or 0 )" )

/*==============================================================================================
    Section: Animation
==============================================================================================*/
Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction("setAnimation", "h:n[,n,n]", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetHoloAnimation(@value 2, @value 3, value %4)
end]], "" ) 

Component:AddFunction("setAnimation", "h:s[,n,n]", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetHoloAnimation(@value 1:LookupSequence( @value 2 ), @value 3, value %4)
end]], "" )

Component:AddFunction("animationLength", "h:", "n", "( $IsValid( @value 1 ) and @value 1:SequenceDuration( ) or 0 )" )

Component:AddFunction("setPose", "h:s,n", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetPoseParameter(@value 2, @value 3 )
end]], "" )

Component:AddFunction("getPose", "h:s", "n", "( $IsValid( @value 1 ) and @value 1:GetPoseParameter( @value 2 ) or 0 )" )

Component:AddFunction("animation", "h:s", "n", [[
if $IsValid( @value 1 ) then
	%util = @value 1:LookupSequence(@value 2)
end]], "(%util or 0)" )

Component:AddFunction( "getAnimation", "h:", "n", "( $IsValid( @value 1 ) and @value 1:GetSequence( ) or 0 )" )

Component:AddFunction( "getAnimationName", "h:n", "s", "( $IsValid( @value 1 ) and @value 1:GetSequenceName( @value 2 ) or \"\" )" )

Component:AddFunction( "setAnimationRate", "h:n", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:SetPlaybackRate(@value 2)
end]], "" )

/*==============================================================================================
    Section: Remove
==============================================================================================*/
Component:AddFunction("remove", "h:", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	@value 1:Remove( )
end]], "" )

/*==============================================================================================
    Section: Player Blocking, Does not work on the entity.
==============================================================================================*/
Component:AddFunction("blockPlayer", "h:e", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	if IsValid( @value 2 ) and @value 2:IsPlayer( ) then
		@value 1:BlockPlayer( @value 2 )
	end
end]], "" )

Component:AddFunction("unblockPlayer", "h:e", "", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	if IsValid( @value 2 ) and @value 2:IsPlayer( ) then
		@value 1:UnblockPlayer( @value 2 )
	end
end]], "" )

Component:AddFunction("isBlocked", "h:e", "b", [[
if $IsValid( @value 1 ) and @value 1.Player == Context.player then
	if IsValid( @value 2 ) and @value 2:IsPlayer( ) then
		%util = @value 1:IsBlocked( @value 2 )
	end
end]], "(%util or false)" )