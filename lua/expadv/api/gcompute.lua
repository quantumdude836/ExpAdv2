local LANGUAGE = GCompute.Languages.Create( "EXPADV2" )

EXPADV.GCompute = LANGUAGE

----------------------------------------------------------------------------------

local Tokenizer = LANGUAGE:GetTokenizer( )
Tokenizer:AddPatternSymbol( GCompute.Lexing.TokenType.Identifier, "[a-zA-Z_][a-zA-Z0-9_]*" )
Tokenizer:AddPatternSymbols( GCompute.Lexing.TokenType.Number, {
		"0b[01]+",
		"0x[0-9a-fA-F]+",
		"[0-9]+%.[0-9]*e[-+]?[0-9]+%.[0-9]*",
		"[0-9]+%.[0-9]*e[-+]?[0-9]+",
		"[0-9]+%.[0-9]*",
		"[0-9]+e[-+]?[0-9]+%.[0-9]*",
		"[0-9]+e[-+]?[0-9]+", "[0-9]+"
} )

Tokenizer:AddPlainSymbols( GCompute.Lexing.TokenType.MemberIndexer, { "." } )
Tokenizer:AddPlainSymbol( GCompute.Lexing.TokenType.StatementTerminator, ";" )
Tokenizer:AddPlainSymbols( GCompute.Lexing.TokenType.Newline, { "\r\n", "\r", "\n" } )
Tokenizer:AddPatternSymbol( GCompute.Lexing.TokenType.Whitespace, "[ \t]+" )

Tokenizer:AddPlainSymbol( GCompute.Lexing.TokenType.Comment, "//[^\n\r]*" )
Tokenizer:AddCustomSymbol( GCompute.Lexing.TokenType.Comment, "/*", function( Code, Offset )
	local endOffset = string.find( Code, "*/", Offset + 2, true )
	if endOffset then return string.sub( Code, Offset, endOffset + 1), endOffset - Offset + 2 end
	return string.sub( Code, Offset ), string.len( Code ) - Offset + 1
end )

Tokenizer:AddCustomSymbols (GCompute.Lexing.TokenType.String, {"\"", "'"}, function (code, offset)
	local quotationMark = string.sub (code, offset, offset)
	local searchStartOffset = offset + 1
	local backslashOffset = 0
	local quotationMarkOffset = 0
	while true do
		if backslashOffset and backslashOffset < searchStartOffset then
			backslashOffset = string.find (code, "\\", searchStartOffset, true)
		end
		if quotationMarkOffset and quotationMarkOffset < searchStartOffset then
			quotationMarkOffset = string.find (code, quotationMark, searchStartOffset, true)
		end
		
		if backslashOffset and quotationMarkOffset and backslashOffset > quotationMarkOffset then backslashOffset = nil end
		if not backslashOffset then
			if quotationMarkOffset then
				return string.sub (code, offset, quotationMarkOffset), quotationMarkOffset - offset + 1
			else
				return string.sub (code, offset), string.len (code) - offset + 1
			end
		end
		searchStartOffset = backslashOffset + 2
	end
end )
	
----------------------------------------------------------------------------------

local KeywordClassifier = LANGUAGE:GetKeywordClassifier( )
KeywordClassifier:AddKeywords( GCompute.Lexing.KeywordType.Modifier, { "global", "input", "output" } )
KeywordClassifier:AddKeywords( GCompute.Lexing.KeywordType.Control,  { "if", "else", "elseif", "while", "for", "foreach", "switch", "case", "default", "try", "catch" } )
KeywordClassifier:AddKeywords( GCompute.Lexing.KeywordType.Control,  { "break", "return", "continue", "throw" } )
KeywordClassifier:AddKeywords( GCompute.Lexing.KeywordType.DataType, { "method", "function", "event" } )
KeywordClassifier:AddKeywords( GCompute.Lexing.KeywordType.Constant, { "true", "false" } )

----------------------------------------------------------------------------------

local EditorHelperTable = LANGUAGE.EditorHelperTable

