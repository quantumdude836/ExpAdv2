/* ---	--------------------------------------------------------------------------------
	@: Array Component
   ---	*/

local Component = EXPADV.AddComponent( "arays" , true )

Component:AddException( "array" )

/* ---	--------------------------------------------------------------------------------
	@: Table Class
   ---	*/

local Array = Component:AddClass( "array" , "ar" )

Array:DefaultAsLua( function( ) return {_type="void"} end )

Array:StringBuilder( function( A ) return string.format( "array<%s,%i>", EXPADV.TypeName(A._type), #A ) end )

/* ---	--------------------------------------------------------------------------------
	@: Basic Operators
   ---	*/

EXPADV.SharedOperators( )

Array:AddPreparedOperator( "=", "n,ar", "", "Context.Memory[@value 1] = @value 2" ) -- Keeping this virtual, becuase i might need to add to it later :D

Component:AddInlineOperator( "#","ar","n", "#@value 1" )

Component:AddInlineOperator( "table", "ar", "t", "EXPADV.ResultTable(@value 1.__type, @value 1)" )

function Component:OnPostRegisterClass( Name, Class )

	EXPADV.SharedOperators( )

	if Name == "generic" or Name == "function" then return end

/* ---	--------------------------------------------------------------------------------
	@: Get Operator
   ---	*/

	Array:AddPreparedOperator( "get", "ar,n," .. Class.Short, Class.Short, string.format([[
		if @value 1.__type ~= %q then Context.Throw(@trace, "array", "array type missmatch, %s expected got " .. EXPADV.TypeName(@value 1.__type)) end
		if @value 1[@value 2] == nil then Context.Throw(@trace, "array", "array reach index " .. @value 2 .. " returned void" ) end
		]], Class.Short, Class.Name), "@value 1[@value 2]")

/* ---	--------------------------------------------------------------------------------
	@: Set Operator
   ---	*/

	Array:AddPreparedOperator( "set", "ar,n," .. Class.Short, "", string.format([[
		if @value 1.__type ~= %q then Context.Throw(@trace, "array", "array type missmatch, %s expected got " .. EXPADV.TypeName(@value 1.__type)) end
		]], Class.Short, Class.Name), "@value 1[@value 2] = @value 3")

/* ---	--------------------------------------------------------------------------------
	@: Set Operator
   ---	*/

   Component:AddInlineFunction( string.format("%sArray", Class.Name ), "", "ar", string.format( "{__type=%q}", Class.Short) )
end

/* ---	--------------------------------------------------------------------------------
	@: Now for a way to build a filled table
	---	*/

Component:AddGeneratedOperator( "array", "s,...", "ar", function( Operator, Compiler, Trace, Type, ... )
	local Inputs = { ... }
	local Preperation = { }
	local Values=  { }
	
	for I = 1, #Inputs, 1 do
		local Input = Inputs[I]

		if Input.FLAG == EXPADV_PREPARE or Input.FLAG == EXPADV_INLINEPREPARE then
			Preperation[#Preperation + 1] = Input.Prepare
		end

		if Input.FLAG == EXPADV_INLINE or Input.FLAG == EXPADV_INLINEPREPARE then
			Values[I] = Input.Inline
		end
	end

	local LuaInline = string.format( "{ __type = %q, %s }", Type, table.concat( Values, "," ) )

	return { Trace = Trace, Inline = LuaInline, Prepare = table.concat( Preperation, "\n" ), Return = "_ar", FLAG = EXPADV_INLINEPREPARE }
end )