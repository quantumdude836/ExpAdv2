/* --- --------------------------------------------------------------------------------
	@: Entity Component
	@: Author: RipMax
   --- */

local Component = EXPADV.AddComponent( "entity", true )

/* --- --------------------------------------------------------------------------------
	@: Entity Class
   --- */

local EntObject = Component:AddClass( "entity", "e" )

EntObject:DefaultAsLua( Entity(0) )

/* --- --------------------------------------------------------------------------------
	@: Wire Support
   --- */

if WireLib then
	EntObject:WireInput( "ENTITY" )
	EntObject:WireOutput( "ENTITY" )
end

/* --- --------------------------------------------------------------------------------
	@: Logical and Comparison
   --- */

EXPADV.SharedOperators( )

Component:AddInlineOperator( "==", "e,e", "b", "(@value 1 == @value 2)" )
Component:AddInlineOperator( "!=", "e,e", "b", "(@value 1 ~= @value 2)" )

/* --- --------------------------------------------------------------------------------
	@: Operators
   --- */

Component:AddInlineOperator( "is", "e", "b", "(@value 1 ~= Entity(0))" )
Component:AddInlineOperator( "not", "e", "b", "(@value 1 == Entity(0))" )

/* --- --------------------------------------------------------------------------------
	@: Casting
   --- */

Component:AddInlineOperator( "string", "e", "s", "string.format( \"Entity[&i][&i]\", @value 1:EntIndex(), @value 1:GetClass())" )

/* --- --------------------------------------------------------------------------------
	@: Assignment
   --- */

EntObject:AddVMOperator( "=", "n,e", "", function( Context, Trace, MemRef, Value )
	local Prev = Context.Memory[MemRef]
	Context.Memory[MemRef] = Value
	Context.Trigger[MemRef] = Context.Trigger[MemRef] or ( Prev ~= Value )
end )


/* --- --------------------------------------------------------------------------------
	@: Constructor
   --- */

Component:AddInlineFunction( "entity", "", "e", "Context.entity" )
Component:AddInlineFunction( "entity", "n", "e", "Entity(@value 1)" )

Component:AddFunctionHelper( "entity", "", "Returns the chip the code is executing in." )
Component:AddFunctionHelper( "entity", ":n", "Returns the entity of the given index." )

/* --- --------------------------------------------------------------------------------
	@: Accessors Get
   --- */

Component:AddInlineFunction( "isValid", "e:", "b", "@value 1:IsValid()")
Component:AddFunctionHelper( "isValid", "e:", "Returns if the given entity is valid.")

Component:AddInlineFunction( "validPhysics", "e:", "b", "@value 1:GetPhysicsObject():IsValid() && @value 1:GetMoveType == MOVETYPE_VPHYSICS")
Component:AddFunctionHelper( "validPhysics", "e:", "Returns if the given entity has valid physics.")

Component:AddInlineFunction( "pos", "e:", "v", "(@value 1:IsValid() and @value 1:GetPos() or Vector(0,0,0))")
Component:AddFunctionHelper( "pos", "e:", "Gets the position of the given entity.")

Component:AddInlineFunction( "angle", "e:", "a", "(@value 1:IsValid() and @value 1:GetAngles() or Angle(0,0,0))")
Component:AddFunctionHelper( "angle", "e:", "Gets the angle of the given entity.")

Component:AddInlineFunction( "forward", "e:", "v", "(@value 1:IsValid() and @value 1:GetForward() or Vector(0,0,0))")
Component:AddFunctionHelper( "forward", "e:", "Gets the forward vector of the given entity.")

Component:AddInlineFunction( "right", "e:", "v", "(@value 1:IsValid() and @value 1:GetRight() or Vector(0,0,0))")
Component:AddFunctionHelper( "right", "e:", "Gets the right-facing vector of the given entity.")

Component:AddInlineFunction( "up", "e:", "v", "(@value 1:IsValid() and @value 1:GetUp() or Vector(0,0,0)))")
Component:AddFunctionHelper( "up", "e:", "Gets the upwards vector of the given entity.")

