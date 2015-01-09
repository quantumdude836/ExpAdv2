/* --- --------------------------------------------------------------------------------
	@: Default Exceptions
   --- */

EXPADV.AddException( nil, "invoke" )
EXPADV.AddException( nil, "cast" )

/* --- --------------------------------------------------------------------------------
	@: Default Classes
   --- */

local Class_Boolean   = EXPADV.AddClass( nil, "boolean", "b" )
local Class_Function  = EXPADV.AddClass( nil, "function", "f" )
local Class_Delgate   = EXPADV.AddClass( nil, "delegate", "d" )
local Class_Exception = EXPADV.AddClass( nil, "exception", "ex" )
local Class_Class = EXPADV.AddClass( nil, "class", "cls" ) --Nope: Not what you think it is.

Class_Boolean:AddAlias( "bool" )
Class_Boolean:CanSerialize( true )
Class_Boolean:DefaultAsLua( false )
Class_Function:DefaultAsLua( "function( ) end" )

if WireLib then
	Class_Boolean:WireOutput( "NORMAL", function( Context, MemoryRef )
		return Context.Memory[ MemoryRef ] and 1 or 0
	end ) 

	Class_Boolean:WireInput( "NORMAL", function( Context, MemoryRef, InValue )
		Context.Memory[ MemoryRef ] = (InValue ~= 0)
	end )
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

