if !EXPADV then return ErrorNoHalt( "Expression Advanced 2, Failed to load peripheral tool." ) end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Language
   --- */

if CLIENT then
	language.Add( "Tool.expadv2_peripheral.name", "Peripheral" )
	language.Add( "Tool.expadv2_peripheral.desc", "Create an Expression advanced Peripheral." )
	language.Add( "Tool.expadv2_peripheral.help", "TODO - Replace me!" )
	
	language.Add( "Tool.expadv2_peripheral.0", "Left click to create peripheral, Right click to link Expression Advanced or Peripheral." )
	language.Add( "Tool.expadv2_peripheral.1", "Now link an Expression Advanced." )
	language.Add( "Tool.expadv2_peripheral.2", "Now link a or create a peripheral." )

	language.Add( "limit_expadv_peripheral", "Expression Advanced peripheral limit reached." )
	language.Add( "Undone_expadv_peripheral", "Expression Advanced - Removed peripheral." )
	language.Add( "Cleanup_expadv_peripheral", "Expression Advanced - Removed peripheral." )
	language.Add( "Cleaned_expadvs_peripheral", "Expression Advanced - Removed all peripherals." )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Tool Information
   --- */

if WireLib then
	TOOL.Name						= "Peripheral - Expression Advanced 2"
	TOOL.Category					= "Chips, Gates"
	TOOL.Tab						= "Wire"
else
	TOOL.Name						= "Peripheral - Expression Advanced 2"
	TOOL.Category					= "Scriptable"
	TOOL.Tab						= "Tools"
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Cvars
   --- */

TOOL.ClientConVar.Model 		= ""
TOOL.ClientConVar.Peripheral 	= ""
TOOL.ClientConVar.Weldworld 	= 0
TOOL.ClientConVar.Frozen		= 0

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: 
   --- */

function TOOL:RightClick( Trace )
	if CLIENT or !IsValid(Trace.Entity) then
		return false
	elseif self:GetStage( ) == 0 and Trace.Entity.ExpAdv then
		self.ExpAdv = Trace.Entity
		self:SetStage( 2 )
	elseif self:GetStage( ) == 0 and Trace.Entity.IsPeripheral then
		self.Peripheral = Trace.Entity
		self:SetStage( 1 )
	elseif self:GetStage( ) == 2 and Trace.Entity.IsPeripheral then
		self:SetStage(0)
		if IsValid(self.ExpAdv) then
			self.ExpAdv:AddPeripheral(Trace.Entity)
			self.ExpAdv = nil
		end
	elseif self:GetStage( ) == 1 and Trace.Entity.ExpAdv then
		self:SetStage(0)
		if IsValid(self.Peripheral) then
			Trace.Entity:AddPeripheral(self.Peripheral)
			self.Peripheral = nil
		end
	end
end


/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: 
   --- */

function TOOL:LeftClick( Trace )
	if CLIENT or self:GetStage( ) == 1 then
		return false
	end

	local Type = self:GetClientInfo(  "peripheral" )
	if !EXPADV.Peripherals[Type] then return false end

	local Peripheral = EXPADV.Peripherals[Type].Spawn( Trace, self:GetOwner( ) )
	if !IsValid(Peripheral) then return end

	local WeldWorld = self:GetClientNumber( "weldworld" )

	undo.Create( "expadv_peripheral" )
	undo.AddEntity( Peripheral )
	undo.SetPlayer( self:GetOwner( ) ) 

	if self:GetClientNumber( "weld" ) >= 1 then
		if !IsValid( Trace.Entity ) and WeldWorld then
			undo.AddEntity( constraint.Weld( Peripheral, Trace.Entity, 0, Trace.PhysicsBone, 0, 0, WeldWorld ) )
		end 
	end

	undo.Finish( )

	if self:GetClientNumber("frozen") >= 1 then
		Peripheral:GetPhysicsObject( ):EnableMotion( false )
	end

	
	self:GetOwner( ):AddCleanup( "expadv2_peripheral", Peripheral )

	if self:GetStage( ) == 2 and IsValid( self.ExpAdv ) then
		self:SetStage(0)
		if IsValid(self.ExpAdv) then
			self.ExpAdv:AddPeripheral(Peripheral)
			self.ExpAdv = nil
		end
	elseif self:GetStage( ) == 0 then
		self.Peripheral = Peripheral
		self:SetStage( 1 )
	end

	return true
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Tool Panel
   --- */

if CLIENT then
	function TOOL.BuildCPanel( Panel )
		local PerType = Panel:ComboBox( "Peripheral" )

		local Models = vgui.Create( "PropSelect" )
		Models:SetConVar( "expadv2_peripheral_model" )
		Panel:AddItem( Models )

		local PanSel = Panel:PanelSelect(  )
		local WeldWorld = Panel:CheckBox( "Weld peripheral to world.", "expadv2_peripheral_weldworld" )
		local MakeFrozen = Panel:CheckBox( "Freeze peripheral.", "expadv2_peripheral_frozen" )

		local Panels = { }

		for Name, Info in pairs( EXPADV.Peripherals ) do
			PerType:AddChoice( Name )

			if Info.ToolPanel then
				local Pnl = vgui.Create( "DForm" )
				Info.ToolPanel( Pnl )
				PanSel:AddPanel( Pnl )
				Panels[Name] = Pnl
			end
		end

		PerType.OnSelect = function( panel, Index, Value )
			local Peripheral = EXPADV.Peripherals[Value]
			if !Peripheral then return end

			RunConsoleCommand( "expadv2_peripheral_peripheral", Value )

			if !Panels[Value] then
				PanSel:SetVisible( false )
				-- TODO: Shrink out of existance.
			else
				PanSel:SelectPanel( Panels[Value] )
				PanSel:SetVisible( true )
			end

			DScrollPanel.Clear( Models.List )

			if !Peripheral.Models then
				Models:SetVisible( false )
				-- TODO: Shrink out of existance.
			else
				Models:SetVisible( true )
				for _, Model in pairs( Peripheral.Models ) do
					Models:AddModel( Model )
				end
			end

			Panel:InvalidateLayout( true )
		end

		Models:SetVisible( false )
		PanSel:SetVisible( false )
		PerType:ChooseOptionID( 1 )
	end
end