Component:AddInlineFunction( "class", "e:", "s", "(@value 1:IsValid() and @value 1:GetClass() or \"worldspawn\")")
Component:AddFunctionHelper( "class", "e:", "Gets the class of the given entity.")

Component:AddInlineFunction( "name", "e:", "s", "(@value 1:IsValid() and @value 1:Name() or \"\")")
Component:AddFunctionHelper( "name", "e:", "Gets the name of the given entity.")

Component:AddInlineFunction( "index", "e:", "n", "(@value 1:IsValid() and @value 1:EntIndex() or 0)")
Component:AddFunctionHelper( "index", "e:", "Gets the index of the given entity.")

Component:AddInlineFunction( "model", "e:", "s", "(@value 1:IsValid() and @value 1:GetModel() or \"\")")
Component:AddFunctionHelper( "model", "e:", "Gets the model of the given entity.")

Component:AddInlineFunction( "material", "e:", "s", "(@value 1:IsValid() and @value 1:GetMaterial() or \"\")")
Component:AddFunctionHelper( "material", "e:", "Gets the material of the given entity.")

Component:AddInlineFunction( "physProp", "e:", "s", "(@value 1:IsValid() and @value 1:GetPhysicsObject():GetMaterial() or \"\")")
Component:AddFunctionHelper( "physProp", "e:", "Gets the physical properties of the given entity.")

Component:AddInlineFunction( "getColor", "e:", "c", "(@value 1:IsValid() and @value 1:GetColor() or Color(255,255,255,255))")
Component:AddFunctionHelper( "getColor", "e:", "Gets the color of the given entity.")

Component:AddInlineFunction( "getColour", "e:", "c", "(@value 1:IsValid() and @value 1:GetColor() or Color(255,255,255,255))") -- Because why not :) ?
Component:AddFunctionHelper( "getColour", "e:", "Gets the colour of the given entity.")

Component:AddInlineFunction( "owner", "e:", "e", "(@value 1:IsValid() and EXPADV.GetOwner(@value 1) or Context.player)")
Component:AddFunctionHelper( "owner", "e:", "Gets the owner of the given entity.")

Component:AddInlineFunction( "boxCenter", "e:", "v", "((@value 1:IsValid() && @value 1:GetPhysicsObject():IsValid()) and @value 1:OBBCenter() or Vector(0,0,0))")
Component:AddFunctionHelper( "boxCenter", "e:", "Gets the collision bounding size for the given entity.")

Component:AddInlineFunction( "boxSize", "e:", "v", "((@value 1:IsValid() && @value 1:GetPhysicsObject():IsValid()) and (@value 1:OBBMaxs() - @value 1:OBBMins()) or Vector(0,0,0))")
Component:AddFunctionHelper( "boxSize", "e:", "Gets the collision bounding size for the given entity.")

Component:AddInlineFunction( "boxMax", "e:", "v", "((@value 1:IsValid() && @value 1:GetPhysicsObject():IsValid()) and @value 1:OBBMaxs() or Vector(0,0,0))")
Component:AddFunctionHelper( "boxMax", "e:", "Gets the collision bounding max size for the given entity.")

Component:AddInlineFunction( "boxMin", "e:", "v", "((@value 1:IsValid() && @value 1:GetPhysicsObject():IsValid()) and @value 1:OBBMins() or Vector(0,0,0))")
Component:AddFunctionHelper( "boxMin", "e:", "Gets the collision bounding min size for the given entity.")

/* --- --------------------------------------------------------------------------------
	@: Accessors Set
   --- */

EXPADV.ServerOperators()

Component:AddPreparedFunction( "setPos", "e:v", "", "if(IsValid(@value 1) && EXPADV.PPCheck(@value 1,Context.player)) then @value 1:SetPos(@value 2) end")
Component:AddFunctionHelper( "setPos", "e:v", "Sets the position of the given entity.")

