/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Shared Info!
   --- */

AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base 			= "expadv_gate"
ENT.ExpAdv 			= true
ENT.NextBot 		= true
ENT.RenderGroup		= RENDERGROUP_OPAQUE

if CLIENT then return end

ENT.Type = "nextbot"

function ENT:Initialize( )
	self:SetUseType( SIMPLE_USE )

	if WireLib then
		self.Inputs = WireLib.CreateInputs( self, { } )
		self.Outputs = WireLib.CreateOutputs( self, { } )
	end

	self:ResetStatus( )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Behavior Thread
   --- */

function ENT:BehaveStart()
	--MsgN("Behavior started")
	-- We dont do anything here.
	-- The script needs to upload and run first.
end

function ENT:PostStartUp( )
	--MsgN("Script Loaded")
	self.BehaveThread = coroutine.create(function()
		self:CallEvent("behavior", self.loco)
	end)
end

function ENT:BehaveUpdate(Interval)
	if self.BehaveThread and self:IsRunning() then
		self:CallEvent("behaviorUpdate", Interval)

		self.Inthread = true
		EXPADV.coroutine.resume2(self.Context, self.BehaveThread)
		self.Inthread = false
	end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Stuck
   --- */

function ENT:HandleStuck()
	self:CallEvent("handleStuck", self.loco)
	self.loco:ClearStuck()
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Feet
   --- */

function ENT:OnLeaveGround()
	self:CallEvent("feetLeaveGround")
end

function ENT:OnLandOnGround()
	self:CallEvent("feetLandOnGround")
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Movment
   --- */

function ENT:MoveToPos(pos, lookahead, tolerance, maxage, repath)
	local path = Path( "Follow" )

	path:SetMinLookAheadDistance( lookahead or 300 )

	path:SetGoalTolerance( tolerance or 20 )

	path:Compute( self, pos )

	if !path:IsValid()then 
		return "failed"
	end

	while path:IsValid() do

		path:Update(self)

		-- If we're stuck then call the HandleStuck function and abandon
		if self.loco:IsStuck()  then
			self:HandleStuck();
			return "stuck"
		end

		if maxage and path:GetAge() > maxage then return "timeout" end

		if repath and path:GetAge() > repath then path:Compute( self, pos ) end

		coroutine.yield()
	end

	return "ok"
end

function ENT:ChaseTarget(ent, lookahead, tolerance)
	if !IsValid(ent) then
		return
	end

	local path = Path("Chase")
	path:SetMinLookAheadDistance(lookahead or 300)
	path:SetGoalTolerance(tolerance or 20)

	path:Compute(self, ent:GetPos())

	if !path:IsValid() then 
		return "failed"
	end

	while path:IsValid() do

		if !!IsValid(ent) then
			return "failed"
		end

		path:Compute(self, ent:GetPos())
		
		path:Chase(self, ent)
		
		-- If we're stuck then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then

			self:HandleStuck();
			return "stuck"
		end

		coroutine.yield()
	end

	return "ok"
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Animation
   --- */

function ENT:BodyUpdate()
	local act = self:GetActivity()

	if ( act == ACT_RUN || act == ACT_WALK ) then
		self:CallEvent("updateBodyPose")
	end

	self:FrameAdvance()
end

function ENT:PlaySequenceAndWait( name, speed )

	local len = self:SetSequence( name )
	speed = speed or 1
	
	self:ResetSequenceInfo()
	self:SetCycle( 0 )
	self:SetPlaybackRate( speed  )

	-- wait for it to finish
	coroutine.wait( len / speed )
end

function ENT:PlaySceneAndWait( scene )
	coroutine.wait(self:PlayScene(scene)) 
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Ragdoll
   --- */

function ENT:OnKilled( damageinfo )
	self:BecomeRagdoll( damageinfo )
end
