/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Shared!
   --- */

ENT.Type 					= "anim"
ENT.Base 					= "expadv_base"
ENT.ExpAdv 					= true
ENT.AutomaticFrameAdvance  	= true

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: States
   --- */

   EXPADV_STATE_OFFLINE = 0
   EXPADV_STATE_ONLINE = 1
   EXPADV_STATE_ALERT = 2
   EXPADV_STATE_CRASHED = 3
   EXPADV_STATE_BURNED = 4

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Effects
   --- */

-- if CLIENT then game.AddParticles( "particles/fire_01.pcf" ) end
-- PrecacheParticleSystem( "fire_verysmall_01" )


/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Net Vars
   --- */

AccessorFunc( ENT, "TickQuotaCL", "TickQuotaCL", FORCE_NUMBER )
AccessorFunc( ENT, "StopWatchCL", "StopWatchCL", FORCE_NUMBER )
AccessorFunc( ENT, "AverageCL", "AverageCL", FORCE_NUMBER )
AccessorFunc( ENT, "StateCL", "StateCL", FORCE_NUMBER )

function ENT:SetupDataTables( )

	self:NetworkVar( "Float", 0, "TickQuota" )
	self:NetworkVar( "Float", 1, "StopWatch" )
	self:NetworkVar( "Float", 2, "Average" )
	self:NetworkVar( "Float", 3, "StateSV" )

end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Reset State
   --- */

function ENT:ResetState( State )
	if SERVER then
		self:SetTickQuota( 0 )
		self:SetStopWatch( 0 )
		self:SetAverage( 0 )
		self:SetStateSV( State or EXPADV_STATE_OFFLINE )
	end

	if CLIENT then
		self:SetTickQuotaCL( 0 )
		self:SetStopWatchCL( 0 )
		self:SetAverageCL( 0 )
		self:SetStateCL( State or EXPADV_STATE_OFFLINE )
	end
end

function ENT:SetState( State )
	if SERVER then
		self:SetStateSV( State )
	elseif CLIENT then
		self:SetStateCL( State )
	end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Update Info
   --- */

function ENT:OnUpdate( Context )
	if !Context then return end

	if SERVER and WireLib then
		self:TriggerOutputs( )
	end
end

function ENT:UpdateOverlay( )
	
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Think
   --- */

function ENT:Think( )
	if self:IsRunning( ) then

		local Context = self.Context
		local Perf = Context.Status.Perf or 0
		local Counter = Context.Status.Counter or 0
		local StopWatch = Context.Status.StopWatch or 0

		if SERVER then
			self:SetTickQuota( Perf )
			self:SetAverage( self:GetAverage( ) * 0.95 + (Perf * 0.05) )
			self:SetStopWatch( self:GetStopWatch( ) * 0.95 + ( StopWatch * 50000 ) )
		end

		if CLIENT then
			self:SetTickQuotaCL( Perf )
			self:SetAverageCL( self:GetAverageCL( ) * 0.95 + (Perf * 0.05) )
			self:SetStopWatchCL( self:GetStopWatchCL( ) * 0.95 + ( StopWatch * 50000 ) )
		end

		Counter = Counter + Perf - expadv_softquota
		if Counter < 0 then Counter = 0 end

		local State = self:GetStateSV( ) or 0
		if Counter > expadv_hardquota * 0.5 then
			self:SetStateSV( EXPADV_STATE_ALERT )
		elseif (self:GetStateSV( ) or 0) == EXPADV_STATE_ALERT then
			self:SetStateSV( EXPADV_STATE_ONLINE )
		end

		Context.Status.Perf = 0
		Context.Status.StopWatch = 0
		Context.Status.Counter = Counter
	end

	if SERVER then
		if self:GetModel( ) ~= "models/lemongate/lemongate.mdl" then return end
	    local Attachment = self:LookupAttachment("fan_attch")

	    local State = self:GetStateSV( ) or 0
	    local Counter = self:GetAverage( ) or 0
	    local Percent = (Counter / expadv_hardquota) * 100
	    
	    local SpinSpeed = self.SpinSpeed or 0
	    if State >= EXPADV_STATE_CRASHED then SpinSpeed = 0 end
	    
	    self.SpinSpeed = SpinSpeed + math.Clamp( Percent - SpinSpeed, -0.1, 0.1 )
	    self:SetPlaybackRate( self.SpinSpeed )
	    self:ResetSequence( self:LookupSequence( self.SpinSpeed <= 0 and "idle" or "spin" ) )

	    -- print( "Spin Speed:", self.SpinSpeed, "vs", Percent, " - ", Counter, " / ", expadv_hardquota )
	end

	self:NextThink( CurTime( ) + 0.030303 )
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
	self:ScriptError( "Tick Quota Exceeded." )
end

function ENT:HitHardQuota( )
	self:SetState( EXPADV_STATE_BURNED )
	self:ScriptError( "Hard Quota Exceeded." )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Print Outs
   --- */

function ENT:LuaError( Msg )
	self:SetState( EXPADV_STATE_CRASHED )

	if SERVER then
	else
		chat.AddText( Color( 150, 150, 0 ), "[" .. self.player:Name( ) .. "] ", Color( 255, 0, 0 ), "Expresion Advanced - Error: ", Color( 255, 255, 255 ), Msg )
	end
end

function ENT:ScriptError( Msg )
	self:SetState( EXPADV_STATE_CRASHED )

	if SERVER then
	else
		chat.AddText( Color( 150, 150, 0 ), "[" .. self.player:Name( ) .. "] ", Color( 255, 0, 0 ), "Expresion Advanced - Script Error: ", Color( 255, 255, 255 ), Msg )
	end
end

function ENT:Exception( Exception )
	self:SetState( EXPADV_STATE_CRASHED )

	if SERVER then
	else
		chat.AddText( Color( 150, 150, 0 ), "[" .. self.player:Name( ) .. "] ", Color( 255, 0, 0 ), "Expresion Advanced - Uncatched exception: ", Color( 255, 255, 255 ), Exception.Exception, " -> ", Exception.Msg )
	end
end

function ENT:OnCompileError( ErMsg, Compiler )
	self:SetState( EXPADV_STATE_CRASHED )

	if SERVER then
	else
		chat.AddText( Color( 150, 150, 0 ), "[" .. self.player:Name( ) .. "] ", Color( 255, 0, 0 ), "Expresion Advanced - Validate Error: ", Color( 255, 255, 255 ), ErMsg )
	end
end

function ENT:ShutDown( )
	if SERVER then
	else
		chat.AddText( Color( 255, 0, 0 ), "Expresion Advanced - ShutDown: ", Color( 255, 255, 255 ), tostring( self ) )
	end
end