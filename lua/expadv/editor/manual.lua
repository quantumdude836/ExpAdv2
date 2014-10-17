local function GetAvalibility( Operator )
	if Operator.LoadOnServer and Operator.LoadOnClient then return "Shared" end
	if Operator.LoadOnServer then return "Serverside" end
	if Operator.LoadOnClient then return "Clientside" end
	return "Unkown"
end

local function NamePerams( Perams, Count, Varg )
	local Names = { }

	for I = 1, Count do
		if Perams[I] == "" or Perams[I] == "..." then break end
		Names[I] = EXPADV.TypeName( Perams[I] or "" )
		if Names[I] == "void" then Names[I] = nil; break end
	end
		
	if Varg then table.insert( Names, "..." ) end

	return table.concat( Names, ", " )
end


function EXPADV.Editor.OpenHelper( )

		if IsValid( EXPADV.Editor.Manual ) then
			EXPADV.Editor.Manual:SetVisible( true )
			return
		end

		--------------------------------------------------------------------------

		local Frame = vgui.Create( "DFrame" )
		Frame:SetTitle( "Expression Advanced 2 - User Manual" )
		Frame:SetSize( ScrW( ) - 50, ScrH( ) - 50 )
		Frame:Center( )
		Frame:MakePopup( )

		EXPADV.Editor.Manual = Frame

		--------------------------------------------------------------------------

		function Frame:Close( )
			self:SetVisible( false )
		end
		
		--------------------------------------------------------------------------

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

		TabSheet:AddSheet( "Components", ClassTab, nil, true, true, "Classes" )

		--------------------------------------------------------------------------

		ClassTab.ClassSheets = { }
		ClassTab.ComponentNodes = { }
		ClassTab.ComponentSheets = { }

		local RootNode = ClassTab.NodeList:AddNode( "Components" )
		local CoreNode = RootNode:AddNode( "Core" )
		
		RootNode:SetExpanded( true )

		--------------------------------------------------------------------------

		local CoreComponentSheet = ClassTab.ClassCanvas:Add( "DScrollPanel" )
		CoreComponentSheet:DockPadding( 5, 5, 5 ,5 )
		CoreComponentSheet:SetVisible( true )
		CoreComponentSheet:Dock( FILL )

		CoreComponentSheet.Info = CoreComponentSheet:Add( "DListView" )
		CoreComponentSheet.Info:AddColumn( "" ):SetFixedWidth( 60 )
		CoreComponentSheet.Info:AddColumn( "" )
			
		CoreComponentSheet.Info:AddLine( "Component", "Core" )
		CoreComponentSheet.Info:AddLine( "Author", "Rusketh" ) 
		CoreComponentSheet.Info:AddLine( "Description", "Primary structure of Expression Advanced 2." )
		CoreComponentSheet.Info:DataLayout( )
			
			function CoreNode:DoClick( )
				if ClassTab.ActiveCanvas then
					ClassTab.ActiveCanvas:SetVisible( false )
				end
				
				ClassTab.ActiveCanvas = CoreComponentSheet
				CoreComponentSheet:SetVisible( true )
			end

			CoreNode.DoRightClick = CoreNode.DoClick

		--------------------------------------------------------------------------

		for _, Component in pairs( EXPADV.Components ) do
			ComponentNode = RootNode:AddNode( Component.Name )
			ClassTab.ComponentNodes[Component.Name] = ComponentNode
			
			local Sheet = ClassTab.ClassCanvas:Add( "DScrollPanel" )
			Sheet:DockPadding( 5, 5, 5 ,5 )
			Sheet:SetVisible( false )
			Sheet:Dock( FILL )
			
			---------------------------------------------------------------------
			
			Sheet.Info = Sheet:Add( "DListView" )
			Sheet.Info:AddColumn( "" ):SetFixedWidth( 60 )
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
			
			ComponentNode.DoRightClick = ComponentNode.DoClick
		end

		--------------------------------------------------------------------------


		for Name, Class in pairs( EXPADV.Classes ) do
			local Sheet = ClassTab.ClassCanvas:Add( "DScrollPanel" )
			Sheet:DockPadding( 5, 5, 5 ,5 )
			Sheet:SetVisible( false )
			Sheet:Dock( FILL )
			
			ClassTab.ClassSheets[Class.Short] = Sheet
			
			local ComponentNode = CoreNode
			
			if Class.Component then
				ComponentNode = ClassTab.ComponentNodes[Class.Component.Name]
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

			ThisNode.DoRightClick = ThisNode.DoClick

			---------------------------------------------------------------------
			
			Sheet.Info = Sheet:Add( "DListView" )
			Sheet.Info:AddColumn( "" ):SetFixedWidth( 60 )
			Sheet.Info:AddColumn( "" )
			
			Sheet.Info:AddLine( "Class", Name )
			Sheet.Info:AddLine( "Extends", Class.DerivedClass and Class.DerivedClass.Name or "generic" ) 
			Sheet.Info:AddLine( "Component", Class.Component and Class.Component.Name or "Core" )
			Sheet.Info:AddLine( "Avalibility", GetAvalibility( Class ) )
			Sheet.Info:DataLayout( )
			
			---------------------------------------------------------------------
			
			if EXPADV.Class_Operators[Class.Short] then
				if !Sheet.Operators then
					Sheet.Operators = Sheet:Add( "DListView" )
					Sheet.Operators:AddColumn( "Avalibility" ):SetFixedWidth( 60 )
					Sheet.Operators:AddColumn( "Operator" ):SetFixedWidth( 70 )
					Sheet.Operators:AddColumn( "Return" ):SetFixedWidth( 60 )
					Sheet.Operators:AddColumn( "Example" )
					Sheet.Operators:AddColumn( "Description" )
				end
				
				for _, Operator in pairs( EXPADV.Class_Operators[Class.Short] ) do
					Sheet.Operators:AddLine( GetAvalibility(Operator), Operator.Type or "", EXPADV.TypeName( Operator.Return or "" ) or "Void", Operator.Example, Operator.Description )
				end
			end
			
		end

		--------------------------------------------------------------------------

		for _, Operator in pairs( EXPADV.Operators ) do
			if Operator.InputCount == 0 or !Operator.Example or Operator.Example == "" then continue end
			
			local Sheet = ClassTab.ClassSheets[Operator.Input[1]]
			
			if !Sheet.Operators then
				Sheet.Operators = Sheet:Add( "DListView" )
				Sheet.Operators:AddColumn( "Avalibility" ):SetFixedWidth( 60 )
				Sheet.Operators:AddColumn( "Operator" ):SetFixedWidth( 70 )
				Sheet.Operators:AddColumn( "Return" ):SetFixedWidth( 60 )
				Sheet.Operators:AddColumn( "Example" )
				Sheet.Operators:AddColumn( "Description" )
			end
			
			Sheet.Operators:AddLine( GetAvalibility(Operator), Operator.Type or "", EXPADV.TypeName( Operator.Return or "" ) or "Void", Operator.Example, Operator.Description )
		end

		--------------------------------------------------------------------------

		for _, Operator in pairs( EXPADV.Functions ) do
			if Operator.Method then
				
				local Sheet = CoreComponentSheet
				
				if Operator.Component then
					Sheet = ClassTab.ClassSheets[ Operator.Input[1] ]
				end
				
				if !Sheet.Methods then
					Sheet.Methods = Sheet:Add( "DListView" )
					Sheet.Methods:AddColumn( "Avalibility" ):SetFixedWidth( 60 )
					Sheet.Methods:AddColumn( "Return" ):SetFixedWidth( 60 )
					Sheet.Methods:AddColumn( "Method" )
					Sheet.Methods:AddColumn( "Description" )
				end
				
				local Inputs = table.Copy( Operator.Input )
				local Signature = string.format( "%s.%s(%s)", EXPADV.TypeName( table.remove( Inputs, 1 ) ), Operator.Name, NamePerams( Inputs, Operator.InputCount, Operator.UsesVarg ) )
				
				Sheet.Methods:AddLine( GetAvalibility(Operator), EXPADV.TypeName( Operator.Return or "" ) or "Void", Signature, Operator.Description )
				
			else
				
				local Sheet = CoreComponentSheet
				
				if Operator.Component then
					Sheet = ClassTab.ComponentSheets[Operator.Component.Name]
				end
				
				if !Sheet.Functions then
					Sheet.Functions = Sheet:Add( "DListView" )
					Sheet.Functions:AddColumn( "Avalibility" ):SetFixedWidth( 60 )
					Sheet.Functions:AddColumn( "Return" ):SetFixedWidth( 60 )
					Sheet.Functions:AddColumn( "Function" )
					Sheet.Functions:AddColumn( "Description" )
				end
				
				local Signature = string.format( "%s(%s)", Operator.Name, NamePerams( Operator.Input, Operator.InputCount, Operator.UsesVarg ) )
				
				Sheet.Functions:AddLine( GetAvalibility(Operator), EXPADV.TypeName( Operator.Return or "" ) or "Void", Signature, Operator.Description )
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
				Sheet.Events:AddColumn( "Avalibility" ):SetFixedWidth( 60 )
				Sheet.Events:AddColumn( "Return" ):SetFixedWidth( 60 )
				Sheet.Events:AddColumn( "Event" )
				Sheet.Events:AddColumn( "Description" )
			end
				
			local Signature = string.format( "%s(%s)", Event.Name, NamePerams( Event.Input, Event.InputCount, false ) )
				
			Sheet.Events:AddLine( GetAvalibility(Event), EXPADV.TypeName( Event.Return or "" ) or "Void", Signature, Event.Description or "N/A" )
			
		end

		--------------------------------------------------------------------------

		local LabelColor = Color( 0, 0, 0 )
		
		local function LayOut( Sheet )
			local W, H = Sheet:GetParent( ):GetSize( )
			local X, Y = 5, 5

			if Sheet.Info then
				if !Sheet.Info_Label then
					Sheet.Info_Label = Sheet:Add( "DLabel" )
					Sheet.Info_Label:SetText( "Information:" )
					Sheet.Info_Label:SetTextColor( LabelColor )
				end
				
				Sheet.Info_Label:SetPos( X, Y )
				Sheet.Info_Label:SizeToContents( )
				Y = Y + Sheet.Info_Label:GetTall( ) + 5

				Sheet.Info:SetPos( X, Y )
				Sheet.Info:SetSize( W - 30, Sheet.Info:DataLayout( ) + Sheet.Info:GetHeaderHeight() )
				Y = Y + Sheet.Info:GetTall( ) + 5
			end
			
			if Sheet.Operators then
				if !Sheet.Operators_Label then
					Sheet.Operators_Label = Sheet:Add( "DLabel" )
					Sheet.Operators_Label:SetText( "Operators:" )
					Sheet.Operators_Label:SetTextColor( LabelColor )
				end
				
				Sheet.Operators_Label:SetPos( X, Y )
				Sheet.Operators_Label:SizeToContents( )
				Y = Y + Sheet.Operators_Label:GetTall( ) + 5

				Sheet.Operators:SetPos( X, Y )
				Sheet.Operators:SetSize( W - 30, Sheet.Operators:DataLayout( ) + Sheet.Operators:GetHeaderHeight() )
				Y = Y + Sheet.Operators:GetTall( ) + 5
			end
			
			
			if Sheet.Methods then
				if !Sheet.Methods_Label then
					Sheet.Methods_Label = Sheet:Add( "DLabel" )
					Sheet.Methods_Label:SetText( "Methods:" )
					Sheet.Methods_Label:SetTextColor( LabelColor )
				end
				
				Sheet.Methods_Label:SetPos( X, Y )
				Sheet.Methods_Label:SizeToContents( )
				Y = Y + Sheet.Methods_Label:GetTall( ) + 5

				Sheet.Methods:SetPos( X, Y )
				Sheet.Methods:SetSize( W - 30, Sheet.Methods:DataLayout( ) + Sheet.Methods:GetHeaderHeight() )
				Y = Y + Sheet.Methods:GetTall( ) + 5
			end
			
			
			if Sheet.Functions then
				if !Sheet.Functions_Label then
					Sheet.Functions_Label = Sheet:Add( "DLabel" )
					Sheet.Functions_Label:SetText( "Functions:" )
					Sheet.Functions_Label:SetTextColor( LabelColor )
				end
				
				Sheet.Functions_Label:SetPos( X, Y )
				Sheet.Functions_Label:SizeToContents( )
				Y = Y + Sheet.Functions_Label:GetTall( ) + 5

				Sheet.Functions:SetPos( X, Y )
				Sheet.Functions:SetSize( W - 30, Sheet.Functions:DataLayout( ) + Sheet.Functions:GetHeaderHeight() )
				Y = Y + Sheet.Functions:GetTall( ) + 5
			end
			
			if Sheet.Events then
				if !Sheet.Events_Label then
					Sheet.Events_Label = Sheet:Add( "DLabel" )
					Sheet.Events_Label:SetText( "Events:" )
					Sheet.Events_Label:SetTextColor( LabelColor )
				end
				
				Sheet.Events_Label:SetPos( X, Y )
				Sheet.Events_Label:SizeToContents( )
				Y = Y + Sheet.Events_Label:GetTall( ) + 5

				Sheet.Events:SetPos( X, Y )
				Sheet.Events:SetSize( W - 30, Sheet.Events:DataLayout( ) + Sheet.Events:GetHeaderHeight() )
				Y = Y + Sheet.Events:GetTall( ) + 5
			end
			
			Sheet:SetTall( Y + 5 )
		end

		function ClassTab.ClassCanvas:PerformLayout( )
			LayOut( CoreComponentSheet )
			for I, Sheet in pairs( ClassTab.ClassSheets ) do LayOut( Sheet ) end
			for I, Sheet in pairs( ClassTab.ComponentSheets ) do LayOut( Sheet ) end
		end

		ClassTab.ClassCanvas:InvalidateLayout( )

		--------------------------------------------------------------------------

		local FunctionPanel = vgui.Create( "DPanel" )
		FunctionPanel:DockMargin( 5, 5, 5 ,5 )
		FunctionPanel:Dock( FILL )

		TabSheet:AddSheet( "Browser", FunctionPanel, nil, true, true, "Browse and search functions." )

		local Sheet = FunctionPanel:Add( "DScrollPanel" )

		Sheet.Methods = Sheet:Add( "DListView" )
		Sheet.Methods:AddColumn( "Avalibility" ):SetFixedWidth( 60 )
		Sheet.Methods:AddColumn( "Return" ):SetFixedWidth( 60 )
		Sheet.Methods:AddColumn( "Method" )
		Sheet.Methods:AddColumn( "Description" )

		Sheet.Functions = Sheet:Add( "DListView" )
		Sheet.Functions:AddColumn( "Avalibility" ):SetFixedWidth( 60 )
		Sheet.Functions:AddColumn( "Return" ):SetFixedWidth( 60 )
		Sheet.Functions:AddColumn( "Function" )
		Sheet.Functions:AddColumn( "Description" )

		Sheet.Events = Sheet:Add( "DListView" )
		Sheet.Events:AddColumn( "Avalibility" ):SetFixedWidth( 60 )
		Sheet.Events:AddColumn( "Return" ):SetFixedWidth( 60 )
		Sheet.Events:AddColumn( "Event" )
		Sheet.Events:AddColumn( "Description" )

		local function Search( Query )
			
			Sheet.Methods:Clear( )

			Sheet.Functions:Clear( )

			Sheet.Events:Clear( )

			for _, Operator in pairs( EXPADV.Functions ) do
				
				if Query and Query ~= "" and !string.find( Operator.Name, Query ) then continue end
				
				if Operator.Method then
					local Inputs = table.Copy( Operator.Input )
					local Signature = string.format( "%s.%s(%s)", EXPADV.TypeName( table.remove( Inputs, 1 ) ), Operator.Name, NamePerams( Inputs, Operator.InputCount, Operator.UsesVarg ) )
					
					Sheet.Methods:AddLine( GetAvalibility(Operator), EXPADV.TypeName( Operator.Return or "" ) or "Void", Signature, Operator.Description )
				else
					local Signature = string.format( "%s(%s)", Operator.Name, NamePerams( Operator.Input, Operator.InputCount, Operator.UsesVarg ) )
					
					Sheet.Functions:AddLine( GetAvalibility(Operator), EXPADV.TypeName( Operator.Return or "" ) or "Void", Signature, Operator.Description )
				end
			end

			for _, Event in pairs( EXPADV.Events ) do
				if Query and Query ~= "" and !string.find( Event.Name, Query ) then continue end

				local Signature = string.format( "%s(%s)", Event.Name, NamePerams( Event.Input, Event.InputCount, false ) )
					
				Sheet.Events:AddLine( GetAvalibility(Event), EXPADV.TypeName( Event.Return or "" ) or "Void", Signature, Event.Description or "N/A" )
				
			end

			FunctionPanel:InvalidateLayout( )
		end

		local SearchPanel = FunctionPanel:Add( "DPanel" )
		local QueryBox = SearchPanel:Add( "DTextEntry" )
		QueryBox:SetEnterAllowed( true )

		local SearchButton = SearchPanel:Add( "EA_ImageButton" ) 
		SearchButton:SetIconFading( false )
		SearchButton:SetIconCentered( false )
		SearchButton:SetTextCentered( false )
		SearchButton:DrawButton( true )
		SearchButton:SetMaterial( Material( "fugue/magnifier-left.png" ) )

		function SearchButton:DoClick( )
			Search( QueryBox:GetValue( ) )
		end

		function SearchButton:OnEnter( )
			Search( QueryBox:GetValue( ) )
		end

		Search( )

		function FunctionPanel:PerformLayout( )
			LayOut( Sheet )

			Sheet:SetPos( 5, 5 )
			Sheet:SetSize( self:GetWide( ) - 20, self:GetTall( ) - 50 )

			SearchPanel:SetPos( 5, self:GetTall( ) - 40 )
			SearchPanel:SetSize( self:GetWide( ) - 20, 30 )

			QueryBox:SetSize( SearchPanel:GetWide( ) - 40, 20 )
			QueryBox:SetPos( 5, 5 )

			SearchButton:SetSize( 20, 20 )
			SearchButton:SetPos( SearchPanel:GetWide( ) - 30, 5 )
		end
end

