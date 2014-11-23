local PANEL = { }

PANEL.Font = nil
PANEL.FontWidth = nil
PANEL.FontHeight = nil

PANEL.Caret = nil

PANEL.Active = false

PANEL.MaxFunctions = 10
PANEL.Functions = { }

PANEL.Selected = 1
PANEL.Width = 0

PANEL.Info = nil

function PANEL:Init()
	self.Font = self:GetParent().Font
	self.FontWidth = self:GetParent().FontWidth
	self.FontHeight = self:GetParent().FontHeight
	
	self.Selected = 0
	
	self.Active = false
	
	self:Update()
	
	if self.Info == nil then self:CreateInfo() end
	
	if #self.Functions == 0 then self:CloseAll() end
end

function pairsByKeys (t, f)
      local a = {}
      for n in pairs(t) do table.insert(a, n) end
      table.sort(a, f)
      local i = 0      -- iterator variable
      local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
      end
      return iter
end

function PANEL:Update() 
	self.Caret = self:GetParent().Caret
	self.Width = 0
	self.Functions = { }
	
	local Comma = false
	local Line = string.sub(string.Split(self:GetParent():GetCode(), "\n")[self.Caret.x], 0, self.Caret.y - 1)
	local Pos = string.find(string.reverse(Line), "[ \\.,\\(\\)\\{\\}]", 0)
	if Pos != nil then
		Pos = Pos - 2
	end
	if string.sub(string.sub(Line, string.len(Line) - (Pos or string.len(Line)) - 1, string.len(Line) - (Pos or string.len(Line))), 0, 1) == "." then Comma = true end
	Line = string.sub(Line, string.len(Line) - (Pos or string.len(Line)))
	
	local firstLetter = string.sub(Line, 1, 1) // engage hacky methods..... GO!
	if string.len(Line) == 0 || firstLetter == string.upper(firstLetter) then self:CloseAll(); return end

	for Index, Operator in pairsByKeys( EXPADV.Functions ) do
		if #self.Functions > self.MaxFunctions then break end
		if string.lower(string.sub(Operator.Name, 0, string.len(Line))) == string.lower(Line) then
			if Operator.Method and Comma or !Operator.Method and !Comma then
				table.insert(self.Functions, Operator)
				local Len = string.len((Operator.Method and EXPADV.TypeName(table.remove(table.Copy(Operator.Input), 1)) .. "." or "") .. Operator.Name) * self.FontWidth + 10
				if(Len > self.Width) then self.Width = Len end
			end
		end
	end
	
	self:SetSize(self.Width, self.FontHeight * math.Clamp(#self.Functions, 3, PANEL.MaxFunctions))
	
	if self.Functions[self.Selected] == nil and self.Selected != 0 then self.Selected = 1 end
	if #self.Functions == 0 then self:CloseAll() end
end

function PANEL:Scroll(Dir)
	self.Selected = self.Selected + Dir
	if(self.Selected > math.Clamp(#self.Functions, 0, self.MaxFunctions)) then self.Selected = 1 end
	if(self.Selected < 1) then self.Selected = math.Clamp(#self.Functions, 0, self.MaxFunctions) end
	self:OpenInfo()
end

function PANEL:Apply() 
	if self.Functions[self.Selected] == nil then return end
	local Code = self:GetParent():GetCode()
	local Line = string.sub(string.Split(Code, "\n")[self.Caret.x], 0, self.Caret.y - 1)
	local Pos = string.find(string.reverse(Line), "[ \\.,\\(\\)\\{\\}]", 0)
	if Pos != nil then
		Pos = Pos - 1
	end
	local Split1 = string.sub(Line, 0, string.len(Line) - (Pos or string.len(Line)))
	local Split2 = string.sub(string.Split(Code, "\n")[self.Caret.x], self.Caret.y)
	local Temp = string.Split(Code, "\n")
	Temp[self.Caret.x] = Split1 .. self.Functions[self.Selected].Name .. Split2
	local Scroll = self:GetParent().Scroll
	self:GetParent():SetCode(string.Implode("\n",Temp))
	self:GetParent().Caret = Vector2(self.Caret.x, string.len(Split1 .. self.Functions[self.Selected].Name) + 1) 
	self:GetParent().Start = self:GetParent().Caret
	self:GetParent().Scroll = Scroll
	self:GetParent().ScrollBar:SetScroll(Scroll.x - 1)
	self:GetParent().hScrollBar:SetScroll(Scroll.y - 1)
	self:CloseAll()
end

function PANEL:OnMousePressed( code )
	if code == MOUSE_LEFT then 
		local x, y = self:CursorPos( ) 
		if x <= self.Width and self.Functions[math.floor(y / self.FontHeight) + 1] != nil then
			self.Selected = math.floor(y / self.FontHeight) + 1
			self:Apply()
		end
	end
end

function PANEL:DrawText(text, x, y, w) 
	local Line = 0
	local exploded = string.Explode("\n", text)
	for _,v in pairs(exploded) do
		if string.len(v) * self.FontWidth >= w then
			Str = v
			while string.len(Str) > 0 do
				surface.SetTextPos(x, y + Line * self.FontHeight)
				surface.DrawText(string.sub(Str, 0, math.floor(w / self.FontWidth) - 1))
				Str = string.sub(Str, math.floor(w / self.FontWidth))
				Line = Line + 1
			end
		else		
			surface.SetTextPos(x, y + Line * self.FontHeight)
			surface.DrawText(v)
			Line = Line + 1
		end
	end
end

function PANEL:Paint(w, h) 
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawRect( 0, 0, self.Width, h )
	surface.SetDrawColor( 90, 90, 90, 255 )
	surface.DrawOutlinedRect( 0, 0, self.Width, h )
	
	surface.SetFont(self.Font)
	surface.SetTextColor(255, 255, 255, 255)
	
	for I=1, self.MaxFunctions do
		if self.Functions[I] == nil then break end
		
		if self.Selected == I then
			surface.SetDrawColor(120, 120, 120, 255)
			surface.DrawRect(0, (I-1) * self.FontHeight, self.Width, self.FontHeight)
		end
		surface.SetTextPos(5, (I-1) * self.FontHeight) 
		surface.DrawText((self.Functions[I].Method and EXPADV.TypeName(table.remove(table.Copy(self.Functions[I].Input), 1)) .. "." or "") .. self.Functions[I].Name)		
	end
	
	----- Info ----- 
	
	--[[if self.Functions[self.Selected] == nil then return end
	
	surface.SetDrawColor( 90, 90, 90, 150 )
	surface.DrawRect(300, 0, 300, h)
	self:DrawText((self.Functions[self.Selected].Method and EXPADV.TypeName(table.remove(table.Copy(self.Functions[self.Selected].Input), 1)) .. "." or "")  
	.. self.Functions[self.Selected].Name .. "(" .. self:NamePerams(self.Functions[self.Selected].Input, self.Functions[self.Selected].InputCount, self.Functions[self.Selected].UsesVarg) .. ")\n" 
	.. "Returns " .. (EXPADV.TypeName(self.Functions[self.Selected].Return or "") or "void") .. "\n\n" 
	.. , 305, 5, 300) 
	]]--
end

function PANEL:CreateInfo()
	self.Info = self:GetParent():Add("DPanel")
	self.Info.Paint = function(u, w, h) 
		surface.SetDrawColor( 90, 90, 90, 150 )
		surface.DrawRect(0, 0, w, h)
	end
	self.Info:SetVisible(false)
	
	self.Info.Text = vgui.Create("RichText", self.Info)
	self.Info.Text:Dock(FILL)
	self.Info.Text:SetVerticalScrollbarEnabled(true)
	self.Info.Text:SetFGColor(Color(255,255,255,255))
end

function PANEL:OpenInfo( )
	if self.Functions[self.Selected] == nil then 
		self.Info:SetVisible(false)
		return 
	end
	local x, y = self:GetPos()
	local w, h = self:GetSize()
	self.Info:SetPos(x + w, y)
	self.Info:SetVisible(true)
	self.Info:SetSize(300, math.Clamp(h, 100, 500))
	
	self.Info.Text:SetFontInternal("TargetIDSmall")
	self.Info.Text:SetFGColor(Color(255, 255, 255, 255))
	self.Info.Text:SetText((self.Functions[self.Selected].Method and EXPADV.TypeName(table.remove(table.Copy(self.Functions[self.Selected].Input), 1)) .. "." or "")  
	.. self.Functions[self.Selected].Name .. "(" .. self:NamePerams(self.Functions[self.Selected].Input, self.Functions[self.Selected].InputCount, self.Functions[self.Selected].UsesVarg, self.Functions[self.Selected].Method == true) .. ")\n"
	.. "Returns " .. (EXPADV.TypeName(self.Functions[self.Selected].Return or "") or "void") 
	.. "\n\n" .. (self.Functions[self.Selected].Description or "No description"))
	
end

function PANEL:CloseInfo()
	if self.Info then
		self.Info:SetVisible(false)
	end
end

function PANEL:NamePerams( Perams, Count, Varg, Method )
	local Names = { }

	for I = 1, Count do
		if Perams[I] == "" or Perams[I] == "..." then break end
		Names[I] = EXPADV.TypeName( Perams[I] or "" )
		if Names[I] == "void" then Names[I] = nil; break end
	end
		
	if Varg then table.insert( Names, "..." ) end
	if Method then table.remove( Names, 1 ) end
	
	return table.concat( Names, ", " )
end

function PANEL:CloseAll( ) 
	self:SetVisible(false)
	self:CloseInfo()
end

vgui.Register( "EA_CodeCompletion", PANEL, "DPanel" ) 