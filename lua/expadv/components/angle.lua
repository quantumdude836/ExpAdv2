/* --- --------------------------------------------------------------------------------
	@: Entity Component
   --- */

local Component = EXPADV.AddComponent( "angle", true )

/* --- --------------------------------------------------------------------------------
	@: Angle Class
   --- */

local AngObject = Component:AddClass( "angle", "a" )

AngObject:DefaultAsLua( Angle(0,0,0) )

/* --- --------------------------------------------------------------------------------
	@: Assignment
   --- */

EXPADV.SharedOperators( )

AngObject:AddVMOperator( "=", "n,a", "", function( Context, Trace, MemRef, Value )
	local Prev = Context.Memory[MemRef] or Angle( 0, 0, 0 )
	
	Context.Memory[MemRef] = Value
	Context.Delta[MemRef] = Prev - Value
	Context.Trigger[MemRef] = Context.Trigger[MemRef] or ( Prev ~= Value )
end )

AngObject:AddInlineOperator( "$", "n", "a", "(Context.Delta[@value 1] or Angle(0,0,0))" )

/* --- --------------------------------------------------------------------------------
	@: Logical and Comparison
   --- */

Component:AddInlineOperator( "==", "a,a", "b", "(@value 1 == @value 2)" )
Component:AddInlineOperator( "!=", "a,a", "b", "(@value 1 ~= @value 2)" )
Component:AddInlineOperator( ">", "a,a", "b", "(@value 1 > @value 2)" )
Component:AddInlineOperator( "<", "a,a", "b", "(@value 1 < @value 2)" )
Component:AddInlineOperator( ">=", "a,a", "b", "(@value 1 >= @value 2)" )
Component:AddInlineOperator( "<=", "a,a", "b", "(@value 1 <= @value 2)" )

/* -----------------------------------------------------------------------------------
	@: Arithmetic
   --- */

Component:AddInlineOperator( "+", "a,a", "a", "(@value 1 + @value 2)" )
Component:AddInlineOperator( "-", "a,a", "a", "(@value 1 - @value 2)" )
Component:AddInlineOperator( "*", "a,a", "a", "(@value 1 * @value 2)" )
Component:AddInlineOperator( "/", "a,a", "a", "(@value 1 / @value 2)" )

/* -----------------------------------------------------------------------------------
	@: Number Arithmetic
   --- */

Component:AddInlineOperator( "+", "a,n", "a", "(@value 1 + Angle(@value 2, @value 2, @value 2))")
Component:AddInlineOperator( "+", "n,a", "a", "(Angle(@value 1, @value 1, @value 1) + @value 2)")

Component:AddInlineOperator( "-", "a,n", "a", "(@value 1 - Angle(@value 2, @value 2, @value 2))")
Component:AddInlineOperator( "-", "n,a", "a", "(Angle(@value 1, @value 1, @value 1) - @value 2)")

Component:AddInlineOperator( "*", "a,n", "a", "(@value 1 * Angle(@value 2, @value 2, @value 2))")
Component:AddInlineOperator( "*", "n,a", "a", "(Angle(@value 1, @value 1, @value 1) * @value 2)")

Component:AddInlineOperator( "/", "a,n", "a", "(@value 1 / Angle(@value 2, @value 2, @value 2))")
Component:AddInlineOperator( "/", "n,a", "a", "(Angle(@value 1, @value 1, @value 1) / @value 2)")

/* -----------------------------------------------------------------------------------
	@: Operators
   --- */

Component:AddInlineOperator( "is", "a", "b", "(@value 1 ~= Angle(0, 0, 0))" )
Component:AddInlineOperator( "not", "a", "b", "(@value 1 == Angle(0, 0, 0))" )
Component:AddInlineOperator( "-", "n", "b", "(-@value 1)" )

/* -----------------------------------------------------------------------------------
	@: Constructor
   --- */

Component:AddInlineFunction( "ang", "", "v", "Angle(0, 0, 0)" )
Component:AddInlineFunction( "ang", "n", "v", "Angle(@value 1, @value 1, @value 1)" )
Component:AddInlineFunction( "ang", "n,n,n", "v", "Angle(@value 1, @value 2, @value 3)" )

