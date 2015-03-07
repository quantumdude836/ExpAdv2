/* --- --------------------------------------------------------------------------------
	@: Constraint Core Component
	@: Author: shadowscion, Omicron, Sparky
   --- */

local Component = EXPADV.AddComponent( "constraintcore", true )

Component.Author = "shadowscion, Omicron, Sparky"
Component.Description = "Allows creation of contraints."


/* --- --------------------------------------------------------------------------------
	@: Util
   --- */

/*function ConstraintCore.AddConstraint( Constraint, Context )
	local P = Context.Player

	-- undo.Create( Constraint:Name() ) // Any easy way to get the constraint type?
	undo.Create( "Lemongate Constraint" )
		undo.AddEntity( Constraint )
		undo.SetPlayer( P )
	undo.Finish()

	P:AddCleanup( "constraints", Constraint )
end*/

/* --- --------------------------------------------------------------------------------
	@: Constraint removal
   --- */

EXPADV.ServerOperators()

Component:AddPreparedFunction("removeAllConstraints", "e:", "", [[
if @value 1:IsValid() and EXPADV.PPCheck(Context,@value 1) then
	$constraint.RemoveAll( @value 1 )
end]] )
Component:AddFunctionHelper( "removeAllConstraints", "e:", "Removes all constraints.")

Component:AddPreparedFunction("removeConstraints", "e:s", "", [[
if @value 1:IsValid() and EXPADV.PPCheck(Context,@value 1) then
	$constraint.RemoveConstraints( @value 1, @value 2 )
end]] )
Component:AddFunctionHelper( "removeConstraints", "e:s", "Removes specific constraints. Weld Axis Ballsocket etc.")

/* --- --------------------------------------------------------------------------------
	@: Constraints
   --- */

----------------------------
-- Weld
----------------------------
Component:AddPreparedFunction("weldTo", "e:e,n,b", "", [[
if @value 1:IsValid() and EXPADV.PPCheck(Context,@value 1) then
	if (@value 2:IsValid() and EXPADV.PPCheck(Context,@value 2)) or @value 2:IsWorld() then
		$constraint.Weld( @value 1, @value 2, 0, 0, @value 3, @value 4 )
	end
end]] )
Component:AddFunctionHelper( "weldTo", "e:e,n,b", "Entity 1, Entity 2, Forcelimit, Nocollide")

----------------------------
-- Axis
----------------------------
Component:AddPreparedFunction("axisTo", "e:e,v,v,n,n,n,n,v", "", [[
if @value 1:IsValid() and EXPADV.PPCheck(Context,@value 1) then
	if (@value 2:IsValid() and EXPADV.PPCheck(Context,@value 2)) or @value 2:IsWorld() then
		$constraint.Axis( @value 1, @value 2, 0, 0, @value 3, @value 4, @value 5, @value 6, @value 7, @value 8, @value 9 )
	end
end]] )
Component:AddFunctionHelper( "axisTo", "e:e,v,v,n,n,n,n,v", "Entity 1, Entity 2, Position 1, Position 2, Forcelimit, Torquelimit, Friction, Nocollide, Axis")

----------------------------
-- Ballsocket
----------------------------
Component:AddPreparedFunction("ballsocketTo", "e:e,v,n,n,n", "", [[
if @value 1:IsValid() and EXPADV.PPCheck(Context,@value 1) then
	if (@value 2:IsValid() and EXPADV.PPCheck(Context,@value 2)) or @value 2:IsWorld() then
		$constraint.Ballsocket( @value 1, @value 2, 0, 0, @value 3, @value 4, @value 5, @value 6 )
	end
end]] )
Component:AddFunctionHelper( "ballsocketTo", "e:e,v,n,n,n", "Entity 1, Entity 2, Position, Forcelimit, Torquelimit, Nocollide")

