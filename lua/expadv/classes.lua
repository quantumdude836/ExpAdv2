/* --- --------------------------------------------------------------------------------
	@: Create base class
   --- */

EXPADV.BaseClassObj = { }

EXPADV.BaseClassObj.__index = EXPADV.BaseClassObj 

local BaseClassObj = EXPADV.BaseClassObj

/* --- --------------------------------------------------------------------------------
	@: Basic Support
   --- */

-- Builds a VM operator, to return the default zero value object of a class.
function BaseClassObj:DefaultAsLua( Default ) -- Object / function( )
	local DefaultObject = Default
	
	if istable( Default ) then
		DefaultObject = function( ) return setmetatable( table.Copy( Default ), getmetatable( Default ) ) end
	elseif !isfunction( Default ) then
		DefaultObject = function( ) return Default end
	end

	self.CreateNew = DefaultObject
end

function BaseClassObj:AddDescription( Desc )
	if SERVER then return end
	self.Desciption = Desc
end

-- Derives this class as well as its operators and methods from another class.
function BaseClassObj:ExtendClass( ExtendClass ) -- String
	self.DeriveFrom = ExtendClass
end

-- Allows more convenient names to be used when defining class type in expadv2 script.
function BaseClassObj:AddAlias( Alias ) -- String
	self.AliasList[Alias] = true
end

-- Use this to define a tostring method for your class, this takes the natives context into account.
function BaseClassObj:StringBuilder( Function ) -- function( table Context, obj Value )
	self.ToString = Function
end

-- Overrides the changed check to use 'Obj.HasChanged == true'
function BaseClassObj:UsesHasChanged( )
	self.HasUpdateCheck = true
end

/* --- --------------------------------------------------------------------------------
	@: Operator Support
   --- */

function BaseClassObj:AddInlineOperator( Name, Input, Return, Inline )
	EXPADV.AddInlineOperator( self.Component, Name, Input, Return, Inline ).AttachedClass = self.Short
end

function BaseClassObj:AddPreparedOperator( Name, Input, Return, Preperation, Inline )
	EXPADV.AddPreparedOperator( self.Component, Name, Input, Return, Preperation, Inline ).AttachedClass = self.Short
end

function BaseClassObj:AddVMOperator( Name, Input, Return, Function )
	EXPADV.AddVMOperator( self.Component, Name, Input, Return, Function ).AttachedClass = self.Short
end

function BaseClassObj:AddGeneratedOperator( Name, Input, Return, Function )
	EXPADV.AddGeneratedOperator( self.Component, Name, Input, Return, Function ).AttachedClass = self.Short
end

/* --- --------------------------------------------------------------------------------
	@: Wire Support
   --- */

if WireLib then

	local function WireOut( Context, MemoryRef ) return Context.Memory[ MemoryRef ] end

	-- Defines the wire outport type name of your class.
	-- Optionally define a method to translate native type in memory to wire type.
	function BaseClassObj:WireOutput( WireType, Function ) -- String, function( table Context, number MemoryRef )
		self.Wire_Out_Type = string.upper( WireType )

		self.Wire_Out_Util = Function or WireOut
	end

	local function WireIn( Context, MemoryRef, InValue ) Context.Memory[ MemoryRef ] = InValue end

	-- Defines the wire inport type name of your class.
	-- Optionally define a method to translate wire type to native type and store in memory.
	function BaseClassObj:WireInput( WireType, Function ) -- function( table Context, number MemoryRef, obj Value )
		self.Wire_In_Type = string.upper( WireType )
		
		self.Wire_In_Util = Function or WireIn
	end

	local DefaultWireLink = function( A ) return A end
	
	function BaseClassObj:WireLinkOutput( Function )
		if !self.Wire_Out_Type then return ErrorNoHalt( string.format( "No wiretype defined for class %s.", self.Name ) ) end

		self.Wire_Link_Out = Function or DefaultWireLink
	end

	function BaseClassObj:WireLinkInput( Function )
		if !self.Wire_In_Type then return ErrorNoHalt( string.format(  "No wiretype defined for class %s.", self.Name ) ) end

		self.Wire_Link_In = Function or DefaultWireLink
	end
