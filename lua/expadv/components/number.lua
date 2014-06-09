/* --- --------------------------------------------------------------------------------
	@: Math Component
---	*/

local MathComponent = EXPADV.AddComponent( "math" , true )
local Number = MathComponent:AddClass( "number" , "n" )

Number:DefaultAsLua( 0 )
Number:AddAlias( "int" )

if WireLib then
	Number:WireInput( "NUMBER" ) 
	Number:WireOutput( "NUMBER" ) 
end

Number:StringBuilder( function( Context, Trace, Obj ) return tostring( Obj ) end )

MathComponent:AddInlineOperator("==", "n,n", "b", "(@value 1 == @value 2)" )
MathComponent:AddInlineOperator("!=", "n,n", "b", "(@value 1 != @value 2)" )
MathComponent:AddInlineOperator(">", "n,n", "b", "(@value 1 > @value 2)" )
MathComponent:AddInlineOperator("<", "n,n", "b", "(@value 1 < @value 2)" )
MathComponent:AddInlineOperator(">=","n,n", "b", "(@value 1 >= @value 2)" )
MathComponent:AddInlineOperator("<=","n,n", "b", "(@value 1 <= @value 2)" )

MathComponent:AddInlineOperator("+", "n,n", "n", "(@value 1 + @value 2)" )
MathComponent:AddInlineOperator("-", "n,n", "n", "(@value 1 - @value 2)" )
MathComponent:AddInlineOperator("*", "n,n", "n", "(@value 1 * @value 2)" )
MathComponent:AddInlineOperator("/", "n,n", "n", "(@value 1 / @value 2)" )
MathComponent:AddInlineOperator("%", "n,n", "n", "(@value 1 % @value 2)" )
MathComponent:AddInlineOperator("^", "n,n", "n", "(@value 1 ^ @value 2)" )

MathComponent:AddInlineOperator("is", "n", "b", "(@value 1 >= 1)" )
MathComponent:AddInlineOperator("not", "n", "b", "(@value 1 < 1)" )
MathComponent:AddInlineOperator("-", "n", "b", "(-@value 1)" )
MathComponent:AddInlineOperator("$", "n", "n", "((Context.Memory[@value 1] or 0) - (Context.Delta[@value 1] or 0))" )

MathComponent:AddInlineOperator("=n","n","n", "(Context.Memory[@value 1] or 0)" )

MathComponent:AddPreparedOperator( "n=", "n,n", "", [[
	@define value = Context.Memory[@value 1]
	Context.Trigger = Context.Delta[@value 1] ~= @value
	Context.Memory[@value 1] = @value 2
	Context.Delta[@value 1] = @value
]] ) -- First value is memory address, second is value.

-- Example of custom realtime memory allication method
-- MathComponent:AddPreparedOperator("=n", "s,n", "n", "Context.Memory[ Context.Cells[@value 1].MemRef ] = @value 2" )