Component:AddPreparedFunction( "setAng", "e:a", "", "if(IsValid(@value 1) && EXPADV.PPCheck(@value 1,Context.player)) then @value 1:SetAngles(@value 2) end")
Component:AddFunctionHelper( "setAng", "e:a", "Sets the angle of the given entity.")

Component:AddPreparedFunction( "setModel", "e:s", "", "if(IsValid(@value 1) && EXPADV.PPCheck(@value 1,Context.player)) then @value 1:SetModel(Model(@value 2)) end")
Component:AddFunctionHelper( "setModel", "e:s", "Sets the model of the given entity.")

Component:AddPreparedFunction( "setMaterial", "e:s", "", "if(IsValid(@value 1) && EXPADV.PPCheck(@value 1,Context.player)) then @value 1:SetMaterial(@value 2) end")
Component:AddFunctionHelper( "setMaterial", "e:s", "Sets the material of the given entity.")

Component:AddPreparedFunction( "setPhysProp", "e:s", "", "if(IsValid(@value 1) && EXPADV.PPCheck(@value 1,Context.player)) then @value 1:GetPhysicsObject():SetMaterial(@value 2) end")
Component:AddFunctionHelper( "setPhysProp", "e:s", "Sets the physical properties of the given entity.")

Component:AddPreparedFunction( "setColor", "e:c", "", "if(IsValid(@value 1) && EXPADV.PPCheck(@value 1,Context.player)) then @value 1:SetColor(@value 2) end")
Component:AddFunctionHelper( "setColor", "e:c", "Sets the color of the given entity.")

Component:AddPreparedFunction( "setColour", "e:c", "", "if(IsValid(@value 1) && EXPADV.PPCheck(@value 1,Context.player)) then @value 1:SetColor(@value 2) end") -- Because why not :) ?
Component:AddFunctionHelper( "setColour", "e:c", "Sets the colour of the given entity.")

/* --- --------------------------------------------------------------------------------
	@: VEHICLES
   --- */

EXPADV.SharedOperators()

Component:AddInlineFunction( "driver", "e:", "ply", "((@value 1:IsValid() && @value 1:IsVehicle() && @value 1:GetDriver():IsValid()) and @value 1:GetDriver() or Entity(0))")
Component:AddFunctionHelper( "driver", "e:", "Gets the driver of the given vehicle.")

Component:AddInlineFunction( "passenger", "e:", "ply", "((@value 1:IsValid() && @value 1:IsVehicle() && @value 1:GetPassenger(0):IsValid()) and @value 1:GetPassenger(0) or Entity(0))")
Component:AddFunctionHelper( "passenger", "e:", "Gets the passenger of the given vehicle.")

EXPADV.ServerOperators()

Component:AddPreparedFunction( "lockPod", "e:", "", 
[[if(@value 1:IsValid() && EXPADV.PPCheck(@value 1,Context.player) && @value 1:IsVehicle()) then
	if(@value 2) then 
		this:Fire("Lock","",0)
	else
		this:Fire("Unlock","",0)
	end
end]])

Component:AddFunctionHelper( "lockPod", "e:", "Locks the given vehicle.")

Component:AddPreparedFunction( "ejectPod", "e:", "", 
[[if(@value 1:IsValid() && EXPADV.PPCheck(@value 1,Context.player) && @value 1:IsVehicle() && @value 1:GetDriver():IsValid()) then
	@value 1:GetDriver():ExitVehicle()
end]])

Component:AddFunctionHelper( "lockPod", "e:", "Ejects the driver from the given vehicle.")

Component:AddPreparedFunction( "killPod", "e:", "", 
[[if(@value 1:IsValid() && EXPADV.PPCheck(@value 1,Context.player) && @value 1:IsVehicle() && @value 1:GetDriver():IsValid()) then
	@value 1:GetDriver():Kill()
end]])

Component:AddFunctionHelper( "killPod", "e:", "Kills the driver of the given vehicle.")

/* --- --------------------------------------------------------------------------------
	@: Physics Geters
   --- */

