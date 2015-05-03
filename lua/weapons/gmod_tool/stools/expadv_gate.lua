if !EXPADV then return ErrorNoHalt( "Expression Advanced 2, Failed to load tool." ) end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Language
   --- */

if CLIENT then
	language.Add( "Tool.expadv_gate.name", "Expression Advanced 2 - Gate" )
	language.Add( "Tool.expadv_gate.desc", "Creates an ingame scripted entity." )
	language.Add( "Tool.expadv_gate.0", "LMB: Spawn Gate or upload to gate; RMB: Download from gate or select a pod to link." )
	language.Add( "Tool.expadv_gate.1", "RMB: Now click the Gate you wish to link to this pod." )
	
	language.Add( "limit_expadv", "Expression Advanced Entity limit reached." )
	language.Add( "Undone_expadv", "Expression Advanced - Removed." )
	language.Add( "Cleanup_expadv", "Expression Advanced - Removed." )
	language.Add( "Cleaned_expadvs", "Expression Advanced - Removed All Entities." )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Tool Information
   --- */

	TOOL.Name						= "ExpAdv2 Gate"
	TOOL.Category					= "Expadv2"

if WireLib then
	TOOL.Tab						= "Wire"
	TOOL.Wire_MultiCategories		= { "Expadv2", "Chips, Gates" }
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
table.insert( GateModels, "models/shadowscion/lemongate/gate.mdl" )

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
	@: Left Click
   --- */

function TOOL:LeftClick( Trace )

	if IsValid( Trace.Entity ) then -- and EXPADV.IsFriend( Trace.Entity, self:GetOwner( ) ) then
		if Trace.Entity.ExpAdv and SERVER then
			EXPADV.RequestCode(self:GetOwner(), Trace.Entity)
			return true
		end
	end

	if CLIENT then return true end

	local Model, ExpAdv = self:GetClientInfo( "model" )

	local Ang = Trace.HitNormal:Angle( ) + Angle( 90, 0, 0 )

	ExpAdv = MakeExpadv( self:GetOwner( ), Trace.HitPos, Ang, Model, nil, nil )

	if !IsValid( ExpAdv ) then return false end

	ExpAdv:SetPos( Trace.HitPos - Trace.HitNormal * ExpAdv:OBBMins().z )

	undo.Create( "expadv" )

	undo.AddEntity( ExpAdv )

	undo.SetPlayer( self:GetOwner( ) ) 

	if self:GetClientNumber( "weld" ) == 1 then
		local WeldWorld = self:GetClientNumber( "weldworld"  ) == 1

		if IsValid( Trace.Entity ) or WeldWorld then
			undo.AddEntity( constraint.Weld( ExpAdv, Trace.Entity, 0, Trace.PhysicsBone, 0, 0, WeldWorld ) )
		end 
	end

	undo.Finish( )

	if self:GetClientNumber("frozen") == 1 then
		ExpAdv:GetPhysicsObject( ):EnableMotion( false )
	end

	self:GetOwner( ):AddCleanup( "expadv", ExpAdv )

	EXPADV.RequestCode(self:GetOwner(), ExpAdv)

	return true
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Right Click
   --- */

function TOOL:RightClick( Trace )
	if CLIENT then
		return
	elseif !IsValid(Trace.Entity) or self:GetOwner():EyePos():Distance( Trace.Entity:GetPos() ) > 156 then
		-- Do nothing.
	elseif self:GetStage() == 0 and Trace.Entity:IsVehicle() then
		self:SetStage(1)
		self.TargetPod = Trace.Entity
		return true
	elseif self:GetStage() == 0 and Trace.Entity.ExpAdv then
		EXPADV.SendToEditor(self:GetOwner(), Trace.Entity)
		return true
	elseif self:GetStage() == 1 and Trace.Entity.ExpAdv then
		EXPADV.Notifi(self:GetOwner(), "Pod has been linked to gate.", nil, 1 )
		Trace.Entity:LinkPod(self.TargetPod)
		self.TargetPod = nil
		self:SetStage(0)
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

		local PropList = vgui.Create( "PropSelect" )
		PropList:SetConVar( "expadv_gate_model" )

		for _, Model in pairs( GateModels ) do
			PropList:AddModel( Model, false )
		end

		CPanel:AddItem( PropList )

		CPanel:CheckBox( "Create Welded", "expadv_gate_weld" )
		CPanel:CheckBox( "Create Frozen", "expadv_gate_frozen" )
		CPanel:CheckBox( "Create Welded to World", "expadv_gate_weldworld" )
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