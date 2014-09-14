/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Shared!
   --- */

ENT.Type 			= "anim"
ENT.Base 			= "expadv_base"
ENT.ExpAdv 			= true

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Net Vars
   --- */

AccessorFunc( ENT, "TickQuotaCL", "TickQuotaCL", FORCE_NUMBER )
AccessorFunc( ENT, "StopWatchCL", "StopWatchCL", FORCE_NUMBER )
AccessorFunc( ENT, "Average", "AverageCL", FORCE_NUMBER )

function ENT:SetupDataTables( )

	self:NetworkVar( "Float", 0, "TickQuota" )
	self:NetworkVar( "Float", 1, "StopWatch" )
	self:NetworkVar( "Float", 1, "Average" )

end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Reset Status
   --- */

function ENT:ResetStatus( )
	if SERVER then
		self:SetTickQuota( 0 )
		self:SetStopWatch( 0 )
	end

	if CLIENT then
		self:SetTickQuotaCL( 0 )
		self:SetStopWatchCL( 0 )
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
	--self.BaseClass.Think( self ) Base class doesnt think!
	
	if self:IsRunning( ) and (self.NextRefresh or 0) < CurTime( ) then
		self.NextRefresh = CurTime( ) + 1

		local Context = self.Context
		local Counter = Context.Status.Counter or 0
		local StopWatch = Context.Status.StopWatch or 0
		
		-- local Average = ((SERVER and self:GetAverage() or self:GetAverageCL()) * 0.95) + (Counter * 0.5)

		if SERVER then
			self:SetTickQuota( Counter )
			self:SetStopWatch( StopWatch )
			self:SetAverage( Average )
		end

		if CLIENT then
			self:SetTickQuotaCL( Counter )
			self:SetStopWatchCL( StopWatch )
			self:SetAverageCL( Average )
		end
	end

	self:NextThink( CurTime( ) + 0.030303 )
	return true
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Quota Stuffs
   --- */

function ENT:OnStartUp( )
	self:ResetStatus( )
end

function ENT:OnHitQuota( )
	self:OnScriptError( self.Context, "Tick Quota Exceeded." )
	self.Context:ShutDown( )
end

function ENT:OnHitHardQuota( )
	self:OnScriptError( self.Context, "Hard Quota Exceeded." )
	self.Context:ShutDown( )
	EXPADV.UnregisterContext( self.Context )
end