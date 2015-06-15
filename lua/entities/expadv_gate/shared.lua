/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Shared!
   --- */

ENT.Type 					= "anim"
ENT.Base 					= "expadv_base"
ENT.ExpAdv 					= true
ENT.AutomaticFrameAdvance  	= true

ENT.EXPADV_GATE				= ENT

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Queded Compiler
   --- */

function ENT:CompileScript(Root, Files)

	if EXPADV.ReadSetting( "compile_rate", 60 ) <= 0 then
		return self.EXPADV_BASE.CompileScript(self, Root, Files)
	end
	
	if self:IsRunning( ) then
		self.Context:ShutDown( )
		EXPADV.UnregisterContext( self.Context )
	end
	
	if self.SlowCompiler then EXPADV.UnqueueCompiler(self.SlowCompiler) end

	if !Root or Root == "" then
		return self:ScriptError( "No code submited, compiler exited." )
	end

	self.SlowCompiler = EXPADV.NewSoftCompiler(Root, Files, self, self.player)

	self.SlowCompiler.OnFail = function(sc, err)
		if IsValid(self) then
			self.SlowCompiler = nil
			self:OnCompileError(err)
		end
	end

	self.SlowCompiler.OnCompletion = function(sc, Instruction)
		if IsValid(self) then
			self:BuildInstance( sc, Instruction )
		end
	end

	self.SlowCompiler.PostResume = function(sc, percent)
		if IsValid(self) then
			if SERVER then
				self:SetSV_Loaded(percent)
			else
				self:SetCL_Loaded(percent)
			end
		end
	end

	if SERVER then
		self:SetSV_Loaded(0)
		self:SetSV_State( EXPADV_STATE_COMPILE )
	else
		self:SetCL_Loaded(0)
		self:SetCL_State( EXPADV_STATE_COMPILE )
	end

	EXPADV.QueueCompiler(self.SlowCompiler)
end

function ENT:OnRemove()
	if self.SlowCompiler then EXPADV.UnqueueCompiler(self.SlowCompiler) end
	
	hook.Remove( "PlayerInitialSpawn", self )

	if !self:IsRunning( ) then return end
	
	self.Context:ShutDown( )
end
/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Effects
   --- */

