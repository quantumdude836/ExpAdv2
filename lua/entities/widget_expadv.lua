AddCSLuaFile()

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Right, I have never made a widget before, this could prove interesting.
	@: Ozzy && Black Sabbath, lets go...
   --- */

local WIDGET = { Base = "widget_base" }

function WIDGET:Initialize()
	self.BaseClass.Initialize( self )
	self:SetSize(20)
end

function WIDGET:DrawImage(X, Y, Size, Matrerial, Pos, Ang)
	render.SetMaterial( Matrerial )	

	cam.Start3D2D(Pos or self:GetPos(), Ang or self:GetAngles(), self:GetSize())
		surface.SetDrawColor(Color(255, 255, 255, 255))
		
		render.SetColorMaterialIgnoreZ()

		surface.DrawTexturedRect(X, Y, Size, Size)

		render.SetColorMaterial()	
	cam.End3D2D()
end

function WIDGET:Submit()
	local Target = self:GetTarget()

	if !IsValid(Target) or !Target.Submit then return end
	
	Target:Submit()
end

scripted_ents.Register( WIDGET, "widget_expadv_base" )

/*------------------------------------------------------------------------------------------------------------*/

local WIDGET = { Base = "widget_expadv_base" }

function WIDGET:Initialize()
	self.BaseClass.Initialize( self )
	self:SetCollisionBounds( Vector( -1, -1, -1 ), Vector( 1, 1, 1 ) )
	self:SetSolid( SOLID_NONE )

	self:SetImage("omicron/leamongear")
end

function WIDGET:Setup( Attach, Image, Position, Angle )
	self:SetImage(Image)
	self:SetTarget( Attach )
	self:SetParent( Attach )
	self:SetLocalPos( Position or Vector( 0, 0, 0 ) )
	self:SetLocalAngles( Angle or Angle( 0, 0, 0 ) )
end

function WIDGET:SetImage(Image)
	self.Image = Image
	self.Image_Mat = Material(Image)
end

function WIDGET:GetImage() return self.Image end

function WIDGET:OverlayRender()
	if !self.Image_Mat then return end
	
	self:DrawImage(0, 0, self:GetSize(), self.Image_Mat)
end

local widget_expadv_icon = WIDGET

scripted_ents.Register( WIDGET, "widget_expadv_icon" )

/*------------------------------------------------------------------------------------------------------------*/

local WIDGET = {
	Base = "widget_expadv_icon",
	
	Mat_Yes = Material("fugue/tick.png"),
	Mat_No = Material("fugue/cross-script.png"),
	Mat_Block = Material("fugue/headstone-cross.png")
}

AccessorFunc( WIDGET, "_value", "Value", FORCE_BOOL )
AccessorFunc( WIDGET, "_blocked", "IsBlocked", FORCE_BOOL )
AccessorFunc( WIDGET, "_canBlock", "CanBlock", FORCE_BOOL )

function WIDGET:Initialize()
	self.BaseClass.Initialize( self )
	self:SetCollisionBounds( Vector( -0.25, -0.25, -0.25 ), Vector( 0.25, 0.25, 0.25 ) )
end

function WIDGET:OverlayRender()
	self.BaseClass.OverlayRender( self )

	if self:GetCanBlock() and self:GetIsBlocked() then
		self:DrawImage(10, 10, 10, self.Mat_Block)
	elseif self:GetValue() then
		self:DrawImage(10, 10, 10, self.Mat_Yes)
	else
		self:DrawImage(10, 10, 10, self.Mat_No)
	end	
end

function WIDGET:OnChanged(Value, IsBlocked)
	-- Stub
end

function WIDGET:OnCkick()
	if SERVER then 
		return self:Submit()
	elseif self._value and self._canBlock then
		self._value = false
		self._blocked = true
	elseif self._value then
		self._value = false
		self._blocked = true
	elseif self._blocked then
		self._value = false
		self._blocked = false
	else
		self._value = true
		self._blocked = false
	end

	self:OnChanged(self._value, self._blocked)

	self:Submit()
end

local widget_expadv_feature = WIDGET

scripted_ents.Register( WIDGET, "widget_expadv_feature" )

