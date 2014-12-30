/* -----------------------------------------------------------------------------------
	@: Derma Component
   --- */

local Component = EXPADV.AddComponent( "derma", true )

Component.Author = "Szymekk"
Component.Description = "Adds derma objects."

EXPADV.ClientOperators()

local Panels = {}

function Component:OnShutDown( Context )
	if !Panels[Context] then return end
	for k,v in pairs(Panels[Context]) do
		v:Remove()
	end
	Panels[Context] = { }
end

function Component:OnCoreReload( )
	for _,a in pairs(Panels) do
		for k,v in pairs(a) do
			Panel:Remove()
		end
		Panels[_] = { }
	end
end

Component:AddInlineFunction("canUseDerma", "", "b", [[EXPADV.CanAccessFeature(Context.entity, "Derma")]])

/* -----------------------------------------------------------------------------------
	@: Panel
--- */

local PanelClass = Component:AddClass( "dpanel", "dp" )

local function CreatePanel( Context, Trace, Name, Object ) 
	local CreatedPanel

	if IsValid(Context.entity) and Context.entity.ScreenDerma then
		CreatedPanel = Context.entity:CreateDermaObject(Name, Object)
	elseif !EXPADV.CanAccessFeature(Context.entity, "Derma") then
		Context:Throw( Trace, "derma panel", "Derma isn't enabled" )
		return nil
	elseif Object == nil then
		CreatedPanel = vgui.Create( Name )
	else
		CreatedPanel = vgui.Create( Name, Object )
	end

	Panels[Context] = Panels[Context] or { }
	Panels[Context][#Panels[Context]+1] = CreatedPanel
	
	return CreatedPanel
end

PanelClass:AddPreparedOperator( "=", "n,dp", "", "Context.Memory[@value 1] = @value 2" )

Component:AddVMFunction( "dpanel", "", "dp", function(Context, Trace) return CreatePanel(Context, Trace, "DPanel") end )

Component:AddPreparedFunction("setPos", "dp:v2", "", "@value 1:SetPos(@value 2.x, @value 2.y)")
Component:AddPreparedFunction("setSize", "dp:v2", "", "@value 1:SetSize(@value 2.x, @value 2.y)")
Component:AddPreparedFunction("setText", "dp:s", "", "@value 1:SetText(@value 2)")
Component:AddPreparedFunction("setVisible", "dp:b", "", "@value 1:SetVisible(@value 2)")

Component:AddInlineFunction("getPos", "dp:", "v2", "Vector2(@value 1:GetPos())")
Component:AddInlineFunction("getSize", "dp:", "v2", "Vector2(@value 1:GetSize())")
Component:AddInlineFunction("getText", "dp:", "s", "@value 1:GetText()")

Component:AddPreparedFunction("noDock", "dp:", "", "@value 1:Dock($NODOCK)")
Component:AddPreparedFunction("dockFill", "dp:", "", "@value 1:Dock($FILL)")
Component:AddPreparedFunction("dockLeft", "dp:", "", "@value 1:Dock($LEFT)")
Component:AddPreparedFunction("dockTop", "dp:", "", "@value 1:Dock($TOP)")
Component:AddPreparedFunction("dockRight", "dp:", "", "@value 1:Dock($RIGHT)")
Component:AddPreparedFunction("dockBottom", "dp:", "", "@value 1:Dock($BOTTOM)")

Component:AddPreparedFunction("dockMargin", "dp:n,n,n,n", "", "@value 1:DockMargin(@value 2, @value 3, @value 4, @value 5)")
Component:AddPreparedFunction("dockPadding", "dp:n,n,n,n", "", "@value 1:DockPadding(@value 2, @value 3, @value 4, @value 5)")

Component:AddPreparedFunction("center", "dp:", "", "@value 1:Center()")

Component:AddPreparedFunction("onPaint", "dp:d", "", [[@value 1.Paint = function() Context:Execute( "paint", @value 2 ) end]])

PanelClass:AddPreparedOperator( "=", "n,dp", "", "Context.Memory[@value 1] = @value 2" )

/* -----------------------------------------------------------------------------------
	@: Frame
--- */

local FrameClass = Component:AddClass( "dframe", "df" )
FrameClass:ExtendClass( "dp" )

Component:AddInlineOperator( "dpanel", "df", "dp", "@value 1" )

FrameClass:AddPreparedOperator( "=", "n,df", "", "Context.Memory[@value 1] = @value 2" )
FrameClass:AddPreparedOperator( "=", "n,dp", "", "Context.Memory[@value 1] = @value 2" )

Component:AddVMFunction( "dframe", "", "df", function(Context, Trace) return CreatePanel(Context, Trace, "DFrame") end )

Component:AddPreparedFunction("setDraggable", "df:b", "", "@value 1:SetDraggable(@value 2)")
Component:AddPreparedFunction("setSizable", "df:b", "", "@value 1:SetSizable(@value 2)")
Component:AddPreparedFunction("setBackgroundBlur", "df:b", "", "@value 1:SetBackgroundBlur(@value 2)")
Component:AddPreparedFunction("setTitle", "df:s", "", "@value 1:SetTitle(@value 2)")
Component:AddPreparedFunction("makePopup", "df:", "", "@value 1:MakePopup()")

/* -----------------------------------------------------------------------------------
	@: Label
--- */

local LabelClass = Component:AddClass( "dlabel", "dl" )
LabelClass:ExtendClass( "dp" )

LabelClass:AddPreparedOperator( "=", "n,dl", "", "Context.Memory[@value 1] = @value 2" )

Component:AddInlineOperator( "dpanel", "dl", "dp", "@value 1" )

Component:AddVMFunction( "dlabel", "dp", "dl", function(Context, Trace, Panel) return CreatePanel(Context, Trace, "DLabel", Panel) end )
Component:AddVMFunction( "dlabel", "df", "dl", function(Context, Trace, Panel) return CreatePanel(Context, Trace, "DLabel", Panel) end )
Component:AddVMFunction( "dlabel", "", "dl", function(Context, Trace) return CreatePanel(Context, Trace, "DLabel") end )

Component:AddPreparedFunction( "setTextColor", "dl:c", "", "@value 1:SetTextColor(@value 2)")

Component:AddInlineFunction( "getTextColor", "dl:", "c", "@value 1:GetTextColor()")

/* -----------------------------------------------------------------------------------
	@: Button
--- */

local ButtonClass = Component:AddClass( "dbutton", "db" )
ButtonClass:ExtendClass( "dp" )

ButtonClass:AddPreparedOperator( "=", "n,db", "", "Context.Memory[@value 1] = @value 2" )

Component:AddInlineOperator( "dpanel", "db", "dp", "@value 1" )

Component:AddVMFunction( "dbutton", "dp", "db", function(Context, Trace, Panel) return CreatePanel(Context, Trace, "DButton", Panel) end )
Component:AddVMFunction( "dbutton", "df", "db", function(Context, Trace, Panel) return CreatePanel(Context, Trace, "DButton", Panel) end )
Component:AddVMFunction( "dbutton", "", "db", function(Context, Trace) return CreatePanel(Context, Trace, "DButton") end )

Component:AddPreparedFunction("onClick", "db:d", "", [[
	@value 1.DoClick = function() Context:Execute( "dbutton", @value 2 ) end
]])

/* -----------------------------------------------------------------------------------
	@: Text Entry
--- */

local TextEntryClass = Component:AddClass( "dtextentry", "dte" )
TextEntryClass:ExtendClass( "dp" )

TextEntryClass:AddPreparedOperator( "=", "n,dte", "", "Context.Memory[@value 1] = @value 2" )

Component:AddInlineOperator( "dpanel", "dte", "dp", "@value 1" )

Component:AddVMFunction( "dtextentry", "dp", "dte", function(Context, Trace, Panel) return CreatePanel(Context, Trace, "DTextEntry", Panel) end )
Component:AddVMFunction( "dtextentry", "df", "dte", function(Context, Trace, Panel) return CreatePanel(Context, Trace, "DTextEntry", Panel) end )
Component:AddVMFunction( "dtextentry", "", "dte", function(Context, Trace) return CreatePanel(Context, Trace, "DTextEntry") end )

Component:AddPreparedFunction("onTextChanged", "dte:d", "", [[@value 1.OnTextChanged = function() Context:Execute( "textentry", @value 2 ) end]])

/* -----------------------------------------------------------------------------------
	@: Check Box
--- */

local CheckBoxClass = Component:AddClass( "dcheckbox", "dcb" )
CheckBoxClass:ExtendClass( "dp" )

CheckBoxClass:AddPreparedOperator( "=", "n,dcb", "", "Context.Memory[@value 1] = @value 2" )

Component:AddInlineOperator( "dpanel", "dcb", "dp", "@value 1" )

Component:AddVMFunction( "dcheckbox", "dp", "dcb", function(Context, Trace, Panel) return CreatePanel(Context, Trace, "DCheckBoxLabel", Panel) end )
Component:AddVMFunction( "dcheckbox", "df", "dcb", function(Context, Trace, Panel) return CreatePanel(Context, Trace, "DCheckBoxLabel", Panel) end )
Component:AddVMFunction( "dcheckbox", "", "dcb", function(Context, Trace) return CreatePanel(Context, Trace, "DCheckBoxLabel") end )

Component:AddPreparedFunction("setChecked", "dcb:b", "", "@value 1:SetChecked( @value 2 )")
Component:AddInlineFunction("getChecked", "dcb:", "b", "@value 1:GetChecked( )")

Component:AddPreparedFunction("onChange", "dcb:d", "", [[@value 1.OnChange = function() Context:Execute( "checkbox", @value 2 ) end]])

/* -----------------------------------------------------------------------------------
	@: Panel List
--- */

local PanelListClass = Component:AddClass( "dpanellist", "dpl" )
PanelListClass:ExtendClass( "dp" )

PanelListClass:AddPreparedOperator( "=", "n,dpl", "", "Context.Memory[@value 1] = @value 2" )

Component:AddVMFunction( "dpanellist", "dp", "dpl", function(Context, Trace, Panel) return CreatePanel(Context, Trace, "DPanelList", Panel) end )
Component:AddVMFunction( "dpanellist", "df", "dpl", function(Context, Trace, Panel) return CreatePanel(Context, Trace, "DPanelList", Panel) end )
Component:AddVMFunction( "dpanellist", "", "dpl", function(Context, Trace) return CreatePanel(Context, Trace, "DPanelList") end )

/* -----------------------------------------------------------------------------------
	@: Num Slider
--- */

local NumSliderClass = Component:AddClass( "dnumslider", "dns" )
NumSliderClass:ExtendClass( "dp" )

NumSliderClass:AddPreparedOperator( "=", "n,dns", "", "Context.Memory[@value 1] = @value 2" )

Component:AddVMFunction( "dnumslider", "dp", "dns", function(Context, Trace, Panel) return CreatePanel(Context, Trace, "DNumSlider", Panel) end )
Component:AddVMFunction( "dnumslider", "df", "dns", function(Context, Trace, Panel) return CreatePanel(Context, Trace, "DNumSlider", Panel) end )
Component:AddVMFunction( "dnumslider", "", "dns", function(Context, Trace) return CreatePanel(Context, Trace, "DNumSlider") end )

Component:AddPreparedFunction("setMin", "dns:n", "", "@value 1:SetMin(@value 2)")
Component:AddPreparedFunction("setMax", "dns:n", "", "@value 1:SetMax(@value 2)")
Component:AddPreparedFunction("setValue", "dns:n", "", "@value 1:SetValue(@value 2)")
Component:AddInlineFunction("getValue", "dns:", "n", "@value 1:GetValue()")
Component:AddPreparedFunction("onChange", "dns:d", "", [[@value 1.ValueChanged = function() Context:Execute( "numslider", @value 2 ) end]])

/* -----------------------------------------------------------------------------------
	@: Menu
--- */

local MenuClass = Component:AddClass( "dmenu", "dm" )
MenuClass:ExtendClass( "dp" )

MenuClass:AddPreparedOperator( "=", "n,dm", "", "Context.Memory[@value 1] = @value 2" )

Component:AddVMFunction( "dmenu", "", "dm", function(Context, Trace) return CreatePanel(Context, Trace, "DMenu") end )

Component:AddPreparedFunction("addOption", "dm:s", "", "@value 1:AddOption(@value 2)")
Component:AddPreparedFunction("addOption", "dm:s,d", "", [[@value 1:AddOption(@value 2, function() Context:Execute("dmenu", @value 3) end)]])
Component:AddInlineFunction("addSubMenu", "dm:s", "dm", "@value 1:AddSubMenu(@value 2)")
Component:AddInlineFunction("addSubMenu", "dm:s,d", "dm", [[@value 1:AddSubMenu(@value 2, function() Context:Execute("dmenu", @value 3) end)]])
Component:AddPreparedFunction("addSpacer", "dm:", "", "@value 1:AddSpacer()")
Component:AddPreparedFunction("open", "dm:", "", "@value 1:Open()")

/* -----------------------------------------------------------------------------------
	@: Menu Bar
--- */

local MenuBarClass = Component:AddClass( "dmenubar", "dmb" )
MenuBarClass:ExtendClass( "dp" )

MenuBarClass:AddPreparedOperator( "=", "n,dmb", "", "Context.Memory[@value 1] = @value 2" )

Component:AddVMFunction( "dmenubar", "dp", "dmb", function(Context, Trace, Panel) return CreatePanel(Context, Trace, "DMenuBar", Panel) end )
Component:AddVMFunction( "dmenubar", "df", "dmb", function(Context, Trace, Panel) return CreatePanel(Context, Trace, "DMenuBar", Panel) end )

Component:AddInlineFunction("addMenu", "dmb:s", "dm", "@value 1:AddMenu(@value 2)")

/* -----------------------------------------------------------------------------------
	@: Color Mixer
--- */

local ColorMixerClass = Component:AddClass( "dcolormixer", "dcm" )
ColorMixerClass:ExtendClass( "dp" )

ColorMixerClass:AddPreparedOperator( "=", "n,dcm", "", "Context.Memory[@value 1] = @value 2" )

Component:AddVMFunction( "dcolormixer", "dp", "dcm", function(Context, Trace, Panel) return CreatePanel(Context, Trace, "DColorMixer", Panel) end )
Component:AddVMFunction( "dcolormixer", "df", "dcm", function(Context, Trace, Panel) return CreatePanel(Context, Trace, "DColorMixer", Panel) end )
Component:AddVMFunction( "dcolormixer", "", "dcm", function(Context, Trace) return CreatePanel(Context, Trace, "DColorMixer") end )

Component:AddPreparedFunction("setColor", "dcm:c", "", "@value 1:SetColor(@value 2)")
Component:AddInlineFunction("getColor", "dcm:", "c", "@value 1:GetColor()")

/* -----------------------------------------------------------------------------------
	@: Property Sheet
--- */

local PropSheetClass = Component:AddClass( "dpropertysheet", "dps" )
PropSheetClass:ExtendClass( "dp" )
PropSheetClass:AddAlias("dpropsheet")

PropSheetClass:AddPreparedOperator( "=", "n,dps", "", "Context.Memory[@value 1] = @value 2" )

Component:AddVMFunction( "dpropertysheet", "dp", "dps", function(Context, Trace, Panel) return CreatePanel(Context, Trace, "DPropertySheet", Panel) end )
Component:AddVMFunction( "dpropertysheet", "df", "dps", function(Context, Trace, Panel) return CreatePanel(Context, Trace, "DPropertySheet", Panel) end )
Component:AddVMFunction( "dpropertysheet", "", "dps", function(Context, Trace) return CreatePanel(Context, Trace, "DPropertySheet") end )


/* -----------------------------------------------------------------------------------
	@: Functions for all classes
--- */

function Component:OnPostRegisterClass( Name, Class )
	if Class.Component != self && Name != "dframe" then return end

	Component:AddPreparedFunction("addSheet", "dps:s," .. Class.Short .. ",s", "", [[@value 1:AddSheet(@value 2, @value 3, @value 4)]])
	EXPADV.AddFunctionAlias("addSheet", "dps:s," .. Class.Short)

	Component:AddPreparedFunction("addItem", "dpl:" .. Class.Short .. "", "", [[@value 1:AddItem(@value 2)]])

end

/* -----------------------------------------------------------------------------------
	@: Events
--- */

EXPADV.ClientEvents()

Component:AddEvent("enableDerma", "", "")
Component:AddEvent("disableDerma", "", "")

/* -----------------------------------------------------------------------------------
	@: Features
--- */

if CLIENT then
	concommand.Add( "expadv_killderma", function( Player )
		for _,a in pairs(Panels) do
			for k,v in pairs(a) do
				v:Remove()
			end
			Panels[_] = { }
		end
	end )
end

Component:AddFeature( "Derma", "Using Derma GUI components.", "fugue/block.png" )

if CLIENT then
	function Component:OnChangeFeatureAccess(Entity, Feature, Value)
		if Feature == "Derma" then
			if Value then
				Entity:CallEvent( "enableDerma" )
			else
				if !Panels[Entity.Context] then return end
				for k,v in pairs(Panels[Entity.Context]) do
					v:Remove()
				end
				Panels[Context] = { }
				Entity:CallEvent( "disableDerma" )
			end
		end
	end
end


