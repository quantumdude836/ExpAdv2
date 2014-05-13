local Compiler = EXPADV.Compiler

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Raw Values
   --- */

function Compiler:Compile_BOOL( Trace, Bool )
	return { Trace = Trace, Inline = Bool and "true" or "false", Return = "b", FLAG = EXPADV_INLINE, IsRaw = true }
end

function Compiler:Compile_NUM( Trace, Int )
	return { Trace = Trace, Inline = tostring( Int ), Return = "n", FLAG = EXPADV_INLINE, IsRaw = true }
end

function Compiler:Compile_STR( Trace, String )
	return -- TODO:
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Operators
   --- */

function Compiler:Compile_OR( Trace, Expresion1, Expression2 )
	local Operator = self:LookUpOperator( "||", Expresion1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Logic operator (or) does not support '%s || %s'", self:NiceClass( Expresion1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1, Expression2 )
end

function Compiler:Compile_AND( Trace, Expresion1, Expression2 )
	local Operator = self:LookUpOperator( "&&", Expresion1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Logic operator (and) does not support '%s && %s'", self:NiceClass( Expresion1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1, Expression2 )
end

function Compiler:Compile_BOR( Trace, Expresion1, Expression2 )
	local Operator = self:LookUpOperator( "|", Expresion1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Binary operator (bor) does not support '%s | %s'", self:NiceClass( Expresion1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1, Expression2 )
end

function Compiler:Compile_BAND( Trace, Expresion1, Expression2 )
	local Operator = self:LookUpOperator( "&", Expresion1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Binary operator (band) does not support '%s & %s'", self:NiceClass( Expresion1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1, Expression2 )
end

function Compiler:Compile_BXOR( Trace, Expresion1, Expression2 )
	local Operator = self:LookUpOperator( "^^", Expresion1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Binary operator (bxor) does not support '%s ^^ %s'", self:NiceClass( Expresion1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1, Expression2 )
end

function Compiler:Compile_EQ( Trace, Expresion1, Expression2 )
	local Operator = self:LookUpOperator( "==", Expresion1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Comparason operator (equals) does not support '%s == %s'", self:NiceClass( Expresion1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1, Expression2 )
end

function Compiler:Compile_NEG( Trace, Expresion1, Expression2 )
	local Operator = self:LookUpOperator( "!=", Expresion1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Comparason operator (not equal) does not support '%s != %s'", self:NiceClass( Expresion1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1, Expression2 )
end

function Compiler:Compile_GTH( Trace, Expresion1, Expression2 )
	local Operator = self:LookUpOperator( ">", Expresion1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Comparason operator (grater then) does not support '%s > %s'", self:NiceClass( Expresion1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1, Expression2 )
end

function Compiler:Compile_LTH( Trace, Expresion1, Expression2 )
	local Operator = self:LookUpOperator( "<", Expresion1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Comparason operator (less then) does not support '%s < %s'", self:NiceClass( Expresion1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1, Expression2 )
end

function Compiler:Compile_GEQ( Trace, Expresion1, Expression2 )
	local Operator = self:LookUpOperator( ">=", Expresion1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Comparason operator (grater equal) does not support '%s >= %s'", self:NiceClass( Expresion1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1, Expression2 )
end

function Compiler:Compile_LEQ( Trace, Expresion1, Expression2 )
	local Operator = self:LookUpOperator( "<=", Expresion1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Comparason operator (less equal) does not support '%s <= %s'", self:NiceClass( Expresion1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1, Expression2 )
end

function Compiler:Compile_BSHR( Trace, Expresion1, Expression2 )
	local Operator = self:LookUpOperator( ">>", Expresion1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Binary operator (bitshift right) does not support '%s >> %s'", self:NiceClass( Expresion1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1, Expression2 )
end

function Compiler:Compile_BSHL( Trace, Expresion1, Expression2 )
	local Operator = self:LookUpOperator( "<<", Expresion1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Binary operator (bitshift left) does not support '%s << %s'", self:NiceClass( Expresion1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1, Expression2 )
end

function Compiler:Compile_ADD( Trace, Expresion1, Expression2 )
	print( "Add Operator ", Expresion1.Return, Expression2.Return )

	local Operator = self:LookUpOperator( "+", Expresion1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Arithmatic operator (add) does not support '%s + %s'", self:NiceClass( Expresion1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1, Expression2 )
end

function Compiler:Compile_SUB( Trace, Expresion1, Expression2 )
	local Operator = self:LookUpOperator( "-", Expresion1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Arithmatic operator (subtract) does not support '%s - %s'", self:NiceClass( Expresion1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1, Expression2 )
end

function Compiler:Compile_MUL( Trace, Expresion1, Expression2 )
	local Operator = self:LookUpOperator( "*", Expresion1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Arithmatic operator (multiply) does not support '%s * %s'", self:NiceClass( Expresion1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1, Expression2 )
end

function Compiler:Compile_DIV( Trace, Expresion1, Expression2 )
	local Operator = self:LookUpOperator( "/", Expresion1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Arithmatic operator (divishion) does not support '%s / %s'", self:NiceClass( Expresion1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1, Expression2 )
end

function Compiler:Compile_MOD( Trace, Expresion1, Expression2 )
	local Operator = self:LookUpOperator( "%", Expresion1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Arithmatic operator (modulus) does not support '%s %% %s'", self:NiceClass( Expresion1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1, Expression2 )
end

function Compiler:Compile_EXP( Trace, Expresion1, Expression2 )
	local Operator = self:LookUpOperator( "^", Expresion1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Arithmatic operator (exponent) does not support '%s ^ %s'", self:NiceClass( Expresion1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1, Expression2 )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Expression Variables
   --- */

-- Varible operators, state their first peramater is there type, The first paramater will actually always be an int (memory refrence).
function Compiler:Compile_INC( Trace, bVarFirst, Variable )

	local MemRef, MemScope = self:FindCell( Trace, Variable, true )

	local Class = self.Cells[ MemRef ].Return

	local Operator = self:LookUpOperator( bVarFirst and "i++" or "++i" , Class )

	if !Operator then
		if bVarFirst then
			self:TraceError( Trace, "Assigment operator (increment) does not support '%s++'", self:NiceClass( Class ) )
		else
			self:TraceError( Trace, "Assigment operator (increment) does not support '++%s'", self:NiceClass( Class ) )
		end
	end

	return Operator.Compile( self, Trace, MemRef )
end

function Compiler:Compile_DEC( Trace, bVarFirst, Variable )

	local MemRef, MemScope = self:FindCell( Trace, Variable, true )

	local Class = self.Cells[ MemRef ].Return

	local Operator = self:LookUpOperator( bVarFirst and "i--" or "--i" , Class )

	if !Operator then
		if bVarFirst then
			self:TraceError( Trace, "Assigment operator (decrement) does not support '%s--'", self:NiceClass( Class ) )
		else
			self:TraceError( Trace, "Assigment operator (decrement) does not support '--%s'", self:NiceClass( Class ) )
		end
	end

	return Operator.Compile( self, Trace, MemRef )
end

function Compiler:Compile_VAR( Trace, Variable )

	local MemRef, MemScope = self:FindCell( Trace, Variable, true )

	local Class = self.Cells[ MemRef ].Return

	return { Trace = Trace, Inline = string.format( "Context.Memory[%i]", MemRef ), Return = Class, FLAG = EXPADV_INLINE, IsRaw = true, Variable = Variable }
end