/*------------------------------------------------------------------------------------------------------------*/

local WIDGET = { Base = "widget_expadv_base" }

function WIDGET:Initialize()
	self.BaseClass.Initialize( self )
	self:SetCollisionBounds( Vector( -10, -10, -10 ), Vector( 10, 10, 10 ) )
	self:SetSolid( SOLID_NONE )
	self.Items = { }
end

function WIDGET:Setup( Attach, Position, Angle )
	self:SetImage(Image)
	self:SetTarget( Attach )
	self:SetParent( Attach )
	self:SetLocalPos( Position or Vector( 0, 0, 0 ) )
	self:SetLocalAngles( Angle or Angle( 0, 0, 0 ) )
end

function WIDGET:AddItem(Item, bLayout)
	if table.HasValue(self.Items, Item) then return end

	Item:SetTarget( self )
	Item:SetParent( self )
	
	self:DeleteOnRemove(Item)

	self.Items[#self.Items + 1] = Item

	if bLayout then self:DoLayout() end

	return Item
end

function WIDGET:DoLayout()
	if #self.Items > 1 then return end
	
	local step = 360 / (#self.Items + 1)

	for k, Item in pairs(self.Items) do
		local i = (k * step)
		local x = math.cos(i) * self:GetSize() * 0.5
		local y = math.sin(i) * self:GetSize() * 0.5
		Item:SetLocalPos( Vector( x, y, Item:GetSize() ) )
	end
end

function WIDGET:OverlayRender()
	
	--TODO: Draw Background Donut
	
	if self:IsHovered() then
		-- TODO: Setup Highlight Stencil

		if self:IsPressed() then
			-- TODO: Draw Selection
			-- HIGHLIGHTED
		elseif self:IsHovered() then
			-- TODO: Draw Selection
			-- PRESSED
		elseif self:SomethingHovered() then
			-- TODO: Draw Selection
			-- FADED
		else
			-- TODO: Draw Selection
			-- NORMAL
		end

		-- TODO: Pop Stencil
	end

	-- TODO: Draw Inner Ring
end

local widget_expadv_menu = WIDGET

scripted_ents.Register( WIDGET, "widget_expadv_menu" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Ok, now we need to use these widgets
   --- */

local function AddEntityFeature(Gate, Widget, FeatureName)
	local Feature = EXPADV.Features[FeatureName]

	if !Feature then return end

	local Opt = ents.Create("widget_expadv_feature")
	Opt:Setup( self, Feature.Icon )
	Opt:SetCanBlock(true)
	Opt:Spawn()

	if EXPADV.IsFeatureBlockedForEntity( Gate, FeatureName ) then
		Opt:SetValue(false)
		Opt:SetIsBlocked(true)
	elseif EXPADV.GetAcessToFeatureForEntity( Gate, FeatureName ) then
		Opt:SetValue(true)
		Opt:SetIsBlocked(false)
	else
		Opt:SetValue(false)
		Opt:SetIsBlocked(false)
	end

	function Opt:OnChange(Value, Block)
		EXPADV.SetFeatureBlockedForEntity( Gate, FeatureName, Value )
		EXPADV.SetAcessToFeatureForEntity( Gate, FeatureName, Block )
	end

	Widget:AddItem(Opt)

	return Opt
end

function EXPADV.CreateOverLay(Gate)
	if !IsValid(Gate) or IsValid(Gate.Widget) then return false end

	Gate.widget = ents.Create("widget_expadv_menu")
	Gate.widget:Setup(Gate)

	AddEntityFeature(Gate, Gate.widget, "Sounds from url")
	AddEntityFeature(Gate, Gate.widget, "3D rendering")
	AddEntityFeature(Gate, Gate.widget, "HUD rendering")
	AddEntityFeature(Gate, Gate.widget, "File access")
	AddEntityFeature(Gate, Gate.widget, "Derma")

	Gate.widget:DoLayout()
	Gate.widget:Spawn()

	function Gate.widget.Submit()
		Gate.widget:Remove()
		Gate.widget = nil
	end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Note Pad:
   --- */

--LocalPlayer():GetHoveredWidget() == LocalPlayer():GetPressedWidget()
	 -- MIND CHANGE!