end

/* --- --------------------------------------------------------------------------------
	@: Serialization Support
   --- */

require( "von" )

if von then
	-- Not yet supported, please do not use this method.
	function BaseClassObj:Serialize( Function ) -- function( table Context, obj Value )
		self.SerializeAsString = Function
	end

	-- Not yet supported, please do not use this method.
	function BaseClassObj:Deserialize( Function ) -- function( table Context, String seralized )
		self.DeserializeFromString = Function
	end

	-- Not yet supported, please do not use this method.
	function EXPADV.Serialize( Context, Short, Obj ) -- Table, String, Obj
		-- Assigned: Vercas
		-- Todo: return serialized

		--	This is an initial attempt to check behaviour.
		return von.serialize({Short, Obj})
	end

	-- Not yet supported, please do not use this method.
	function EXPADV.Deserialize( Context, Seralized ) -- Table, String
		-- Assigned: Vercas
		-- Todo: return Short, Obj

		local res = von.deserialize(serialized)

		return res[2], res[1]
	end

end

/* --- --------------------------------------------------------------------------------
	@: Server -> Client Support
   --- */

EXPADV.BaseClassObj.LoadOnServer = true

EXPADV.BaseClassObj.LoadOnClient = true

-- Defines the class as server side only.
function BaseClassObj:MakeServerOnly( )
	self.LoadOnClient = false
end

-- Defines the class as cleint side only.
function BaseClassObj:MakeClientOnly( )
	self.LoadOnServer = false
end

/* --- --------------------------------------------------------------------------------
	@: Class framework
   --- */

local Temp_Classes = { }

