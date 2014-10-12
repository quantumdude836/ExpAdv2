/* --- --------------------------------------------------------------------------------
	@: Wire Component
   --- */

if !WireLib then return end

local Component = EXPADV.AddComponent( "wire" , true )

Component.Author = "Rusketh"
Component.Description = "Adds basic wiremod and wirelink support."

EXPADV.ServerOperators( )

/* --- --------------------------------------------------------------------------------
	@: WireLink Class
   --- */

local WireLink = Component:AddClass( "wirelink", "wl" )

WireLink:MakeServerOnly( )

WireLink:WireInput( "WIRELINK" )

WireLink:DefaultAsLua( Entity(0) )

/* --- --------------------------------------------------------------------------------
	@: Operators
   --- */

Component:AddInlineOperator( "entity", "wl", "e", "@value 1" )

/* --- --------------------------------------------------------------------------------
	@: Acessors
   --- */

WireLink:AddVMOperator( "=", "n,wl", "", function( Context, Trace, MemRef, Value )
	Context.Memory[MemRef] = Value
end )

function Component:OnPostRegisterClass( Name, Class )
	EXPADV.ServerOperators( )

	if Wire_Out_Type then

		WireLink:AddVMOperator( "get", "wl,s," .. Class.Short, Class.Short,
			function( Context, Trace, WireLink, Index )
				local Value

				if IsValid( WireLink ) and WireLink.Outputs then
					local Output = WireLink.Outputs[Index]

					if Output and Output.Type == Class.Wire_In_Type then
						Class.Wire_In_Util( Context, 0 )
						Value = Context.Memory[0]
						Context.Memory[0] = nil
					end
				end

				if Value ~= nil then return Value end

				if Class.CreateNew then return Class.CreateNew( ) end

				Context:Throw( Trace, "WireLink", "Invalid use of wirelink, output is of wrong type or does not exist." )
			end )
	end

	if Wire_Out_Util then

		WireLink:AddVMOperator( "set", "wl,s," .. Class.Short, "",
			function( Context, Trace, WireLink, Index, Value )
				if IsValid( WireLink ) and WireLink.Inputs then
					local Input = WireLink.Inputs[Index]

					if Input and Input.Type == Class.Wire_Out_Type then
						Class.Wire_Out_Util( Context, 0, Value )
						WireLib.TriggerInput( WireLink, Index, Context.Memory[0] )
						Context.Memory[0] = nil
					end
				end
			end )
	end
end

/* --- --------------------------------------------------------------------------------
	@: Functions
   --- */

Component:AddVMFunction( "hasInput", "wl:s", "b", function( Context, Trace, WireLink, Index )
		return IsValid( WireLink ) and WireLink.Inputs and WireLink.Inputs[Index]
	end )

Component:AddVMFunction( "hasOutput", "wl:s", "b", function( Context, Trace, WireLink, Index )
		return IsValid( WireLink ) and WireLink.Outputs and WireLink.Outputs[Index]
	end )

Component:AddVMFunction( "isHiSpeed", "wl:", "b", function( Context, Trace, WireLink )
		return IsValid( WireLink ) and (WireLink.WriteCell or WireLink.ReadCell)
	end )

Component:AddVMFunction("inputType", "wl:s", "s", 
	function( Context, Trace, WireLink )
		if !(IsValid( WireLink ) and WireLink.Inputs and WireLink.Inputs[Index]) then return "" end
		return string.lower(WireLink.Inputs[Index].Type or "")
	end )

Component:AddVMFunction("outputType", "wl:s", "s", 
	function( Context, Trace, WireLink )
		if !(IsValid( WireLink ) and WireLink.Outputs and WireLink.Outputs[Index]) then return "" end
		return string.lower(WireLink.Outputs[Index].Type or "")
	end )

/* --- --------------------------------------------------------------------------------
	@: Read / Write Cell
   --- */

local function WriteCell( Context, Trace, WireLink, Address, Value )
	if !IsValid( WireLink ) or !WireLink.WriteCell then return end
	return WireLink:WriteCell( Address, Value ) or false
end

local function ReadCell( Context, Trace, WireLink, Address, Value )
	if !IsValid( WireLink ) or !WireLink.ReadCell then return 0 end
	return WireLink:ReadCell( Address, Value ) or 0
end

Component:AddVMFunction( "writeCell", "wl:n,n", "b", WriteCell )

Component:AddVMFunction( "readCell", "wl:n", "n", ReadCell )

WireLink:AddVMOperator( "set", "wl,s,n", "b", WriteCell )

WireLink:AddVMOperator( "get", "wl,s", "n", ReadCell )

/* --- --------------------------------------------------------------------------------
	@: Read Array
   --- */

local function ReadArray( Context, Trace, WireLink, Start, End )
	local Array = { __type = "n" }

	if !IsValid( WireLink ) or !WireLink.ReadCell then return Array end

	for Address = Start, Start + End do
		Array[#Array + 1] = WireLink:WriteCell( ReadCell ) or 0
	end

	return Array
end

Component:AddVMFunction( "readArray", "wl:n,n", "a", ReadArray )

/* --- --------------------------------------------------------------------------------
	@: Read / Write String
   --- */

local String_Byte = string.byte
local String_Char = string.char
local Math_Floor  = math.floor

local function WriteStringZero( Context, Trace, WireLink, Address, String )
	if !IsValid( WireLink ) or !WireLink.WriteCell then return 0 end
		
	if !WireLink:WriteCell( Address + #String, 0 ) then return 0 end

	for I = 1, #String do
		if !WireLink:WriteCell( Address + I - 1, String_Byte( String, I ) ) then
			return 0
		end
	end

	return Address + #String + 1
end

local function ReadStringZero( Contex, Trace, WireLink, Address )
	if !IsValid( WireLink ) or !WireLink.ReadCell then return "" end

	local Values = { }

	for I = Address, Address + 16384 do
			local Byte = WireLink:ReadCell( I, Byte )
			
			if !Byte then
				return ""
			elseif Byte < 1 then
				break
			elseif Byte >= 256 then
				Byte = 32
			end
			
			Values[#Table + 1] = String_Char( Math_Floor( Byte ) )
	end
	
	return table.concat( Values )
end

Component:AddVMFunction( "writeStringZero", "wl:n,s", "n", WriteStringZero )
Component:AddVMFunction( "readStringZero", "wl:n", "s", ReadStringZero )

/* --- --------------------------------------------------------------------------------
	@: Helpers
   --- */

Component:AddFunctionHelper( "hasOutput", "_wl:s", "Returns true if the linked component has an output of the specified name." )
Component:AddFunctionHelper( "readCell", "_wl:n", "Reads from high speed memory on the linked component." )
Component:AddFunctionHelper( "writeCell", "_wl:n,n", "Writes to high speed memory on the linked component." )
Component:AddFunctionHelper( "outputType", "_wl:s", "Returns the wiretype of an output on the linked component." )
Component:AddFunctionHelper( "hasInput", "_wl:s", "Returns true if the linked component has an input of the specified name." )
Component:AddFunctionHelper( "isHiSpeed", "_wl:", "Returns true if the wirelinked object supports the HiSpeed interface. See wiremod wiki for more information." )
Component:AddFunctionHelper( "inputType", "_wl:s", "Returns the wiretype of an input on the linked component." )
