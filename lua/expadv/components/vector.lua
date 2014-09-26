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
VectorComponent:AddInlineOperator( "/", "v,v", "v", "Vector(@value 1.x / @value 2.x, @value 1.y / @value 2.y, @value 1.z / @value 2.z)" )

/* -----------------------------------------------------------------------------------
	@: Number Arithmetic
   --- */

VectorComponent:AddInlineOperator( "+", "v,n", "v", "(@value 1 + Vector(@value 2, @value 2, @value 2))")
VectorComponent:AddInlineOperator( "+", "n,v", "v", "(Vector(@value 1, @value 1, @value 1) + @value 2)")

VectorComponent:AddInlineOperator( "-", "v,n", "v", "(@value 1 - Vector(@value 2, @value 2, @value 2))")
VectorComponent:AddInlineOperator( "-", "n,v", "v", "(Vector(@value 1, @value 1, @value 1) - @value 2)")

VectorComponent:AddInlineOperator( "*", "v,n", "v", "(@value 1 * Vector(@value 2, @value 2, @value 2))")
VectorComponent:AddInlineOperator( "*", "n,v", "v", "(Vector(@value 1, @value 1, @value 1) * @value 2)")

VectorComponent:AddInlineOperator( "/", "v,n", "v", "Vector(@value 1.x / @value 2, @value 1.y / @value 2, @value 1.x / @value 2)")
VectorComponent:AddInlineOperator( "/", "n,v", "v", "Vector(@value 1 / @value 2.x, @value 1 / @value 2.y, @value 1 / @value 2.z)")

/* -----------------------------------------------------------------------------------
	@: Operators
   --- */

VectorComponent:AddInlineOperator( "is", "v", "b", "(@value 1 ~= Vector(0, 0, 0))" )
VectorComponent:AddInlineOperator( "not", "v", "b", "(@value 1 == Vector(0, 0, 0))" )
VectorComponent:AddInlineOperator( "-", "v", "v", "(-@value 1)" )

/* -----------------------------------------------------------------------------------
	@: Casting
   --- */

VectorComponent:AddInlineOperator( "string", "v", "s", "string.format( \"Vec( %i, %i, %i )\", @value 1.x, @value 1.y, @value 1.z)" )

/* -----------------------------------------------------------------------------------
	@: Assignment
   --- */

VectorObj:AddVMOperator( "=", "n,v", "", function( Context, Trace, MemRef, Value )
   local Prev = Context.Memory[MemRef] or Vector( 0, 0, 0 )

   Context.Memory[MemRef] = Value
   Context.Delta[MemRef] = Prev - Value
   Context.Trigger[MemRef] = Context.Trigger[MemRef] or ( Prev ~= Value )
end )

VectorObj:AddInlineOperator( "$", "n", "v", "(Context.Delta[@value 1] or Vector(0,0,0))" )

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

/* -----------------------------------------------------------------------------------
	@: Vector Object
   --- */

require( "vector2" )

local Vector2Obj = VectorComponent:AddClass( "vector2", "v2" )

Vector2Obj:StringBuilder( function( Vector ) return string.format( "Vec2( %i, %i )", Vector.x, Vector.y ) end )
Vector2Obj:DefaultAsLua( Vector2(0, 0) )

/* -----------------------------------------------------------------------------------
	@: Wire Support
   --- */

if WireLib then
	Vector2Obj:WireInput( "VECTOR2", function( Context, MemoryRef, InValue )
		Context.Memory[ MemoryRef ] = Vector2(InValue[1], InValue[2])
	end )

	Vector2Obj:WireOutput( "VECTOR2", function( Context, MemoryRef )
		local Val = Context.Memory[ MemoryRef ]
		return {Val.x, Val.y}
	end )
end

/* -----------------------------------------------------------------------------------
	@: Logical and Comparison
   --- */

VectorComponent:AddInlineOperator( "==", "v2,v2", "b", "(@value 1 == @value 2)" )
VectorComponent:AddInlineOperator( "!=", "v2,v2", "b", "(@value 1 ~= @value 2)" )
VectorComponent:AddInlineOperator( ">", "v2,v2", "b", "(@value 1 > @value 2)" )
VectorComponent:AddInlineOperator( "<", "v2,v2", "b", "(@value 1 < @value 2)" )
VectorComponent:AddInlineOperator( ">=", "v2,v2", "b", "(@value 1 >= @value 2)" )
VectorComponent:AddInlineOperator( "<=", "v2,v2", "b", "(@value 1 <= @value 2)" )

/* -----------------------------------------------------------------------------------
	@: Arithmetic
   --- */

VectorComponent:AddInlineOperator( "+", "v2,v2", "v2", "(@value 1 + @value 2)" )
VectorComponent:AddInlineOperator( "-", "v2,v2", "v2", "(@value 1 - @value 2)" )
VectorComponent:AddInlineOperator( "*", "v2,v2", "v2", "(@value 1 * @value 2)" )
VectorComponent:AddInlineOperator( "/", "v2,v2", "v2", "(@value 1 / @value 2)" )

/* -----------------------------------------------------------------------------------
	@: Number Arithmetic
   --- */

