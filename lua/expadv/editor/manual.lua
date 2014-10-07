TEST_Panel = vgui.Create( "DFrame" )

--------------------------------------------------------------------------

local function GetAvaliblity( Operator )
	if Operator.LoadOnServer and Operator.LoadOnClient then return "Shared" end
	if Operator.LoadOnServer then return "Serverside" end
	if Operator.LoadOnClient then return "Clientside" end
	return "Unkown"
end

local function NamePerams( Perams, Varg )
	local Names = { }

	for I = 1, #Perams do
		Names[I] = EXPADV.TypeName( Perams[I] )
	end
		
	if Varg then table.insert( Names, "..." ) end

	return table.concat( Names, ", " )
end
	
--------------------------------------------------------------------------

local Frame = TEST_Panel
Frame:SetTitle( "Expression Advanced 2 - User Manual" )
Frame:SetSize( ScrW( ) - 50, ScrH( ) - 50 )
Frame:Center( )
Frame:MakePopup( )

local TabSheet = Frame:Add( "DPropertySheet" )
TabSheet:Dock( FILL )

--------------------------------------------------------------------------

local WikiPanel = vgui.Create( "DHTML" )
WikiPanel:OpenURL( "https://github.com/Rusketh/ExpAdv2/wiki/Syntax" )
WikiPanel:DockMargin( 5, 5, 5 ,5 )
WikiPanel:Dock( FILL )

TabSheet:AddSheet( "WIKI: Syntax", WikiPanel, nil, true, true, "About our syntax" )

--------------------------------------------------------------------------

local ClassTab = vgui.Create( "DPanel" )
ClassTab:DockMargin( 5, 5, 5 ,5 )
ClassTab:Dock( FILL )

ClassTab.NodeList = ClassTab:Add( "DTree" )
ClassTab.NodeList:SetWide( 200 )
ClassTab.NodeList:DockMargin( 5, 5, 5 ,5 )
ClassTab.NodeList:Dock( LEFT )

ClassTab.ClassCanvas = ClassTab:Add( "DPanel" )
ClassTab.ClassCanvas:DockMargin( 5, 5, 5 ,5 )
ClassTab.ClassCanvas:Dock( FILL )

TabSheet:AddSheet( "Compoents", ClassTab, nil, true, true, "Classes" )

--------------------------------------------------------------------------

ClassTab.ClassSheets = { }
ClassTab.ComponentNodes = { }
ClassTab.ComponentSheets = { }

local RootNode = ClassTab.NodeList:AddNode( "Components" )
local CoreNode = RootNode:AddNode( "Core" )

--------------------------------------------------------------------------

local CoreComponentSheet = ClassTab.ClassCanvas:Add( "DPanel" )
CoreComponentSheet:DockPadding( 5, 5, 5 ,5 )
CoreComponentSheet:SetVisible( false )
CoreComponentSheet:Dock( FILL )

CoreComponentSheet.Info = CoreComponentSheet:Add( "DListView" )
CoreComponentSheet.Info:Dock( FILL )
CoreComponentSheet.Info:AddColumn( "Information" )
CoreComponentSheet.Info:AddColumn( "" )
	
CoreComponentSheet.Info:AddLine( "Component", "Core" )
CoreComponentSheet.Info:AddLine( "Author", "Rusketh" ) 
CoreComponentSheet.Info:AddLine( "Description", "Primary structure of Expression Advanced 2." )
CoreComponentSheet.Info:DataLayout( )
	
--------------------------------------------------------------------------

for _, Component in pairs( EXPADV.Components ) do
	ComponentNode = RootNode:AddNode( Component.Name )
	ClassTab.ComponentNodes[Component.Name] = ComponentNode
	
	local Sheet = ClassTab.ClassCanvas:Add( "DPanel" )
	Sheet:DockPadding( 5, 5, 5 ,5 )
	Sheet:SetVisible( false )
	Sheet:Dock( FILL )
	
	---------------------------------------------------------------------
	
	Sheet.Info = Sheet:Add( "DListView" )
	Sheet.Info:Dock( TOP )
	Sheet.Info:AddColumn( "Information" )
	Sheet.Info:AddColumn( "" )
	
	Sheet.Info:AddLine( "Component", Component.Name )
	Sheet.Info:AddLine( "Author", Component.Author or "Unkown" ) 
	Sheet.Info:AddLine( "Description", Component.Description or "N/A" )
	Sheet.Info:DataLayout( )
	
	---------------------------------------------------------------------
	
	ClassTab.ComponentSheets[Component.Name] = Sheet
	
	function ComponentNode:DoClick( )
		if ClassTab.ActiveCanvas then
			ClassTab.ActiveCanvas:SetVisible( false )
		end
		
		ClassTab.ActiveCanvas = Sheet
		Sheet:SetVisible( true )
	end
	
end

--------------------------------------------------------------------------


