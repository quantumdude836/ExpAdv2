/* --- --------------------------------------------------------------------------------
	@: Math Component
   --- */

local MathComponent = EXPADV.AddComponent( "math" , true )

/* --- --------------------------------------------------------------------------------
	@: Number Object
   --- */

local Number = MathComponent:AddClass( "number" , "n" )

Number:StringBuilder( function( Context, Trace, Obj ) return tostring( Obj ) end )
Number:DefaultAsLua( 0 )
Number:AddAlias( "int" )

/* --- --------------------------------------------------------------------------------
	@: Wire Support
   --- */

if WireLib then
	Number:WireInput( "NUMBER" ) 
	Number:WireOutput( "NUMBER" ) 
end

/* --- --------------------------------------------------------------------------------
	@: Logical and Comparason
   --- */

MathComponent:AddInlineOperator( "==", "n,n", "b", "(@value 1 == @value 2)" )
MathComponent:AddInlineOperator( "!=", "n,n", "b", "(@value 1 != @value 2)" )
MathComponent:AddInlineOperator( ">", "n,n", "b", "(@value 1 > @value 2)" )
MathComponent:AddInlineOperator( "<", "n,n", "b", "(@value 1 < @value 2)" )
MathComponent:AddInlineOperator( ">=","n,n", "b", "(@value 1 >= @value 2)" )
MathComponent:AddInlineOperator( "<=","n,n", "b", "(@value 1 <= @value 2)" )

/* --- --------------------------------------------------------------------------------
	@: Arithmatic
   --- */

MathComponent:AddInlineOperator( "+", "n,n", "n", "(@value 1 + @value 2)" )
MathComponent:AddInlineOperator( "-", "n,n", "n", "(@value 1 - @value 2)" )
MathComponent:AddInlineOperator( "*", "n,n", "n", "(@value 1 * @value 2)" )
MathComponent:AddInlineOperator( "/", "n,n", "n", "(@value 1 / @value 2)" )
MathComponent:AddInlineOperator( "%", "n,n", "n", "(@value 1 % @value 2)" )
MathComponent:AddInlineOperator( "^", "n,n", "n", "(@value 1 ^ @value 2)" )
 
/* --- --------------------------------------------------------------------------------
	@: Operators
   --- */

MathComponent:AddInlineOperator( "is", "n", "b", "(@value 1 >= 1)" )
MathComponent:AddInlineOperator( "not", "n", "b", "(@value 1 < 1)" )
MathComponent:AddInlineOperator( "-", "n", "b", "(-@value 1)" )

/* --- --------------------------------------------------------------------------------
	@: Assigment
   --- */

MathComponent:AddPreparedOperator( "n=", "n,n", "", [[
	@define value = Context.Memory[@value 1]
	Context.Trigger = Context.Delta[@value 1] ~= @value
	Context.Memory[@value 1] = @value 2
	Context.Delta[@value 1] = @value
]] )

MathComponent:AddInlineOperator("=n","n","n", "(Context.Memory[@value 1] or 0)" )

MathComponent:AddInlineOperator( "$", "n", "n", "((Context.Memory[@value 1] or 0) - (Context.Delta[@value 1] or 0))" )

local Increment_Prepare  = [[
	@define value = Context.Memory[@value 1]
	Context.Trigger = Context.Delta[@value 1] ~= @value
	Context.Memory[@value 1] = @value + 1
	Context.Delta[@value 1] = @value
]]

MathComponent:AddPreparedOperator( "n++", "n", "n", Increment_Prepare, "@value " )

MathComponent:AddPreparedOperator( "++n", "n", "n", Increment_Prepare, "(@value + 1)" )

local Decrement_Prepare  = [[
	@define value = Context.Memory[@value 1]
	Context.Trigger = Context.Delta[@value 1] ~= @value
	Context.Memory[@value 1] = @value - 1
	Context.Delta[@value 1] = @value
]]

MathComponent:AddPreparedOperator( "n--", "n", "n", Decrement_Prepare, "@value " )

MathComponent:AddPreparedOperator( "--n", "n", "n", Decrement_Prepare, "(@value - 1)" )

MathComponent:AddPreparedOperator( "~n", "n", "b", [[
	@define value = Context.Memory[@value 1]
	@define changed = (Context.Click[@value 1] == nil) or (Context.Click[@value 1] ~= @value)
	Context.Click[@value 1] = @value
]], "@Changed" )

/* --- --------------------------------------------------------------------------------
	@: Casting
   --- */

MathComponent:AddInlineOperator( "string", "n", "s", "tostring(@value 1)" )

/* --- --------------------------------------------------------------------------------
	@: Max Value
   --- */

MathComponent:AddInlineOperator( "max", "n,n,n,n,n", "n", "math.max(@value 1, @value 2, @value 3, @value 4, @value 5)" )
MathComponent:AddFunctionHelper( "max", "n,n,n,n,n", "returns the higest value out of 3 numbers." )
EXPADV.AddFunctionAlias( "max", "n,n,n,n" )
EXPADV.AddFunctionAlias( "max", "n,n,n" )
EXPADV.AddFunctionAlias( "max", "n,n" )

/* --- --------------------------------------------------------------------------------
	@: Min Value
   --- */

MathComponent:AddInlineOperator( "min", "n,n,n,n,n", "n", "math.min(@value 1, @value 2, @value 3, @value 4, @value 5)" )
MathComponent:AddFunctionHelper( "min", "n,n,n,n,n", "returns the lowest value out of 3 numbers." )
EXPADV.AddFunctionAlias( "min", "n,n,n,n" )
EXPADV.AddFunctionAlias( "min", "n,n,n" )
EXPADV.AddFunctionAlias( "min", "n,n" )

/* --- --------------------------------------------------------------------------------
	@: Max Value
   --- */
