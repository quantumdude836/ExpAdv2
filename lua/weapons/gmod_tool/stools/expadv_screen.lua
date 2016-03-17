if !EXPADV then return ErrorNoHalt( "Expression Advanced 2, Failed to load tool." ) end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Language
   --- */

if CLIENT then
	language.Add( "Tool.expadv_screen.name", "Expression Advanced 2 - Screen" )
	language.Add( "Tool.expadv_screen.desc", "Creates an ingame scripted entity." )
	language.Add( "Tool.expadv_screen.0", "LMB: Spawn Screen or upload to screen; RMB: Download from screen or select a pod to link." )
	language.Add( "Tool.expadv_screen.1", "RMB: Now click the Screen you wish to link to this pod." )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Tool Information
   --- */

	TOOL.Name						= "ExpAdv2 Screen"
	TOOL.Category					= "Expadv2"

if WireLib then
	TOOL.Tab						= "Wire"
		TOOL.Wire_MultiCategories	= { "Visuals/Screens" }
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Cvars
   --- */

TOOL.ClientConVar.model 		= "models/props_phx/construct/metal_plate1.mdl"
TOOL.ClientConVar.derma			= 0
TOOL.ClientConVar.weld		 	= 0
TOOL.ClientConVar.weldworld 	= 0
TOOL.ClientConVar.frozen		= 0
TOOL.ClientConVar.resolution	= 512

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

	Player:AddCount( "expadv_screens", ExpAdv )
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

	Player:AddCount( "expadv_screens", ExpAdv )
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

	if self:GetClientNumber( "derma" ) == 1 then
		ExpAdv = MakeExpadvScreenDerma( self:GetOwner( ), Trace.HitPos, Ang, Model, nil, nil, Resolution )
	else
		ExpAdv = MakeExpadvScreen( self:GetOwner( ), Trace.HitPos, Ang, Model, nil, nil, Resolution )
	end

	if IsValid(ExpAdv) then
		ExpAdv:SetResolution(self:GetClientNumber( "resolution" ) or 512)
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
		PropList:SetConVar( "expadv_screen_model" )

		for Model, _ in pairs( EXPADV.Monitors ) do
			PropList:AddModel( Model )
		end

		CPanel:AddItem( PropList )
		CPanel:CheckBox( "Derma Integration", "expadv_screen_derma" )
		CPanel:CheckBox( "Create Welded", "expadv_screen_weld" )
		CPanel:CheckBox( "Create Frozen", "expadv_screen_frozen" )
		CPanel:CheckBox( "Create Welded to World", "expadv_screen_weldworld" )

		local ResLabel = vgui.Create("DLabel")
		ResLabel:SetText("Screen Resolution:")
		ResLabel:SetDark()

		local Resolution = vgui.Create( "DComboBox" )
		Resolution:SetValue(512)
		Resolution:AddChoice("256", 256)
		Resolution:AddChoice("512", 512)
		Resolution:AddChoice("1024", 1024)

		function Resolution:Paint(w, h)
			surface.SetDrawColor(50, 50, 50, 255)
			surface.DrawRect(0, 0, w, h)
		end

		Resolution.OnSelect = function(self, index, value)
			RunConsoleCommand( "expadv_screen_resolution", value )
		end

		CPanel:AddItem(ResLabel)
		CPanel:AddItem(Resolution)
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
