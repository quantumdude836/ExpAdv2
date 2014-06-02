/*	---	--------------------------------------------------------------------------------
	@: Server -> Math Component
---	*/

local MathComponent = EXPADV.AddComponent( "math" , true )
local Number = MathComponent:AddClass( "number" , "n" )

Number:DefaultAsLua( 0 )
Number:AddAlias( "int" )

if WireLib then
	Number:WireInput( "NUMBER" ) 
	Number:WireOutput( "NUMBER" ) 
end

/*	---	--------------------------------------------------------------------------------
	@:Section -> Math Operators.
---	*/

MathComponent:AddInlineOperator( Name, Input, Return, Inline )
MathComponent:AddPreparedOperator( Name, Input, Return, Prepare, Inline )

-- TODO: COMPONENT NOT YET SUPPORTEDs
MathComponent:AddPreparedOperator("=","n","n",[[
	
]], "@value 2")

-- TODO: COMPONENT NOT YET SUPPORTED
MathComponent:AddPreparedOperator("~","n","b",[[
	
]], "%Changed")

/*	---
	@Compare:
---	*/

MathComponent:AddInlineOperator("==", "n,n", "b", "(@value 1 == @value 2)" )
MathComponent:AddInlineOperator("!=", "n,n", "b", "(@value 1 != @value 2)" )
MathComponent:AddInlineOperator(">", "n,n", "b", "(@value 1 > @value 2)" )
MathComponent:AddInlineOperator("<", "n,n", "b", "(@value 1 < @value 2)" )
MathComponent:AddInlineOperator(">=","n,n", "b", "(@value 1 >= @value 2)" )
MathComponent:AddInlineOperator("<=","n,n", "b", "(@value 1 <= @value 2)" )

/*	---
	@Arithmatic:
---	*/

MathComponent:AddInlineOperator("+", "n,n", "n", "(@value 1 + @value 2)" )
MathComponent:AddInlineOperator("-", "n,n", "n", "(@value 1 - @value 2)" )
MathComponent:AddInlineOperator("*", "n,n", "n", "(@value 1 * @value 2)" )
MathComponent:AddInlineOperator("/", "n,n", "n", "(@value 1 / @value 2)" )
MathComponent:AddInlineOperator("%", "n,n", "n", "(@value 1 % @value 2)" )
MathComponent:AddInlineOperator("^", "n,n", "n", "(@value 1 ^ @value 2)" )

/*	---
	@General:
---	*/

MathComponent:AddInlineOperator("is", "n", "b", "(@value 1 >= 1)" )
MathComponent:AddInlineOperator("not", "n", "b", "(@value 1 < 1)" )
MathComponent:AddInlineOperator("-", "n", "b", "(-@value 1)" )
MathComponent:AddInlineOperator("$", "n", "n", "((Context.Memory[@value 1] or 0) - (Context.Delta[@value 1] or 0))" )

/*	---	---------------------------------------------------------------------------------
	@:Section -> Assignment Operators
---	/*

-- For saving to memory.
MathComponent:AddPreparedOperator("=n", "n,n", "n", [[
	@define value = Context.Memory[@value 1]
	Context.Trigger = Context.Delta[@value 1] ~= @value
	Context.Memory[@value 1] = @value 2
	Context.Delta[@value 1] = value
]] ) -- First value is memory address, second is value.

-- Example of custom realtime memory allication method
-- MathComponent:AddPreparedOperator("=n", "s,n", "n", "Context.Memory[ Context.Cells[@value 1].MemRef ] = @value 2" )

/*	---
	@Assign Before:
---	*/
	-- TODO: NOT YET SUPPORTED

/*	---
	@Assign After:
---	*/
	-- TODO: NOT YET SUPPORTED
	

/*	---	---------------------------------------------------------------------------------
	@:Section -> Min Max Function
---	*/

	-- TODO ADD THIS AREA
	
/*	---	---------------------------------------------------------------------------------
	@:Section -> Random Numbers
---	*/

	-- TODO ADD THIS AREA
	
/*	---	---------------------------------------------------------------------------------
	@:Section -> Advanced Math
---	*/

	-- TODO ADD THIS AREA
	
/*	---	---------------------------------------------------------------------------------
	@:Section -> Trig
---	*/

	-- TODO ADD THIS AREA
	
/*	---	---------------------------------------------------------------------------------
	@:Section -> Binary
---	*/

	-- TODO ADD THIS AREA

/*	---	---------------------------------------------------------------------------------
	@:Section -> Constants
---	*/

	-- TODO ADD THIS AREA