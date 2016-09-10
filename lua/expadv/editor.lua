/*---------------------------------------------------------------------------
	Expression Advanced: Editor.
	Purpose: Make the fancy EA editor.
	Author: Oskar 
---------------------------------------------------------------------------*/
EXPADV.Editor = { }

local Editor = EXPADV.Editor

require( "vector2" )
/*---------------------------------------------------------------------------
	Custom fonts
---------------------------------------------------------------------------*/

timer.Simple( 0.5, function()
	surface.CreateFont( "Trebuchet22", {
		font 		= "Trebuchet MS",
		size 		= 22,
		weight 		= 900,
		blursize 	= 0,
		scanlines 	= 0,
		antialias 	= true,
		underline 	= false,
		italic 		= false,
		strikeout 	= false,
		symbol 		= false,
		rotary 		= false,
		shadow 		= false,
		additive 	= false,
		outline 	= false
	} )

	surface.CreateFont( "Trebuchet20", {
		font 		= "Trebuchet MS",
		size 		= 20,
		weight 		= 900,
		blursize 	= 0,
		scanlines 	= 0,
		antialias 	= false,
		underline 	= false,
		italic 		= false,
		strikeout 	= false,
		symbol 		= false,
		rotary 		= false,
		shadow 		= false,
		additive 	= false,
		outline 	= false
	} )
end ) 

/*---------------------------------------------------------------------------
	Home Screen
---------------------------------------------------------------------------*/
local HomeScreen = [[
/*------------------------------------------------------------------
    Expression Advanced 2
--------------------------------------------------------------------
        New to EXPADV2, Click (?) in the toolbar,
            it's the easiest and fastest way to learn.

        The github repository can be found here:
            https://github.com/Rusketh/ExpAdv2
        
        For a better look at the new syntax:
            https://github.com/Rusketh/ExpAdv2/wiki/Syntax
    
        Expression Advanced 2 for Dummies:
            http://goo.gl/g6WEfs it's your offical guide to ExpAdv2.
    
        For a list of components and Classes:
            https://github.com/Rusketh/ExpAdv2/wiki/Components
        	
        The bug tracker can be found here:
            https://github.com/Rusketh/ExpAdv2/issues
        
        For function requests please use the bug tracker.
            We will add functions as they are requested.

        DO NOT MESSAGE RUSKETH WITH BUGS ON STEAM.
        TO REPORT A BUG USE THE BUG TRACKER ON GITHUB.
------------------------------------------------------------------*/
]]

/*---------------------------------------------------------------------------
	Syntax Highlighting
---------------------------------------------------------------------------*/
local function SyntaxColorLine( self, Row ) 
	local Tokens, Ok 
	
	Ok, Tokens = pcall( EXPADV.Highlight, self, Row )
	
	if !Ok then 
		ErrorNoHalt( Tokens .. "\n" )
		Tokens = {{self.Rows[Row], Color(255,255,255)}} 
	end 
	
	return Tokens 
end


/*---------------------------------------------------------------------------
	Editor Functions
---------------------------------------------------------------------------*/ 
function Editor.Create( )
	if Editor.Instance then return end 
	
	file.CreateDir("expadv2")
	
	local Instance = vgui.Create( "EA_EditorPanel" ) 
	
	function Instance:OnTabCreated( Tab, Code, Path ) 
		if Code or Path then return false end 
		local Editor = Tab:GetPanel( ) 
		Editor:SetCode( HomeScreen ) 
		Editor.Caret = Vector2( #Editor.Rows, #Editor.Rows[#Editor.Rows] + 1 ) 
		Editor.Start = Vector2( 1, 1 ) 
		return true 
	end
	
	Instance:SetSyntaxColorLine( SyntaxColorLine ) 
	
	Instance:SetKeyBoardInputEnabled( true )
	Instance:SetVisible( false ) 
	
	Editor.Instance = Instance 
end

function Editor.Open( Code, NewTab )
	Editor.Create( ) 
	Editor.Instance:Open( Code, NewTab ) 
end

function Editor.NewTab( Script, FilePath )
	Editor.Create( ) 
	Editor.Instance:NewTab( Script, FilePath ) 
end

function Editor.GetCode( )
	if Editor.Instance then 
		return Editor.Instance:GetCode( )
	end 
end

function Editor.GetSession( )
	if Editor.Instance then 
		return Editor.Instance:GetSession( ) 
	end 
end

function Editor.GetInstance( )
	Editor.Create( )
	return Editor.Instance
end

function Editor.ReciveDownload( Download )
	Editor.Create( ) 
	Editor.Instance:ReciveDownload( Download )
end

function Editor.Validate( Script )
	if Editor.Instance then
		return Editor.Instance:DoValidate( false, Script )
	end
end

/*---------------------------------------------------------------------------
	Reset position command
---------------------------------------------------------------------------*/ 
concommand.Add( "expadv_editor_repos", function( )
	Editor.GetInstance( ):SetPos(10, 10)
	Editor.GetInstance( ):SetSize(ScrW() - 20, ScrH() - 20)
end )