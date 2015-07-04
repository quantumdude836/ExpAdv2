/* --- --------------------------------------------------------------------------------
	@: Default Exceptions
   --- */

EXPADV.AddException( nil, "invoke" )
EXPADV.AddException( nil, "cast" )
EXPADV.AddException( nil, "net" )

/* --- --------------------------------------------------------------------------------
	@: Default Classes
   --- */

local Class_Boolean   = EXPADV.AddClass( nil, "boolean", "b" )
local Class_Function  = EXPADV.AddClass( nil, "function", "f" )
local Class_Delgate   = EXPADV.AddClass( nil, "delegate", "d" )
local Class_Exception = EXPADV.AddClass( nil, "exception", "ex" )
local Class_Class 	  = EXPADV.AddClass( nil, "class", "cls" ) -- Nope: Not what you think it is.

Class_Boolean:AddAlias( "bool" )
Class_Boolean:CanSerialize( true )
Class_Boolean:DefaultAsLua( false )
Class_Boolean:NetWrite(net.WriteBool)
Class_Boolean:NetRead(net.ReadBool)
Class_Function:DefaultAsLua( "function( ) end" )

if WireLib then
	Class_Boolean:WireIO("NORMAL",
        function(Value, Context) -- To Wire
            return Value and 1 or 0
        end, function(Value, context) -- From Wire
            return !(Value == 0)
        end)
end

/* --- --------------------------------------------------------------------------------
	@: Default Operators
   --- */

EXPADV.SharedOperators( )

Class_Boolean:AddVMOperator( "=", "n,b", "", function( Context, Trace, MemRef, Value )
	local Prev = Context.Memory[MemRef]
	Context.Memory[MemRef] = Value
	Context.Trigger[MemRef] = Context.Trigger[MemRef] or ( Prev ~= Value )
end )

Class_Function:AddPreparedOperator( "=", "n,f", "", "Context.Memory[@value 1] = @value 2" )
Class_Delgate:AddPreparedOperator( "=", "n,d", "", "Context.Memory[@value 1] = @value 2" )
Class_Exception:AddPreparedOperator( "=", "n,ex", "", "Context.Memory[@value 1] = @value 2" )

EXPADV.AddInlineOperator( nil, "==", "b,b", "b", "(@value 1 == @value 2)" )
EXPADV.AddInlineOperator( nil, "!=", "b,b", "b", "(@value 1 != @value 2)" )

EXPADV.AddInlineOperator( nil, "is", "b", "b", "@value 1" )
EXPADV.AddInlineOperator( nil, "not", "b", "b", "!@value 1" )

EXPADV.AddInlineOperator( nil, "||", "b,b", "b", "(@value 1 or @value 2)" )

EXPADV.AddInlineOperator( nil, "&&", "b,b", "b", "(@value 1 and @value 2)" )

EXPADV.AddInlineOperator( nil, "string", "b", "s", "(@value 1 and \"true\" or \"false\")" )

EXPADV.AddInlineOperator( nil, "number", "b", "n", "(@value 1 and 1 or 0)" )

EXPADV.AddInlineOperator( nil, "delegate", "f", "d", "@value 1" )

EXPADV.AddInlineOperator( nil, "function", "d", "f", "@value 1" )

EXPADV.AddVMOperator( nil, "call", "f,s,...", "_vr",
	function(Context, Trace, Function, rExpect, ...)
		if !Function then Context:Throw( Trace, "invoke", "Attempt to call void" ) end
		
		local rValue, rType = Function(Context, ...)
		
		if (!rExpect or rExpect == "void") and (!rType or rType == "void") then
			return -- VOID!
		elseif rExpect == "void" then
			Context:Throw( Trace, "invoke", "Invalid return value, void expected got " .. EXPADV.TypeName(rType))
		elseif rType == "void" then
			Context:Throw( Trace, "invoke", "Invalid return value, " .. EXPADV.TypeName(rExpect) .. " expected got void")
		elseif rExpect ~= rType then
			Context:Throw( Trace, "invoke", string.format("Invalid return value, %s expected got %s", EXPADV.TypeName(rExpect), EXPADV.TypeName(rType)))
		end

		return rValue
	end)