EXPADV.SharedOperators()

Component:AddInlineFunction( "mass", "e:", "e", "((@value 1:IsValid() && @value 1:GetPhysicsObject():IsValid() && @value 1:GetMoveType == MOVETYPE_VPHYSICS) and @value 1:GetPhysicsObject():GetMass() or 0)")
Component:AddFunctionHelper( "mass", "e:", "Returns the mass of the given entity.")

Component:AddInlineFunction( "massCenter", "e:", "v", "((@value 1:IsValid() && @value 1:GetPhysicsObject():IsValid() && @value 1:GetMoveType == MOVETYPE_VPHYSICS) and @value 1:LocalToWorld(@value 1:GetPhysicsObject():GetMassCenter()) or Vector(0,0,0))")
Component:AddFunctionHelper( "massCenter", "e:", "Returns the center of mass of the given entity.")

Component:AddInlineFunction( "massCenterL", "e:", "v", "((@value 1:IsValid() && @value 1:GetPhysicsObject():IsValid() && @value 1:GetMoveType == MOVETYPE_VPHYSICS) and @value 1:GetPhysicsObject():GetMassCenter() or Vector(0,0,0))")
Component:AddFunctionHelper( "massCenterL", "e:", "Returns the local center of mass of the given entity.")

Component:AddInlineFunction( "volume", "e:", "n", "((@value 1:IsValid() && @value 1:GetPhysicsObject():IsValid() && @value 1:GetMoveType == MOVETYPE_VPHYSICS) and @value 1:GetPhysicsObject():GetVolume() or 0)")
Component:AddFunctionHelper( "volume", "e:", "Returns the volume of the given entity.")

Component:AddInlineFunction( "isfrozen", "e:", "b", "((@value 1:IsValid() && @value 1:GetPhysicsObject():IsValid() && @value 1:GetMoveType == MOVETYPE_VPHYSICS) and (@value 1:GetPhysicsObject():IsMoveable() == false) or false)")
Component:AddFunctionHelper( "isfrozen", "e:", "Returns if the given entity is frozen.")

Component:AddInlineFunction( "inertia", "e:", "v", "((@value 1:IsValid() && @value 1:GetPhysicsObject():IsValid() && @value 1:GetMoveType == MOVETYPE_VPHYSICS) and @value 1:GetPhysicsObject():GetInertia() or Vector(0,0,0))")
Component:AddFunctionHelper( "inertia", "e:", "Returns the inertia of the given entity.")

Component:AddInlineFunction( "vel", "e:", "v", "(@value 1:IsValid() and @value 1:GetVelocity() or Vector(0,0,0))")
Component:AddFunctionHelper( "vel", "e:", "Returns the velocity of the given entity.")

Component:AddInlineFunction( "velL", "e:", "v", "(@value 1:IsValid() and (@value 1:WorldToLocal(@value 1:GetVelocity() + @value 1:GetPos())) or Vector(0,0,0))")
Component:AddFunctionHelper( "velL", "e:", "Returns the local velocity of the given entity.")

Component:AddInlineFunction( "angVel", "e:", "a",
[[if(@value 1:IsValid() && @value 1:GetPhysicsObject():IsValid() && @value 1:GetMoveType == MOVETYPE_VPHYSICS) then
	@define vel = @value 1:GetPhysicsObject():GetAngleVelocity()
	Angle(@vel.y, @vel.z, @vel.x)
end]])

Component:AddFunctionHelper( "angVel", "e:", "Returns the angular velocity of the given entity.")

Component:AddInlineFunction( "angVelVector", "e:", "a","((@value 1:IsValid() && @value 1:GetPhysicsObject():IsValid() && @value 1:GetMoveType == MOVETYPE_VPHYSICS) and @value 1:GetPhysicsObject():GetAngleVelocity() or Vector(0,0,0))")
Component:AddFunctionHelper( "angVelVector", "e:", "Returns the angular velocity of the given entity as a vector.")

