if !EXPADV then return ErrorNoHalt( "Expression Advanced 2, Failed to load tool." ) end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Language
   --- */

if CLIENT then
	language.Add( "Tool.expadv_bot.name", "Expression Advanced 2 - bot" )
	language.Add( "Tool.expadv_bot.desc", "Creates an ingame scripted entity." )
	language.Add( "Tool.expadv_bot.0", "LMB: Spawn Gate or upload to bot; RMB: Download from bot or select a pod to link." )
	language.Add( "Tool.expadv_bot.1", "RMB: Now click the bot you wish to link to this pod." )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Tool Information
   --- */

	TOOL.Name						= "Bot"
	TOOL.Category					= "Expadv2"

if WireLib then
	TOOL.Tab						= "Wire"
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Cvars
   --- */

TOOL.ClientConVar.model 		= "models/alyx.mdl"

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Model List
   --- */

local botModels = { }

table.insert( botModels, "models/alyx.mdl" )
table.insert( botModels, "models/Barney.mdl" )
table.insert( botModels, "models/breen.mdl" )
table.insert( botModels, "models/Eli.mdl" )
table.insert( botModels, "models/gman_high.mdl" )
table.insert( botModels, "models/Kleiner.mdl" )
table.insert( botModels, "models/monk.mdl" )
table.insert( botModels, "models/odessa.mdl" )
table.insert( botModels, "models/vortigaunt.mdl" )
table.insert( botModels, "models/dog.mdl" )
table.insert( botModels, "models/mossman.mdl" )
table.insert( botModels, "models/Humans/Group01/Female_01.mdl" )
table.insert( botModels, "models/Humans/Group01/Female_03.mdl" )
table.insert( botModels, "models/Humans/Group01/Male_01.mdl" )
table.insert( botModels, "models/Humans/Group01/male_02.mdl" )
table.insert( botModels, "models/Combine_Super_Soldier.mdl" )
table.insert( botModels, "models/Combine_Strider.mdl" )
table.insert( botModels, "models/Combine_Soldier_PrisonGuard.mdl" )
table.insert( botModels, "models/Combine_Soldier.mdl" )
table.insert( botModels, "models/Combine_Scanner.mdl" )
table.insert( botModels, "models/manhack.mdl" )
table.insert( botModels, "models/Lamarr.mdl" )
table.insert( botModels, "models/Zombie/Classic.mdl" )
table.insert( botModels, "models/Zombie/Classic_torso.mdl" )
table.insert( botModels, "models/Zombie/Fast.mdl" )
table.insert( botModels, "models/AntLion.mdl" )
table.insert( botModels, "models/antlion_guard.mdl" )
table.insert( botModels, "models/headcrab.mdl" )
table.insert( botModels, "models/headcrabblack.mdl" )
table.insert( botModels, "models/Roller.mdl" )
table.insert( botModels, "models/Police.mdl" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Make bot Entity
   --- */

local function MakeExpadvbot( Player, Position, Angle, Model, InPorts, OutPorts )
	if Player:GetCount( "expadv" ) > EXPADV.ReadSetting( "limit", 20 ) then
		Player:LimitHit( "Expression Advanced entity limit reached." )
		return nil
	end
	
	local ExpAdv = ents.Create( "expadv_bot" )
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

duplicator.RegisterEntityClass( "expadv_bot", MakeExpadvbot, "Pos", "Ang", "Model", "DupeInPorts", "DupeOutPorts" )

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

	ExpAdv = MakeExpadvbot( self:GetOwner( ), Trace.HitPos, Ang, Model, nil, nil )

	if !IsValid( ExpAdv ) then return false end

	ExpAdv:SetPos( Trace.HitPos - Trace.HitNormal * ExpAdv:OBBMins().z )

	undo.Create( "expadv" )

	undo.AddEntity( ExpAdv )

	undo.SetPlayer( self:GetOwner( ) ) 

	undo.Finish( )

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
		PropList:SetConVar( "expadv_bot_model" )

		for _, Model in pairs( botModels ) do
			PropList:AddModel( Model, false )
		end

		CPanel:AddItem( PropList )
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