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

	local Operator = self:LookUpOperator( string.format( bVarFirst and "%s++" or "%s++", Class.Short ) )

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

	local Operator = self:LookUpOperator( string.format( bVarFirst and "%s--" or "%s--", Class.Short ) )

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

	local Operator = self:LookUpOperator( Class.Short .. "=", "n" )
	if Operator then return Operator.Compile( self, Trace, MemRef ) end
	
	local Operator = self:LookUpOperator( Class.Short .. "=", "s" )
	if Operator then return Operator.Compile( self, Trace, Variable ) end
	
	return { Trace = Trace, Inline = string.format( "Context.Memory[%i]", MemRef ), Return = Class, FLAG = EXPADV_INLINE, IsRaw = true, Variable = Variable }
end


/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Expression Variables
   --- */

function Compiler:Compile_DEFAULT( Trace, Class )
	local Operator = self:LookUpOperator( "default", Class )

	if !Operator then self:TraceError( Trace, "No defined default value for %s", self:NiceClass( Class ) ) end

	return Operator.Compile( self, Trace )
end


/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Sequences
   --- */

local Prep_Words = {
	["return"] = true,
	["continue"] = true,
	["break"] = true,
	["local"] = true,
	["while"] = true,
	["for"] = true,
	["end"] = true,
	["if"] = true,
	["do"] = true
}

local function ValidatePreperation( Preperation )
	-- For now this will only be used to check if inline can be validated.

	Line = string.Trim( Preperation )

	local _, _, Word = string.find( Line, "^([a-zA-Z_][a-zA-Z0-9_]*)" )

	return Valid_Words[ Word ] or ( Word and string.find( Line, "[=%(]" ) )
end

function Compiler:Compile_SEQ( Trace, Instructions )
	local Sequence = { }

	for I = 1, #Instructions do
		local Instruction = Instructions[I]

		local LastLine = Sequence[#Sequence]
		if LastLine == "break" or LastLine == "continue" or LastLine == "return" then
			continue -- It wont validate otherwise.
		end

		if !istable( Instruction ) and ValidatePreperation( tostring( Instruction ) ) then
			Sequence[#Sequence + 1] = Instruction
			continue
		end

		if Instruction.FLAG ~= EXPADV_FUNCTION then
			Sequence[#Sequence + 1] = self:VMToLua( Instruction )
			continue
		end

		if Instruction.FLAG == EXPADV_PREPARE or Instruction.FLAG == EXPADV_INLINEPREPARE then
			Sequence[#Sequence + 1] = Instruction.Prepare
		end

		if Instruction.FLAG == EXPADV_INLINE or Instruction.FLAG == EXPADV_INLINEPREPARE then
			if ValidatePreperation( Instruction.Inline ) then
				Sequence[#Sequence + 1] = Instruction.Inline
			end -- Somtimes the Inline will actually be required preparable code.
		end
	end

	return { Trace = Trace, Return = "", Prepare = table.concat( Sequence, "\n" ),FLAG = EXPADV_PREPARE, IsRaw = true }
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Assigment
   --- */

function Compiler:Compile_ASS( Trace, Variable, Expression, DefinedClass, Modifier )
	
	if DefinedClass then
		self:CreateVariable( Trace, Variable, DefinedClass, Modifier )
	end

	local MemRef, Scope = self:FindCell( Trace, Variable, true )

	self:TestCell( Trace, MemRef, Expression.Return, Variable )
	
	local Operator = self:LookUpOperator( "=(" .. Expression.Return .. ")", "n" )
	
	if Operator then return Operator.Compile( self, Trace, MemRef ) end

	local Operator = self:LookUpOperator( "=(" .. Expression.Return .. ")", "s" )
	
	if !Operator then self:TraceError( Trace, "Assigment operator (=) does not support 'var = %s'", self:NiceClass( Expression.Return ) ) end

	return Operator.Compile( self, Trace, Variable )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Functions
   --- */

function Compiler:Compile_FUNC( Trace, Variable, Expressions )
	
	-- Check for memory ref and call the call operator.

	local MemRef, Scope = self:FindCell( Trace, Variable, false )
	
	if MemRef then
		return self:Compile_CALL( Trace, self:Compile_VAR( Trace, Variable ), Expressions )
	end

	if #Expressions == 0 then
		local Operator = EXPADV.Functions[Variable .. "()"] or EXPADV.Functions[Variable .. "(...)"]
		
		if !Operator then self:TraceError( Trace, "No such function %s()", Variable ) end

		return Operator.Compile( self, Trace, Variable, unpack( Expressions ) )
	end

	local Signature, BestMatch = ""

	for I = 1, #Expressions do
		local Match = string.format( "%s(%s...)", Variable, Signature )
		
		if EXPADV.Functions[ Match ] then BestMatch = EXPADV.Functions[ Match ] end

		Signature = Signature .. Expressions[I].Return
	end

	local Operator = EXPADV.Functions[ string.format( "%s(%s)", Variable, Signature ) ] or BestMatch
	
	if !Operator then
		local Temp = { }
		for K, V in pairs( Expressions ) do Temp[K] = V.Return end
		self:TraceError( Trace, "No such function %s(%s)", Variable, self:NiceClass( unpack( Temp ) ) )
	end

	return Operator.Compile( self, Trace, unpack( Expressions ) )
end