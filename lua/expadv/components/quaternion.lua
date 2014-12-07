/* --- --------------------------------------------------------------------------------
	@: Quatrion Component
   --- */

require( "quaternion" )

local Component = EXPADV.AddComponent( "quaternion", true )

Component.Author = "Shadowsicon"
Component.Description = "Adds coroutines witch can be yeileded and resumed later."

local Obj = Component:AddClass( "quaternion", "q" )

Obj:StringBuilder( function( Q ) return tostring( Q ) end )
Obj:DefaultAsLua( Quaternion.Zero:Clone() )
Obj:AddAlias( "quat" )

/* --- --------------------------------------------------------------------------------
	@: Operators
   --- */

EXPADV.SharedOperators( )

Obj:AddVMOperator( "=", "n,q", "", function( Context, Trace, MemRef, Value )
   Context.Memory[MemRef] = Value
end )

Component:AddInlineOperator( "+", "q,q", "q", "(@value 1 + @value 2)" )
Component:AddInlineOperator( "+", "n,q", "q", "(@value 1 + @value 2)" )
Component:AddInlineOperator( "+", "q,n", "q", "(@value 1 + @value 2)" )

Component:AddInlineOperator( "-", "q", "q", "(-@value 1)" )
Component:AddInlineOperator( "-", "q,q", "q", "(@value 1 - @value 2)" )
Component:AddInlineOperator( "-", "n,q", "q", "(@value 1 - @value 2)" )
Component:AddInlineOperator( "-", "q,n", "q", "(@value 1 - @value 2)" )

Component:AddInlineOperator( "*", "q,n", "q", "(@value 1 * @value 2)" )
Component:AddInlineOperator( "*", "n,q", "q", "(@value 1 * @value 2)" )

Component:AddInlineOperator( "/", "q,n", "q", "(@value 1 / @value 2)" )

Component:AddInlineOperator( "==", "q,q", "b", "(@value 1 == @value 2)" )
Component:AddInlineOperator( "!=", "q,q", "b", "(@value 1 != @value 2)" )

Component:AddInlineOperator( "^", "n,q", "q", "(@value 1 ^ @value 2)" )
Component:AddInlineOperator( "^", "q,n", "q", "(@value 1 ^ @value 2)" )

Component:AddPreparedOperator( "*", "q,q", "q", [[
	@define AR, AI, AJ, AK = @value 1.r, @value 1.i, @value 1.j, @value 1.k
	@define BR, BI, BJ, BK = @value 2.r, @value 2.i, @value 2.j, @value 2.k

	@define Quat = Quaternion(
		@AR * @BR - @AI * @BI - @AJ * @BJ - @AK * @BK,
		@AR * @BI + @AI * @BR + @AJ * @BK - @AK * @BJ,
		@AR * @BJ + @AJ * @BR + @AK * @BI - @AI * @BK,
		@AR * @BK + @AK * @BR + @AI * @BJ - @AJ * @BI
	)
]], "@Quat" )

Component:AddPreparedOperator( "*", "q,v", "q", [[
	@define AR, AI, AJ, AK = @value 1.r, @value 1.i, @value 1.j, @value 1.k
	@define BI, BJ, BK = @value 2.x, @value 2.y, @value 2.z

	@define Quat = Quaternion(
		-@AI * @BI - @AJ * @BJ - @AK * @BK,
		 @AR * @BI + @AJ * @BK - @AK * @BJ,
		 @AR * @BJ + @AK * @BI - @AI * @BK,
		 @AR * @BK + @AI * @BJ - @AJ * @BI
	)
]], "@Quat" )

Component:AddPreparedOperator( "*", "v,q", "q", [[
	@define AR, AI, AJ, AK = @value 2.r, @value 2.i, @value 2.j, @value 2.k
	@define BI, BJ, BK = @value 1.x, @value 1.y, @value 1.z

	@define Quat = Quaternion(
		-@value 1.i * @BI - @value 1.j * @BJ - @value 1.k * @BK,
		 @value 1.r * @BI + @value 1.j * @BK - @value 1.k * @BJ,
		 @value 1.r * @BJ + @value 1.k * @BI - @value 1.i * @BK,
		 @value 1.r * @BK + @value 1.i * @BJ - @value 1.j * @BI
	)
]], "@Quat" )

