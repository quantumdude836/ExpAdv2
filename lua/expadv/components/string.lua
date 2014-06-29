/* ---	--------------------------------------------------------------------------------
	@: String Component
   ---	*/

local StringComponent = EXPADV.AddComponent( "string" , true )

/* --- --------------------------------------------------------------------------------
	@: String Object
   --- */

local String = StringComponent:AddClass( "string" , "s" )

String:StringBuilder( function( Context, Trace, Obj) return Obj end )
String:DefaultAsLua( "" )
String:AddAlias( "str" )

/* --- --------------------------------------------------------------------------------
	@: Wire Support
   --- */

if WireLib then
	String:WireInput( "STRING" ) 
	String:WireOutput( "STRING" ) 
end

/* --- --------------------------------------------------------------------------------
	@: Logical and Comparason
   --- */

StringComponent:AddInlineOperator("==", "s,s", "b", "(@value 1 == @value 2)" )

StringComponent:AddInlineOperator("!=", "s,s", "b", "(@value 1 ~= @value 2)" )

StringComponent:AddInlineOperator(">", "s,s", "b", "(@value 1 > @value 2)" )

StringComponent:AddInlineOperator("<", "s,s", "b", "(@value 1 < @value 2)" )

StringComponent:AddInlineOperator(">=","s,s", "b", "(@value 1 >= @value 2)" )

StringComponent:AddInlineOperator("<=","s,s", "b", "(@value 1 <= @value 2)" )

/* --- --------------------------------------------------------------------------------
	@: Assigment
   --- */

StringComponent:AddPreparedOperator( "s=", "n,s", "", [[
    Context.Trigger = Context.Trigger or Context.Memory[@value 1] ~= @value 2
    Context.Memory[@value 1] = @value 2
]] )

StringComponent:AddInlineOperator("=s","n","s", "(Context.Memory[@value 1] or \"\")" )

StringComponent:AddPreparedOperator( "~", "n", "b", [[
	@define value = Context.Memory[@value 1]
	@define changed = Context.Changed[@value 1] ~= @value
	Context.Changed[@value 1] = @value
]], "@changed" )


/* --- --------------------------------------------------------------------------------
	@: Arithmatic
   --- */

StringComponent:AddInlineOperator("+","s,s", "s", "(@value 1 .. @value 2)" )

StringComponent:AddInlineOperator("+","s,n", "s", "(@value 1 .. @value 2)" )

StringComponent:AddInlineOperator("+","n,s", "s", "(@value 1 .. @value 2)" )

StringComponent:AddInlineOperator( "#","s","n", "(string.len(@value 1))" )

/* --- --------------------------------------------------------------------------------
	@: Operators
   --- */

StringComponent:AddInlineOperator( "is", "s", "b", "(@value 1 ~= \"\")" )

StringComponent:AddInlineOperator( "not", "s", "b", "(@value 1 == \"\")" )

/* --- --------------------------------------------------------------------------------
	@: Indexing
   --- */

StringComponent:AddInlineOperator( "[]", "s,n", "s", "string.sub(@value 1, @value 2, @value 2)" )

/* --- --------------------------------------------------------------------------------
	@: Casting
   --- */

StringComponent:AddInlineOperator( "number", "s", "n", "tonumber(@value 1)" )

/* --- --------------------------------------------------------------------------------
	@: Find and replace
   --- */

StringComponent:AddInlineFunction( "find", "s:s", "n", "(string.find(@value 1, @value 2) or 0)" )

StringComponent:AddInlineFunction( "find", "s:s,n", "n", "(string.find(@value 1, @value 2, @value 3) or 0)" )

StringComponent:AddInlineFunction( "find", "s:s,n,b", "n", "(string.find(@value 1, @value 2, @value 3, @value 4) or 0)" )

StringComponent:AddInlineFunction( "replace", "s.s,s", "s", "(string.Replace(@value 1, @value 2, @value 3) or \"\")" )

/* --- --------------------------------------------------------------------------------
	@: Explodes and matches
   --- */

-- StringComponent:AddInlineFunction( "explode", "s:s", "s*", "string.Explode(@value 2, @value 1)" )

-- StringComponent:AddInlineFunction( "explode", "s:s,b", "s*", "string.Explode(@value 2, @value 1, @value 3)" )

-- StringComponent:AddInlineFunction( "matchPattern", "s:s", "s*", "{string.match(@value 1, @value 2)}" )

-- StringComponent:AddInlineFunction( "matchPattern", "s:s,n", "s*", "{string.match(@value 1, @value 2, @value 3)}" )

StringComponent:AddInlineFunction( "matchFirst", "s:s", "s", "string.match(@value 1, @value 2)" )

StringComponent:AddInlineFunction( "matchFirst", "s:s,n", "s", "string.match(@value 1, @value 2, @value 3)" )

/*
StringComponent:CreateSetting( "gmatch_limit", 50 )

StringComponent:AddPreparedFunction( "gmatch", "s:s", "s*", [[
	@define array, iter, values = {}, string.gmatch( @value 1, @value 2 )

	for i = 1, @setting gmatch_limit do
		@values = {@iter( )}
		if table.getn(@values) == 0 then break end
		@array[i] = @values
	end
]], "@array" )

StringComponent:AddPreparedFunction( "gmatch", "s:s,n", "s*", [[
	@define array, iter, values = {}, string.gmatch( @value 1, @value 2 )

	for i = 1, math.Clamp( @value 3 or @setting gmatch_limit, 0, @setting gmatch_limit) do
		@values = {@iter( )}
		if table.getn(@values) == 0 then break end
		@array[i] = @values
	end
]], "@array" ) */

/* --- --------------------------------------------------------------------------------
	@: Format
   --- */

StringComponent:AddPreparedFunction( "format", "s:...", "s", [[
	@define values, result = {}
	
	for i, variant in pairs( { @... } ) do
		@values[I] = tostring( @variant[1] )
	end
	
	@result = string.format( @value 1, unpack(@values) )
]], "@result" )

/* --- --------------------------------------------------------------------------------
	@: Insert / Remove
   --- */
   
StringComponent:AddInlineFunction( "remove", "s:n,n", "s", "(string.sub( @Value 1, 1, @value - 1 ) .. string.sub( @Value 1, @value 3 or (@value 2 + 1) ))" )
StringComponent:AddFunctionHelper( "remove", "s:n,n", "Removes nth Char from string." )
		  EXPADV.AddFunctionAlias( "remove", "s:n" )

StringComponent:AddInlineFunction( "Insert", "s:s,n,n", "s", "(string.sub( @value 1, 1, @value 3 ) .. @value 2 .. string.sub( @value 1, @value 4 or (@value 3 + 1) ))" )
StringComponent:AddFunctionHelper( "Insert", "s:s,n,n", "Inserts into string after nth char." )
		  EXPADV.AddFunctionAlias( "Insert", "s:s,n" )