Component:AddInlineFunction( "radius", "e:", "n","(@value 1:IsValid() and @value 1:BoundingRadius() or 0)")
Component:AddFunctionHelper( "radius", "e:", "Returns the bounding radius of the given entity.")

/* --- --------------------------------------------------------------------------------
	@: Physics Seters
   --- */

EXPADV.ServerOperators()

Component:AddPreparedFunction( "setMass", "e:n", "","if(@value 1:IsValid() && EXPADV.PPCheck(@value 1, Context.player) && @value 1:GetPhysicsObject():IsValid() && @value 1:GetMoveType() == MOVETYPE_VPHYSICS then @value 1:GetPhysicsObject():SetMass(@value 2 or 0) end")
Component:AddFunctionHelper( "setMass", "e:n", "Sets the mass of the given entity.")

Component:AddPreparedFunction( "applyForce", "e:v", "",
[[if(@value 1:IsValid() && EXPADV.PPCheck(@value 1, Context.player) && @value 1:GetPhysicsObject():IsValid() && @value 1:GetMoveType == MOVETYPE_VPHYSICS) then
	if(@value 2 < Vector(math.huge, math.huge, math.huge) && -Vector(math.huge, math.huge, math.huge) < @value 2) then
		@value 1:GetPhysicsObject():ApplyForceCenter(@value 2)
	end
end]])

Component:AddFunctionHelper( "applyForce", "e:v", "Applies a vector of force on the given entity.")

Component:AddPreparedFunction( "applyOffsetForce", "e:v,v", "",
[[if(@value 1:IsValid() && EXPADV.PPCheck(@value 1, Context.player) && @value 1:GetPhysicsObject():IsValid() && @value 1:GetMoveType == MOVETYPE_VPHYSICS) then
	if(@value 2 < Vector(math.huge, math.huge, math.huge) && -Vector(math.huge, math.huge, math.huge) < @value 2 && @value 3 < Vector(math.huge, math.huge, math.huge) && -Vector(math.huge, math.huge, math.huge) < @value 3) then
		@value 1:GetPhysicsObject():ApplyForceOffset(@value 2, @value 3)
	end
end]])

Component:AddFunctionHelper( "applyForceOffset", "e:v,v", "Applies an offset vector of force on the given entity.")

Component:AddPreparedFunction( "applyAngForce", "e:a", "",
[[
if(@value 1:IsValid() && EXPADV.PPCheck(@value 1, Context.player) && @value 1:GetPhysicsObject():IsValid() && @value 1:GetMoveType == MOVETYPE_VPHYSICS) then
	if(@value 2 < Angle(math.huge, math.huge, math.huge) && -Angle(math.huge, math.huge, math.huge) < @value 2) then
		if(@value 2.p != 0 || @value 2.y != 0 || @value 2.r != 0) then
			@define phys = @value 1:GetPhysicsObject()
			
			@define up = @value 1:GetUp()
			@define left = @value 1:GetRight() * -1
			@define forward = @value 1:GetForward()
			
			if(@value 2.p ~= 0) then
				@define pitch = @up * (@value 2.p * 0.5)
				@phys:ApplyForceOffset( @forward, @pitch )
				@phys:ApplyForceOffset( @forward * -1, @pitch * -1 )
			end

			-- apply yaw force
			if(@value 2.y ~= 0) then
				@define yaw = forward * (@value 2.y * 0.5)
				@phys:ApplyForceOffset( @left, @yaw )
				@phys:ApplyForceOffset( @left * -1, @yaw * -1 )
			end

			-- apply roll force
			if(@value 2.r ~= 0) then
				@define roll = left * (@value 2.r * 0.5)
				@phys:ApplyForceOffset( @up, @roll )
				@phys:ApplyForceOffset( @up * -1, @roll * -1 )
			end
		end
	end
end
]])

Component:AddFunctionHelper( "applyAngForce", "e:a", "Applies torque to the given entity depending on the given angle")

/* --- --------------------------------------------------------------------------------
	@: Misc
   --- */

