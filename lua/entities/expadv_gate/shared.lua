/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Shared!
   --- */

ENT.Type 					= "anim"
ENT.Base 					= "expadv_base"
ENT.ExpAdv 					= true
ENT.AutomaticFrameAdvance  	= true

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Effects
   --- */

-- if CLIENT then game.AddParticles( "particles/fire_01.pcf" ) end
-- PrecacheParticleSystem( "fire_verysmall_01" )

AccessorFunc( ENT, "ClientState", "ClientState", FORCE_NUMBER )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Ops
   --- */

function ENT:SetupDataTables( )
	self:AddExpVar( "FLOAT", 0, "TickQuota" )
	self:AddExpVar( "FLOAT", 1, "StopWatch" )
	self:AddExpVar( "FLOAT", 2, "Average" )
	self:AddExpVar( "FLOAT", 3, "ServerState" )
	self:AddExpVar( "STRING", 0, "GateName" )
	self:AddExpVar( "ENTITY", 0, "LinkedPod" )
end

if SERVER then
	function ENT:CalculateOps(Context)
		self:SetTickQuota(Context.Status.Perf)
		self:SetStopWatch(self:GetStopWatch(0) * 0.95 + (Context.Status.StopWatch * 50000))
		self:SetAverage(self:GetAverage(0) * 0.95 + Context.Status.Perf)
		
		if Context.Status.Counter > expadv_hardquota * 0.5 then
			self:SetServerState(EXPADV_STATE_ALERT)
		else
			self:SetServerState(EXPADV_STATE_ONLINE)
		end
	end
end

if CLIENT then
	function ENT:CalculateOps(Context)
		self.ClientTickQuota = Context.Status.Perf
		self.ClientStopWatch = self.ClientStopWatch * 0.95 + (Context.Status.StopWatch * 50000)
		self.ClientAverage = self.ClientAverage * 0.95 + Context.Status.Perf

		if Context.Status.Counter > expadv_hardquota * 0.5 then
			self:SetClientState(EXPADV_STATE_ALERT)
		else
			self:SetClientState(EXPADV_STATE_ONLINE)
		end
	end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Reset State
   --- */

function ENT:ResetState( State )
	
	if SERVER then
		self:SetTickQuota( 0 )
		self:SetStopWatch( 0 )
		self:SetAverage( 0 )
		self:SetServerState( State or EXPADV_STATE_OFFLINE )
	end

	if CLIENT then
		self.ClientTickQuota = 0
		self.ClientStopWatch = 0
		self.ClientAverage = 0
		self:SetClientState( State or EXPADV_STATE_OFFLINE )
	end
end

function ENT:SetState( State )
	if SERVER then
		self:SetServerState( State )
	elseif CLIENT then
		self:SetClientState( State )
	end
end

function ENT:PostStartUp( )
	self:SetState( EXPADV_STATE_ONLINE )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Think
   --- */

function ENT:Think( )

	if SERVER and self:GetModel( ) == "models/lemongate/lemongate.mdl" then
		local Context = self.Context

		local Attachment = self:LookupAttachment("fan_attch")

	    local Percent = (self:GetAverage(1) / expadv_hardquota) * 100
	    
	    local SpinSpeed = self.SpinSpeed or 0

	    if self:GetServerState(EXPADV_STATE_OFFLINE) >= EXPADV_STATE_CRASHED then SpinSpeed = 0 end
	    
	    self.SpinSpeed = SpinSpeed + math.Clamp( Percent - SpinSpeed, -0.1, 0.1 )

	    self:SetPlaybackRate( self.SpinSpeed )

	    self:ResetSequence( self:LookupSequence( self.SpinSpeed <= 0 and "idle" or "spin" ) )
	end

	if self.Compiler_Instance then
		if self.Compiler_Instance.Running then
			self.Compiler_Instance:Resume( )
		else
			self.Compiler_Instance = nil
		end
	end

	self:NextThink(CurTime() + 1)
	return true
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