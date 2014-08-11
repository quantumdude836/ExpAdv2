/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Shared!
   --- */

ENT.Type 			= "anim"
ENT.Base 			= "expadv_base"

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Net Vars
   --- */

function ENT:SetupDataTables( )

	self:NetworkVar( "Bool", 0, "Crashed" )
	self:NetworkVar( "Bool", 1, "Sparking" )
	self:NetworkVar( "Bool", 2, "Ignited" )

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

function ENT:OnUpdate( )
	local Context = self.Context
	if !Context then return end

	local NewQuota = (self:GetTickQuota( ) + Context.Status.TickQuota) * 1000000
	local SoftQuota = math.max( 0, self:GetSoftQuota( ) ) + NewQuota - EXPADV.CVarSoftQuota:GetInt( ) * (engine.TickInterval()/0.0303030303) / 1000000

	if SERVER then
		self:SetTickQuota( NewQuota )
		self:SetSoftQuota( SoftQuota )
		self:SetAvgeQuota( (self:GetAvgeQuota( ) * 0.95) + (NewQuota * 0.5) )
	end

	if CLIENT then
		self.cl_TickQuota = NewQuota
		self.cl_SoftQuota = SoftQuota
		self.cl_AvgeQuota = (self:GetAvgeQuota( ) * 0.95) + (NewQuota * 0.5)
	end

	Context.Status.TickQuota = 0

	if SERVER and WireLib then self:TriggerOutputs( ) end

	self:CheckUsage( )
	
	MsgN( "Update: ", NewQuota, " vs ", SoftQuota )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Status
   --- */

function ENT:CheckUsage( )
	local TickQuota = self.cl_TickQuota or self:GetTickQuota( )
	local SoftQuota = self.cl_SoftQuota or self:GetSoftQuota( )
	local AvgeQuota = self.cl_AvgeQuota or self:GetAvgeQuota( )

	if !self.Context then return end

	if SoftQuota > EXPADV.CVarHardQuota:GetInt( ) then
		self:OnHitHardQuota( )
	elseif SoftQuota > EXPADV.CVarHardQuota:GetInt( ) * 0.3 then
		self:OnHitSoftQuota( )
	elseif SERVER then
		self:SetSparking( false )
		self:SetIgnited( false )
	end
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

function ENT:OnHitSoftQuota( )
	if SERVER then
		self:SetSparking( true )
		self:SetIgnited( false )
	end

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
end

--[[function ENT:OnShutDown( )

end]]