EXPADV.SharedOperators()

Component:AddInlineFunction( "isPlayerHolding", "e:", "b", "(@value 1:IsValid() and @value 1:IsPlayerHolding() or false)")
Component:AddFunctionHelper( "isPlayerHolding", "e:", "Returns if the entity is being held by the player.")

Component:AddInlineFunction( "isOnFire", "e:", "b", "(@value 1:IsValid() and @value 1:IsOnFire() or false)")
Component:AddFunctionHelper( "isOnFire", "e:", "Returns if the entity is on fire.")

Component:AddInlineFunction( "isWeapon", "e:", "b", "(@value 1:IsValid() and @value 1:IsWeapon() or false)")
Component:AddFunctionHelper( "isWeapon", "e:", "Returns if the entity is a weapon.")

Component:AddInlineFunction( "health", "e:", "n", "(@value 1:IsValid() and @value 1:Health() or 0)")
Component:AddFunctionHelper( "health", "e:", "Returns the health of the entity.")

Component:AddPreparedFunction( "elevation", "e:v", "n", [[
	if(IsValid(@value 1)) then
		@define pos = this:WorldToLocal(@value 2)
		@pos = (180 / math.pi) * math.asin(@pos.z / @pos:Length())
	end
]], "(@pos or 0)" )
Component:AddFunctionHelper( "elevation", "e:v", "Returns the elevation between the two given points" )

Component:AddPreparedFunction( "bearing", "e:v", "n", [[
	if(IsValid(@value 1)) then
		@define pos = this:WorldToLocal(@value 2)
		@pos = (180 / math.pi) * -math.atan2(@pos.y, @pos.x)
	end
]], "(@pos or 0)" )
Component:AddFunctionHelper( "bearing", "e:v", "Returns the bearing between the two given points")

Component:AddPreparedFunction( "heading", "e:v", "a", [[
	if(IsValid(@value 1)) then
		@define pos = this:WorldToLocal(@value 2)
	
		@define bearing = (180 / math.pi) * -math.atan2(@pos.y, @pos.x)
		@define elevation = (180 / math.pi) * math.asin(@pos.z / @pos:Length())
	
		@define ang = Angle(@elevation, @bearing, 0)
	end
]], "(@ang or Angle(0,0,0))" )
Component:AddFunctionHelper( "heading", "e:v", "Returns the heading angle between the two given points")

/* --- --------------------------------------------------------------------------------
	@: Entity Events
   --- */

EXPADV.ServerEvents( )
Component:AddEvent( "onKill", "e,e,e", "" )
Component:AddEvent( "onDamage", "e,e,n,v", "" )
Component:AddEvent( "propBreak", "e,e", "" )

/* --- --------------------------------------------------------------------------------
	@: Server Hooks
   --- */

if SERVER then

   hook.Add( "PlayerDeath", "Expav.Event", function( Killed, Inflictor, Attacker )
		Attacker = Attacker or Entity( 0 )
		EXPADV.CallEvent( "onKill", Killed, Attacker, Inflictor or Attacker )
	end)

	hook.Add( "OnNPCKilled", "Expav.Event", function( Killed, Attacker, Inflictor )
		Attacker = Attacker or Entity( 0 )
		EXPADV.CallEvent( "onKill", Killed, Attacker, Inflictor or Attacker )
	end)

	hook.Add("EntityTakeDamage", "Expav.Event", function( Ent, Damage )
		local Attacker = Damage:GetAttacker( ) or Entity( 0 )
		local Num = Damage:GetDamage( ) or 0
		local Pos = Damage:GetDamagePosition( ) or Vector( 0, 0, 0 )
		EXPADV.CallEvent( "onDamage", Ent, Attacker, Num, Pos )
	end)

	hook.Add("PropBreak", "Expav.Event", function( Attacker, Ent )
		local Attacker = Attacker or Entity( 0 )
		EXPADV.CallEvent( "propBreak", Ent, Attacker )
	end)
	
end