Component:AddPreparedOperator( "/", "n,q", "q", [[
	@define AR, AI, AJ, AK = @value 2.r, @value 2.i, @value 2.j, @value 2.k
	@define Div = @value 1R * @value 1R + @value 1I * @value 1I + @value 1J * @value 1J + @value 1K * @value 1K

	@define Quat = Quaternion(
		(@value 1 / @value 1.r) / @Div, 
		(-@value 1 / @value 1.i) / @Div, 
		(-@value 1 / @value 1.j) / @Div, 
		(-@value 1 / @value 1.k) / @Div
	)
]], "@Quat" )

Component:AddPreparedOperator( "/", "q,q", "q", [[
	@define AR, AI, AJ, AK = @value 1.r, @value 1.i, @value 1.j, @value 1.k
	@define BR, BI, BJ, BK = @value 2.r, @value 2.i, @value 2.j, @value 2.k
	@define Div = @BR * @BR + @BI * @BI + @BJ * @BJ + @BK * @BK

	@define Quat = Quaternion(
		( @value 1.r * @BR + @value 1.i * @BI + @value 1.j * @BJ + @value 1.k * @BK) / @Div,
		(-@value 1.r * @BI + @value 1.i * @BR - @value 1.j * @BK + @value 1.k * @BJ) / @Div,
		(-@value 1.r * @BJ + @value 1.j * @BR - @value 1.k * @BI + @value 1.i * @BK) / @Div,
		(-@value 1.r * @BK + @value 1.k * @BR - @value 1.i * @BJ + @value 1.j * @BI) / @Div
	)
]], "@Quat" )

/* --- --------------------------------------------------------------------------------
	@: Build Quat
   --- */

Component:AddInlineFunction( "quat", "", "q", "Quaternion.Zero:Clone()" )
Component:AddInlineFunction( "quat", "n", "q", "Quaternion(@value 1, 0, 0, 0)" )
Component:AddInlineFunction( "quat", "n,n,n,n", "q", "Quaternion(@value 1, @value 2, @value 3, @value 4)" )
Component:AddInlineFunction( "quat", "v", "q", "Quaternion(0, @value 1.x, @value 1.y, @value 1.z)" )

Component:AddInlineFunction("qi", "", "q", "Quaternion(0, 1, 0, 0)" )
Component:AddInlineFunction("qj", "", "q", "Quaternion(0, 0, 1, 0)" )
Component:AddInlineFunction("qk", "", "q", "Quaternion(0, 0, 0, 1)" )

Component:AddInlineFunction("qi", "n", "q", "Quaternion(0, @value 1, 0, 0)" )
Component:AddInlineFunction("qj", "n", "q", "Quaternion(0, 0, @value 1, 0)" )
Component:AddInlineFunction("qk", "n", "q", "Quaternion(0, 0, 0, @value 1)" )

Component:AddInlineFunction( "quat", "a", "q", "Quaternion.Zero:Clone():AngleToQuat(@value 1)" )
Component:AddInlineFunction( "quat", "e", "q", "IsValid(@value 1) and Quaternion.Zero:Clone():AngleToQuat(@value 1:GetAngles()) or Quaternion.Zero:Clone()" )
Component:AddInlineFunction( "quat", "v,v", "q", "Quaternion.Zero:Clone():VecsToQuat(@value 1, @value 2)" )

/* --- --------------------------------------------------------------------------------
	@: Get Quat
   --- */

Component:AddInlineFunction( "real", "q:", "n", "(@value 1.r)" )
Component:AddInlineFunction( "i", "q:", "n", "(@value 1.i)" )
Component:AddInlineFunction( "j", "q:", "n", "(@value 1.j)" )
Component:AddInlineFunction( "k", "q:", "n", "(@value 1.k)" )
Component:AddInlineFunction( "vec", "q", "v", "Vector( @value 1.i, @value 1.j, @value 1.k )" )
Component:AddInlineFunction( "qMod", "q", "q", "( @value 1.r < 0 and Quaternion(-@value 1.r, -@value 1.i, -@value 1.j, -@value 1.k) or @value 1 )" )

