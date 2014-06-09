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

/*==============================================================================================
	Section: Operators
==============================================================================================*/

-- Assign:

StringComponent:AddPreparedOperator( "s=", "n,s", "", [[
    Context.Trigger = Context.Trigger or Context.Memory[@value 1] ~= @value 2
    Context.Memory[@value 1] = @value 2
]] )

-- Changed:

StringComponent:AddPreparedOperator( "~", "n", "b", [[
	@define value = Context.Memory[@value 1]
	@define changed = Context.Changed[@value 1] ~= @value
	Context.Changed[@value 1] = @value
]], "@changed" )

-- Compare:

StringComponent:AddInlineOperator("==", "s,s", "b", "(@value 1 == @value 2)" )

StringComponent:AddInlineOperator("!=", "s,s", "b", "(@value 1 ~= @value 2)" )

StringComponent:AddInlineOperator(">", "s,s", "b", "(@value 1 > @value 2)" )

StringComponent:AddInlineOperator("<", "s,s", "b", "(@value 1 < @value 2)" )

StringComponent:AddInlineOperator(">=","s,s", "b", "(@value 1 >= @value 2)" )

StringComponent:AddInlineOperator("<=","s,s", "b", "(@value 1 <= @value 2)" )

-- Arithmetic:

StringComponent:AddInlineOperator("+","s,s", "s", "(@value 1 .. @value 2)" )

StringComponent:AddInlineOperator("+","s,n", "s", "(@value 1 .. @value 2)" )

StringComponent:AddInlineOperator("+","n,s", "s", "(@value 1 .. @value 2)" )

StringComponent:AddInlineOperator( "#","s","n", "(string.len(@value 1))" )

-- General:

StringComponent:AddInlineOperator("=s","n","s", "(Context.Memory[@value 1] or \"\")" )

StringComponent:AddInlineOperator( "is", "s", "b", "(@value 1 ~= \"\")" )

StringComponent:AddInlineOperator( "not", "s", "b", "(@value 1 == \"\")" )

-- Index:

StringComponent:AddInlineOperator( "[]", "s,n", "s", "string.sub(@value 1, @value 2, @value 2)" )

-- Casting:

StringComponent:AddInlineOperator( "number", "s", "n", "tonumber(@value 1)" )

/*==============================================================================================
	Section: Finding and Replacing
==============================================================================================*/

StringComponent:AddInlineOperator( "find", "s:s", "n", "(string.find(@value 1, @value 2) or 0)" )

StringComponent:AddInlineOperator( "find", "s:s,n", "n", "(string.find(@value 1, @value 2, @value 3) or 0)" )

StringComponent:AddInlineOperator( "find", "s:s,n,b", "n", "(string.find(@value 1, @value 2, @value 3, @value 4) or 0)" )

StringComponent:AddInlineOperator( "replace", "s:s,s", "s", "(string.Replace(@value 1, @value 2, @value 3) or \"\")" )

/*==============================================================================================
	Section: Explode / Matches
==============================================================================================*/

-- StringComponent:AddInlineFunction( "explode", "s:s", "s*", "string.Explode(@value 2, @value 1)" )

-- StringComponent:AddInlineFunction( "explode", "s:s,b", "s*", "string.Explode(@value 2, @value 1, @value 3)" )

-- StringComponent:AddInlineFunction( "matchPattern", "s:s", "s*", "{string.match(@value 1, @value 2)}" )

-- StringComponent:AddInlineFunction( "matchPattern", "s:s,n", "s*", "{string.match(@value 1, @value 2, @value 3)}" )

StringComponent:AddInlineFunction( "matchFirst", "s:s", "s", "string.match(@value 1, @value 2)" )

StringComponent:AddInlineFunction( "matchFirst", "s:s,n", "s", "string.match(@value 1, @value 2, @value 3)" )

--[[ StringComponent:AddPreparedFunction( "gmatch", "s:s", "s*", [[
	@define array, iter, values = {}, string.gmatch( @value 1, @value 2 )

	for i = 1, 50 do
		@values = {@iter( )}
		if table.getn(@values) == 0 then break end
		@array[i] = @values
	end
]], "@array" )]]

--[[ StringComponent:AddPreparedFunction( "gmatch", "s:s,n", "s*", [[
	@define array, iter, values = {}, string.gmatch( @value 1, @value 2 )

	for i = 1, math.Clamp( @value 3 or 50, 0, 50) do
		@values = {@iter( )}
		if table.getn(@values) == 0 then break end
		@array[i] = @values
	end
]], "@array" ) ]]

/*==============================================================================================
	Section: Format
==============================================================================================*/

--TODO: Add error handling

StringComponent:AddPreparedFunction( "format", "s:...", "s", [[
	@define values, result = {}
	
	for i, variant in pairs( { @... } ) do
		@values[I] = istable(@variant[1]) and tostring( @variant[1] ) or variant[1]
	end
	
	@result = string.format( @value 1, unpack(@values) )
]], "@result" )
