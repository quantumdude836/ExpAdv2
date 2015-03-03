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

Component:AddPreparedFunction("removeConstraint", "e:s", "", [[
if @value 1:IsValid() and EXPADV.PPCheck(Context,@value 1) then
	$constraint.RemoveConstraints( @value 1, @value 2 )
end]] )

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

----------------------------
-- Axis
----------------------------
Component:AddPreparedFunction("axisTo", "e:e,v,v,n,n,n,n,v", "", [[
if @value 1:IsValid() and EXPADV.PPCheck(Context,@value 1) then
	if (@value 2:IsValid() and EXPADV.PPCheck(Context,@value 2)) or @value 2:IsWorld() then
		$constraint.Axis( @value 1, @value 2, 0, 0, @value 3, @value 4, @value 5, @value 6, @value 7, @value 8, @value 9 )
	end
end]] )

----------------------------
-- Ballsocket
----------------------------
Component:AddPreparedFunction("ballsocketTo", "e:e,v,n,n,n", "", [[
if @value 1:IsValid() and EXPADV.PPCheck(Context,@value 1) then
	if (@value 2:IsValid() and EXPADV.PPCheck(Context,@value 2)) or @value 2:IsWorld() then
		$constraint.Ballsocket( @value 1, @value 2, 0, 0, @value 3, @value 4, @value 5, @value 6 )
	end
end]] )

----------------------------
-- Advanced Ballsocket
----------------------------
Component:AddPreparedFunction("advBallsocketTo", "e:e,v,v,n,n,v,v,v,n", "", [[
if @value 1:IsValid() and EXPADV.PPCheck(Context,@value 1) then
	if (@value 2:IsValid() and EXPADV.PPCheck(Context,@value 2)) or @value 2:IsWorld() then
		$constraint.AdvBallsocket( @value 1, @value 2, 0, 0, @value 3, @value 4, @value 5, @value 6, @value 7.x, @value 7.y, @value 7.z, @value 8.x, @value 8.y, @value 8.x, @value 9.x, @value 9.y, @value 9.z, @value 10, 0 )
	end
end]] )

----------------------------
-- Rope
----------------------------			
Component:AddPreparedFunction("ropeTo", "e:e,v,v,n,n,n,n,s,b", "", [[
if @value 1:IsValid() and EXPADV.PPCheck(Context,@value 1) then
	if (@value 2:IsValid() and EXPADV.PPCheck(Context,@value 2)) or @value 2:IsWorld() then
		@define Mat = @value 9 == "" and "cable/rope" or @value 9
		$constraint.Rope( @value 1, @value 2, 0, 0, @value 3, @value 4, @value 5, @value 6, @value 7, @value 8, %Mat, @value 10 )
	end
end]] )

----------------------------
-- Elastic
----------------------------
Component:AddPreparedFunction("elasticTo", "e:e,v,v,n,n,n,s,n,b", "", [[
if @value 1:IsValid() and EXPADV.PPCheck(Context,@value 1) then
	if (@value 2:IsValid() and EXPADV.PPCheck(Context,@value 2)) or @value 2:IsWorld() then
		@define Mat = @value 8 == "" and "cable/rope" or @value 8
		$constraint.Elastic( @value 1, @value 2, 0, 0, @value 3, @value 4, @value 5, @value 6, @value 7, %Mat, @value 9, @value 10 )
	end
end]] )

----------------------------
-- Slider
----------------------------
Component:AddPreparedFunction("sliderTo", "e:e,v,v,n", "", [[
if @value 1:IsValid() and EXPADV.PPCheck(Context,@value 1) then
	if (@value 2:IsValid() and EXPADV.PPCheck(Context,@value 2)) or @value 2:IsWorld() then
		$constraint.Slider( @value 1, @value 2, 0, 0, @value 3, @value 4, @value 5 )
	end
end]] )

----------------------------
-- NoCollide
----------------------------
Component:AddPreparedFunction("noCollideAll", "e:b", "", [[
if @value 1:IsValid() and EXPADV.PPCheck(Context,@value 1) then
	@value 1:SetCollisionGroup( @value 2 and $COLLISION_GROUP_WORLD or $COLLISION_GROUP_NONE )
end]] )

Component:AddPreparedFunction("noCollideTo", "e:e", "", [[
if @value 1:IsValid() and EXPADV.PPCheck(Context,@value 1) then
	if @value 2:IsValid() and EXPADV.PPCheck(Context,@value 2) then
		$constraint.NoCollide( @value 1, @value 2, 0, 0 )
	end
end]] )