Component:AddPreparedFunction( "forward", "q:", "v", [[
	@define A, B, C, D = @value 1.r, @value 1.i, @value 1.j, @value 1.k
	@define E, F = @C * 2, @D * 2
]], "Vector( @value 1 * @value 1 + @B * @B - @C * @C - @D * @D, @E * @B + @F * @value 1, @F * @B - @E * @value 1 )" )

Component:AddPreparedFunction( "right", "q:", "v", [[
	@define A, B, C, D = @value 1.r, @value 1.i, @value 1.j, @value 1.k
	@define E, F, G = @B * 2, @C * 2, @D * 2
]], "Vector( @G * @value 1 - @E * @C, @B * @B - @value 1 * @value 1 + @D * @D - @C * @C, -@E * @value 1 - @F * @D )" )

Component:AddPreparedFunction( "up", "q:", "v", [[
	@define A, B, C, D = @value 1.r, @value 1.i, @value 1.j, @value 1.k
	@define E, F = @B * 2, @C * 2
]], "Vector( @F * @value 1 + @E * @D, @F * @D - @E * @value 1, @value 1 * @value 1 - @B * @B - @C * @C + @D * @D )" )

Component:AddInlineFunction( "abs", "q", "n", "math.sqrt(@value 1.r * @value 1.r + @value 1.i * @value 1.i + @value 1.j * @value 1.j + @value 1.k * @value 1.k)" )

Component:AddPreparedFunction( "inv", "q", "q", [[
	@define Div = @value 1.r * @value 1.r + @value 1.i * @value 1.i + @value 1.j * @value 1.j + @value 1.k * @value 1.k
	@define Quat = @Div == 0 and Quaternion(0, 0, 0, 0) or Quaternion(@value 1.r / @Div, -@value 1.i / @Div, -@value 1.j / @Div, -@value 1.k / @Div)
]], "@Quat" )

Component:AddInlineFunction( "conj", "q", "q", "Quaternion(@value 1.r, -@value 1.i, -@value 1.j, -@value 1.k)" )
Component:AddInlineFunction( "exp", "q", "q", "(@value 1:Exp())" )
Component:AddInlineFunction( "log", "q", "q", "(@value 1:Log())" )

Component:AddInlineFunction( "qRotation", "v,n", "q", "Quaternion.Zero:Clone():RotateQuat(@value 1, @value 2)" )
Component:AddInlineFunction( "qRotation", "v", "q", "Quaternion.Zero:Clone():RotateQuat(@value 1)" )
Component:AddInlineFunction( "toAngle", "q:", "a", "@value 1:QuatToAngle()" )
Component:AddInlineFunction( "slerp", "q,q,n", "q", "Quaternion.Zero:Clone():SlerpQuat(@value 1, @value 2, @value 3)" )

Component:AddPreparedFunction( "rotationAngle", "q", "n", [[
	@define Ret = 0
	@define Square = @value 1.r * @value 1.r + @value 1.i * @value 1.i + @value 1.j * @value 1.j + @value 1.k * @value 1.k
	if @Square then
		@define Root = math.sqrt(@Square)

		@Ret = 2 * math.acos(math.Clamp(@value 1.r / @Root, -1, 1)) * (180 / math.pi)
		if @Ret > 180 then @Ret = @Ret - 360 end
	end
]], "@Ret" )

Component:AddPreparedFunction( "rotationAxis", "q", "v", [[
	@define Ret = Vector(0, 0, 1)
	@define Square = @value 1.i * @value 1.i + @value 1.j * @value 1.j + @value 1.k * @value 1.k
	if @Square then
		@define Root = math.sqrt(@Square)

		@Ret = Vector( @value 1.i / @Root, @value 1.j / @Root, @value 1.k / @Root )
	end
]], "@Ret" )

