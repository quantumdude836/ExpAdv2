/* --- --------------------------------------------------------------------------------
	@: Expression Advanced 2 - IDE(A) v2.0
	@: Main Window
   --- */

	-- local Main = vgui.Create("DPanel")
	local Main = vgui.Create("EditablePanel")
	function Main:Paint( w, h ) 
		surface.SetDrawColor(Color(0,0,0))
		surface.DrawRect(0,0,w,h)
	end 
	
	Main:SetKeyBoardInputEnabled( true )
	Main:SetMouseInputEnabled( true )
	
	Main.TitleBar = vgui.Create("DPanel", Main)
	Main.SideBar = vgui.Create("DPanel", Main)
	Main.Canvas = vgui.Create("DPanel", Main)

	Main.TabBar = vgui.Create("DPanel", Main.TitleBar)
	Main.FileBar = vgui.Create("DPanel", Main.Canvas)
	Main.ValidateBar = vgui.Create("DPanel", Main.Canvas)
	
	Main.CanvasLeft = vgui.Create("DPanel")
	Main.CanvasRight = vgui.Create("DPanel")

	Main.Divider = vgui.Create("DHorizontalDivider", Main.Canvas)
	Main.Divider:SetLeft(Main.CanvasLeft)
	Main.Divider:SetRight(Main.CanvasRight)
	Main.Divider:SetDividerWidth( 5 )
	Main.Divider:SetLeftWidth( 200 )
	Main.Divider:SetLeftMin( 200 )
	Main.Divider:SetRightMin( 400 )

	Main.CanvasLeft.Bar = vgui.Create("DPanel", Main.CanvasLeft)
	Main.CanvasLeft.Canvas = vgui.Create("DPanel", Main.CanvasLeft)

	-- Main:SetBackgroundColor(Color(0, 0, 0))
	Main.TitleBar:SetBackgroundColor(Color(50, 50, 50))
	Main.SideBar:SetBackgroundColor(Color(50, 50, 50))
	Main.Canvas:SetBackgroundColor(Color(65, 65, 117))

	Main.CanvasLeft:SetBackgroundColor(Color(25, 25, 25))
	Main.CanvasRight:SetBackgroundColor(Color(25, 25, 25))

	Main.CanvasLeft.Bar:SetBackgroundColor(Color(50, 50, 50))
	Main.CanvasLeft.Canvas:SetBackgroundColor(Color(50, 50, 50))

	Main.TabBar:SetBackgroundColor(Color(70, 70, 70))
	Main.FileBar:SetBackgroundColor(Color(70, 70, 70))
	Main.ValidateBar:SetBackgroundColor(Color(0, 255, 0))

	Main.TitleText = vgui.Create("DLabel", Main.TitleBar)
	-- Main.TitleText:SetFont("DefaultLarge")
	Main.TitleText:SetFont("Trebuchet20")
	Main.TitleText:SetText("Expression Advanced 2 - IDE(A) v2.0")
	Main.TitleText:SizeToContents()

	Main.NewButton = vgui.Create("DImageButton", Main.TitleBar)
	Main.NewButton.DoClick = function() Main:NewCodeTab() end
	Main.NewButton:SetMaterial(Material("fugue/script--plus.png"))

	Main.SaveButton = vgui.Create("DImageButton", Main.FileBar)
	Main.SaveButton.DoClick = function() end
	Main.SaveButton:SetMaterial(Material("fugue/disk.png"))
	
	Main.SaveAsButton = vgui.Create("DImageButton", Main.FileBar)
	Main.SaveAsButton.DoClick = function() end
	Main.SaveAsButton:SetMaterial(Material("fugue/disks.png"))
	
	Main.OpenButton = vgui.Create("DImageButton", Main.FileBar)
	Main.OpenButton.DoClick = function() end
	Main.OpenButton:SetMaterial(Material("fugue/blue-folder-horizontal-open.png"))

	Main.CloseButton = vgui.Create("DImageButton", Main.SideBar)
	Main.CloseButton.DoClick = function() Main:Remove() end
	Main.CloseButton:SetMaterial(Material("fugue/cross-button.png"))

	Main.SettingsButton = vgui.Create("DImageButton", Main.CanvasLeft.Bar)
	Main.SettingsButton.DoClick = function() end
	Main.SettingsButton:SetMaterial(Material("fugue/gear.png"))

	Main.ComponentsButton = vgui.Create("DImageButton", Main.CanvasLeft.Bar)
	Main.ComponentsButton.DoClick = function() end
	Main.ComponentsButton:SetMaterial(Material("fugue/question.png"))

	Main.SessionButton = vgui.Create("DImageButton", Main.CanvasLeft.Bar)
	Main.SessionButton.DoClick = function() end
	Main.SessionButton:SetMaterial(Material("fugue/share.png"))

	Main.SoundButton = vgui.Create("DImageButton", Main.CanvasLeft.Bar)
	Main.SoundButton.DoClick = function() end
	Main.SoundButton:SetMaterial(Material("fugue/speaker-volume.png"))

	Main.FontUpButton = vgui.Create("DImageButton", Main.SideBar)
	Main.FontUpButton.DoClick = function() end
	Main.FontUpButton:SetMaterial(Material("fugue/edit-size-up.png"))

	Main.FontDownButton = vgui.Create("DImageButton", Main.SideBar)
	Main.FontDownButton.DoClick = function() end
	Main.FontDownButton:SetMaterial(Material("fugue/edit-size-down.png"))

	Main.VoiceButton = vgui.Create("DImageButton", Main.SideBar)
	Main.VoiceButton.DoClick = function() end
	Main.VoiceButton:SetMaterial(Material("fugue/microphone.png"))

