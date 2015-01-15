/*local function PaintServer( Gate, w, h )
    
    local percentage = 0
    local compileStatus = Gate:GetServerCompletion( ) or 0
    
    if compileStatus < 100 then
    	if compileStatus > 0 then percentage = compileStatus / 100 end

       -- TODO: Loading Overlay
    else
    	local state = Gate:GetServerState(0)
    	local tick = Gate:GetTickQuota(0)
    	local average = Gate:GetAverage(0) 
    	local cpu = Gate:GetStopWatch(0)

    	-- TODO: Overlay

    	if average > 0 then percentage = average / 100 end
    end

    --local x, y = ((w*0.5)-20)+(math.sin(percentage*180)*100),((h*0.5)-20)+(math.cos(percentage*180)*100),
    --surface.SetMaterial(Material("fugue/arrow-090.png"))
    --surface.DrawTexturedRect(x, y, 20, 200, 0)
end*/

/* --- --------------------------------------------------------------------------------
	@: Feature Button
   --- */

local PANEL = {
	Mat_Yes = Material("fugue/tick.png"),
	Mat_No = Material("fugue/cross-script.png"),
	Mat_Block = Material("fugue/lock-warning.png")
}

AccessorFunc( PANEL, "_value", "Value", FORCE_BOOL )
AccessorFunc( PANEL, "_blocked", "IsBlocked", FORCE_BOOL )
AccessorFunc( PANEL, "_canBlock", "CanBlock", FORCE_BOOL )
AccessorFunc( PANEL, "m_Material", "Material" )

function PANEL:Init()
	self:SetDrawBackground(false)
	self:SetDrawBorder(false)
	self:SetText("")
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(Color(200, 200, 200, 255))

	if self.Hovered then
		surface.SetDrawColor(Color(255, 255, 255, 255))
	end

	surface.SetMaterial(self.m_Material)
	surface.DrawTexturedRect(0, 0, w, h)

	if self:GetCanBlock() and self:GetIsBlocked() then
		surface.SetMaterial(self.Mat_Block)
	elseif self:GetValue() then
		surface.SetMaterial(self.Mat_Yes)
	else
		surface.SetMaterial(self.Mat_No)
	end

	surface.SetDrawColor(Color(255, 255, 255, 255))
	surface.DrawTexturedRect(10, 10, w - 20, h - 20)
end

function PANEL:SetImage(image)
	if type(image) == "string" then image = Material(image) end
	self:SetMaterial(image)
end

function PANEL:OnChanged(Value, IsBlocked)
	-- Stub
end

function PANEL:DoClick()
	if self._value and self._canBlock then
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
end

vgui.Register( "EA_Feature", PANEL, "DButton" ) 

/* --- --------------------------------------------------------------------------------
	@: OverLay
   --- */

function EXPADV.CreateOverlay(Gate)
	if !IsValid(Gate) or !Gate.ExpAdv then return end
	if IsValid(Gate.Overlay) then Gate.Overlay:Remove() end

	local Panel = vgui.Create("DPanel")

	Panel.Items = { }
	
	function Panel:Paint(w, h)
		surface.SetFont("default")

		surface.SetMaterial(Material("tek/5.png"))
		surface.SetDrawColor(Color(255, 255, 255, 255))
		surface.DrawTexturedRect(0, 0, w, h)

		for k, item in pairs(self.Items) do
			local x, y = item:GetPos()
			local _w, _h = item:GetSize()

			surface.SetDrawColor(Color(0, 0, 0, 150))
			surface.SetMaterial(Material("omicron/lemongear.png"))
			surface.DrawTexturedRect(x - 20, y - 20, _w + 36, _h + 36)

			surface.SetDrawColor(Color(255, 255, 255, 150))
			surface.SetMaterial(Material("omicron/lemongear.png"))
			surface.DrawTexturedRect(x - 16, y - 16, _w + 32, _h + 32)
		end

		local playerName = "WorldSpwaned"
		if IsValid(Gate.player) then playerName = Gate.player:Name() end
		
		draw.SimpleText(Gate:GetGateName() or "Generic", "ExpAdv_OverlayFont", w*0.35, h*0.5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(playerName, "ExpAdv_OverlayFont", w*0.65, h*0.5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

		surface.SetDrawColor(Color(255,255,255))
		surface.DrawLine((w*0.5)-200, (h*0.5)-20, (w*0.5)+200, (h*0.5)-20)
		surface.DrawLine((w*0.5)-200, (h*0.5)+20, (w*0.5)+200, (h*0.5)+20)


	end

	function Panel:Think()
		if !IsValid(Gate) then return self:Remove() end

		local toScreenData = Gate:GetPos():ToScreen()
		if !toScreenData.visible then return self:Remove() end

		self:SetPos(toScreenData.x - (self:GetWide() * 0.5), toScreenData.y - (self:GetTall() * 0.5))
		self:PerformLayout()
	end

	for Feature, Info in pairs(EXPADV.Features) do
		local FeatureBox = Panel:Add("EA_Feature")
		FeatureBox:SetSize(64,64)
		FeatureBox:SetCanBlock(true)
		FeatureBox:SetImage(Info.Icon or "fugue/bug.png")
		FeatureBox:SetTooltip(string.format("%s: %s", Feature, Info.Description or ""))

		FeatureBox:SetValue(EXPADV.GetAcessToFeatureForEntity(Gate, Feature))
		FeatureBox:SetIsBlocked(EXPADV.IsFeatureBlockedForEntity(Gate, Feature))

		function FeatureBox:OnChanged(value, blocked)
			EXPADV.SetAcessToFeatureForEntity(Gate, Feature, value)
			EXPADV.SetFeatureBlockedForEntity(Gate, Feature, blocked)
		end
		
		Panel.Items[#Panel.Items + 1] = FeatureBox
	end

	local Restart = Panel:Add("DImageButton")
	Restart:SetSize(64,64)
	Restart:SetImage("fugue/arrow-retweet.png")
	Restart:SetTooltip("Restart this Script, clientside.")

	Panel.Items[#Panel.Items + 1] = Restart


	function Panel:PerformLayout()
		self:SetSize(600, 600)

		local count = #self.Items
		if count == 0 then return end

		local tall = self:GetTall() * 0.5
		local step = 360 / (count + 2)
		local s = tall * 0.7

		for i = 1, count do
			local item = self.Items[i]

			local x = ((self:GetWide()*0.5)+(math.sin(i*step)*s))-(item:GetWide()*0.5)
			local y = (tall+(math.cos(i*step)*s))-(item:GetTall()*0.5)

			item:SetPos(x, y)
		end
	end


	Gate.Overlay = Panel

	return Panel
end

/* --- --------------------------------------------------------------------------------
	@: Features Key
   --- */

local Key_State = false
local Active_Panel

hook.Add("Think", "expadv.features", function()
	local state = input.IsKeyDown(KEY_P)

	if state == Key_State then return end

	if state and !Active_Panel then
		local Gate = LocalPlayer():GetEyeTrace().Entity
		Active_Panel = EXPADV.CreateOverlay(Gate)
	elseif state then
		Active_Panel:Remove()
		Active_Panel = nil
	end

	Key_State = state
end)