/* ---
	@: Expression Advanced 2.
	@: Because the old one was shit.
	@: Team SpaceTown -> Rusketh, Oskar_
   --- */

/* ---
	@: We need a basic component system.
	@: This will be improved further down.
   --- */

local Components = { }

EXPADV.Components = Components

/* ------------------------------------------------------------------------ */

local BaseComponent = { Name = "BASE", Enabled = false }

BaseComponent.__index = BaseComponent

function EXPADV.GetBaseComponent( )
	return BaseClass
end

function EXPADV.NewComponent( Name, bEnabled )
	local New = setmetatable( { Name = Name, Enabled = bEnabled or false }, BaseComponent )
	
	Components[ string.lower( Name ) ] = New

	return New
end

/* ---
	@: Component Settings.
   --- */

function BaseComponent:CreateSetting( Name, Default )
	Name = string.lower( string.format( "%s.%s", self.Name, Name ) )

	EXPADV.Config.Settings[ Name ] = EXPADV.Config.Settings[ Name ] or Default
end

function BaseComponent:ReadSetting( Name, Default )
	Name = string.lower( string.format( "%s.%s", self.Name, Name ) )

	return EXPADV.Config.Settings[ Name ] or Default
end

function BaseComponent:NewClass( ... )
	local Class = NewClass( ... )

	Class.Copmonent = self

	return Class
end