Component:AddPreparedFunction( "rotationVector", "q", "v", [[
	@define Ret = Vector(0, 0, 0)
	@define Square = @value 1.r * @value 1.r + @value 1.i * @value 1.i + @value 1.j * @value 1.j + @value 1.k * @value 1.k
	@define Max = math.max( @value 1.i * @value 1.i + @value 1.j * @value 1.j + @value 1.k * @value 1.k )
	if @Square and @Max then
		@define Acos = 2 * math.acos(math.Clamp(@value 1.r / math.sqrt(@Square), -1, 1)) * (180 / math.pi)
		if @Acos > 180 then @Acos = @Acos - 360 end
		@Acos = @Acos / math.sqrt(@Max)

		@Ret = Vector( @value 1.i * @Acos, @value 1.j * @Acos, @value 1.k * @Acos )
	end
]], "@Ret" )

/* --- --------------------------------------------------------------------------------
	@: Helper Data
   --- */

Component:AddFunctionHelper( "forward", "q:", "Returns the forward vector of a quaternion." )
Component:AddFunctionHelper( "right", "q:", "Returns the right vector of a quaternion." )
Component:AddFunctionHelper( "up", "q:", "Returns the up vector of a quaternion." )

Component:AddFunctionHelper( "i", "q:", "Returns the I component of the quaternion." )
Component:AddFunctionHelper( "j", "q:", "Returns the J component of a quaternion." )
Component:AddFunctionHelper( "k", "q:", "Returns the K component of a quaternion." )
Component:AddFunctionHelper( "real", "q:", "Returns the R component of a quaternion." )

Component:AddFunctionHelper( "qi", "", "Returns a quaternion with an I component of 1." )
Component:AddFunctionHelper( "qi", "n", "Returns a quaternion with an I component of (number)." )
Component:AddFunctionHelper( "qj", "", "Returns a quaternion with an J component of 1." )
Component:AddFunctionHelper( "qj", "n", "Returns a quaternion with an J component of (number)." )
Component:AddFunctionHelper( "qk", "", "Returns a quaternion with an K component of 1." )
Component:AddFunctionHelper( "qk", "n", "Returns a quaternion with an K component of (number)." )

Component:AddFunctionHelper( "abs", "q", "Returns the magnitude (length) of a quaternion." )
Component:AddFunctionHelper( "conj", "q", "Returns the conjugate of a quaternion." )
Component:AddFunctionHelper( "inv", "q", "Returns the inverse of a quaternion." )
Component:AddFunctionHelper( "log", "q", "Returns the logarithm of a quaternion to base e." )
Component:AddFunctionHelper( "qMod", "q", "Returns the modulus of a quaternion." )

Component:AddFunctionHelper( "toAngle", "q:", "Converts a quaternion to an angle." )
Component:AddFunctionHelper( "slerp", "q,q,n", "Interpolates between two quaternions by a ratio of the given number." )
Component:AddFunctionHelper( "vec", "q", "Creates a vector from a quaternion." )
Component:AddFunctionHelper( "rotationVector", "q", "Returns the rotation vector of a quaternion." )
Component:AddFunctionHelper( "qRotation", "v,n", "Returns a quaternion from a vector, number controls the angle." )
Component:AddFunctionHelper( "qRotation", "v", "Returns a quaternion from a vector, vector components control axis and angle." )

Component:AddFunctionHelper( "quat", "", "Returns an empty quaternion." )
Component:AddFunctionHelper( "quat", "a", "Converts (angle) to a quaternion." )
Component:AddFunctionHelper( "quat", "e", "Converts the angles of (entity) to a quaternion." )
Component:AddFunctionHelper( "quat", "n,n,n,n", "Creates a quaternion nR nI nJ nK." )
Component:AddFunctionHelper( "quat", "n", "Creates a quaternion with an R component of (number)." )
Component:AddFunctionHelper( "quat", "v,v", "Creates a quaternion using (vector forward) and (vector up)." )
Component:AddFunctionHelper( "quat", "v", "Converts (vector) to a quaternion." )
