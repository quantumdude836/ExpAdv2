if !EXPADV then return ErrorNoHalt( "Expression Advanced 2, Failed to load tool." ) end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Language
   --- */

if CLIENT then
	language.Add( "Tool.expadv2.name", "Expression Advanced 2" )
	language.Add( "Tool.expadv2.desc", "Creates an ingame scriptable entity." )
	language.Add( "Tool.expadv2.help", "Place an Expression Advanced Gate or screen." )
	language.Add( "Tool.expadv2.0", "Place an Expession Advanced Gate or screen." )
	
	language.Add( "limit_expadv", "Expression Advanced Entity limit reached." )
	language.Add( "Undone_expadv", "Expression Advanced - Removed." )
	language.Add( "Cleanup_expadv", "Expression Advanced - Removed." )
	language.Add( "Cleaned_expadvs", "Expression Advanced - Removed All Entities." )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Tool Information
   --- */

if WireLib then
	TOOL.Name						= "Expression Advanced 2"
	TOOL.Category					= "Chips, Gates"
	TOOL.Tab						= "Wire"
else
	TOOL.Name						= "Expression Advanced 2"
	TOOL.Category					= "Scriptable"
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Cvars
   --- */

TOOL.ClientConVar.model 		= "models/lemongate/lemongate.mdl"
TOOL.ClientConVar.weld		 	= 0
TOOL.ClientConVar.weldworld 	= 0
TOOL.ClientConVar.frozen		= 0

hook.Add( "Expadv.PostLoadConfig", "Expadv.Tool", function( )
	EXPADV.CreateSetting( "limit", 20 )
end )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Model List
   --- */
local GateModels = { }

table.insert( GateModels, "models/lemongate/lemongate.mdl" )

if WireLib then
	table.insert( GateModels, "models/bull/gates/processor.mdl" )
	table.insert( GateModels, "models/expression 2/cpu_controller.mdl" )
	table.insert( GateModels, "models/expression 2/cpu_expression.mdl" )
	table.insert( GateModels, "models/expression 2/cpu_interface.mdl" )
	table.insert( GateModels, "models/expression 2/cpu_microchip.mdl" )
	table.insert( GateModels, "models/expression 2/cpu_processor.mdl" )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Clean up
   --- */

