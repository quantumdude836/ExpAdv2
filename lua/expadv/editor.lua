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
/*----------------------------------------------------
    Welcome to Expression Advanced 2 - Alpha:
  Your Lemon-Gate code is outdated and won't work.
----------------------------------------------------*/
 
//Define Variables:
    number var = 22;
 
//Define functions:
    function number add( number a, number b ) {
        return a + b;
    }
 
//Method operator is now period (.) not colon (:):
    entity().pos();
 
//For loops are now inbeded:
    for ( number i = 1; 100; 2 ) {
        print( i );
    }
 
/*----------------------------------------------------
    Your code now runs on the server and client.
        for now clientside code is usless.
----------------------------------------------------*/
 
//Define serverside code:
    server {
        print( "SERVERSIDE" );
    }
 
//Define clientside code:
    client {
        print( "CLIENTSIDE" );
    }
 
/*----------------------------------------------------
    Any code not defined inside one of these defintions
    is considered both serverside and clientside.
        (Root is serverside and clientside.)
 
    You can also prefix statements with server/client.
----------------------------------------------------*/
 
    number Var = 22;

    server Var += 10;

    print( Var );
 
/*----------------------------------------------------
    The github repository can be found here:
        https://github.com/Rusketh/ExpAdv2
	
	For a list of components and Classes:
		https://github.com/Rusketh/ExpAdv2/wiki/Components
		
    The bug tracker can be found here:
        https://github.com/Rusketh/ExpAdv2/issues
 
    For function requests please use the bug tracker.
        We will add functions as they are requested.
----------------------------------------------------*/
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
		return Editor.Instance:DoValidate( nil, nil, Script )
	end
end