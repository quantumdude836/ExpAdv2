/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: ExpAdv2 Entity!
   --- */

include( "shared.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "overlay.lua" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Print Outs
   --- */

function ENT:OnLuaError( Context, Msg )
	EXPADV.PrintColor( Context, Color( 255, 0, 0 ), "Expresion Advanced - Error: ", Color( 255, 255, 255 ), Msg )
end

function ENT:OnScriptError( Context, Msg )
	EXPADV.PrintColor( Context, Color( 255, 0, 0 ), "Expresion Advanced - Script Error: ", Color( 255, 255, 255 ), Msg )
end

function ENT:OnUncatchedException( Context, Exception )
	EXPADV.PrintColor( Context, Color( 255, 0, 0 ), "Expresion Advanced - Uncatched exception: ", Color( 255, 255, 255 ), Exception.Exception, " -> ", Execption.Msg )
end

function ENT:OnCompileError( ErMsg, Compiler )
	EXPADV.PrintColor( Context, Color( 255, 0, 0 ), "Expresion Advanced - Validate Error: ", Color( 255, 255, 255 ), ErMsg )
end

-- function ENT:OnStartUp( Context ) end

function ENT:OnShutDown( Context )
	EXPADV.PrintColor( Context, Color( 255, 0, 0 ), "Expresion Advanced - ShutDown: ", Color( 255, 255, 255 ), tostring( self ) )
end

-- function ENT:OnContextUpdate( Context ) end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Events
   --- */

function ENT:OnClientLoaded( Ply )
	local Context = self.Context

	-- timer.Simple( 1, function( ) -- Delay this, allowing the clients code to properly function.
	--if !IsValid( self ) or !IsValid( Ply ) then return end

		if Context and Context.Online and Context.event_clientLoaded then
			Context:Execute( "Event clientLoaded", Context.event_clientLoaded, Ply )
		end
	-- end )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Pod Connectivity
   --- */

function ENT:LinkPod(Pod)
	if !IsValid(Pos) or !Pod:IsVehicle() then return end

	self:SetLinkedPod(Pod)
end

hook.Add( "Expadv.BuildDupeInfo", "expadv.pod", function( Ent, DupeTable )
	if !Ent.GetLinkedPod then return end
	DupeTable.Pod = Ent:GetLinkedPod()
end )

hook.Add( "Expadv.PasteDupeInfo", "expadv.pod", function( Ent, DupeTable, FromID )
	if !Ent.SetLinkedPod then return end
	if !DupeTable.Pod then return end
	Ent:LinkPod(FromID(DupeTable.Pod))
end )

hook.Add( "PlayerEnteredVehicle", "expadv.pod", function( Ply, Ent )
	for _, Context in pairs( EXPADV.CONTEXT_REGISTERY ) do
		if !Context.Online or !IsValid(Context.entity) then continue end
		if !Context.entity.GetLinkedPod or Context.entity:GetLinkedPod() ~= Ent then continue end
		Context.entity:CallEvent( "playerEnteredVehicle", Ply )	
	end
end)

hook.Add( "PlayerLeaveVehicle", "expadv.pod", function( Ply, Ent )
	for _, Context in pairs( EXPADV.CONTEXT_REGISTERY ) do
		if !Context.Online or !IsValid(Context.entity) then continue end
		if !Context.entity.GetLinkedPod or Context.entity:GetLinkedPod() ~= Ent then continue end
		Context.entity:CallEvent( "playerExitedVehicle", Ply )	
	end
end)