cleanup.Register( "expadv" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Utility
   --- */

local function IsExpAdv( Entity )
	if !IsValid( Entity ) then return false end
	return Entity.Base == "expadv_base"
end -- TODO: Use somthing other then base class comparason.

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Make Gate Entity
   --- */

local function MakeExpadv( Player, Position, Angle, Model, InPorts, OutPorts )
	if Player:GetCount( "expadv" ) > EXPADV.ReadSetting( "limit", 20 ) then
		Player:LimitHit( "Expression Advanced entity limit reached." )
		return nil
	end
	
	local ExpAdv = ents.Create( "expadv_gate" )
	if !IsValid( ExpAdv ) then return end

	ExpAdv:SetPos( Position )
	ExpAdv:SetAngles( Angle )
	ExpAdv:SetModel( Model )
	ExpAdv:Activate( )
	ExpAdv:Spawn( )

	Player:AddCount( "expadv", ExpAdv )
	ExpAdv:SetPlayer( Player )
	ExpAdv.player = Player

	ExpAdv:ApplyDupePorts( InPorts, OutPorts )

	return ExpAdv
end

duplicator.RegisterEntityClass( "expadv_gate", MakeExpadv, "Pos", "Ang", "Model", "DupeInPorts", "DupeOutPorts" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Make Screen Entity
   --- */

local function MakeExpadvScreen( Player, Position, Angle, Model, InPorts, OutPorts )
	if Player:GetCount( "expadv" ) > EXPADV.ReadSetting( "limit", 20 ) then
		Player:LimitHit( "Expression Advanced entity limit reached." )
		return nil
	end
	
	local ExpAdv = ents.Create( "expadv_screen" )
	if !IsValid( ExpAdv ) then return end

	ExpAdv:SetPos( Position )
	ExpAdv:SetAngles( Angle )
	ExpAdv:SetModel( Model )
	ExpAdv:Activate( )
	ExpAdv:Spawn( )

	Player:AddCount( "expadv", ExpAdv )
	ExpAdv:SetPlayer( Player )
	ExpAdv.player = Player

	ExpAdv:ApplyDupePorts( InPorts, OutPorts )

	return ExpAdv
end

duplicator.RegisterEntityClass( "expadv_screen", MakeExpadvScreen, "Pos", "Ang", "Model", "DupeInPorts", "DupeOutPorts" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Left Click
   --- */

function TOOL:LeftClick( Trace )
	if IsValid( Trace.Entity ) then -- and EXPADV.IsFriend( Trace.Entity, self:GetOwner( ) ) then
		if Trace.Entity.ExpAdv and SERVER then
			net.Start( "expadv.request" )
			net.WriteUInt( Trace.Entity:EntIndex( ), 16 )
			net.Send( self:GetOwner( ) )

			return true
		end
	end

	if CLIENT then
		return true
	end

	local Model, ExpAdv = self:GetClientInfo( "model" )
	local Ang = Trace.HitNormal:Angle( ) + Angle( 90, 0, 0 )

	if EXPADV.GetMonitor( Model ) then
		ExpAdv = MakeExpadvScreen( self:GetOwner( ), Trace.HitPos, Ang, Model )
	else
		ExpAdv = MakeExpadv( self:GetOwner( ), Trace.HitPos, Ang, Model )
	end

	if !IsValid( ExpAdv ) then return false end

	ExpAdv:SetPos( Trace.HitPos - Trace.HitNormal * ExpAdv:OBBMins().z )

	local WeldWorld = self:GetClientNumber( "weldworld" )

	undo.Create( "expadv" )
	undo.AddEntity( ExpAdv )
	undo.SetPlayer( self:GetOwner( ) ) 

	if self:GetClientNumber( "weld" ) >= 1 then
		if !IsValid( Trace.Entity ) and WeldWorld then
			undo.AddEntity( constraint.Weld( ExpAdv, Trace.Entity, 0, Trace.PhysicsBone, 0, 0, WeldWorld ) )
		end 
	end

	undo.Finish( )

	if self:GetClientNumber("frozen") >= 1 then
		ExpAdv:GetPhysicsObject( ):EnableMotion( false )
	end

	
	self:GetOwner( ):AddCleanup( "expadv", ExpAdv )

	net.Start( "expadv.request" )
	net.WriteUInt( ExpAdv:EntIndex( ), 16 )
	net.Send( self:GetOwner( ) )

	return true
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Right Click
   --- */

function TOOL:RightClick( Trace )
	if CLIENT then return false end

	if IsValid( Trace.Entity ) and Trace.Entity.ExpAdv then -- and EXPADV.IsFriend( Trace.Entity, self:GetOwner( ) ) then
		net.Start( "expadv.download" )
		net.WriteUInt( Trace.Entity:EntIndex( ), 16 )
		net.WriteString( Trace.Entity:GetGateName( ) )
		net.Send( self:GetOwner( ) )
		return true
	end

	self:GetOwner( ):SendLua( "EXPADV.Editor.Open( )" )
	return false
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Tool Panel
   --- */

if CLIENT then
	function TOOL.BuildCPanel( CPanel )
		local CheckScreen = CPanel:CheckBox( "Create screen" )
		
		local Props = vgui.Create( "PropSelect" )
		Props:SetConVar( "expadv2_model" )
		CPanel:AddItem( Props )

		local CheckWeld = CPanel:CheckBox( "Create Welded", "expadv2_weld" )
		local CheckWorld = CPanel:CheckBox( "Weld To World", "expadv2_weldworld" )
		local CheckFroze = CPanel:CheckBox( "Create Frozen", "expadv2_frozen" )

		local function ShowGateModels( )
			DScrollPanel.Clear( Props.List )

			RunConsoleCommand( "expadv2_model", "models/lemongate/lemongate.mdl" )

			for _, Mdl in pairs( GateModels ) do
				Props:AddModel( Mdl )
			end
		end

		local function ShowScreenModels( )
			DScrollPanel.Clear( Props.List )

			RunConsoleCommand( "expadv2_model", "models/hunter/plates/plate1x1.mdl" )

			for Mdl, _ in pairs( EXPADV.GetMonitors( ) ) do
				Props:AddModel( Mdl )
			end
		end

		function CheckScreen:OnChange( Val )
			if !Val then ShowGateModels( ) else ShowScreenModels( ) end
		end

		ShowGateModels( )
	end
end


/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Ghost
   --- */

function TOOL:Think( )

	if !IsValid( self.GhostEntity ) or self.GhostEntity:GetModel( ) != self:GetClientInfo( "model" ) then
		return self:MakeGhostEntity( self:GetClientInfo( "model" ), Vector(0,0,0), Angle(0,0,0) )
	end
	
	local Trace = util.TraceLine( util.GetPlayerTrace( self:GetOwner( ) ) )
		
	if Trace.Hit then
		
		if IsValid( Trace.Entity ) and (Trace.Entity.ExpAdv or Trace.Entity:IsPlayer( ) ) then
			return self.GhostEntity:SetNoDraw( true )
		end
		
		local Ang = Trace.HitNormal:Angle( )
		Ang.pitch = Ang.pitch + 90
		
		self.GhostEntity:SetPos( Trace.HitPos - Trace.HitNormal * self.GhostEntity:OBBMins( ).z )
		self.GhostEntity:SetAngles( Ang )
		
		self.GhostEntity:SetNoDraw( false )
	end
end