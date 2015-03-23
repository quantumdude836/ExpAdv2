if !EXPADV then return ErrorNoHalt( "Expression Advanced 2, Failed to load tool." ) end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Language
   --- */

if CLIENT then
	language.Add( "Tool.expadv2.name", "Expression Advanced 2" )
	language.Add( "Tool.expadv2.desc", "ExpAdv2 - Scriptable ingame gates and screens." )
	language.Add( "Tool.expadv2.help", "LMB: Spawn ExpAdv2; RMB: Download code from ExpAdv2 || Select pod to link to ExpAdv2" )
	language.Add( "Tool.expadv2.0", "LMB: Spawn ExpAdv2; RMB: Download code from ExpAdv2 || Select pod to link to ExpAdv2" )
	language.Add( "Tool.expadv2.1", "Now right click the ExpAdv2 you wish to link this to." )
	
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
TOOL.ClientConVar.screen 		= 0
TOOL.ClientConVar.derma			= 0
TOOL.ClientConVar.weld		 	= 0
TOOL.ClientConVar.weldworld 	= 0
TOOL.ClientConVar.frozen		= 0
TOOL.ClientConVar.resolution	= 512

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
	@: Utility
   --- */

local function IsExpAdv( Entity )
	if !IsValid( Entity ) then return false end
	return Entity.Base == "expadv_base" or Entity.ExpAdv
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

local function MakeExpadvScreen( Player, Position, Angle, Model, InPorts, OutPorts, Resolution )
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

duplicator.RegisterEntityClass( "expadv_screen", MakeExpadvScreen, "Pos", "Ang", "Model", "DupeInPorts", "DupeOutPorts")

local function MakeExpadvScreenDerma( Player, Position, Angle, Model, InPorts, OutPorts, Resolution )
	if Player:GetCount( "expadv" ) > EXPADV.ReadSetting( "limit", 20 ) then
		Player:LimitHit( "Expression Advanced entity limit reached." )
		return nil
	end
	
	local ExpAdv = ents.Create( "expadv_scr_vgui" )
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

duplicator.RegisterEntityClass( "expadv_scr_vgui", MakeExpadvScreenDerma, "Pos", "Ang", "Model", "DupeInPorts", "DupeOutPorts")

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

	if self:GetClientNumber( "screen" ) == 1 then

		if self:GetClientNumber( "derma" ) == 1 then
			ExpAdv = MakeExpadvScreenDerma( self:GetOwner( ), Trace.HitPos, Ang, Model, nil, nil, Resolution )
		else
			ExpAdv = MakeExpadvScreen( self:GetOwner( ), Trace.HitPos, Ang, Model, nil, nil, Resolution )
		end

		if IsValid(ExpAdv) then
			ExpAdv:SetResolution(self:GetClientNumber( "resolution" ) or 512)
		end
	else
		ExpAdv = MakeExpadv( self:GetOwner( ), Trace.HitPos, Ang, Model, nil, nil )
	end

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
		PropList:SetConVar( "expadv2_model" )
		CPanel:AddItem( PropList )

		local Screen = CPanel:CheckBox( "Create screen", "expadv2_screen" )
		local Derma = CPanel:CheckBox( "Use VGUI for Screen", "expadv2_derma" )
		local CheckWeld  = CPanel:CheckBox( "Create Welded", "expadv2_weld" )
		local CheckFroze = CPanel:CheckBox( "Create Frozen", "expadv2_frozen" )
		local CheckWorld = CPanel:CheckBox( "Create Welded to World", "expadv2_weldworld" )


		local ResLabel = vgui.Create("DLabel")
		ResLabel:SetText("Screen Resolution:")
		ResLabel:SetDark()

		local Resolution = vgui.Create( "DComboBox" )
		Resolution:SetValue(512)
		Resolution:AddChoice("256", 256)
		Resolution:AddChoice("512", 512)
		Resolution:AddChoice("1024", 1024)
		--Because you cant see the text, or change the text color lets get hacky :D
		function Resolution:Paint(w, h)
			surface.SetDrawColor(50, 50, 50, 255)
			surface.DrawRect(0, 0, w, h)
		end

		Resolution.OnSelect = function(self, index, value)
			RunConsoleCommand( "expadv2_resolution", value )
		end

		CPanel:AddItem(ResLabel)
		CPanel:AddItem(Resolution)

		local function AddModel( Mdl, IsScreen )
			local Icon = vgui.Create( "SpawnIcon", PropList )
			Icon:SetModel( Mdl )
			Icon:SetToolTip( Mdl )
			Icon.Model = Mdl

			Icon.DoClick = function( ) 			
				RunConsoleCommand( "expadv2_screen", IsScreen and 1 or 0 )
				RunConsoleCommand( "expadv2_model", Mdl )
				Screen:SetValue(IsScreen)
				Resolution:SetVisible(IsScreen)
				ResLabel:SetVisible(IsScreen)
			end

			PropList.List:AddItem( Icon )
			table.insert( PropList.Controls, Icon )
		end

		for _, Model in pairs( GateModels ) do
			AddModel( Model, false )
		end

		for Model, _ in pairs( EXPADV.Monitors ) do
			AddModel( Model, true )
		end

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