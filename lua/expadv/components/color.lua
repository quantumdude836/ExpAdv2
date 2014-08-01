/* ---	--------------------------------------------------------------------------------
	@: Color Component
   ---	*/

local ColorComponent = EXPADV.AddComponent( "color", true )

/* ---	--------------------------------------------------------------------------------
	@: Color Object
   ---	*/

local ColorObj = ColorComponent:AddClass( "color", "c" )

ColorObj:StringBuilder( function( Color) return string.format( "Color< %i, %i, %i, %i >", Color.r, Color.g, Color.b, Color.a ) end )
ColorObj:DefaultAsLua( Color(255, 255, 255, 255) )

if WireLib then
	ColorObj:WireInput( "VECTOR", 
		function( Context, MemoryRef, InValue ) 
			Context.Memory[ MemoryRef ] = Color( InValue.x, InValue.y, InValue.z, 255 )
		end )

	ColorObj:WireOutput( "VECTOR", 
		function( Context, MemoryRef ) 
			local Color = Context.Memory[ MemoryRef ]
			return Vector(Color.r, Color.g, Color.b)
		end )
end

/* --- --------------------------------------------------------------------------------
	@: Logical and Comparison
   --- */

ColorComponent:AddInlineOperator( "==", "c,c", "b", "(@value 1 == @value 2)" )

ColorComponent:AddInlineOperator( "!=", "c,c", "b", "(@value 1 ~= @value 2)" )

/* --- --------------------------------------------------------------------------------
	@: Operators
   --- */

ColorComponent:AddInlineOperator( "is", "c", "b", "(@value 1 ~= Color(0, 0, 0, 0))" )

ColorComponent:AddInlineOperator( "not", "c", "b", "(@value 1 == Color(0, 0, 0, 0))" )

/* --- --------------------------------------------------------------------------------
	@: Casting
   --- */

ColorComponent:AddInlineOperator( "string", "c", "s", "string.format( \"Color< %i, %i, %i, %i >\", @value 1.r, @value 1.g, @value 1.b, @value 1.a )" )

ColorComponent:AddInlineOperator( "color", "s", "c", "string.ToColor(@value 1)" )

/* --- --------------------------------------------------------------------------------
	@: Assignment
   --- */

ColorComponent:AddPreparedOperator( "c=", "n,c", "", [[
	@define value = Context.Memory[@value 1]
	Context.Trigger = Context.Delta[@value 1] ~= @value
	Context.Memory[@value 1] = @value 2
]] )

ColorComponent:AddInlineOperator( "=c", "n", "c", "Context.Memory[@value 1]" )

/* --- --------------------------------------------------------------------------------
	@: Constructor
   --- */

ColorComponent:AddInlineFunction( "color", "n,n,n,n", "c", "Color(@value 1, @value 2, @value 3, @value 4)" )
ColorComponent:AddFunctionHelper( "color", "n,n,n,n", "Creates a color object")
EXPADV.AddFunctionAlias( "color", "n,n,n" )

/* --- --------------------------------------------------------------------------------
	@: Accessors
   --- */

--GETTERS
ColorComponent:AddInlineFunction( "getRed", "c:", "n", "@value 1.r")
ColorComponent:AddFunctionHelper( "getRed", "c:", "Gets the red value of a color object")

ColorComponent:AddInlineFunction( "getGreen", "c:", "n", "@value 1.g")
ColorComponent:AddFunctionHelper( "getGreen", "c:", "Gets the green value of a color object")

ColorComponent:AddInlineFunction( "getBlue", "c:", "n", "@value 1.b")
ColorComponent:AddFunctionHelper( "getBlue", "c:", "Gets the blue value of a color object")

ColorComponent:AddInlineFunction( "getAlpha", "c:", "n", "@value 1.a")
ColorComponent:AddFunctionHelper( "color", "c:", "Gets the alpha value of a color object")

--SETTERS
ColorComponent:AddPreparedFunction( "setRed", "c:n", "", "@value 1.r = @value 2")
ColorComponent:AddFunctionHelper( "setRed", "c:n", "Sets the red value of a color object")

ColorComponent:AddPreparedFunction( "setGreen", "c:n", "", "@value 1.g = @value 2")
ColorComponent:AddFunctionHelper( "setGreen", "c:n", "Sets the green value of a color object")

ColorComponent:AddPreparedFunction( "setBlue", "c:n", "", "@value 1.b = @value 2")
ColorComponent:AddFunctionHelper( "setBlue", "c:n", "Sets the blue value of a color object")

ColorComponent:AddPreparedFunction( "setAlpha", "c:n", "", "@value 1.a = @value 2")
ColorComponent:AddFunctionHelper( "setAlpha", "c:n", "Sets the alpha value of a color object")

/* --- --------------------------------------------------------------------------------
	@: HSV2RGB
   --- */

ColorComponent:AddInlineFunction( "hsv2rgb", "n,n,n", "c", "$HSVToColor(@value 1, @value 2, @value 3)")
ColorComponent:AddFunctionHelper( "hsv2rgb", "n,n,n", "Converts hsv color to regular color")

ColorComponent:AddInlineFunction( "rgb2hsv", "n,n,n", "c", "$ColorToHSV(@value 1, @value 2, @value 3)")
ColorComponent:AddFunctionHelper( "rgb2hsv", "n,n,n", "Converts regular color to hsv color")
