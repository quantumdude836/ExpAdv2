/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Create base class
   --- */

EXPADV.BaseClassObj = { }

EXPADV.BaseClassObj.__index = EXPADV.BaseClassObj 

local BaseClassObj = EXPADV.BaseClassObj

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Basic Support
   --- */

function BaseClassObj:DefaultAsLua( Default ) -- Object / function( Trace, Context )
	if istable( Default ) then
		Default = function( ) return table.Copy( Default ) end
	elseif !isfunction( Default ) then
		Default = function( ) return Default end
	end

	self.CreateNew = Default
end

EXPADV.BaseClassObj.DeriveFrom = "generic"

function BaseClassObj:ExtendClass( ExtendClass )
	self.DeriveFrom = ExtendClass
end

local Temp_Aliases = { }

function BaseClassObj:AddAlias( Alias )
	Temp_Aliases[ Alias ] = self
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Wire Support
   --- */

if WireLib then

	local function WireOut( Context, MemoryRef ) return Context.Memory[ MemoryRef ] end

	function BaseClassObj:WireOutput( WireType, Function ) -- function( Context, MemoryRef ) return Converted end
		self.Wire_Out_Type = string.upper( WireType )

		self.Wire_Out_Util = Function or WireOut
	end

	local function WireIn( Context, MemoryRef, InValue ) Context.Memory[ MemoryRef ] = InValue end

	function BaseClassObj:WireInput( WireType, Function ) -- function( Context, MemoryRef,  InValue ) end
		self.Wire_In_Type = string.upper( WireType )
		
		self.Wire_In_Util = Function or WireIn
	end

end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Seralization Support
   --- */

function BaseClassObj:Serialize( Function ) -- function( Value ) return String end
	self.SerializeAsString = Function
end

function BaseClassObj:Deserialize( Function ) -- function( String ) return Value end
	self.DeserializeFromString = Function
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Server -> Client Support
   --- */

EXPADV.BaseClassObj.LoadOnServer = true

EXPADV.BaseClassObj.LoadOnClient = true

function BaseClassObj:MakeServerOnly( )
	self.LoadOnClient = false
end

function BaseClassObj:MakeClientOnly( )
	self.LoadOnServer = false
end

function BaseClassObj:NetSend( Function ) -- function( Value ) return String end
	self.SendToClient = Function
end

function BaseClassObj:NetReceive( Function ) -- function( Value ) return String end
	self.ReceiveFromServer = Function
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Class framework
   --- */

local Temp_Classes = { }

function EXPADV.AddClass( Component, Name, Short )
	if #Short > 1 then Short = "x" .. Short end

	local Class = setmetatable( { Component = Component, Name = Name, Short = Short }, EXPADV.BaseClassObj )

	Temp_Classes[ #Temp_Classes + 1 ] = Class

	return Class
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Define generic Class
   --- */

local Class_Generic = EXPADV.AddClass( nil, "generic", "g" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Define Null Class
   --- */

   -- TODO

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Define boolean class
   --- */

local Class_Boolean = EXPADV.AddClass( nil, "boolean", "g" )
	  
	  Class_Boolean:AddAlias( "bool" )

	  Class_Boolean:DefaultAsLua( false )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Register variant class!
   --- */

local Class_Variant = EXPADV.AddClass( nil, "variant", "vr" )
		
	  Class_Variant:DefaultAsLua( { false, "b" } )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: GetClass
   --- */

function EXPADV.GetClass( Name )
	if !Name then return end

	if EXPADV.Classes[ Name ] then return EXPADV.Classes[ Name ] end

	if EXPADV.ClassAliases[ Name ] then return EXPADV.ClassAliases[ Name ] end

	if #Name > 1 then Name = "x" .. Name end

	if EXPADV.ClassShorts[ Name ] then return EXPADV.ClassShorts[ Name ] end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Load classes!
   --- */

function EXPADV.LoadClasses( )
 	EXPADV.Classes = { }

 	EXPADV.ClassShorts = { }

 	EXPADV.ClassAliases = { }

 	-- EXPADV.RunHook( "LoadClasses" )

 	for I = 1, #Temp_Classes do
 		local Class = Temp_Classes[I]

 		if Class.Component and !Class.Component.Enabled then continue end

 		EXPADV.Classes[ Class.Name ] = Class

 		EXPADV.ClassShorts[ Class.Short ] = Class
 	end

 	for _, Class in pairs( EXPADV.Classes ) do

 		local DeriveClass = EXPADV.GetClass( Class.DeriveFrom )

 		Class.DerivedClass = DeriveClass

 		if !DeriveClass then
 			EXPADV.Classes[ Class.Name ] = nil

 			EXPADV.ClassShorts[ Class.Short ] = nil

 			continue
 		end

 		EXPADV.ClassAliases[ Class.Name ] = Class

 		if Class.CreateNew then
 			EXPADV.AddVMOperator( Class.Component, "default", Class.Short , Class.Short, Class.CreateNew )
 		end -- ^ Add default operator, can now do this :D

 		MsgN( "Registered Class: " .. Class.Name )

 		if DeriveClass == Class_Generic then continue end

 		Class.LoadOnServer = DeriveClass.LoadOnServer

		Class.LoadOnClient = DeriveClass.LoadOnClient

 		if !Class.CreateNew then
 			Class.CreateNew = DeriveClass.CreateNew
 		end
 			
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

		-- TODO: Extend net usage?

 	end

 	for _, Class in pairs( EXPADV.Classes ) do
 		-- EXPADV.RunHook( "RegisterClass", Class )
 	end

 	for Alias, Class in pairs( EXPADV.ClassAliases ) do
 		
 		if Class.Component and !Class.Component.Enabled then
 			EXPADV.ClassAliases[Alias] = nil
 		end

 	end

 end