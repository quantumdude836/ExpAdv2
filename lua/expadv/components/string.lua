/*	---	--------------------------------------------------------------------------------
	@: String Component
---	*/

local MathComponent = EXPADV.AddComponent( "string" , true )
local String = MathComponent:AddClass( "string" , "s" )

String:StringBuilder( function( Context, Trace, Obj) return Obj end )
String:DefaultAsLua( "" )
String:AddAlias( "str" )

if WireLib then
	String:WireInput( "STRING" ) 
	String:WireOutput( "STRING" ) 
end

