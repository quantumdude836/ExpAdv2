/* --- --------------------------------------------------------------------------------
	@: String Component
   --- */

local Component = EXPADV.AddComponent( "string" , true )

Component.Author = "Rusketh"
Component.Description = "Added basic and advanced functions to do with strings."

/* --- --------------------------------------------------------------------------------
	@: String Object
   --- */

local String = Component:AddClass( "string" , "s" )

String:StringBuilder( function( Obj ) return Obj end )
String:DefaultAsLua( "" )
String:AddAlias( "str" )

/* --- --------------------------------------------------------------------------------
	@: Wire Support
   --- */

if WireLib then
	String:WireInput( "STRING" ) 
	String:WireOutput( "STRING" )

	String:WireLinkOutput( )
	String:WireLinkInput( )
end

/* --- --------------------------------------------------------------------------------
	@: Logical and Comparison
   --- */

Component:AddInlineOperator("==", "s,s", "b", "(@value 1 == @value 2)" )

Component:AddInlineOperator("!=", "s,s", "b", "(@value 1 ~= @value 2)" )

Component:AddInlineOperator(">", "s,s", "b", "(@value 1 > @value 2)" )

Component:AddInlineOperator("<", "s,s", "b", "(@value 1 < @value 2)" )

Component:AddInlineOperator(">=","s,s", "b", "(@value 1 >= @value 2)" )

Component:AddInlineOperator("<=","s,s", "b", "(@value 1 <= @value 2)" )

/* --- --------------------------------------------------------------------------------
	@: Assignment
   --- */

String:AddVMOperator( "=", "n,s", "", function( Context, Trace, MemRef, Value )
   local Prev = Context.Memory[MemRef]
   Context.Memory[MemRef] = Value
   Context.Trigger[MemRef] = Context.Trigger[MemRef] or ( Prev ~= Value )
end )

-- Component:AddPreparedOperator( "~", "n", "b", [[
-- 	@define value = Context.Memory[@value 1]
-- 	@define changed = Context.Changed[@value 1] ~= @value
-- 	Context.Changed[@value 1] = @value
-- ]], "@changed" )


/* --- --------------------------------------------------------------------------------
	@: Arithmetic
   --- */

Component:AddInlineOperator("+","s,s", "s", "(@value 1 .. @value 2)" )

Component:AddInlineOperator("+","s,n", "s", "(@value 1 .. @value 2)" )

Component:AddInlineOperator("+","n,s", "s", "(@value 1 .. @value 2)" )

Component:AddInlineOperator( "#","s","n", "(string.len(@value 1))" )

/* --- --------------------------------------------------------------------------------
	@: Operators
   --- */

Component:AddInlineOperator( "is", "s", "b", "(@value 1 ~= \"\")" )

Component:AddInlineOperator( "not", "s", "b", "(@value 1 == \"\")" )

/* --- --------------------------------------------------------------------------------
	@: Indexing
   --- */

String:AddInlineOperator( "get", "s,n", "s", "string.sub(@value 1, @value 2, @value 2)" )

/* --- --------------------------------------------------------------------------------
	@: Casting
   --- */

Component:AddInlineOperator( "number", "s", "n", "tonumber(@value 1)" )

/* --- --------------------------------------------------------------------------------
	@: basic
   --- */

Component:AddInlineFunction( "sub", "s:n,n", "s", "string.sub(@value 1, @value 2, @value 3)" )
Component:AddFunctionHelper( "sub", "s:n,n", "Returns a substring starting at location (number1 start) and ending at (number2 end)." )

Component:AddInlineFunction( "lower", "s:", "s", "string.lower(@value 1)" )
Component:AddFunctionHelper( "lower", "s:", "Returns a lower-cased (string)." )

Component:AddInlineFunction( "upper", "s:", "s", "string.upper(@value 1)" )
Component:AddFunctionHelper( "upper", "s:", "Returns an uppercased string." )

/* --- --------------------------------------------------------------------------------
	@: Find and replace
   --- */

Component:AddInlineFunction( "find", "s:s", "n", "(string.find(@value 1, @value 2) or 0)" )
Component:AddFunctionHelper( "find", "s:s", "Returns the location of first instance of (string) in a string." )

Component:AddInlineFunction( "find", "s:s,n", "n", "(string.find(@value 1, @value 2, @value 3) or 0)" )
Component:AddFunctionHelper( "find", "s:s,n", "Returns he location of first instance of (string) in a string, starting at location (number)." )

