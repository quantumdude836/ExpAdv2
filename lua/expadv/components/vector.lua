/* ---	--------------------------------------------------------------------------------
	@: Vector Component
   ---	*/

local VectorComponent = EXPADV.AddComponent( "vector", true )

/* ---	--------------------------------------------------------------------------------
	@: Vector Object
   ---	*/

local VectorObj = VectorComponent:AddClass( "vector", "v" )

VectorObj:DefaultAsLua( Vector(0, 0, 0) )
VectorObj:AddAlias( "vec" )

/* --- --------------------------------------------------------------------------------
	@: Wire Support
   --- */

if WireLib then
	VectorObj:WireInput( "VECTOR" )
	VectorObj:WireOutput( "VECTOR" )
end

/* --- --------------------------------------------------------------------------------
	@: Logical and Comparison
   --- */

VectorComponent:AddInlineOperator( "==", "v,v", "b", "(@value 1 == @value 2)" )
VectorComponent:AddInlineOperator( "!=", "v,v", "b", "(@value 1 ~= @value 2)" )
VectorComponent:AddInlineOperator( ">", "v,v", "b", "(@value 1 > @value 2)" )
VectorComponent:AddInlineOperator( "<", "v,v", "b", "(@value 1 < @value 2)" )
VectorComponent:AddInlineOperator( ">=", "v,v", "b", "(@value 1 >= @value 2)" )
VectorComponent:AddInlineOperator( "<=", "v,v", "b", "(@value 1 <= @value 2)" )

/* --- --------------------------------------------------------------------------------
	@: Arithmetic
   --- */

VectorComponent:AddInlineOperator( "+", "v,v", "v", "(@value 1 + @value 2)" )
VectorComponent:AddInlineOperator( "-", "v,v", "v", "(@value 1 - @value 2)" )
VectorComponent:AddInlineOperator( "*", "v,v", "v", "(@value 1 * @value 2)" )
VectorComponent:AddInlineOperator( "/", "v,v", "v", "(@value 1.x / @value 2.x) (@value 1.y / @value 2.y) (@value 1.z / @value 2.z)" )
VectorComponent:AddInlineOperator( "%", "v,v", "v", "(math.fmod(@value 1.x, @value 2.x) (math.fmod(@value 1.y, @value 2.y) (math.fmod(@value 1.z, @value 2.z)" )

/* --- --------------------------------------------------------------------------------
	@: Number Arithmetic
   --- */

/* --- --------------------------------------------------------------------------------
	@: Operators
   --- */

VectorComponent:AddInlineOperator( "is", "v", "b", "(@value 1 ~= Vector(0, 0, 0))" )
VectorComponent:AddInlineOperator( "not", "v", "b", "(@value 1 == Vector(0, 0, 0))" )
VectorComponent:AddInlineOperator( "-", "n", "b", "(-@value 1)" )

/* --- --------------------------------------------------------------------------------
	@: Casting
   --- */

VectorComponent:AddInlineOperator( "string", "v", "s", "string.format( \"Vector< %i, %i, %i >\", @value 1.x, @value 1.y, @value 1.z)" )

/* --- --------------------------------------------------------------------------------
	@: Assignment
   --- */

VectorComponent:AddPreparedOperator( "v=", "n,v", "", [[
	@define value = Context.Memory[@value 1]
	Context.Trigger = Context.Delta[@value 1] ~= @value
	Context.Memory[@value 1] = @value 2
]] )

VectorComponent:AddInlineOperator( "=v", "n", "v", "Context.Memory[@value 1]" )

/* --- --------------------------------------------------------------------------------
	@: Constructor
   --- */

VectorComponent:AddInlineFunction( "vec", "", "v", "Vector(0, 0, 0)" )
VectorComponent:AddInlineFunction( "vec", "n", "v", "Vector(@value 1, @value 1, @value 1)" )
VectorComponent:AddInlineFunction( "vec", "n,n,n", "v", "Vector(@value 1, @value 2, @value 3)" )

VectorComponent:AddFunctionHelper( "vec", "n,n,n", "Creates a vector object" )
VectorComponent:AddFunctionHelper( "vec", "n", "Creates a vector object" )
VectorComponent:AddFunctionHelper( "vec", "", "Creates a vector object" )

/* --- --------------------------------------------------------------------------------
	@: Accessors
   --- */

--GETTERS
VectorComponent:AddInlineFunction( "getX", "v:", "n", "@value 1.x")
VectorComponent:AddFunctionHelper( "getX", "v:", "Gets the X value of a vector")

VectorComponent:AddInlineFunction( "getY", "v:", "n", "@value 1.y")
VectorComponent:AddFunctionHelper( "getY", "v:", "Gets the Y value of a vector")

VectorComponent:AddInlineFunction( "getZ", "v:", "n", "@value 1.z")
VectorComponent:AddFunctionHelper( "getZ", "v:", "Gets the Z value of a vector")

--SETTERS
VectorComponent:AddPreparedFunction( "setX", "v:n", "", "@value 1.x = @value 2")
VectorComponent:AddFunctionHelper( "setX", "v:n", "Sets the X value of a vector")

VectorComponent:AddPreparedFunction( "setY", "v:n", "", "@value 1.y = @value 2")
VectorComponent:AddFunctionHelper( "setY", "v:n", "Sets the Y value of a vector")

VectorComponent:AddPreparedFunction( "setZ", "v:n", "", "@value 1.z = @value 2")
VectorComponent:AddFunctionHelper( "setZ", "v:n", "Sets the Z value of a vector")