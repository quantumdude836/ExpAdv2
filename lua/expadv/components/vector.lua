/* -----------------------------------------------------------------------------------
	@: Vector Component
   --- */

local VectorComponent = EXPADV.AddComponent( "vector", true )

/* -----------------------------------------------------------------------------------
	@: Vector Object
   --- */

local VectorObj = VectorComponent:AddClass( "vector", "v" )

VectorObj:StringBuilder( function( Vector ) return string.format( "Vec( %i, %i, %i )", Vector.x, Vector.y, Vector.z ) end )
VectorObj:DefaultAsLua( Vector(0, 0, 0) )
VectorObj:AddAlias( "vec" )

/* -----------------------------------------------------------------------------------
	@: Wire Support
   --- */

if WireLib then
	VectorObj:WireInput( "VECTOR" )
	VectorObj:WireOutput( "VECTOR" )
end

/* -----------------------------------------------------------------------------------
	@: Logical and Comparison
   --- */

VectorComponent:AddInlineOperator( "==", "v,v", "b", "(@value 1 == @value 2)" )
VectorComponent:AddInlineOperator( "!=", "v,v", "b", "(@value 1 ~= @value 2)" )
VectorComponent:AddInlineOperator( ">", "v,v", "b", "(@value 1 > @value 2)" )
VectorComponent:AddInlineOperator( "<", "v,v", "b", "(@value 1 < @value 2)" )
VectorComponent:AddInlineOperator( ">=", "v,v", "b", "(@value 1 >= @value 2)" )
VectorComponent:AddInlineOperator( "<=", "v,v", "b", "(@value 1 <= @value 2)" )

/* -----------------------------------------------------------------------------------
	@: Arithmetic
   --- */

VectorComponent:AddInlineOperator( "+", "v,v", "v", "(@value 1 + @value 2)" )
VectorComponent:AddInlineOperator( "-", "v,v", "v", "(@value 1 - @value 2)" )
VectorComponent:AddInlineOperator( "*", "v,v", "v", "(@value 1 * @value 2)" )
VectorComponent:AddInlineOperator( "/", "v,v", "v", "(@value 1 / @value 2)" )

/* -----------------------------------------------------------------------------------
	@: Number Arithmetic
   --- */

VectorComponent:AddInlineOperator( "+", "v,n", "v", "(@value 1 + Vector(@value 2, @value 2, @value 2))")
VectorComponent:AddInlineOperator( "+", "n,v", "v", "(Vector(@value 1, @value 1, @value 1) + @value 2)")

VectorComponent:AddInlineOperator( "-", "v,n", "v", "(@value 1 - Vector(@value 2, @value 2, @value 2))")
VectorComponent:AddInlineOperator( "-", "n,v", "v", "(Vector(@value 1, @value 1, @value 1) - @value 2)")

VectorComponent:AddInlineOperator( "*", "v,n", "v", "(@value 1 * Vector(@value 2, @value 2, @value 2))")
VectorComponent:AddInlineOperator( "*", "n,v", "v", "(Vector(@value 1, @value 1, @value 1) * @value 2)")

VectorComponent:AddInlineOperator( "/", "v,n", "v", "(@value 1 / Vector(@value 2, @value 2, @value 2))")
VectorComponent:AddInlineOperator( "/", "n,v", "v", "(Vector(@value 1, @value 1, @value 1) / @value 2)")

/* -----------------------------------------------------------------------------------
	@: Operators
   --- */

VectorComponent:AddInlineOperator( "is", "v", "b", "(@value 1 ~= Vector(0, 0, 0))" )
VectorComponent:AddInlineOperator( "not", "v", "b", "(@value 1 == Vector(0, 0, 0))" )
VectorComponent:AddInlineOperator( "-", "n", "b", "(-@value 1)" )

/* -----------------------------------------------------------------------------------
	@: Casting
   --- */

VectorComponent:AddInlineOperator( "string", "v", "s", "string.format( \"Vec( %i, %i, %i )\", @value 1.x, @value 1.y, @value 1.z)" )

/* -----------------------------------------------------------------------------------
	@: Assignment
   --- */

VectorComponent:AddPreparedOperator( "v", "v,n", "", [[
	@define value = Context.Memory[@value 2]
	Context.Memory[@value 2] = @value 1
	Context.Delta[@value 2] = @value
]] )

/* -----------------------------------------------------------------------------------
	@: Constructor
   --- */

VectorComponent:AddInlineFunction( "vec", "", "v", "Vector(0, 0, 0)" )
VectorComponent:AddInlineFunction( "vec", "n", "v", "Vector(@value 1, @value 1, @value 1)" )
VectorComponent:AddInlineFunction( "vec", "n,n,n", "v", "Vector(@value 1, @value 2, @value 3)" )

VectorComponent:AddFunctionHelper( "vec", "n,n,n", "Creates a vector object" )
VectorComponent:AddFunctionHelper( "vec", "n", "Creates a vector object" )
VectorComponent:AddFunctionHelper( "vec", "", "Creates a vector object" )

VectorComponent:AddInlineFunction( "randVec", "n,n", "v", "Vector( $math.random(@value 1, @value 2), $math.random(@value 1, @value 2), $math.random(@value 1, @value 2) )" )
VectorComponent:AddFunctionHelper( "randVec", "n,n", "Creates a random vector constrained to the given values" )

/* -----------------------------------------------------------------------------------
	@: Accessors
   --- */

--GETTERS
VectorComponent:AddInlineFunction( "getX", "v:", "n", "@value 1.x" )
VectorComponent:AddFunctionHelper( "getX", "v:", "Gets the X value of a vector" )

VectorComponent:AddInlineFunction( "getY", "v:", "n", "@value 1.y" )
VectorComponent:AddFunctionHelper( "getY", "v:", "Gets the Y value of a vector" )

VectorComponent:AddInlineFunction( "getZ", "v:", "n", "@value 1.z" )
VectorComponent:AddFunctionHelper( "getZ", "v:", "Gets the Z value of a vector" )

--SETTERS
VectorComponent:AddPreparedFunction( "setX", "v:n", "", "@value 1.x = @value 2" )
VectorComponent:AddFunctionHelper( "setX", "v:n", "Sets the X value of a vector" )

VectorComponent:AddPreparedFunction( "setY", "v:n", "", "@value 1.y = @value 2" )
VectorComponent:AddFunctionHelper( "setY", "v:n", "Sets the Y value of a vector" )

VectorComponent:AddPreparedFunction( "setZ", "v:n", "", "@value 1.z = @value 2" )
VectorComponent:AddFunctionHelper( "setZ", "v:n", "Sets the Z value of a vector" )