Component:AddInlineFunction( "find", "s:s,n,b", "n", "(string.find(@value 1, @value 2, @value 3, @value 4) or 0)" )
Component:AddFunctionHelper( "find", "s:s,n,b", "Returns he location of first instance of (string) in a string, starting at location (number), using stirng patters if bool is true." )

Component:AddInlineFunction( "replace", "s:s,s", "s", "(string.Replace(@value 1, @value 2, @value 3) or \"\")" )
Component:AddFunctionHelper( "replace", "s:s,s", "Finds and replaces every occurrence of the first argument with the second argument." )

/* --- --------------------------------------------------------------------------------
	@: Explodes and matches
   --- */

Component:AddPreparedFunction( "explode", "s:s", "ar", "@define Array = string.Explode(@value 2, @value 1)\n@Array.__type = 's'", "@Array" )

Component:AddPreparedFunction( "explode", "s:s,b", "ar", "@define Array = string.Explode(@value 2, @value 1, @value 3)\n@Array.__type = 's'", "@Array" )

Component:AddInlineFunction( "matchPattern", "s:s", "ar", "{__type = 's',string.match(@value 1, @value 2)}" )

Component:AddInlineFunction( "matchPattern", "s:s,n", "ar", "{__type = 's',string.match(@value 1, @value 2, @value 3)}" )

Component:AddInlineFunction( "matchFirst", "s:s", "s", "{__type = 's',string.match(@value 1, @value 2)}" )
Component:AddFunctionHelper( "matchFirst", "s:s", "Returns a string match to (string) starting at the leftmost character." )

Component:AddInlineFunction( "matchFirst", "s:s,n", "s", "{__type = s',string.match(@value 1, @value 2, @value 3)}" )
Component:AddFunctionHelper( "matchFirst", "s:s,n", "Returns a string match to (string) starting at the leftmost character starting at location (number)." )

Component:CreateSetting( "gmatch_limit", 50 )

Component:AddPreparedFunction( "gmatch", "s:s", "ar", [[
	@define array, iter, values = {__type = 's'}, string.gmatch( @value 1, @value 2 )

	for i = 1, @setting gmatch_limit do
		@values = {@iter( )}
		if table.getn(@values) == 0 then break end
		@array[i] = @values
	end
]], "@array" )

Component:AddPreparedFunction( "gmatch", "s:s,n", "ar", [[
	@define array, iter, values = {__type = 's'}, string.gmatch( @value 1, @value 2 )

	for i = 1, math.Clamp( @value 3 or @setting gmatch_limit, 0, @setting gmatch_limit) do
		@values = {@iter( )}
		if table.getn(@values) == 0 then break end
		@array[i] = @values
	end
]], "@array" )

/* --- --------------------------------------------------------------------------------
	@: Format
   --- */

Component:AddPreparedFunction( "format", "s:...", "s", [[
	@define values, result = {}
	
	for i, variant in pairs( { @... } ) do
		@values[I] = tostring( @variant[1] )
	end
	
	@result = string.format( @value 1, unpack(@values) )
]], "@result" )

/* --- --------------------------------------------------------------------------------
	@: Insert / Remove
   --- */
   
Component:AddInlineFunction( "remove", "s:n,n", "s", "(string.sub( @value 1, 1, @value 2 - 1 ) .. string.sub( @value 1, @value 3 or (@value 2 + 1) ))" )
Component:AddFunctionHelper( "remove", "s:n,n", "Removes nth Char from string." )
		  EXPADV.AddFunctionAlias( "remove", "s:n" )

Component:AddInlineFunction( "insert", "s:s,n,n", "s", "(string.sub( @value 1, 1, @value 3 ) .. @value 2 .. string.sub( @value 1, @value 4 or (@value 3 + 1) ))" )
Component:AddFunctionHelper( "insert", "s:s,n,n", "Inserts into string after nth char." )
		  EXPADV.AddFunctionAlias( "insert", "s:s,n" )

/* --- --------------------------------------------------------------------------------
	@: Char and byte
   --- */

Component:AddInlineFunction( "toByte", "s:", "n", [[(@value 1 ~= "" and string.byte(@value 1) or -1)]] )
Component:AddFunctionHelper( "toByte", "s:", "Returns the ASCII code for a given character." )

Component:AddInlineFunction( "toChar", "n:", "s", [[(@value 1 ~= -1 and string.char(@value 1) or "")]] )
Component:AddFunctionHelper( "toChar", "n:", "Returns the character for a given ASCII code." )