for Name, Class in pairs( EXPADV.Classes ) do
	local Sheet = ClassTab.ClassCanvas:Add( "DPanel" )
	Sheet:DockPadding( 5, 5, 5 ,5 )
	Sheet:SetVisible( false )
	Sheet:Dock( FILL )
	
	ClassTab.ClassSheets[Class.Short] = Sheet
	
	local ComponentNode = CoreNode
	
	if Class.Component then
		ComponentNode = ClassTab.ComponentNodes[Class.Component]
		if !ComponentNode then
			ComponentNode = RootNode:AddNode( Class.Component.Name )
			ClassTab.ComponentNodes[Class.Component] = ComponentNode
		end
	end
	
	if !ComponentNode.ClassNode then
		ComponentNode.ClassNode = ComponentNode:AddNode( "Classes" )
	end
	
	local ThisNode = ComponentNode.ClassNode:AddNode( Name )
	
	function ThisNode:DoClick( )
		if ClassTab.ActiveCanvas then
			ClassTab.ActiveCanvas:SetVisible( false )
		end
		
		ClassTab.ActiveCanvas = Sheet
		Sheet:SetVisible( true )
	end

	---------------------------------------------------------------------
	
	Sheet.Info = Sheet:Add( "DListView" )
	Sheet.Info:Dock( TOP )
	Sheet.Info:AddColumn( "Information" )
	Sheet.Info:AddColumn( "" )
	
	Sheet.Info:AddLine( "Class", Name )
	Sheet.Info:AddLine( "Extends", Class.DerivedClass and Class.DerivedClass.Name or "generic" ) 
	Sheet.Info:AddLine( "Component", Class.Component and Class.Component.Name or "Core" )
	Sheet.Info:AddLine( "Avaliblity", GetAvaliblity( Class ) )
	Sheet.Info:DataLayout( )
	
	---------------------------------------------------------------------
	
	if EXPADV.Class_Operators[Class.Short] then
		if !Sheet.Operators then
			Sheet.Operators = Sheet:Add( "DListView" )
			Sheet.Operators:AddColumn( "Avalibility" )
			Sheet.Operators:AddColumn( "Operator" )
			Sheet.Operators:AddColumn( "Return" )
			Sheet.Operators:AddColumn( "Example" )
			Sheet.Operators:AddColumn( "Description" )
			Sheet.Operators:Dock( TOP )
		end
		
		for _, Operator in pairs( EXPADV.Class_Operators[Class.Short] ) do
			Sheet.Operators:AddLine( GetAvaliblity(Operator), Operator.Type or "", EXPADV.TypeName( Operator.Return or "" ) or "Void", Operator.Example, Operator.Description )
		end
	end
	
end

--------------------------------------------------------------------------

for _, Operator in pairs( EXPADV.Operators ) do
	if Operator.InputCount == 0 or !Operator.Example then continue end
	
	local Sheet = ClassTab.ClassSheets[Operator.Input[1]]
	
	if !Sheet.Operators then
		Sheet.Operators = Sheet:Add( "DListView" )
		Sheet.Operators:AddColumn( "Avalibility" )
		Sheet.Operators:AddColumn( "Operator" )
		Sheet.Operators:AddColumn( "Return" )
		Sheet.Operators:AddColumn( "Example" )
		Sheet.Operators:AddColumn( "Description" )
		Sheet.Operators:Dock( TOP )
	end
	
	Sheet.Operators:AddLine( GetAvaliblity(Operator), Operator.Type or "", EXPADV.TypeName( Operator.Return or "" ) or "Void", Operator.Example, Operator.Description )
end

--------------------------------------------------------------------------

for _, Operator in pairs( EXPADV.Functions ) do
	if Operator.Method then
		local Sheet = ClassTab.ClassSheets[Operator.Input[1]]
		
		if !Sheet then continue end
		
		if !Sheet.Methods then
			Sheet.Methods = Sheet:Add( "DListView" )
			Sheet.Methods:AddColumn( "Avalibility" )
			Sheet.Methods:AddColumn( "Return" )
			Sheet.Methods:AddColumn( "Method" )
			Sheet.Methods:AddColumn( "Description" )
			Sheet.Methods:Dock( TOP )
		end
		
		local Inputs = table.Copy( Operator.Input )
		local Signature = string.format( "%s.%s(%s)", EXPADV.TypeName( table.remove( Operator.Input, 1 ) ), Operator.Name, NamePerams( Inputs, Operator.UsesVarg ) )
		
		Sheet.Methods:AddLine( GetAvaliblity(Operator), EXPADV.TypeName( Operator.Return or "" ) or "Void", Signature, Operator.Description )
		
	else
		
		local Sheet = CoreComponentSheet
		
		if Operator.Component then
			Sheet = ClassTab.ComponentSheets[Operator.Component.Name]
		end
		
		if !Sheet then continue end
		
		if !Sheet.Functions then
			Sheet.Functions = Sheet:Add( "DListView" )
			Sheet.Functions:AddColumn( "Avalibility" )
			Sheet.Functions:AddColumn( "Return" )
			Sheet.Functions:AddColumn( "function" )
			Sheet.Functions:AddColumn( "Description" )
			Sheet.Functions:Dock( TOP )
		end
		
		local Signature = string.format( "%s(%s)", Operator.Name, NamePerams( Operator.Input, Operator.UsesVarg ) )
		
		Sheet.Functions:AddLine( GetAvaliblity(Operator), EXPADV.TypeName( Operator.Return or "" ) or "Void", Signature, Operator.Description )
	end
end

--------------------------------------------------------------------------

for _, Event in pairs( EXPADV.Events ) do
	local Sheet = CoreComponentSheet
		
	if Event.Component then
		Sheet = ClassTab.ComponentSheets[Event.Component.Name]
	end
		
	if !Sheet then continue end
		
	if !Sheet.Events then
		Sheet.Events = Sheet:Add( "DListView" )
		Sheet.Events:AddColumn( "Avalibility" )
		Sheet.Events:AddColumn( "Return" )
		Sheet.Events:AddColumn( "event" )
		Sheet.Events:AddColumn( "Description" )
		Sheet.Events:Dock( TOP )
	end
		
	local Signature = string.format( "%s(%s)", Event.Name, NamePerams( Event.Input, false ) )
		
	Sheet.Events:AddLine( GetAvaliblity(Event), EXPADV.TypeName( Event.Return or "" ) or "Void", Signature, Event.Description or "N/A" )
	
end

--------------------------------------------------------------------------
