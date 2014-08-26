/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Shared!
   --- */

ENT.Type 			= "anim"
ENT.Base 			= "expadv_base"

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Net Vars
   --- */

function ENT:SetupDataTables( )

	self:NetworkVar( "Bool", 0, "Online" )
	self:NetworkVar( "Bool", 1, "Crashed" )
	self:NetworkVar( "Bool", 2, "Sparking" )
	self:NetworkVar( "Bool", 3, "Ignited" )

	self:NetworkVar( "String", 0, "Title" )
	self:NetworkVar( "String", 1, "CrashMsg" )

	self:NetworkVar( "Float", 0, "TickQuota" )
	self:NetworkVar( "Float", 1, "SoftQuota" )
	self:NetworkVar( "Float", 2, "AvgeQuota" )

end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Reset Status
   --- */

function ENT:ResetStatus( )
	if SERVER then
		self:SetOnline( false )
		self:SetCrashed( false )
		self:SetSparking( false )
		self:SetIgnited( false )
		
		self:SetTickQuota( 0 )
		self:SetSoftQuota( 0 )
		self:SetAvgeQuota( 0 )
	end

	if CLIENT then
		self.cl_TickQuota = 0
		self.cl_SoftQuota = 0
		self.cl_AvgeQuota = 0
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
	local Context = self.Context

	if !Context then
		return self:ResetStatus( )
	end

	if SERVER then
		self:SetOnline( Context.Online )
		self:SetTickQuota( Context.Status.TickQuota )
		self:SetSoftQuota( Context.Status.QuotaCount )
		self:SetAvgeQuota( Context.Status.AverageQuota )
	end

	if CLIENT then
		self.cl_TickQuota = Context.Status.TickQuota
		self.cl_SoftQuota = Context.Status.QuotaCount
		self.cl_AvgeQuota = Context.Status.AverageQuota
	end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Think
   --- */
function ENT:Think( )
	self.BaseClass.Think( self )
	self:NextThink( CurTime( ) + 0.030303 )

	if self:IsRunning( ) then
		local Status = self.Context.Status

		Status.QuotaCount = Status.QuotaCount + Status.TickQuota - expadv_softquota
		
		Status.AverageQuota = Status.AverageQuota * 0.95 + Status.TickQuota * 0.05

		Status.TickQuota = 0

		if Status.QuotaCount < 0 then Status.QuotaCount = 0 end
	end

	self:UpdateOverlay( )

	return true
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Quota Stuffs
   --- */

function ENT:OnStartUp( )
	self:ResetStatus( )
end

function ENT:OnHitQuota( )
	if SERVER then
		self:SetSparking( false )
		self:SetIgnited( false )
		self:SetCrashed( true )
	end
	
	self:OnScriptError( self.Context, "Tick Quota Exceeded." )

	self.Context:ShutDown( )
end

function ENT:OnHitHardQuota( )
	if SERVER then
		self:SetSparking( false )
		self:SetIgnited( true )
		self:SetCrashed( true )
	end
	
	self:OnScriptError( self.Context, "Hard Quota Exceeded." )

	self.Context:ShutDown( )
	EXPADV.UnregisterContext( self.Context )
end