/* --- --------------------------------------------------------------------------------
	@: Expression Advanced 2 - IDE(A) v2.0
	@: Main Window - Layout
   --- */

	Main.PerformLayout = function(Main, w, h)
		Main.TitleBar:SetPos(5, 5)
		Main.TitleBar:SetSize(w - 41, 30)

		Main.NewButton:SetPos(275, 7)
		Main.NewButton:SetSize(16, 16)

		Main.TabBar:SetPos(300, 5)
		Main.TabBar:SetSize(w - 305 - 41, 20)
		Main.TabBar:InvalidateLayout(true)

		Main.SideBar:SetPos(w - 31, 5)
		Main.SideBar:SetSize(26, h - 10)
		
		Main.CloseButton:SetPos(5, 5)
		Main.CloseButton:SetSize(16, 16)
		
		Main.FontUpButton:SetPos(5, 26)
		Main.FontUpButton:SetSize(16, 16)
		
		Main.FontDownButton:SetPos(5, 51)
		Main.FontDownButton:SetSize(16, 16)

		Main.VoiceButton:SetPos(5, h - 40)
		Main.VoiceButton:SetSize(16, 16)

		Main.TitleText:SetPos(5, 5)

		local cw, ch = w - 41, h - 45

		Main.Canvas:SetPos(5, 40)
		Main.Canvas:SetSize(cw, ch)

		Main.ValidateBar:SetPos(5, ch - 31)
		Main.ValidateBar:SetSize(cw - 87, 26)

		Main.FileBar:SetPos(cw - 77, ch - 31)
		Main.FileBar:SetSize(72, 26)

		Main.SaveButton:SetPos(5, 5)
		Main.SaveButton:SetSize(16, 16)

		Main.SaveAsButton:SetPos(26, 5)
		Main.SaveAsButton:SetSize(16, 16)

		Main.OpenButton:SetPos(51, 5)
		Main.OpenButton:SetSize(16, 16)

		Main.Divider:SetPos(5, 5)
		Main.Divider:SetSize(cw - 10, ch - 41)
		
		Main.CanvasLeft:InvalidateLayout(false)
	end

	Main.CanvasLeft.PerformLayout = function(CanvasLeft, w, h)
		Main.CanvasLeft.Bar:SetPos(5, 5)
		Main.CanvasLeft.Bar:SetSize(w - 10, 26)

		Main.SettingsButton:SetPos(5, 5)
		Main.SettingsButton:SetSize(16, 16)

		Main.SessionButton:SetPos(30, 5)
		Main.SessionButton:SetSize(16, 16)

		Main.SoundButton:SetPos(51, 5)
		Main.SoundButton:SetSize(16, 16)

		Main.ComponentsButton:SetPos(w - 31, 5)
		Main.ComponentsButton:SetSize(16, 16)

		Main.CanvasLeft.Canvas:SetPos(5, 36)
		Main.CanvasLeft.Canvas:SetSize(w - 10, h - 41)
	end