VectorComponent:AddInlineOperator( "+", "v2,n", "v2", "(@value 1 + Vector2(@value 2, @value 2))")
VectorComponent:AddInlineOperator( "+", "n,v2", "v2", "(Vector2(@value 1, @value 1) + @value 2)")

VectorComponent:AddInlineOperator( "-", "v2,n", "v2", "(@value 1 - Vector2(@value 2, @value 2))")
VectorComponent:AddInlineOperator( "-", "n,v2", "v2", "(Vector2(@value 1, @value 1) - @value 2)")

VectorComponent:AddInlineOperator( "*", "v2,n", "v2", "(@value 1 * Vector2(@value 2, @value 2))")
VectorComponent:AddInlineOperator( "*", "n,v", "v2", "(Vector2(@value 1, @value 1) * @value 2)")

VectorComponent:AddInlineOperator( "/", "v2,n", "v2", "(@value 1 / Vector2(@value 2, @value 2))")
VectorComponent:AddInlineOperator( "/", "n,v2", "v2", "(Vector2(@value 1, @value 1) / @value 2)")

/* -----------------------------------------------------------------------------------
	@: Operators
   --- */

VectorComponent:AddInlineOperator( "is", "v2", "b", "(@value 1 ~= Vector2(0, 0))" )
VectorComponent:AddInlineOperator( "not", "v2", "b", "(@value 1 == Vector2(0, 0))" )
VectorComponent:AddInlineOperator( "-", "v2", "v2", "(-@value 1)" )

/* -----------------------------------------------------------------------------------
	@: Casting
   --- */

VectorComponent:AddInlineOperator( "string", "v2", "s", "string.format( \"Vec2( %i, %i )\", @value 1.x, @value 1.y)" )

/* -----------------------------------------------------------------------------------
	@: Assignment
   --- */

Vector2Obj:AddVMOperator( "=", "n,v2", "", function( Context, Trace, MemRef, Value )
   local Prev = Context.Memory[MemRef] or Vector2( 0, 0 )
   
   Context.Memory[MemRef] = Value
   Context.Delta[MemRef] = Prev - Value
   Context.Trigger[MemRef] = Context.Trigger[MemRef] or ( Prev ~= Value )
end )

Vector2Obj:AddInlineOperator( "$", "n", "v2", "(Context.Delta[@value 1] or Vector2(0,0))" )

/* -----------------------------------------------------------------------------------
	@: Constructor
   --- */

VectorComponent:AddInlineFunction( "vec2", "", "v2", "Vector2(0, 0)" )
VectorComponent:AddInlineFunction( "vec2", "n", "v2", "Vector2(@value 1, @value 1)" )
VectorComponent:AddInlineFunction( "vec2", "n,n", "v2", "Vector2(@value 1, @value 2)" )

VectorComponent:AddFunctionHelper( "vec2", "n,n", "Creates a vector2 object" )
VectorComponent:AddFunctionHelper( "vec2", "n", "Creates a vector2 object" )
VectorComponent:AddFunctionHelper( "vec2", "", "Creates a vector2 object" )

VectorComponent:AddInlineFunction( "randVec2", "n,n", "v2", "Vector2( $math.random(@value 1, @value 2), $math.random(@value 1, @value 2) )" )
VectorComponent:AddFunctionHelper( "randVec2", "n,n", "Creates a random vector2 constrained to the given values" )

/* -----------------------------------------------------------------------------------
	@: Accessors
   --- */

--GETTERS
VectorComponent:AddInlineFunction( "getX", "v2:", "n", "@value 1.x" )
VectorComponent:AddFunctionHelper( "getX", "v2:", "Gets the X value of a vector2" )

VectorComponent:AddInlineFunction( "getY", "v2:", "n", "@value 1.y" )
VectorComponent:AddFunctionHelper( "getY", "v2:", "Gets the Y value of a vector2" )

--SETTERS
VectorComponent:AddPreparedFunction( "setX", "v2:n", "", "@value 1.x = @value 2" )
VectorComponent:AddFunctionHelper( "setX", "v2:n", "Sets the X value of a vector2" )

VectorComponent:AddPreparedFunction( "setY", "v2:n", "", "@value 1.y = @value 2" )
VectorComponent:AddFunctionHelper( "setY", "v2:n", "Sets the Y value of a vector2" )

/* --- --------------------------------------------------------------------------------
@: Loops
   --- */

VectorObj:AddPreparedOperator( "for", "v,v,v,?", "", [[
   for x = @value 1.x, @value 2.x, @value 3.x do
      for y = @value 1.y, @value 2.y, @value 3.y do
         for z = @value 1.z, @value 2.z, @value 3.z do
            local i =  Vector(x,y,z) 
            @prepare 4
         end
      end
   end
]] ) 

Vector2Obj:AddPreparedOperator( "for", "v2,v2,v2,?", "", [[
   for x = @value 1.x, @value 2.x, @value 3.x do
      for y = @value 1.y, @value 2.y, @value 3.y do
         local i =  Vector2(x,y) 
         @prepare 4        
      end
   end
]] )