-- if CLIENT then game.AddParticles( "particles/fire_01.pcf" ) end
-- PrecacheParticleSystem( "fire_verysmall_01" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Ops
   --- */

AccessorFunc( ENT, "CL_TickQuota", "CL_TickQuota", FORCE_NUMBER )
AccessorFunc( ENT, "CL_SoftQuota", "CL_SoftQuota", FORCE_NUMBER )
AccessorFunc( ENT, "CL_Average", "CL_Average", FORCE_NUMBER )
AccessorFunc( ENT, "CL_State", "CL_State", FORCE_NUMBER )
AccessorFunc( ENT, "CL_Loaded", "CL_Loaded", FORCE_NUMBER )

function ENT:SetupDataTables( )
	self:AddExpVar( "FLOAT", 1, "SV_TickQuota" )
	self:AddExpVar( "FLOAT", 2, "SV_SoftQuota" )
	self:AddExpVar( "FLOAT", 3, "SV_Average" )
	self:AddExpVar( "FLOAT", 4, "SV_State" )
	self:AddExpVar( "FLOAT", 5, "SV_Loaded" )
	
	self:AddExpVar( "STRING", 1, "GateName" )
	self:AddExpVar( "ENTITY", 1, "LinkedPod" )

	self:ResetState(EXPADV_STATE_ONLINE)
end

function ENT:UpdateOverlay(Force)
	if CurTime() > (self._Overlay or 0) then
		self._Overlay = CurTime() + 0.1
		
		local Status = self.Context.Status

		if SERVER then
			self:SetSV_TickQuota(Status.Tick * 1000000)
			self:SetSV_SoftQuota(Status.Soft * 1000000) 
			self:SetSV_Average(Status.Average * 1000000) 
		elseif CLIENT then
			self:SetCL_TickQuota(Status.Tick * 1000000) 
			self:SetCL_SoftQuota(Status.Soft * 1000000) 
			self:SetCL_Average(Status.Average * 1000000)
		end
	end
end

function ENT:CalculateOps(Context, ForceOverlay)
	local Status = Context.Status
	Status.Average = Status.Average * 0.95 + Status.Tick * 0.05
	Status.Soft = Status.Soft + Status.Tick - (expadv_soft_cpu / 1000000)
	
	self:UpdateOverlay(ForceOverlay)

	if Status.Soft < 0 then
		Status.Soft = 0
	elseif Status.Soft * 1000000 > expadv_hard_cpu then
		self:HitHardQuota()
		Context:ShutDown( )
	elseif Status.Soft / expadv_hard_cpu > 0.33 then
		self:SetState(EXPADV_STATE_ALERT)
	else
		self:SetState(EXPADV_STATE_ONLINE)
	end

	//Status.Tick_Counter = Status.Tick_Counter + Status.Tick
	
	Status.Tick = 0
	Status.Memory = 0
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Reset State
   --- */

function ENT:ResetState( State )
	
	if SERVER then
		self:SetSV_TickQuota(0)
		self:SetSV_SoftQuota(0)
		self:SetSV_Average(0)
		self:SetSV_State( State or EXPADV_STATE_OFFLINE )
	end

	if CLIENT then
		self:SetCL_TickQuota(0)
		self:SetCL_SoftQuota(0)
		self:SetCL_Average(0)
		self:SetCL_State( State or EXPADV_STATE_OFFLINE )
	end
end

function ENT:SetState( State )
	if SERVER then
		self:SetSV_State( State )
	elseif CLIENT then
		self:SetCL_State( State )
	end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Think
   --- */

function ENT:Think( )
	if SERVER and self:GetModel( ) == "models/lemongate/lemongate.mdl" then
		local Attachment = self:LookupAttachment("fan_attch")

	    local Percent = (self:GetSV_Average(1) / expadv_hard_cpu) * 100
	    
	    local SpinSpeed = self.SpinSpeed or 0

	    if self:GetSV_State(EXPADV_STATE_OFFLINE) >= EXPADV_STATE_CRASHED then SpinSpeed = 0 end
	    
	    self.SpinSpeed = SpinSpeed + math.Clamp( Percent - SpinSpeed, -0.33, 0.33 )

	    self:SetPlaybackRate( self.SpinSpeed )

	    local Sequence = self:LookupSequence(self.SpinSpeed <= 0 and "idle" or "spin")
	    self:ResetSequence(Sequence)
	end

	/*if self.Context then
		local Status = self.Context.Status

		if SERVER then
			local Tick = (Status.Tick_Counter / engine.TickInterval())  * 1000000 * 0.2
			self:SetSV_TickQuota(math.Clamp(Tick, 0, 1)) -- Average over last second.
			self:SetSV_SoftQuota(Status.Soft * 1000000)  -- This comment exists cus OCD.
			self:SetSV_Average(Status.Average * 1000000) -- Overall Average.
		elseif CLIENT then
			local Tick = (Status.Tick_Counter / engine.TickInterval())  * 1000000 * 0.2
			self:SetCL_TickQuota(math.Clamp(Tick, 0, 1)) -- Average over last second.
			self:SetCL_SoftQuota(Status.Soft * 1000000)  -- This comment exists cus OCD.
			self:SetCL_Average(Status.Average * 1000000) -- Overall Average.
		end

		Status.Tick_Counter = 0
	end

	self:NextThink(CurTime() + 0.2)
	return true*/
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Quota Stuffs
   --- */

function ENT:StartUp( )
	self:ResetState( EXPADV_STATE_ONLINE )
end

function ENT:HitTickQuota( )
	self:SetState( EXPADV_STATE_BURNED )
	self:NotifiOwner( "Tick Quota Exceeded.", 1, 5 )
end

function ENT:HitHardQuota( )
	self:SetState( EXPADV_STATE_BURNED )
	self:NotifiOwner( "Hard Quota Exceeded.", 1, 5 )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Print Outs
   --- */

function ENT:LuaError( Msg )
	self:SetState( EXPADV_STATE_CRASHED )
	
	if SERVER then
		self:NotifiOwner( "Expression Advanced 2 - Suffered a serverside Lua error:", 1, 5 )
		self:NotifiOwner( Msg, 1, 3 )
	elseif CLIENT and self.player == LocalPlayer( ) then
		self:NotifiOwner( "Expression Advanced 2 - Suffered a clientside Lua error:", 1, 5 )
		self:NotifiOwner( Msg, 1, 3 )
	end
end

function ENT:ScriptError( Msg )
	self:SetState( EXPADV_STATE_CRASHED )

	if SERVER then
		self:NotifiOwner( "Expression Advanced 2 - Suffered a serverside Script error:", 1, 5 )
		self:NotifiOwner( Msg, 1, 3 )
	elseif CLIENT and self.player == LocalPlayer( ) then
		self:NotifiOwner( "Expression Advanced 2 - Suffered a clientside Script error:", 1, 5 )
		self:NotifiOwner( Msg, 1, 3 )
	end
end

function ENT:Exception( Exception )
	self:SetState( EXPADV_STATE_CRASHED )

	local Msg = string.format( "%s - %s", Exception.Exception, Exception.Msg )

	if SERVER then
		self:NotifiOwner( "Expression Advanced 2 - Uncatched Exception (serverside):", 1, 5 )
		self:NotifiOwner( Msg, 1, 3 )
	elseif CLIENT and self.player == LocalPlayer( ) then
		self:NotifiOwner( "Expression Advanced 2 - Uncatched Exception (clientside):", 1, 5 )
		self:NotifiOwner( Msg, 1, 3 )
	end
end

function ENT:OnCompileError( ErMsg, Compiler )
	MsgN( "Compiler Error: ", ErMsg )

	self:SetState( EXPADV_STATE_CRASHED )

	if SERVER then
		self:NotifiOwner( "Expression Advanced 2 - Failed to compile serverside:", 1, 5 )
		self:NotifiOwner( ErMsg, 1, 3 )
	elseif CLIENT and self.player == LocalPlayer( ) then
		self:NotifiOwner( "Expression Advanced 2 - Failed to compile clientside:", 1, 5 )
		self:NotifiOwner( ErMsg, 1, 3 )
	end
end

function ENT:ShutDown( )
	
end

function ENT:NotifiOwner( Message, Type, Duration )
	if !IsValid( self.player ) then return end
	EXPADV.Notifi( self.player, Message, Type, Duration )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Pod Connectivity
   --- */

hook.Add( "Expadv.PreLoadFunctions", "expadv.features",
	function( )
		EXPADV.SharedOperators( )
		EXPADV.AddInlineFunction( nil, "getLinkedPod", "", "e", "(Context.entity:GetLinkedPod() or $Entity(0))")
	end )