/* --- -------------------------------------------------------------------------------
	@: Invoke
   --- */

local function buildLua(...)
	local Inputs = { ... }
	local Preperation = { }
	local Outputs = { }
	
	for I = 1, #Inputs, 1 do
		local Input = Inputs[I]

		if Input.FLAG == EXPADV_PREPARE or Input.FLAG == EXPADV_INLINEPREPARE then
			Preperation[#Preperation + 1] = Input.Prepare
		end

		if Input.FLAG == EXPADV_INLINE or Input.FLAG == EXPADV_INLINEPREPARE then
			if Input.Return == "_vr" then
				Outputs[#Outputs + 1] = Input.Inline
			else
				Outputs[#Outputs + 1] = string.format("{%s,%q}", Input.Inline, Input.Return)
			end
		end
	end

	return table.concat(Preperation, "\n"), Outputs
end

EXPADV.AddGeneratedFunction( nil, "invoke", "cls,d,...", "",
	function(Operator, Compiler, Trace, Class, Delegate, ...)
		local Prepare, Inputs = buildLua(Class, Delegate, ...)

		local dVar = Compiler:DefineVariable( )
		local Inline, tVar = Compiler:DefineVariable( ), Compiler:DefineVariable( )
		
		table.remove(Inputs, 1)
		table.remove(Inputs, 1)

		local Arguments = ""
		if #Inputs > 0 then Arguments = "," .. table.concat(Inputs, ",") end

		Prepare = Prepare .. "\n" .. string.format([[%s = %s]], dVar, Delegate.Inline)
		Prepare = Prepare .. "\n" .. string.format([[%s, %s = %s(Context %s)]], Inline, tVar, dVar, Arguments)
		Prepare = Prepare .. "\n" .. string.format([[if !%s then Context:Throw(%s, "invoke", "Delegate expected to return %s got void.") end]], Inline, Compiler:CompileTrace(Trace), Compiler:NiceClass(Class.PointClass))
		Prepare = Prepare .. "\n" .. string.format([[if %s ~= %q then Context:Throw(%s, "invoke", "Delegate expected to return %s got " .. EXPADV.TypeName(%s) .. ".") end]], tVar, Class.PointClass, Compiler:CompileTrace(Trace), Compiler:NiceClass(Class.PointClass), tVar)

		return {Trace = Trace, Inline = Inline, Prepare = Prepare, Return = Class.PointClass, FLAG = EXPADV_INLINEPREPARE}
	end)
EXPADV.AddFunctionAlias("invoke", "cls,d")

EXPADV.AddGeneratedFunction( nil, "invoke", "d,...", "",
	function(Operator, Compiler, Trace, Delegate, ...)
		local Prepare, Inputs = buildLua(Delegate, ...)
		
		local dVar = Compiler:DefineVariable( )
		local Inline, tVar = Compiler:DefineVariable( ), Compiler:DefineVariable( )
		
		table.remove(Inputs, 1)
		
		local Arguments = ""
		if #Inputs > 0 then Arguments = "," .. table.concat(Inputs, ",") end
		
		Prepare = Prepare .. "\n" .. string.format([[%s = %s]], dVar, Delegate.Inline)
		Prepare = Prepare .. "\n" .. string.format([[%s, %s = %s(Context %s)]], Inline, tVar, dVar, Arguments)
		Prepare = Prepare .. "\n" .. string.format([[if %s then Context:Throw(%s, "invoke", "Delegate expected to return void got " .. EXPADV.TypeName(%s) .. ".") end]], Inline, Compiler:CompileTrace(Trace), tVar)
		
		return {Trace = Trace, Inline = Inline, Prepare = Prepare, Return = "", FLAG = EXPADV_INLINEPREPARE}
	end)
EXPADV.AddFunctionAlias("invoke", "d")

/*EXPADV.AddFunctionHelper("invoke", "cls,d,...", "Executes the given delegate passing given params and returning the value (return type class, the function, params)." )
	Not working :/
*/

/* --- --------------------------------------------------------------------------------
	@: Client and Server
   --- */

EXPADV.AddInlineFunction( nil,  "server", "", "b", "$SERVER" )
EXPADV.AddFunctionHelper( nil, "server", "", "Returns true if running serverside." )

EXPADV.AddInlineFunction( nil, "client", "", "b", "$CLIENT" )
EXPADV.AddFunctionHelper( nil, "client", "", "Returns true if running clientside." )


/* --- -------------------------------------------------------------------------------
	@: Loops
   --- */

EXPADV.AddPreparedOperator( nil, "while", "b,?", "", [[
	while( @value 1 ) do
		@prepare 2
	end
]] )

/* --- --------------------------------------------------------------------------------
	@: Performance
   --- */

local Component = EXPADV.AddComponent( "performance" , true )

Component.Author = "Rusketh"
Component.Description = "Allows for monitoring performance and usage."

EXPADV.SharedOperators()

Component:AddInlineFunction( "cpuTime", "", "n", "(($SysTime( ) - Context.Status.BenchMark) * 1000000)" )
Component:AddFunctionHelper( "cpuTime", "", "Returns the amount of cpu time used so far in the current execution in microseconds." )

Component:AddInlineFunction( "cpuAverage", "", "n", "(Context.Status.Average * 1000000)" )
Component:AddFunctionHelper( "cpuAverage", "", "Returns the amount of cpu time used on average in microseconds." )

Component:AddInlineFunction( "tickQuota", "", "n", "EXPADV.ReadSetting(\"tick_cpu\", 32000)" )
Component:AddFunctionHelper( "tickQuota", "", "Returns the size of the tick quota in microseconds." )

Component:AddInlineFunction( "softQuota", "", "n", "EXPADV.ReadSetting(\"soft_cpu\",  4000)" )
Component:AddFunctionHelper( "softQuota", "", "Returns the size of the soft quota in microseconds." )

Component:AddInlineFunction( "hardQuota", "", "n", "EXPADV.ReadSetting(\"hard_cpu\", 50000)" )
Component:AddFunctionHelper( "hardQuota", "", "Returns the size of the hard quota in microseconds." )

Component:AddVMFunction( "quota", "", "b", --This function curently doesnt work to good
	function( Context, Trace )
		if (SysTime( ) - Context.Status.BenchMark) * 1000000 > (expadv_hard_cpu - expadv_tick_cpu) then
			return false
		elseif Context.Status.Tick * 1000000 >= expadv_soft_cpu * 2 then
			return false
		end

		return true
	end )

Component:AddFunctionHelper( "quota", "", "Returns true if the current qouta is below limit." )
	
Component:AddVMFunction( "quota", "n", "b", --This function curently doesnt work
	function( Context, Trace, Value )
		Value = math.Clamp( Value, 1, 100 )

		if (SysTime( ) - Context.Status.BenchMark) * 1000000 >= (expadv_hard_cpu - expadv_tick_cpu) * Value then
			return false
		elseif Value == 100 then
			if Context.Status.Tick * 1000000 >= expadv_soft_cpu * 2 then
				return false
			end
		elseif Context.Status.Tick * 1000000 >= expadv_soft_cpu * 2 * Value * 0.01 then
			return false
		end

		return true
	end )

Component:AddFunctionHelper( "quota", "n", "Returns true if the given number (in microseconds) is below qouta limit." )

EXPADV.AddDepricatedFunction(Component, "perf", "", "n", "quota", "")
EXPADV.AddDepricatedFunction(Component, "perf", "n", "n", "quota", "n")

/* --- --------------------------------------------------------------------------------
	@: Printing
   --- */

local Component = EXPADV.AddComponent( "print" , true )

Component.Author = "Rusketh"
Component.Description = "Prints stuff to your chat."
Component:AddFeature( "Print", "Prints to you..", "fugue/printer-monochrome.png" )

EXPADV.SharedOperators( )

Component:AddVMFunction( "printColor", "...", "",
	function( Context, Trace, ... )
		
		local Values = { ... }

		for Key, Value in pairs( Values ) do
			if Value[2] == "c" then
				Values[Key] = Value[1]
			else
				Values[Key] = EXPADV.ToString( Value[2], Value[1] )
			end
		end

		EXPADV.PrintColor( Context, Values )
	end )

Component:AddVMFunction( "print", "...", "",
	function( Context, Trace, ... )
		local Values = { ... }

		for Key, Value in pairs( Values ) do
			Values[Key] = EXPADV.ToString( Value[2], Value[1] )
		end

		EXPADV.PrintColor( Context, Values )
	end )
	
local printTable

printTable = function(Context, Trace, Table, Indent, Done)
	Done = Done or {}
	Indent = Indent or ""

	local I = 0

	for _,Key in pairs(Table.Look) do
		local Value = Table.Data[Key]
		local Type = Table.Types[Key]

		if Type == "_ar" and !Done[Value] then
			Done[Value] = true
			
			EXPADV.PrintColor(Context, Indent .. tostring(Key) .. "\t=\t" .. EXPADV.ToString(Type, Value))

			for I = 1, #Value do
				EXPADV.PrintColor(Context, Indent .."\t\t\t[ " .. I .. " ] = " .. EXPADV.ToString(Value.__type, Value[I]))
			end

		elseif Type == "t" and !Done[Value] then
			Done[Value] = true
			printTable(Context, Trace, Value, Indent .. "\t", Done)
		else
			EXPADV.PrintColor(Context, Indent .. tostring(Key) .. "\t=\t" .. EXPADV.ToString(Type, Value))
		end
	end
end

Component:AddVMFunction( "printTable", "t", "", printTable)
	
Component:AddVMFunction( "printArray", "ar", "",
	function( Context, Trace, Array )
		for I = 1, #Array do
			EXPADV.PrintColor( Context, "[ " .. I .. " ] = " .. EXPADV.ToString( Array.__type, Array[I] ) )
		end
	end )

Component:AddFunctionHelper( "printColor", "...", "Prints the contents of ( ... ) to chat seperated with a space using colors." )
Component:AddFunctionHelper( "printTable", "t", "Prints the contents of a table to chat" )
Component:AddFunctionHelper( "printTable", "ar", "Prints the contents of an array to chat" )
Component:AddFunctionHelper( "print", "...", "Prints the contents of ( ... ) to chat seperated with a space." )

if SERVER then util.AddNetworkString( "expadv.printcolor" ) end

function EXPADV.PrintColor( Context, Tbl, ... )

	if !istable(Tbl) then Tbl = {Tbl, ...} end

	if CLIENT then
		if !EXPADV.EntityCanAccessFeature(Context.entity, "Print") then return end
		chat.AddText( unpack(Tbl) )
	elseif IsValid(Context.player) then
		net.Start( "expadv.printcolor" )
			net.WriteTable( Tbl )
		net.Send(Context.player)
	elseif Context.entity and Context.entity.Scripted then
		MsgC(unpack(Tbl))
		net.Start( "expadv.printcolor" )
			net.WriteTable( Tbl )
		net.Broadcast()
	end
end

if CLIENT then
	net.Receive( "expadv.printcolor", function( )
		chat.AddText( unpack( net.ReadTable( ) ) )
	end )
end

/* --- -------------------------------------------------------------------------------
	@: Net
   --- */

EXPADV.AddInlineFunction( nil, "netUsage", "", "n", "(Context.Data.net_bytes or 0)" )
EXPADV.AddFunctionHelper( nil, "netUsage", "", "Returns the current bytes used for client and server sync." )

EXPADV.AddInlineFunction( nil, "netLimit", "", "n", "(expadv_netlimit or 0)" )
EXPADV.AddFunctionHelper( nil, "netLimit", "", "Returns the max bytes that can used for client and server sync." )

/* --- -------------------------------------------------------------------------------
	@: Events
   --- */

EXPADV.SharedEvents( )
	
EXPADV.AddEvent( nil, "tick", "", "" )
EXPADV.AddEvent( nil, "think", "", "" )
EXPADV.AddEvent( nil, "last", "", "" )

EXPADV.ServerEvents( )
EXPADV.AddEvent( nil, "clientLoaded", "ply", "" )
EXPADV.AddEvent( nil, "dupePasted" )

/* --- -------------------------------------------------------------------------------
	@: Shared Hooks
   --- */

hook.Add( "Tick", "Expav.Event", function( )
	EXPADV.CallEvent( "tick" )
end )

hook.Add( "Think", "Expav.Event", function( )
	EXPADV.CallEvent( "think" )
end )

/* --- --------------------------------------------------------------------------------
	@: Variants
   --- */

local Component = EXPADV.AddComponent( "variant" , true )

Component.Author = "Rusketh"
Component.Description = "Adds an object that can pass around anything."

local Class_Variant = Component:AddClass( "variant", "vr" )

Class_Variant:DefaultAsLua( { false, "b" } )

Class_Variant:AddPreparedOperator( "=", "n,vr", "", "Context.Memory[@value 1] = @value 2" )

function Component:OnPostRegisterClass( Name, Class )
	if !Class.LoadOnClient then
		EXPADV.ServerOperators( )
	elseif !Class.LoadOnServer then
		EXPADV.ClientOperators( )
	else EXPADV.SharedOperators( ) end

	self:AddInlineOperator( "variant", Class.Short, "vr", "{ @value 1, @type 1 }" )

	self:AddInlineOperator( Name, "vr", Class.Short, string.format( "( @value 1[2] == %q and @value 1[1] or Context:Throw(@trace, %q, \"Attempt to cast value \" .. EXPADV.TypeName(@value 1[2]) .. \" to %s \") )", Class.Short, "cast", Name ) )
end

Component:AddInlineFunction( "type", "vr:", "s", "EXPADV.TypeName(@value 1[2])" )
Component:AddFunctionHelper( "type", "vr:", "Returns the type of the variant." )

/* --- --------------------------------------------------------------------------------
	@: Variant VON support
   --- */

Class_Variant:AddSerializer( function( Variant )
	if !EXPADV.CanSerialize(Variant[2]) then return end

	return { EXPADV.Serialize( Variant[2], Variant[1] ), Variant[2] }
end )

Class_Variant:AddDeserializer( function( Variant )
	return { EXPADV.Deserialize( Variant[2], Variant[1] ), Variant[2] }
end )

/* --- --------------------------------------------------------------------------------
	@: Debug
   --- */

local Component = EXPADV.AddComponent( "debug" , true )

Component.Author = "Rusketh"
Component.Description = "Used to debug thrown exceptions in your code."

Component:AddInlineFunction( "type", "ex:", "s", "@value 1.Exception" )
Component:AddFunctionHelper( "type", "ex:", "Returns the true type of an Exception" )

Component:AddInlineFunction( "message", "ex:", "s", "@value 1.Message" )
Component:AddFunctionHelper( "message", "ex:", "Returns the current exceptions message." )

Component:AddInlineFunction( "root", "ex:", "ar", [[{@value 1.Trace[1] or 0, @value 1.Trace[2] or 0, __type = "n" } ]] )
Component:AddFunctionHelper( "root", "ex:", "Returns the root of the exception." )

Component:AddVMFunction( "stack", "ex:n", "ar",
	function( Context, Trace, Exception, Index )
		local Stack = Exception.Trace.Stack

		if !Stack or !Stack[Index] then return {0, 0, __type = "n" } end

		return {Stack[Index][1] or 0, Stack[Index][2] or 0, __type = "n" }
	end )
