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
AccessorFunc( ENT, "AverageCL", "AverageCL", FORCE_NUMBER )

function ENT:SetupDataTables( )

	self:NetworkVar( "Float", 0, "TickQuota" )
	self:NetworkVar( "Float", 1, "StopWatch" )
	self:NetworkVar( "Float", 2, "Average" )

end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Reset Status
   --- */

function ENT:ResetStatus( )
	if SERVER then
		self:SetTickQuota( 0 )
		self:SetStopWatch( 0 )
		self:SetAverage( 0 )
	end

	if CLIENT then
		self:SetTickQuotaCL( 0 )
		self:SetStopWatchCL( 0 )
		self:SetAverageCL( 0 )
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

		Context.Status.Perf = 0
		Context.Status.StopWatch = 0
		Context.Status.Counter = Counter
	end

	self:NextThink( CurTime( ) + 0.030303 )
	return true
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Quota Stuffs
   --- */

function ENT:StartUp( )
	self:ResetStatus( )
end

function ENT:HitQuota( )
	self:ScriptError( "Tick Quota Exceeded." )
end

function ENT:HitHardQuota( )
	self:ScriptError( "Hard Quota Exceeded." )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Print Outs
   --- */

function ENT:LuaError( Msg )
	if SERVER then
	else
		chat.AddText( Color( 150, 150, 0 ), "[" .. self.player:Name( ) .. "] ", Color( 255, 0, 0 ), "Expresion Advanced - Error: ", Color( 255, 255, 255 ), Msg )
	end
end

function ENT:ScriptError( Msg )
	if SERVER then
	else
		chat.AddText( Color( 150, 150, 0 ), "[" .. self.player:Name( ) .. "] ", Color( 255, 0, 0 ), "Expresion Advanced - Script Error: ", Color( 255, 255, 255 ), Msg )
	end
end

function ENT:Exception( Exception )
	if SERVER then
	else
		chat.AddText( Color( 150, 150, 0 ), "[" .. self.player:Name( ) .. "] ", Color( 255, 0, 0 ), "Expresion Advanced - Uncatched exception: ", Color( 255, 255, 255 ), Exception.Exception, " -> ", Exception.Msg )
	end
end

function ENT:OnCompileError( ErMsg, Compiler )
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