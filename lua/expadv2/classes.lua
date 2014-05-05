/* ---
	@: Expression Advanced 2.
	@: Because the old one was shit.
	@: Team SpaceTown -> Rusketh, Oskar_
   --- */

/* ---
	@: Class system.
   --- */

local ClassTable = { }

local ClassID, ClassName = { }, { }

local BaseClass = { Name = "BASE", ID = "#" }

BaseClass.__index = BaseClass

function GetBaseClass( )
	return BaseClass
end

function EXPADV.NewClass( Name, ID )
	ID = string.lower( ID )
	Name = string.lower( Name )

	local Class = setmetatable( { Name = Name, ID = ID }, BaseClass )
	
	if #ID >= 2 then ID = "_" .. ID end

	table.insert( ClassTable, Class )

	return Class
end

function EXPADV.GetClass( _Name , bNameOnly, bNoError )
	Name = string.lower( _Name )

	local Class = ClassName[ Name ]
	if Class or !bNameOnly then return Class end

	if #Name >= 2 and Name[1] ~= "_" then
		Name = "_" .. Name
	end
	
	Class = ClassID[ Name ]

	if Class then return Class end

	if bNoError then
		error( "ExprAdv: Could not find class " .. _Name )
	end
end


function BaseClass:Extends( ClassName )
	self.Extends = ClassName
end

function BaseClass:Default( Value )
	self.asNative = toLua( Value, false )
end

function EXPADV.BuildClasses( )

	ClassID = { }
	ClassName  = { }

	EXPADV.APICall( "PreBuildClass" )

	for _, Class in pairs( ClassTable ) do

		if Class.Component and !Class.Component.Enabled then
			continue -- We wont load any disabled class.
		elseif Class.Component then
			Class.Component = Class.Component.Name
		end

		ClassID[ Class.ID ] = Class
		ClassName[ Class.Name ] = Class

	end

	for _, Class in pairs( ClassTable ) do
		if Class.Extends then
			local Extends = GetClass( Class.Extends, false, true )

			if !Extends then
				ClassID[ Class.ID ] = nil
				ClassName[ Class.Name ] = nil
				MsgN( string.format( "ExpAdv: Failed to load %q, extends invalid class %q", Class.Name, Class.Extends )
				continue
			end

			Class.Extends = Extends
		end

		if !Class.asNative and Class.Extends then
			Class.asNative = Class.Extends.asNative
		end
	end

	EXPADV.APICall( "PostBuildClass" )
end