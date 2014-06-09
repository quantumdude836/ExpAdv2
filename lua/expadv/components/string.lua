/* ---	--------------------------------------------------------------------------------
	@: String Component
   ---	*/

local StringComponent = EXPADV.AddComponent( "string" , true )
local String = StringComponent:AddClass( "string" , "s" )

String:StringBuilder( function( Context, Trace, Obj) return Obj end )
String:DefaultAsLua( "" )
String:AddAlias( "str" )

if WireLib then
	String:WireInput( "STRING" ) 
	String:WireOutput( "STRING" ) 
end

StringComponent:AddInlineOperator("#", "s", "n", "string.len(@value 1)" )
StringComponent:AddInlineOperator("+", "s,s", "s", "(@value 1 .. @value 2)" )
StringComponent:AddInlineOperator("is", "s", "b", "(@value 1 ~= \"\")" )