EXPADV.AddGeneratedFunction( nil, "invoke", "cls,d,...", "",
	function( Operator, Compiler, Trace, ... )
		
		local Inputs = { ... }
		local Preperation = { }
		local Variants = { }
		
		for I = 1, #Inputs, 1 do
			local Input = Inputs[I]

			if Input.FLAG == EXPADV_PREPARE or Input.FLAG == EXPADV_INLINEPREPARE then
				Preperation[#Preperation + 1] = Input.Prepare
			end

			if I > 2 then
				if Input.FLAG == EXPADV_INLINE or Input.FLAG == EXPADV_INLINEPREPARE then
					if Input.Return == "_vr" then
						Variants[#Variants + 1] = Input.Inline
					else
						Variants[#Variants + 1] = string.format("{%s,%q}", Input.Inline, Input.Return)
					end
				end
			end
		end

		local Function, Return, Type = Compiler:DefineVariable( ), Compiler:DefineVariable( ), Compiler:DefineVariable( )
		local Arguments = table.concat(Variants, ",")
		if #Variants > 0 then Arguments = "," .. Arguments end
		
		Preperation[#Preperation + 1] = string.format("%s = %s", Function, Inputs[2].Inline )
		Preperation[#Preperation + 1] = string.format("%s, %s = %s( Context %s )", Return, Type, Function, Arguments )
		Preperation[#Preperation + 1] = string.format("if %s ~= %s then Context:Throw(%s,%q,%q) end", Inputs[1].Inline, Type, Compiler:CompileTrace(Trace), "invoke", "This is not the exception, youre looking for." )

		return { Trace = Trace, Inline = Return, Prepare = table.concat( Preperation, "\n" ), Return = Inputs[1].PointClass, FLAG = EXPADV_INLINEPREPARE }
	end ); EXPADV.AddFunctionAlias("invoke", "cls,d")

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

EXPADV.SharedOperators( )

Component:AddInlineFunction( "ops", "", "n", "math.Round(Context.Status.Perf)" )

Component:AddInlineFunction( "opCounter", "", "n", "math.ceil(Context.Status.Perf + Context.Status.Counter)" )

Component:AddInlineFunction( "cpuUsage", "", "n", "($SysTime( ) - Context.Status.BenchMark)" )

Component:AddInlineFunction( "cpuStopWatch", "", "n", "Context.Status.StopWatch" )

		--------------------------------------------------------------

Component:AddVMFunction( "perf", "", "b",
	function( Context, Trace )
		if Context.Status.Perf + Context.Status.Counter > expadv_hardquota - expadv_tickquota then
			return false
		elseif Context.Status.Perf >= expadv_softquota * 2 then
			return false
		end

		return true
	end )

Component:AddVMFunction( "perf", "n", "b",
	function( Context, Trace, Value )
		Value = math.Clamp( Value, 0, 100 )

		if Context.Status.Perf + Context.Status.Counter >= (expadv_hardquota - expadv_tickquota) * Value * 0.01 then
			return false
		elseif Value == 100 then
			if Context.Status.Perf >= expadv_softquota * 2 then
				return false
			end
		elseif Context.Status.Perf >= expadv_softquota * Value * 0.01 then
			return false
		end

		return true
	end )

		--------------------------------------------------------------

Component:AddVMFunction( "minquota", "", "n",
	function( Context, Trace )
		if Context.Status.Perf < expadv_softquota then
			return math.floor(expadv_softquota - Context.Status.Perf)
		else
			return 0
		end
	end )

Component:AddVMFunction( "maxquota", "", "n",
	function( Context, Trace )
		local Perf = Context.Status.Perf

		if Perf >= expadv_tickquota then return 0 end

		local tickquota = expadv_tickquota - Perf
		local hardquota = expadv_hardquota - Context.Status.Counter - Perf + expadv_softquota
			
		if hardquota < tickquota then return math.floor(hardquota) end
		
		return math.floor(tickquota)
	end )

Component:AddVMFunction( "softQuota", "", "n",
	function( Context, Trace )
		return expadv_softquota
	end )

Component:AddVMFunction( "hardQuota", "", "n",
	function( Context, Trace )
		return expadv_hardquota
	end )

/* --- --------------------------------------------------------------------------------
	@: Printing
   --- */

local Component = EXPADV.AddComponent( "print" , true )

Component.Author = "Rusketh"
Component.Description = "Prints stuff to your chat."

EXPADV.SharedOperators( )

Component:AddVMFunction( "printColor", "...", "",
	function( Context, Trace, ... )
		if CLIENT then
			if Context.player ~= LocalPlayer( ) and Context.player ~= Entity(0) then return end
		end

		local Values = { ... }

		for Key, Value in pairs( Values ) do
			if Value[2] == "c" then
				Values[Key] = Value[1]
			else
				Values[Key] = EXPADV.ToString( Value[2], Value[1] )
			end
		end

		if SERVER then
			EXPADV.PrintColor( Context, Values )
		elseif CLIENT then
			chat.AddText( unpack( Values ) )
		end
	end )

Component:AddVMFunction( "print", "...", "",
	function( Context, Trace, ... )
		if CLIENT then
			if Context.player ~= LocalPlayer( ) and Context.player ~= Entity(0) then return end
		end
		
		local Values = { ... }

		for Key, Value in pairs( Values ) do
			Values[Key] = EXPADV.ToString( Value[2], Value[1] )
		end

		if SERVER then
			EXPADV.PrintColor( Context, Values )
		elseif CLIENT then
			chat.AddText( unpack( Values ) )
		end
	end )

Component:AddFunctionHelper( "print", "...", "Prints the contents of ( ... ) to chat seperated with a space." )

if SERVER then
	util.AddNetworkString( "expadv.printcolor" )

	function EXPADV.PrintColor( Context, Tbl )
		if IsValid(Context.player) then
			net.Start( "expadv.printcolor" )
				net.WriteTable( Tbl )
			net.Send( Player )
		elseif Context.entity and Context.entity.Scripted then
			MsgC(unpack(Tbl))
			net.Start( "expadv.printcolor" )
				net.WriteTable( Tbl )
			net.Broadcast()
		end
	end

end

if CLIENT then
	net.Receive( "expadv.printcolor", function( )
		chat.AddText( unpack( net.ReadTable( ) ) )
	end )
end

/* --- -------------------------------------------------------------------------------
	@: Events
   --- */

EXPADV.SharedEvents( )
	
EXPADV.AddEvent( nil, "tick", "", "" )
EXPADV.AddEvent( nil, "think", "", "" )

EXPADV.ServerEvents( )
EXPADV.AddEvent( nil, "trigger", "s,s", "" )
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

Component:AddVMFunction( "stack", "ex:n", "ar",
	function( Context, Trace, Exception, Index )
		local Stack = Exception.Trace.Stack

		if !Stack or !Stack[Index] then return {0, 0, __type = "n" } end

		return {Stack[Index][1] or 0, Stack[Index][2] or 0, __type = "n" }
	end )