Component:AddFunctionHelper( "ang", "n,n,n", "Creates an angle object" )
Component:AddFunctionHelper( "ang", "n", "Creates an angle object" )
Component:AddFunctionHelper( "ang", "", "Creates an angle object" )

Component:AddInlineFunction( "randAng", "n,n", "v", "Angle( $math.random(@value 1, @value 2), $math.random(@value 1, @value 2), $math.random(@value 1, @value 2) )" )
Component:AddFunctionHelper( "randAng", "n,n", "Creates a random angle constrained to the given values" )

/* -----------------------------------------------------------------------------------
	@: Accessors
   --- */

--GETTERS
Component:AddInlineFunction( "getPitch", "a:", "n", "@value 1.p" )
Component:AddFunctionHelper( "getPitch", "a:", "Gets the pitch value of an angle" )

Component:AddInlineFunction( "getYaw", "a:", "n", "@value 1.y" )
Component:AddFunctionHelper( "getYaw", "a:", "Gets the yaw value of an angle" )

Component:AddInlineFunction( "getRoll", "a:", "n", "@value 1.r" )
Component:AddFunctionHelper( "getRoll", "a:", "Gets the roll value of an angle" )

--SETTERS
Component:AddPreparedFunction( "setPitch", "a:n", "", "@value 1.p = @value 2" )
Component:AddFunctionHelper( "setPitch", "a:n", "Sets the pitch value of an angle" )

Component:AddPreparedFunction( "setYaw", "a:n", "", "@value 1.y = @value 2" )
Component:AddFunctionHelper( "setYaw", "a:n", "Sets the yaw value of an angle" )

Component:AddPreparedFunction( "setRoll", "a:n", "", "@value 1.r = @value 2" )
Component:AddFunctionHelper( "setRoll", "a:n", "Sets the roll value of an angle" )

/* -----------------------------------------------------------------------------------
	@: Directions
   --- */

Component:AddInlineFunction( "forward", "a:", "v", "@value 1:Forward( )" )
Component:AddFunctionHelper( "forward", "a:", "Returns a normal vector facing in the direction that the angle points" )

Component:AddInlineFunction( "right", "a:", "v", "@value 1:Right( )" )
Component:AddFunctionHelper( "right", "a:", "Returns a normal vector facing in the direction that points right relative to the angle's direction" )

Component:AddInlineFunction( "up", "a:", "v", "@value 1:Up( )" )
Component:AddFunctionHelper( "up", "a:", "Returns a normal vector facing in the direction that points up relative to the angle's direction" )

/* -----------------------------------------------------------------------------------
	@: Normalize
   --- */

Component:AddPreparedFunction( "normalize", "a:", "a", [[
	@define val = Angle( @value 1.p, @value 1.y, @value 1.r )
	@val:Normalize( )]], "@val" )

Component:AddFunctionHelper( "normalize", "a:", "Normalizes the angles by applying a module with 360 to pitch, yaw and roll" )

/* -----------------------------------------------------------------------------------
	@: Normalize
   --- */

Component:AddPreparedFunction( "rotateAroundAxis", "a:v,n", "a", [[
	@define val = Angle( @value 1.p, @value 1.y, @value 1.r )
	@val:RotateAroundAxis(@value 2, @value 3)]], "@val" )

Component:AddFunctionHelper( "rotateAroundAxis", "a:v,n", "Rotates the angle around the specified axis by the specified degree" )

/* -----------------------------------------------------------------------------------
	@: Snap
   --- */

Component:AddInlineFunction( "snapToPitch", "a:n", "a", [[@value 1@SnapTo("p",@value 2)]] )
Component:AddFunctionHelper( "snapToPitch", "a:n", "Snaps the angle's pitch to nearest interval of degrees" )

Component:AddInlineFunction( "snapToYaw", "a:n", "a", [[@value 1@SnapTo("y",@value 2)]] )
Component:AddFunctionHelper( "snapToYaw", "a:n", "Snaps the angle's yaw to nearest interval of degrees" )

Component:AddInlineFunction( "snapToRoll", "a:n", "a", [[@value 1@SnapTo("r",@value 2)]] )
Component:AddFunctionHelper( "snapToRoll", "a:n", "Snaps the angle's roll to nearest interval of degrees" )