----------------------------
-- Advanced Ballsocket
----------------------------
Component:AddPreparedFunction("advBallsocketTo", "e:e,v,v,n,n,v,v,v,n,n", "", [[
if @value 1:IsValid() and EXPADV.PPCheck(Context,@value 1) then
	if (@value 2:IsValid() and EXPADV.PPCheck(Context,@value 2)) or @value 2:IsWorld() then
		$constraint.AdvBallsocket( @value 1, @value 2, 0, 0, @value 3, @value 4, @value 5, @value 6, @value 7.x, @value 7.y, @value 7.z, @value 8.x, @value 8.y, @value 8.x, @value 9.x, @value 9.y, @value 9.z, @value 10, @value 11 )
	end
end]] )
Component:AddFunctionHelper( "advBallsocketTo", "e:e,v,v,n,n,v,v,v,n,n", "Entity 1, Entity 2, Position 1, Position 2, Forcelimit, Torquelimit, MinAngle, MaxAngle, Friction, RotationOnly, Nocollide")

----------------------------
-- Rope
----------------------------			
Component:AddPreparedFunction("ropeTo", "e:e,v,v,n,n,n,n,s,b", "", [[
if @value 1:IsValid() and EXPADV.PPCheck(Context,@value 1) then
	if (@value 2:IsValid() and EXPADV.PPCheck(Context,@value 2)) or @value 2:IsWorld() then
		@define Mat = @value 9 == "" and "cable/rope" or @value 9
		$constraint.Rope( @value 1, @value 2, 0, 0, @value 3, @value 4, @value 5, @value 6, @value 7, @value 8, @Mat, @value 10 )
	end
end]] )
Component:AddFunctionHelper( "ropeTo", "e:e,v,v,n,n,n,n,s,b", "Entity 1, Entity 2, Position 1, Position 2, Length, AddLength, Forcelimit, Width, Material, Rigid")

----------------------------
-- Elastic
----------------------------
Component:AddPreparedFunction("elasticTo", "e:e,v,v,n,n,n,s,n,b", "", [[
if @value 1:IsValid() and EXPADV.PPCheck(Context,@value 1) then
	if (@value 2:IsValid() and EXPADV.PPCheck(Context,@value 2)) or @value 2:IsWorld() then
		@define Mat = @value 8 == "" and "cable/rope" or @value 8
		$constraint.Elastic( @value 1, @value 2, 0, 0, @value 3, @value 4, @value 5, @value 6, @value 7, @Mat, @value 9, @value 10 )
	end
end]] )
Component:AddFunctionHelper( "elasticTo", "e:e,v,v,n,n,n,s,n,b", "Entity 1, Entity 2, Position 1, Position 2, Constant, Damping, RDamping, Material, Width, Stretchonly")

----------------------------
-- Slider
----------------------------
Component:AddPreparedFunction("sliderTo", "e:e,v,v,n", "", [[
if @value 1:IsValid() and EXPADV.PPCheck(Context,@value 1) then
	if (@value 2:IsValid() and EXPADV.PPCheck(Context,@value 2)) or @value 2:IsWorld() then
		$constraint.Slider( @value 1, @value 2, 0, 0, @value 3, @value 4, @value 5 )
	end
end]] )
Component:AddFunctionHelper( "sliderTo", "e:e,v,v,n", "Entity 1, Entity 2, Position 1, Position 2, Width")

----------------------------
-- NoCollide
----------------------------
Component:AddPreparedFunction("noCollideAll", "e:b", "", [[
if @value 1:IsValid() and EXPADV.PPCheck(Context,@value 1) then
	@value 1:SetCollisionGroup( @value 2 and $COLLISION_GROUP_WORLD or $COLLISION_GROUP_NONE )
end]] )
Component:AddFunctionHelper( "noCollideAll", "e:b", "Disable an entity's collisions with everything except the world")

Component:AddPreparedFunction("noCollideTo", "e:e", "", [[
if @value 1:IsValid() and EXPADV.PPCheck(Context,@value 1) then
	if @value 2:IsValid() and EXPADV.PPCheck(Context,@value 2) then
		$constraint.NoCollide( @value 1, @value 2, 0, 0 )
	end
end]] )
Component:AddFunctionHelper( "noCollideTo", "e:e", "Nocollide an entity to another")
