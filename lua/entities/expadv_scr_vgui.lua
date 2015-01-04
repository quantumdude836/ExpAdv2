/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Shared Info!
   --- */

AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base 			= "expadv_screen"
ENT.ExpAdv 			= true
ENT.Screen 			= true
ENT.ScreenDerma 	= true

if SERVER then return end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Derma:
	@: Contributions from Overv, Divran, Python, Rusketh
   --- */

local function SetParent( self, Parent )
	if Parent then
		local Prev_Parent = self.Parent
		
		if Prev_Parent and Prev_Parent._Children then
			Prev_Parent._Children[self] = nil
		end

		if !Parent._Children then Parent._Children = {} end

		Parent._Children[self] = true
	end

	self.Parent = Parent

	self._SetParent( self, Parent )
end

function ENT:CreateDermaObject( Panel, Parent )
	if isstring(Panel) then Panel = vgui.Create(Panel) end

	if !ValidPanel(Panel) then return end -- Now thats sorted :D

	if !Parent and Parent != false then Parent = self.Panel end

	Panel.Parent = Parent
	Panel:SetParent(Parent)

	if Parent then 
		if !Parent._Children then Parent._Children = {} end
		Parent._Children[Panel] = true
	end
		
	if Panel.SetParent then
		Panel._SetParent = Panel.SetParent

		Panel.SetParent = SetParent
	end
	
	if Panel.CursorPos then
		Panel._CursorPos = Panel.CursorPos

		function Panel.CursorPos(Panel)
			local X, Y = self:absolutePanelPos(Panel)
			local x, y = self:getCursorPos()
			
			X = x - X
			Y = y - Y
			
			return X,Y
		end
	end
	
	return Panel
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Entity
   --- */

function ENT:Initialize()
	self.Attack1 = false
	self.Attack2 = false
	self.In_Use   = false
	self.Hovered = false

	self.Panel = self:CreateDermaObject( "EditablePanel" )
	self.Cursor_Image = self:CreateDermaObject( "DImage" )
	self.Cursor_Image:SetImage("omicron/lemongear.png")
	self.Cursor_Image:SetSize(16, 16)
	self.Cursor_Image:SetVisible(false)

	local Panel = vgui.Create( "EditablePanel" )

	self.BaseClass.Initialize(self)
end

function ENT:OnRemove()
	if self.Panel and self.Panel:IsValid() then self.Panel:Remove() end

	self:RestoreGuiMouse()
end

function ENT:PostDrawScreen( Width, Height )
	if !ValidPanel(self.Panel) then return end

	self.Panel:SetSize(Width, Height)
	self.Panel:SetPos(0, 0)

	self:checkHover( self.Panel )
	self.Panel:SetPaintedManually( false )
	self.Panel:PaintManual()
	self.Panel:SetPaintedManually( true )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: gui.MouseX/Y fixes
	@: Author: Divran
   --- */

local Fixed, __X, __Y = false

function ENT:FixGuiMouse()
	if Fixed then return end

	Fixed = true

	 __X, __Y = gui.MouseX, gui.MouseY

	gui.MouseX, gui.MouseY = function()
		return self.CursorX or 0
	end, function()
		return self.CursorY or 0
	end
end
 
function ENT:RestoreGuiMouse()
	if !Fixed then return end

	Fixed = false

	gui.MouseX, gui.MouseY = __X, __Y
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: 3D2D vgui wrapper
	@: Author: Overv
   --- */

function ENT:getCursorPos()
	return self.CursorX or 0, self.CursorY or 0
end

function ENT:MouseX()
	return self.CursorX or 0
end

function ENT:MouseY()	
	return self.CursorY or 0
end

function ENT:absolutePanelPos( Panel )
	if !Panel or !Panel:IsValid() then return 0, 0 end

	if Panel.Parent then
		local x, y = self:absolutePanelPos( Panel.Parent )
		local xx, yy = Panel:GetPos()
		return x + xx, y + yy
	end

	return Panel:GetPos()
end
 
function ENT:pointInsidePanel( Panel, x, y )
	if !Panel or !Panel:IsValid() then return false end

	local px, py = self:absolutePanelPos( Panel )

	local sx, sy = Panel:GetSize()

	return x >= px and y >= py and x <= px + sx and y <= py + sy
end
 
function ENT:isMouseOver( Panel )
	return self:pointInsidePanel( Panel, self:getCursorPos() )
end
 
function ENT:checkHover( Panel )
	Panel.Hovered = self:pointInsidePanel( Panel, self:getCursorPos() )
	
	for Child in pairs( Panel._Children or {} ) do
		if Child:IsValid() then
			self:checkHover( Child )
		else
			Panel._Children[Child] = nil
		end
	end
end
 
function ENT:postPanelEvent( Panel, event, ... )
	if !Panel:IsValid() or !self:isMouseOver( Panel ) then return false end
	
	local handled = false
	
	for Child in pairs( Panel._Children or {} ) do
		if !Child:IsValid() then
			Panel._Children[child] = nil
		elseif self:postPanelEvent( Child, event, ... ) then
			handled = true
			break
		end
	end
	
	if !handled and Panel[ event ] then
		local ok, msg = pcall( Panel[ event ], Panel, ... )
		
		if !ok then
			self:LuaError( msg )
			-- TODO: Shutdown :D
		end

		return true
	end

	return false
end
 
function ENT:KeyPress( key )
	self:checkHover( self.Panel )
	self:postPanelEvent( self.Panel, "OnMousePressed", key )
end
 
function ENT:KeyRelease( key )
	self:checkHover( self.Panel )
	self:postPanelEvent( self.Panel, "OnMouseReleased", key )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Think - Brains :D
   --- */

function ENT:Think()
	self.BaseClass.Think(self)
 	
 	if !ValidPanel(self.Panel) then return end

 	local CursorPos = self:GetCursor( LocalPlayer() )
	self.CursorX = CursorPos.x
	self.CursorY = CursorPos.y

	self.Cursor_Image:SetPos(self.CursorX, self.CursorY)

 	if CursorPos.x == 0 and CursorPos.y == 0 then
 		if self.Hovered == true then self:RestoreGuiMouse() end

		self.Hovered = false

		return 
	end

	if self.Hovered == false then self:FixGuiMouse() end

	self.Hovered = true
	
	if LocalPlayer():KeyPressed( IN_USE ) then self:KeyPress( IN_USE ) end

	if LocalPlayer():KeyReleased( IN_USE ) then self:KeyRelease( IN_USE ) end
	
	local atk1 = input.IsMouseDown( MOUSE_LEFT )
	local iuse = input.IsMouseDown( IN_USE )

	if (!self.In_Use and iuse) then
		self.In_Use = true
		self:KeyPress( MOUSE_LEFT )
	elseif (self.In_Use and !iuse) then
		self.In_Use = false
		self:KeyRelease( MOUSE_LEFT )
	elseif (!self.Attack1 and atk1) then
		self.Attack1 = true
		self:KeyPress( MOUSE_LEFT )
	elseif (self.Attack1 and !atk1) then
		self.Attack1 = false
		self:KeyRelease( MOUSE_LEFT )
	end
	
	local atk2 = input.IsMouseDown( MOUSE_RIGHT )

	if (!self.Attack2 and atk2) then
		self.Attack2 = true
		self:KeyPress( MOUSE_LEFT )
	elseif (self.Attack2 and !atk2) then
		self.Attack2 = false
		self:KeyRelease( MOUSE_LEFT )
	end
end