/* --- --------------------------------------------------------------------------------
	@: Expression Advanced 2 - IDE(A) v2.0
	@: Tabs
   --- */

	Main.Tabs = {}
	Main.TabsByFile = {}
	Main.ActiveTab = nil

	function Main:NewCodeTab(code, path, name)
		if path and self.TabsByFile[path] then
			return self:SetActiveTab(self.TabsByFile[path])
		end

		local pnl = vgui.Create("GOLEM_Editor")
		local tab = self:NewTab(pnl, name or "generic")
		
		if path then
			tab.file = path
			self.TabsByFile[path] = tab
		end
		
		self:SetActiveTab( tab )
		self:RequestFocus( )
	end

	function Main:NewTab(panel, name)
		local tab = vgui.Create("DButton", self.TabBar)
		tab:SetDrawBackground(false)
		tab.DoClick = function(tab) self:SetActiveTab(tab) end
		tab:SetText("")

		tab.Icon = vgui.Create("DImageButton", tab)
		tab.Icon.DoClick = function() self:CloseTab(tab, false) end
		tab.Icon.DoRightClick = function() self:CloseTab(tab, true) end
		tab.Icon:SetMaterial(Material("fugue/cross-script.png"))
		tab.Icon:SetSize(8, 8)

		tab.Text = vgui.Create("DLabel", tab)
		tab.Text.m_bDisabled = false
		tab.Text.DoClick = function(tab) self:SetActiveTab(tab) end
		tab.Text:SetText(name)

		tab.PerformLayout = function(tab, w, h)
			tab.Text:SizeToContents()
			tab.Text:SetPos(5, 2)

			local tw = tab.Text:GetWide()
			tab.Icon:SetPos(tw + 6, 4)

			tab:SetSize(tw + 16, 20)
		end

		tab.SetName = function(tab, name)
			tab.Text:SetText(name)
			Main.TabBar:InvalidateLayout(false)
		end

		panel:SetParent(self.CanvasRight)
		panel:SetVisible(false)
		panel:SetSize(0, 0)

		tab.GetPanel = function() return panel end

		self.Tabs[#self.Tabs + 1] = tab

		self.TabBar:InvalidateLayout(true)

		return tab
	end

	function Main:CloseTab(tab, save)
		for i, tb in pairs(self.Tabs) do
			if tab == tb then
				table.remove(self.Tabs, i)

				local pnl = tab:GetPanel()

				if save then
					-- TODO
				end
				
				pnl:Remove()
				tab:Remove()

				self.TabBar:InvalidateLayout(false)
				self:SetActiveTab(self.Tabs[#self.Tabs])

				return true
			end
		end
	end
	
	function Main:SetActiveTab(tab)
		if self.ActiveTab ~= tab and ValidPanel(tab) then

			if ValidPanel(self.ActiveTab) then
				local pnl = self.ActiveTab:GetPanel()
				pnl:Dock(NODOCK)
				pnl:SetSize(0,0)
				pnl:SetVisible(false)
			end

			local pnl = tab:GetPanel()
			pnl:SetVisible(true)
			pnl:Dock(FILL)
			pnl:RequestFocus()

			self.ActiveTab = tab
		end
	end

	Main.TabBar.PerformLayout = function(TabBar, w, h)
		local x = 2

		for _, tab in pairs(Main.Tabs) do
			tab:SetPos(x, 0)
			tab:InvalidateLayout(true)
			x = x + 2 + tab:GetWide()
		end
	end

	Main:SetActiveTab(Main:NewCodeTab("TEST PAGE", path, "TEST"))

/* --- --------------------------------------------------------------------------------
	@: Expression Advanced 2 - IDE(A) v2.0
	@: Main Window - Open
   --- */

	Main:SetSize(1200,800)
	Main:Center()
	Main:MakePopup()

	-- timer.Simple(10, function() Main:Remove() end)