-- Define and create a new class, this returns the classes module.
-- This function is for internal use only, use BaseComponent:AddClass( ... )
function EXPADV.AddClass( Component, Name, Short ) -- table, string, string
	if #Short > 1 then Short = "_" .. Short end

	local Class = setmetatable( { Component = Component, Name = Name, Short = Short, DeriveFrom = "generic", AliasList = { } }, EXPADV.BaseClassObj )

	Temp_Classes[ #Temp_Classes + 1 ] = Class

	return Class
end

/* --- --------------------------------------------------------------------------------
	@: Define generic Class
   --- */

local Class_Generic = setmetatable( { Name = "generic", Short = "g" }, EXPADV.BaseClassObj )
	-- We do this manually, so it doesnt get treated like the rest!

/* --- --------------------------------------------------------------------------------
	@: Define Null Class
   --- */

   -- TODO

/* --- --------------------------------------------------------------------------------
	@: GetClass
   --- */

-- Returns a classes module, using either name or id as look up.
function EXPADV.GetClass( Name, bNoShort ) -- String
	if !Name then return end

	if EXPADV.Classes[ Name ] then return EXPADV.Classes[ Name ] end

	if EXPADV.ClassAliases[ Name ] then return EXPADV.ClassAliases[ Name ] end

	if bNoShort then return end

	if #Name > 1 and Name[1] ~= "_" then Name = "_" .. Name end

	if EXPADV.ClassShorts[ Name ] then return EXPADV.ClassShorts[ Name ] end
end

/* --- --------------------------------------------------------------------------------
	@: Type Name!
   --- */

function EXPADV.TypeName( Name, bNoVoid )
	if !Name or Name == "" then return "void" end

	if Name == "..." then return "..." end
	
	if EXPADV.Classes[ Name ] then return EXPADV.Classes[ Name ].Name end

	if EXPADV.ClassAliases[ Name ] then return EXPADV.ClassAliases[ Name ].Name end

	if #Name > 1 and Name[1] ~= "_" then Name = "_" .. Name end

	if EXPADV.ClassShorts[ Name ] then return EXPADV.ClassShorts[ Name ].Name end

	if !bNoVoid then return "void" end
end

/* --- --------------------------------------------------------------------------------
	@: Print Lookup!
   --- */

local ToStringLookUp = { }

-- Used during execution to translate class objects to strings.
function EXPADV.ToString( Short, Obj ) -- String, Obj
	return ToStringLookUp[Short]( Obj )
end

/* --- --------------------------------------------------------------------------------
	@: Load classes!
   --- */

-- Internal function, not for public use.
function EXPADV.LoadClasses( )
 	EXPADV.ClassAliases = { }

 	EXPADV.Classes = { generic = Class_Generic }

 	EXPADV.ClassShorts = { g = Class_Generic }

 	EXPADV.CallHook( "PreLoadClasses" )

 	local Index = 1

 	while Index <= #Temp_Classes do
 		local Class = Temp_Classes[Index]

 		Index = Index + 1

 		if Class.Component and !Class.Component.Enabled then
 			EXPADV.Msg( "Skipping class " .. Class.Name .. " (component disabled)." )
 			continue
 		end

 		EXPADV.Classes[ Class.Name ] = Class

 		EXPADV.ClassShorts[ Class.Short ] = Class

 		EXPADV.CallHook( "PreRegisterClass", Class.Short, Class )
 	end

 	----------------------------------------------------------

 	for _, Class in pairs( EXPADV.Classes ) do
 		if Class == Class_Generic then continue end

 		local DeriveClass = EXPADV.GetClass( Class.DeriveFrom )

 		if !DeriveClass then
 			EXPADV.Classes[ Class.Name ] = nil

 			EXPADV.ClassShorts[ Class.Short ] = nil

 			EXPADV.Msg( "Skipping class " .. Class.Name .. " (extends invalid class '" .. (Class.DeriveFrom or "void") .. "')." )
 			
 			continue
 		end

 		Class.DerivedClass = DeriveClass

 		Class.DeriveGeneric = DeriveClass == Class_Generic

 		EXPADV.ClassAliases[ Class.Name ] = Class

 		for Alias, _ in pairs( Class.AliasList ) do
 			EXPADV.ClassAliases[ Alias ] = Class
 		end

 		EXPADV.Msg( "Registered Class: " .. Class.Name .. " - " .. Class.Short )
 	end -- ^ Derive classes!

 	----------------------------------------------------------

 	for _, Class in pairs( EXPADV.Classes ) do

 		local DeriveClass = Class.DerivedClass

 		if DeriveClass and !Class.CreateNew then
	 		Class.CreateNew = DeriveClass.CreateNew
	 	end

		if Class.CreateNew then
 			local Op = EXPADV.AddVMOperator( Class.Component, "default", Class.Short , Class.Short, Class.CreateNew )
 			Op.LoadOnClient = Class.LoadOnClient
 			Op.LoadOnServer = Class.LoadOnServer
 		end

 		if DeriveClass and !Class.DeriveGeneric and !Class.ToString then
	 		Class.ToString = DeriveClass.ToString
	 	end

	 	if !Class.ToString then
	 		Class.ToString = function( Obj )
 				return string.format("<%s: %s>", Class.Name, tostring( Obj ) )
 			end
 		end

 		ToStringLookUp[Class.Short] = Class.ToString
 		
 		if Class.DeriveGeneric then continue end
 		if Class == Class_Generic then continue end
 		
 		Class.LoadOnServer = DeriveClass.LoadOnServer

		Class.LoadOnClient = DeriveClass.LoadOnClient

 		if WireLib then

 			if !Class.Wire_Out_Type then
 				Class.Wire_Out_Type = DeriveClass.Wire_Out_Type

 				Class.Wire_Out_Util = DeriveClass.Wire_Out_Util
 			end

 			if !Class.Wire_In_Type then
 				Class.Wire_In_Type = DeriveClass.Wire_In_Type

 				Class.Wire_In_Util = DeriveClass.Wire_In_Util
 			end

 		end

		if !Class.SerializeAsString then
			Class.SerializeAsString = DeriveClass.SerializeAsString
		end

		if !Class.DeserializeFromString then
			Class.DeserializeFromString = DeriveClass.DeserializeFromString
		end

 	end

 	for Name, Class in pairs( EXPADV.Classes ) do
 		EXPADV.CallHook( "PostRegisterClass", Name, Class )
 	end
end