function EditorHelperTable:GetCommentFormat( )
	return "//", "/*", "*/"
end

----------------------------------------------------------------------------------

LANGUAGE.RootNamespace = GCompute.NamespaceDefinition( )

function EditorHelperTable:GetRootNamespace( )
    return LANGUAGE.RootNamespace
end


----------------------------------------------------------------------------------

function LANGUAGE.BuildData( )
	local Namespace = LANGUAGE.RootNamespace

	local OperatorTokens = { }

	for _, Token in pairs( EXPADV.Compiler.RawTokens ) do
		OperatorTokens[#OperatorTokens + 1] = Token[1]
	end

	Tokenizer:AddPlainSymbols( GCompute.Lexing.TokenType.Operator, OperatorTokens )

	-------------------------------------------------------------------------------------

	local Classes = { ["..."] = Namespace:AddClass( "..." ) }
	local Void = GCompute.GlobalNamespace:GetMember("void"):ToType( )

	for Name, Class in pairs( EXPADV.Classes ) do
		Classes[Class.Short] = Namespace:AddClass( Name )
	end

	for Name, Class in pairs( EXPADV.Classes ) do
		if Class.DeriveGeneric or !Class.DerivedClass then continue end
		Classes[Class.Short]:AddBaseType( Classes[Class.DerivedClass.Short] )
	end

	-- TODO: !Cake fix this please!
	for _, Operator in pairs( EXPADV.Functions ) do
		local ParameterList = GCompute.ParameterList( )
		local ReturnType = Operator.Return and Classes[Operator.Return]:GetClassType( ) or Void
 
		if !Operator.Method then
			local Member = Namespace:GetMember( Operator.Name )
			if !Member then continue end

			for I = 1, #Operator.Input do
				ParameterList:AddParameter( Classes[Operator.Input[I]]:GetClassType( ) )
			end

			Member:GetClass( 1 ):AddConstructor( ParameterList )
		else
			local MethodClass = Classes[Operator.Input[1]]--:GetClassType( )

			for I = 2, #Operator.Input do
				ParameterList:AddParameter( Classes[Operator.Input[I]]:GetClassType( ) )
			end

			MethodClass:GetNamespace( ):AddMethod( Operator.Name, ParameterList ):SetReturnType( ReturnType )
			
		end
	end

	LANGUAGE:DispatchEvent( "NamespaceChanged" )

	hook.Add( "expadv.UnloadCore", "expadv.GCompute.BuildData", function( )
		GCompute.Languages.Remove( "EXPADV2" )
	end )
end

hook.Add( "Expadv.PostLoadCore", "Expadv.GCompute.RequestData", LANGUAGE.BuildData )

GCompute:AddEventListener( "Unloaded", function( ) hook.Remove( "expadv.PostLoadCore", "expadv.GCompute.BuildData" ) end )

if EXPADV and EXPADV.IsLoaded then LANGUAGE.BuildData( ) end

----------------------------------------------------------------------------------

local PANEL = { }

function PANEL:Init( )
	self.Tabs = vgui.Create( "DPropertySheet", self )
	self.Tabs:Dock( FILL )

	self.CellList = vgui.Create( "DListView" )
	self.CellList:AddColumn( "Cell" )
	self.CellList:AddColumn( "Scope" )
	self.CellList:AddColumn( "Class" )
	self.CellList:AddColumn( "Modifier" )
	self.CellList:AddColumn( "Name" )
	self.CellList:AddColumn( "Value" )

	self.Tabs:AddSheet( "Memory", self.CellList, "gui/codeicons/field",  false, false, "Debug memory" )
	self.CellList:Dock( FILL )

	self.DrawPnl = vgui.Create( "DPanel" )
	self.Tabs:AddSheet( "Render", self.DrawPnl, "gui/codeicons/field",  false, false, "Veiw render hook" )
	self.DrawPnl:Dock( FILL )

	function self.DrawPnl.Paint( Pnl )
		local Context = self.Context

		if !Context or !Context.Online then return end

		local Event = Context.event_render
		if !Event then return end

		Context:Execute( "Event render", Event, Pnl:GetSize( ) )
	end
end

function PANEL:Update( )
	self.CellList:Clear( )

	for MemRef, Cell in pairs( self.Context.Cells ) do
		local Value = self.Context.Memory[MemRef]
		local StrValue = tostring( Value or "#Void" )

		self.CellList:AddLine( MemRef, Cell.Scope, EXPADV.TypeName( Cell.Return ), Cell.Modifier or "N/A", Cell.Variable, StrValue )
	end
end

function PANEL:ShowLog( Log )
	self.Log = { }

	self.Pnl_log = vgui.Create( "DListView" )
	self.Pnl_log:AddColumn( "Instruction" )
	self.Pnl_log:AddColumn( "Length" )
	self.Pnl_log:AddColumn( "Lines" )

	for Name, Native in pairs( Log ) do
		local Line = self.Pnl_log:AddLine( Name, #Native, #string.Explode( "\n", Native ) )
		self.Log[Line] = {Name, Native}
	end

	function self.Pnl_log.OnClickLine( _, Pnl, Selected )
		if !Selected then return end

		local DragonDildos = GCompute.IDE.Instance:CreateView( "Code" )
		DragonDildos:SetTitle( self.Log[Pnl][1] )
		DragonDildos:SetCode( self.Log[Pnl][2] )
		DragonDildos:Select( )
	end

	self.Tabs:AddSheet( "Interpritation", self.Pnl_log, "gui/codeicons/field",  false, false, "View native interpriations" )
	self.Pnl_log:Dock( FILL )
end

function PANEL:Build( Context, Root, stdOut, stdErr )

	EXPADV.RegisterContext( Context )

	self.Context = Context

	Context:StartUp( Root )
end

function PANEL:ShutDown( )
	self.Context:ShutDown( )
	EXPADV.UnregisterContext( self.Context )
end

vgui.Register( "EA_GC_Context", PANEL, "DPanel" )

----------------------------------------------------------------------------------

function EditorHelperTable:Run( codeEditor, compilerStdOut, compilerStdErr, stdOut, stdErr )
	local OnError = function( ErrMsg )
		compilerStdErr:WriteLine( ErrMsg )
	end

	local OnSucess = function ( Instance, Instruction )
		compilerStdOut:WriteLine( "Compiler Finished." )

		Instance.Enviroment.print = function( ... )
			stdOut:WriteLine( ... )
		end

		local Native = table.concat( {
			"return function( Context )",
			"setfenv( 1, Context.Enviroment )",
			Instruction.Prepare or "",
			Instruction.Inline or "",
			"end"
		}, "\n" )

		local Compiled = CompileString( Native, "EXPADV2", false )
		Instance.NativeLog["Root"] = Native

		if isstring( Compiled ) then
			compilerStdErr:WriteLine( "Failed to compile native.")
			compilerStdErr:WriteLine( Compiled )
			
			local DragonDildos = GCompute.IDE.Instance:CreateView( "Code" )
			DragonDildos:SetTitle( "Root" )
			DragonDildos:SetCode( Native )
			DragonDildos:Select( )
		end

		local Context = EXPADV.BuildNewContext( Instance, LocalPlayer( ), LocalPlayer( ) )
		
		compilerStdOut:WriteLine( "Context built." )

		local Frame = vgui.Create( "DFrame" )
		Frame:SetTitle( "Expression Advanced - Debugger" )
		Frame:SetSize( 600, 322 )

		local Pnl = vgui.Create( "EA_GC_Context", Frame )
		Pnl:Dock( FILL )

		Pnl:Build( Context, Compiled( ), stdOut, stdErr )
		Pnl:ShowLog( Instance.NativeLog )

		Frame:Center( )
		Frame:MakePopup( )

		Frame.Close = function( self )
			Pnl:ShutDown( )
			DFrame.Close( self )
		end
	end

	compilerStdOut:WriteLine( "Compiler Started." )

	EXPADV.Compile( codeEditor:GetText( ), { }, OnError, OnSucess )
end