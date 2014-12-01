local Compiler = EXPADV.Compiler

local function Quick( Inline, Return )
	return { Trace = {0,0}, Inline = tostring( Inline ), Return = Return, FLAG = EXPADV_INLINE, IsRaw = true }
end -- ^ Used to quickly insert false instructions.

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
	local ID = #self.Strings + 1
	self.Strings[ ID ] = String
	return { Trace = Trace, Inline = "Context.Strings[" .. ID .. "]", Return = "s", FLAG = EXPADV_INLINE, IsRaw = true }
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Operators
   --- */

function Compiler:Compile_IS( Trace, Expression1, bNoError )
	if Expression1.Return == "b" then return Expression1 end

	local Operator = self:LookUpOperator( "is", Expression1.Return )

	if !Operator then
		if bNoError then return end
		self:TraceError( Trace, "%s can not be used as condition", self:NiceClass( Expression1.Return ) )
	end

	return Operator.Compile( self, Trace, Expression1 )
end

function Compiler:Compile_NOT( Trace, Expression1 )
	local Operator = self:LookUpOperator( "not", Expression1.Return )

	if !Operator then self:TraceError( Trace, "Operator does not support '!%s'", self:NiceClass( Expression1.Return ) ) end

	return Operator.Compile( self, Trace, Expression1 )
end

function Compiler:Compile_LEN( Trace, Expression1 )
	local Operator = self:LookUpOperator( "#", Expression1.Return )

	if !Operator then self:TraceError( Trace, "Length operator does not support '#%s'", self:NiceClass( Expression1.Return ) ) end

	return Operator.Compile( self, Trace, Expression1 )
end

function Compiler:Compile_NEG( Trace, Expression1 )
	local Operator = self:LookUpOperator( "-", Expression1.Return )

	if !Operator then self:TraceError( Trace, "Negation operator does not support '-%s'", self:NiceClass( Expression1.Return ) ) end

	return Operator.Compile( self, Trace, Expression1 )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Some logic operators, must only be executed in a specific order.
	@: We need to prevent preperation, from execution when it shouldn't.
	@: This will be done by our boolean class!
   --- */

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Logical Operators
   --- */

function Compiler:Compile_OR( Trace, Expression1, Expression2 )
	local Operator = self:LookUpOperator( "||", Expression1.Return, Expression2.Return )

	if Operator then
		return Operator.Compile( self, Trace, Expression1, self:MakeVirtual( Expression2 ) )
	end

	local Is1 = self:Compile_IS( Trace, Expression1, true )
	local Is2 = self:Compile_IS( Trace, Expression2, true )

	if Is1 and Is2 then
		local Operator = self:LookUpOperator( "||", Is1.Return, Is2.Return )

		if Operator then
			return Operator.Compile( self, Trace, Is1, self:MakeVirtual( Is2 ) )
		end
	end

	self:TraceError( Trace, "Logic operator (or) does not support '%s || %s'", self:NiceClass( Expression1.Return, Expression2.Return ) )
end

function Compiler:Compile_AND( Trace, Expression1, Expression2 )
	local Operator = self:LookUpOperator( "&&", Expression1.Return, Expression2.Return )

	if Operator then
		return Operator.Compile( self, Trace, Expression1, self:MakeVirtual( Expression2 ) )
	end

	local Is1 = self:Compile_IS( Trace, Expression1, true )
	local Is2 = self:Compile_IS( Trace, Expression2, true )

	if Is1 and Is2 then
		local Operator = self:LookUpOperator( "&&", Is1.Return, Is2.Return )

		if Operator then
			return Operator.Compile( self, Trace, Is1, self:MakeVirtual( Is2 ) )
		end
	end

	self:TraceError( Trace, "Logic operator (and) does not support '%s && %s'", self:NiceClass( Expression1.Return, Expression2.Return ) )
end

function Compiler:Compile_BOR( Trace, Expression1, Expression2 )
	local Operator = self:LookUpOperator( "|", Expression1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Binary operator (bor) does not support '%s | %s'", self:NiceClass( Expression1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expression1, Expression2 )
end

function Compiler:Compile_BAND( Trace, Expression1, Expression2 )
	local Operator = self:LookUpOperator( "&", Expression1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Binary operator (band) does not support '%s & %s'", self:NiceClass( Expression1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expression1, Expression2 )
end

function Compiler:Compile_BXOR( Trace, Expression1, Expression2 )
	local Operator = self:LookUpOperator( "^^", Expression1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Binary operator (bxor) does not support '%s ^^ %s'", self:NiceClass( Expression1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expression1, Expression2 )
end

function Compiler:Compile_GTH( Trace, Expression1, Expression2 )
	local Operator = self:LookUpOperator( ">", Expression1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Comparason operator (grater then) does not support '%s > %s'", self:NiceClass( Expression1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expression1, Expression2 )
end

function Compiler:Compile_LTH( Trace, Expression1, Expression2 )
	local Operator = self:LookUpOperator( "<", Expression1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Comparason operator (less then) does not support '%s < %s'", self:NiceClass( Expression1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expression1, Expression2 )
end

function Compiler:Compile_GEQ( Trace, Expression1, Expression2 )
	local Operator = self:LookUpOperator( ">=", Expression1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Comparason operator (grater equal) does not support '%s >= %s'", self:NiceClass( Expression1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expression1, Expression2 )
end

function Compiler:Compile_LEQ( Trace, Expression1, Expression2 )
	local Operator = self:LookUpOperator( "<=", Expression1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Comparason operator (less equal) does not support '%s <= %s'", self:NiceClass( Expression1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expression1, Expression2 )
end

function Compiler:Compile_BSHR( Trace, Expression1, Expression2 )
	local Operator = self:LookUpOperator( ">>", Expression1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Binary operator (bitshift right) does not support '%s >> %s'", self:NiceClass( Expression1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expression1, Expression2 )
end

function Compiler:Compile_BSHL( Trace, Expression1, Expression2 )
	local Operator = self:LookUpOperator( "<<", Expression1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Binary operator (bitshift left) does not support '%s << %s'", self:NiceClass( Expression1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expression1, Expression2 )
end

function Compiler:Compile_EQ( Trace, Expression1, Expression2 )
	local Operator = self:LookUpOperator( "==", Expression1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Comparason operator (equals) does not support '%s == %s'", self:NiceClass( Expression1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expression1, Expression2 )
end

function Compiler:Compile_NEQ( Trace, Expression1, Expression2 )
	local Operator = self:LookUpOperator( "!=", Expression1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Comparason operator (not equal) does not support '%s != %s'", self:NiceClass( Expression1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expression1, Expression2 )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Multi Logical Operators
   --- */

function Compiler:Compile_MEQ( Trace, Expression, Expressions )
	local Definition = self:DefineVariable( )

	local Prepare = string.format( "%s\n%s = %s", Expression.Prepare or "", Definition, Expression.Inline )

	local Expression = Quick( Definition, Expression.Return )

	local Expr = Compiler:Compile_EQ( Expressions[1].Trace or Trace, Expression, Expressions[1] )

	for I = 2, #Expressions do
		local Compare = self:Compile_EQ( Expressions[I].Trace or Trace, Expression, Expressions[I] )

		Expr = self:Compile_OR( Expressions[I].Trace or Trace, Expr, Compare )
	end

	Expr.Prepare = Prepare .. "\n" .. ( Expr.Prepare or "" )

	return Expr
end

function Compiler:Compile_MNEQ( Trace, Expression, Expressions )
	local Definition = self:DefineVariable( )

	local Prepare = string.format( "%s\n%s = %s", Expression.Prepare or "", Definition, Expression.Inline )

	local Expression = Quick( Definition, Expression.Return )

	local Expr = Compiler:Compile_NEQ( Expressions[1].Trace or Trace, Expression, Expressions[1] )

	for I = 2, #Expressions do
		local Compare = self:Compile_NEQ( Expressions[I].Trace or Trace, Expression, Expressions[I] )

		Expr = self:Compile_AND( Expressions[I].Trace or Trace, Expr, Compare )
	end

	Expr.Prepare = Prepare .. "\n" .. ( Expr.Prepare or "" )

	return Expr
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Arithmatic Operators
   --- */

function Compiler:Compile_ADD( Trace, Expression1, Expression2 )
	local Operator = self:LookUpOperator( "+", Expression1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Arithmatic operator (add) does not support '%s + %s'", self:NiceClass( Expression1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expression1, Expression2 )
end

function Compiler:Compile_SUB( Trace, Expression1, Expression2 )
	local Operator = self:LookUpOperator( "-", Expression1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Arithmatic operator (subtract) does not support '%s - %s'", self:NiceClass( Expression1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expression1, Expression2 )
end

function Compiler:Compile_MUL( Trace, Expression1, Expression2 )
	local Operator = self:LookUpOperator( "*", Expression1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Arithmatic operator (multiply) does not support '%s * %s'", self:NiceClass( Expression1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expression1, Expression2 )
end

function Compiler:Compile_DIV( Trace, Expression1, Expression2 )
	local Operator = self:LookUpOperator( "/", Expression1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Arithmatic operator (divishion) does not support '%s / %s'", self:NiceClass( Expression1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expression1, Expression2 )
end

function Compiler:Compile_MOD( Trace, Expression1, Expression2 )
	local Operator = self:LookUpOperator( "%", Expression1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Arithmatic operator (modulus) does not support '%s %% %s'", self:NiceClass( Expression1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expression1, Expression2 )
end

function Compiler:Compile_EXP( Trace, Expression1, Expression2 )
	local Operator = self:LookUpOperator( "^", Expression1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Arithmatic operator (exponent) does not support '%s ^ %s'", self:NiceClass( Expression1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expression1, Expression2 )
end

function Compiler:Compile_TEN( Trace, Expression1, Expression2, Expression3 )
	if Expression2.Return ~= Expression3.Return then
		self:TraceError( Trace, "Ternary operator does not support '%s : %s ? %s'", self:NiceClass( Expression1.Return, Expression2.Return, Expression3.Return ) )
	end

	Expression1 = self:Compile_IS( Trace, Expression1 )

	local Inline, Prepare = string.format( "(%s and %s or %s)", Expression1.Inline, Expression2.Inline, Expression3.Inline )
	
	if Expression1.Prepare or Expression2.Prepare or Expression3.Prepare then
		Prepare = table.concat( { Expression1.Prepare or "", Expression2.Prepare or "", Expression3.Prepare or "" }, "\n" )
	end

	return { Trace = Trace, Inline = Inline, Prepare = Prepare, Return = Expression2.Return, FLAG = Prepare and EXPADV_INLINEPREPARE or EXPADV_INLINE }
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Expression Variables
   --- */

-- Varible operators, state their first peramater is there type, The first paramater will actually always be an int (memory refrence).
function Compiler:Compile_INC( Trace, bVarFirst, Variable )

	local MemRef, MemScope = self:FindCell( Trace, Variable, true )

	local Class = self.Cells[ MemRef ].Return

	local Operator = self:LookUpClassOperator( Class, bVarFirst and "i++" or "++i", "n" )

	if !Operator then
		if bVarFirst then
			self:TraceError( Trace, "Assigment operator (increment) does not support '%s++'", self:NiceClass( Class ) )
		else
			self:TraceError( Trace, "Assigment operator (increment) does not support '++%s'", self:NiceClass( Class ) )
		end
	end

	return Operator.Compile( self, Trace, Quick( MemRef, "n" ) )
end

function Compiler:Compile_DEC( Trace, bVarFirst, Variable )

	local MemRef, MemScope = self:FindCell( Trace, Variable, true )

	local Class = self.Cells[ MemRef ].Return

	local Operator = self:LookUpClassOperator( Class, bVarFirst and "i--" or "--i", "n" )

	if !Operator then
		if bVarFirst then
			self:TraceError( Trace, "Assigment operator (decrement) does not support '%s--'", self:NiceClass( Class ) )
		else
			self:TraceError( Trace, "Assigment operator (decrement) does not support '--%s'", self:NiceClass( Class ) )
		end
	end

	return Operator.Compile( self, Trace, Quick( MemRef, "n" ) )
end

function Compiler:Compile_VAR( Trace, Variable )
	local MemRef, MemScope = self:FindCell( Trace, Variable, true )

	local Cell = self.Cells[ MemRef ]
	local Class,ArryClass = Cell.Return, Cell.ArryClass

	return { Trace = Trace, Inline = string.format( "Context.Memory[%i]", MemRef ), Return = Class, ArryClass = ArryClass, FLAG = EXPADV_INLINE, IsRaw = true, Variable = Variable, Scope = MemScope, MemRef = MemRef }
end

function Compiler:Compile_DELTA( Trace, Variable )
	local MemRef, MemScope = self:FindCell( Trace, Variable, true )

	local Class = self.Cells[ MemRef ].Return

	local Operator = self:LookUpClassOperator( Class, "$", "n" )
	
	if !Operator then
		self:TraceError( Trace, "Delta operator ($) does not support '$%s'", self:NiceClass( Class ) )
	end

	return Operator.Compile( self, Trace, Quick( MemRef, "n" ) )
end

function Compiler:Compile_CHANGED( Trace, Variable )
	local MemRef, MemScope = self:FindCell( Trace, Variable, true )

	local Class = self.Cells[ MemRef ].Return

	local Operator = self:LookUpOperator( "~", "n" )
	
	if !Operator then
		self:TraceError( Trace, "changed operator (~) does not support '~%s'", self:NiceClass( Class ) )
	end

	return Operator.Compile( self, Trace, Quick( MemRef, "n" ) )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Type Operators
   --- */

function Compiler:Compile_DEFAULT( Trace, Class )
	local Operator = self:LookUpOperator( "default", Class )

	if !Operator then self:TraceError( Trace, "No defined default value for %s", self:NiceClass( Class ) ) end

	return Operator.Compile( self, Trace )
end

function Compiler:Compile_CAST( Trace, Name, Expression, bNoError )
	local Class = self:GetClass( Trace, Name, false )

	if Class.Short == Expression.Return then
		if bNoError then return end
		self:TraceError( Trace, "%s can not be cast to itself.", Class.Name )
	end

	local Operator = self:LookUpOperator( Class.Name, Expression.Return )

	if !Operator then
		if bNoError then return end
		self:TraceError( Trace, "%s can not be cast to %s", self:NiceClass( Expression.Return ), Class.Name )
	end

	return Operator.Compile( self, Trace, Expression )
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

	return Prep_Words[ Word ] or ( Word and string.find( Line, "[=%(]" ) )
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

		if Instruction.FLAG == EXPADV_FUNCTION then
			self:Error( 0, "Compiler failed to build sequence, got vm instruction." )
		end -- ^ This should never even be remotly possible.

		if Instruction.FLAG == EXPADV_PREPARE or Instruction.FLAG == EXPADV_INLINEPREPARE then
			Sequence[#Sequence + 1] = Instruction.Prepare
		end

		if Instruction.FLAG == EXPADV_INLINE or Instruction.FLAG == EXPADV_INLINEPREPARE then
			if ValidatePreperation( Instruction.Inline ) then
				Sequence[#Sequence + 1] = Instruction.Inline
			end -- Somtimes the Inline will actually be required preparable code.
		end
	end

	return { Trace = Trace, Return = "", Prepare = table.concat( Sequence, "\n" ),FLAG = EXPADV_PREPARE, IsSequence = true }
end

function Compiler:PrepareInline( Instruction )
	if Instruction.IsSequence then return Instruction end

	if Instruction.FLAG == EXPADV_FUNCTION then
		self:Error( 0, "Compiler failed to build sequence, got vm instruction." )
	end

	if Instruction.FLAG == EXPADV_INLINE then
		Instruction.Prepare = Instruction.Prepare or ""
	end

	if Instruction.FLAG == EXPADV_INLINE or Instruction.FLAG == EXPADV_INLINEPREPARE then
		if ValidatePreperation( Instruction.Inline ) then
			Instruction.Prepare = Instruction.Prepare .. "\n" .. Instruction.Inline
		end
	end

	Instruction.FLAG = EXPADV_PREPARE
	Instruction.IsSequence = true

	return Instruction
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Statements
   --- */

function Compiler:Compile_IF( Trace, Condition, Sequence, Else )
	Condition = self:Compile_IS( Trace, Condition )

	local Native = { }
	if Condition.Prepare then Native[#Native + 1] = Condition.Prepare end
	if Else and Else.Prepare then Native[#Native + 1] = Else.Prepare end

	Native[#Native + 1] = "if ( " .. Condition.Inline .. " ) then"

	if Sequence.Prepare then Native[#Native + 1] = Sequence.Prepare end
	if Sequence.Inline then Native[#Native + 1] = Sequence.Inline end
	if Else and Else.Inline then Native[#Native + 1] = Else.Inline end

	Native[#Native + 1] = "end"

	return { Trace = Trace, Return = "", Prepare = table.concat( Native, "\n" ),FLAG = EXPADV_PREPARE }
end

function Compiler:Compile_ELSEIF( Trace, Condition, Sequence, Else )
	Condition = self:Compile_IS( Trace, Condition )

	local Native = { }
	if Else and Else.Prepare then Native[#Native + 1] = Else.Prepare end

	Native[#Native + 1] = "elseif ( " .. Condition.Inline .. " ) then"

	if Sequence.Prepare then Native[#Native + 1] = Sequence.Prepare end
	if Sequence.Inline then Native[#Native + 1] = Sequence.Inline end
	if Else and Else.Inline then Native[#Native + 1] = Else.Inline end

	return { Trace = Trace, Return = "", Inline = table.concat( Native, "\n" ), Prepare = Condition.Prepare, FLAG = EXPADV_PREPARE }
end

function Compiler:Compile_ELSE( Trace, Sequence )
	local Native = { "else", Sequence.Prepare or "", Sequence.Inline or "" }
	return { Trace = Trace, Return = "", Inline = table.concat( Native, "\n" ), FLAG = EXPADV_PREPARE}
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Try Catch
   --- */

function Compiler:Compile_TRY( Trace, Sequence, Catch, Final )
	local _, VM_ID = self:MakeVirtual( Sequence, true )

	local Native = {
		"local Ok, Result = pcall( Context.Instructions[" .. VM_ID .. "], Context )",
		"if !Ok then",
			"if type(Result) == \"table\" and Result.Exception then",
				Catch.Prepare,
			[[else
				error( Result, 0 )
			end]],
		"end",

		Final and Final.Prepare or "",
	}

	return { Trace = Trace, Return = "", Prepare = table.concat( Native, "\n" ), FLAG = EXPADV_PREPARE }
end

function Compiler:Compile_CATCH( Trace, MemRef, Accepted, Sequence, Catch )
	local Operator = self:LookUpClassOperator( "_ex", "=", "n", "_ex" )
	local Ass = Operator.Compile( self, Trace, Quick( MemRef, "n" ), Quick( "Result", "_ex" ) )

	local Condition = "true"

	if Accepted then
		Condition = table.concat( Accepted, " == Result.Exception or " ) .. " == Result.Exception "
	end -- ^ Creates a conditon for each accepted exception type.

	local Else = Catch and Catch.Prepare or "error( Result, 0 )"

	local Native = {
		"if (" .. Condition .. ") then",
			Ass.Prepare,
			Sequence.Prepare or "",
			Sequence.Inline or "",
			Catch and "else" .. Catch.Prepare or "",
		"end"
	}

	return { Trace = Trace, Return = "", Prepare = table.concat( Native, "\n" ), FLAG = EXPADV_PREPARE }
end


/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Assigment
   --- */

function Compiler:Compile_ASS( Trace, Variable, Expression, DefinedClass, Modifier )
	
	if DefinedClass then
		self:CreateVariable( Trace, Variable, DefinedClass, Modifier )
	end

	if !Expression.Return or Expression.Return == "" then
		self:TraceError( Trace, "Invalid assigment, %s is assigned void.", Variable )
	end

	local MemRef, Scope = self:FindCell( Trace, Variable, true )

	local Cell = self.Cells[MemRef]

	if Cell and Cell.Return ~= Expression.Return then
		Expression = self:Compile_CAST( Trace, self:NiceClass( Cell.Return ), Expression )
	end -- We cast automatically, to allow us to assign numbers to strings and so forth.

	self:TestCell( Trace, MemRef, Expression.Return, Variable )

	local Operator = self:LookUpClassOperator( Expression.Return, "=", "n", Expression.Return ) -- self:LookUpOperator( "=", Expression.Return, "n" )
	
	if !Operator then
		self:TraceError( Trace, "Assigment operator (=) does not support 'var = %s'", self:NiceClass( Expression.Return ) )
	end

	local Inst = Operator.Compile( self, Trace, Quick( MemRef, "n" ), Expression )

	if Modifier == "input" or (DefinedClass and Modifier == "static") then
		self:PrepareInline( Inst )

		Inst.Prepare = string.format( "if Context.Memory[%i] == nil then\n%s\nend", MemRef, Inst.Prepare )
	end

	return Inst
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Functions
   --- */

function Compiler:Compile_CALL( Trace, Expression, Expressions )
	local Prediction

	if Expression.Return == "f" and Expression.MemRef then
		Prediction = self.KnownReturnTypes[Expression.Scope][Expression.MemRef]
	end

	local SafeOperator = self:LookUpOperator( "call", Expression.Return, "s", "..." )
	
	if SafeOperator and Prediction then
		local Instruction = SafeOperator.Compile( self, Trace, Expression, Quick( "\"" .. Prediction .. "\"", "s" ), unpack( Expressions ) )

		Instruction.Return = Prediction

		return Instruction
	end

	local Operator = self:LookUpOperator( "call", Expression.Return, "..." )

	if SafeOperator and !Operator then
		self:TraceError( Trace, "Type %s can not be called in this way.", self:NiceClass( Expression.Return ) )
	elseif !Operator then
		self:TraceError( Trace, "No such call operation, %s( ... )", self:NiceClass( Expression.Return ) )
	end

	local Instruction = Operator.Compile( self, Trace, Expression, unpack( Expressions ) )

	if Prediction then Instruction.Return = Prediction end

	return Instruction
end

function Compiler:Compile_FUNC( Trace, Variable, Expressions )
	
	-- Check for memory ref and call the call operator.
	local MemRef, Scope = self:FindCell( Trace, Variable, false )
	
	if MemRef then
		return self:Compile_CALL( Trace, self:Compile_VAR( Trace, Variable ), Expressions )
	
	elseif #Expressions == 0 then
		local Operator = EXPADV.Functions[Variable .. "()"] or EXPADV.Functions[Variable .. "(...)"]
		
		if !Operator then self:TraceError( Trace, "No such function %s()", Variable ) end

		return Operator.Compile( self, Trace )
	else

		local Signature, BestMatch = ""

		for I = 1, #Expressions do
			local Match = string.format( "%s(%s...)", Variable, Signature )

			if EXPADV.Functions[ Match ] then BestMatch = EXPADV.Functions[ Match ] end

			Signature = Signature .. Expressions[I].Return
		end

		local Operator = EXPADV.Functions[ string.format( "%s(%s)", Variable, Signature ) ] or BestMatch
		
		if Operator then
			return Operator.Compile( self, Trace, unpack( Expressions ) )
		end
	end

	local Signature = table.concat( { self:NiceClass( unpack( Expressions ) ) }, "," )
	
	self:TraceError( Trace, "No such function %s(%s)", Variable, Signature )
end

function Compiler:Compile_METHOD( Trace, Expression, Method, Expressions, bNoError )
	local Meta = Expression.Return
	
	if #Expressions == 0 then
		local Operator = EXPADV.Functions[Method .. "(" .. Meta .. ":)"] or EXPADV.Functions[Method .. "(" .. Meta .. ":...)"] -- Yes this does look dumb.
		
		if Operator then 
			return Operator.Compile( self, Trace, Expression )
		end
	else
		local Signature, BestMatch = Meta .. ":"

		for I = 1, #Expressions do
			local Match = string.format( "%s(%s...)", Method, Signature )

			if EXPADV.Functions[ Match ] then BestMatch = EXPADV.Functions[ Match ] end

			Signature = Signature .. Expressions[I].Return
		end

		-- MsgN( "Looking for: ", string.format( "%s(%s)", Method, Signature ) )

		local Operator = EXPADV.Functions[ string.format( "%s(%s)", Method, Signature ) ] or BestMatch
		
		if Operator then
			return Operator.Compile( self, Trace, Expression, unpack( Expressions ) )
		end
	end

	local Class = EXPADV.GetClass( Meta )
	
	if Class and Class.DerivedClass then
		Expression.Return = Class.DerivedClass.Short

		local Instr = self:Compile_METHOD( Trace, Expression, Method, Expressions, true )

		if Instr then return Instr end
	end

	if bNoError then return end
	if #Expressions == 0 then self:TraceError( Trace, "No such method %s.%s()", self:NiceClass(Meta), Method ) end

	local Signature = table.concat( { self:NiceClass( unpack( Expressions ) ) }, "," )
	
	self:TraceError( Trace, "No such method %s.%s(%s)", self:NiceClass(Meta), Method, Signature )
end

function Compiler:Compile_RETURN( Trace, Expression )
	local Optional = self.ReturnOptional[ self.ReturnDeph ]
	local Expected = self.ReturnTypes[ self.ReturnDeph ]

	if !Expression then
		if Optional or !Expected then return Quick( "return nil, \"void\"" ) end
		self:TraceError( Trace, "Can not return void here, %s expected.", self:NiceClass( Expected ) )
	end

	if Expected and Expression.Return ~= Expected then
		self:TraceError( Trace, "Can not return %s here, %s expected.", self:NiceClass( Expression.Return, Expected ) )
	end

	--if !Expected and Expression.Return ~= "_vr" then
	--	Expression = self:Compile_CAST( Trace, "variant", Expression )
	--end

	Expression.Inline = string.format( "return %s, %q", Expression.Inline, Expression.Return or "void" )

	return Expression
end

function Compiler:Comile_EVENT_DEL( Trace, Name )
	return { Trace = Trace, Prepare = string.format( "Context.event_%s = nil", Name ), FLAG = EXPADV_PREPARE }
end

function Compiler:Compile_EVENT( Trace, Name, Params, UseVarg, Sequence, Memory )

	local Inputs, PreSequence = { }, { }

	for I, Param in pairs( Params ) do
		local Type = Param[2]

		Inputs[I] = "IN_" .. I

		local Operator = self:LookUpClassOperator( Type, "=", "n", Type )

		if !Operator then
			self:TraceError( Trace, "Invalid argument #%i, %s can not be used as event argument", I, self:NiceClass( Type ) )
		end
		
		PreSequence[ #PreSequence + 1 ] = Operator.Compile( self, Trace, Quick( Param[3], "n" ), Quick( Inputs[I], Type ) )
	end
	
	if UseVarg then Inputs[#Inputs + 1] = "..." end

	table.insert( Inputs, 1, "Context" )

	local Sequence = self:Compile_SEQ( Trace, { self:Compile_SEQ( Trace, PreSequence ), Sequence } )

	local Lua = string.format( "Context.event_%s = function( %s )\nif !Context.Online then return end\n%s\n%send", Name, table.concat( Inputs, "," ), Sequence.Prepare or "", Sequence.Inline or "" )

	return { Trace = Trace, Prepare = Lua, FLAG = EXPADV_PREPARE }
end

function Compiler:Build_Function( Trace, Params, UseVarg, Sequence, Memory )
	local Inputs, PreSequence = { }, { }

	-- { self.TokenData, Class.Short, MemRef }

	local CompiledTrace = self:CompileTrace( Trace )

	for I, Param in pairs( Params ) do
		local Type = Param[2]

		Inputs[I] = "IN_" .. I

		local Operator = self:LookUpClassOperator( Type, "=", "n", Type )

		if !Operator then
			self:TraceError( Trace, "Invalid argument #%i, %s can not be used as function argument", I, self:NiceClass( Type ) )
		end
		
		local Lua = string.format( [[
		if IN_%i == nil or IN_%i[1] == nil then
			Context:Throw( %s, "invoke", "Invalid argument #%i, %s expected got void." )
		]], I, I, CompiledTrace, I, self:NiceClass( Type ) )

		if Param[2] ~= "_vr" then
			Lua = Lua .. string.format( [[
			elseif IN_%i[2] ~= %q then
				Context:Throw( %s, "invoke", "Invalid argument #%i, %s expected got " .. EXPADV.TypeName( IN_%i[2] ) )
			]], I, Type, CompiledTrace, I, self:NiceClass( Type ), I )
		end

		Lua = Lua .. "end"
		
		PreSequence[ #PreSequence + 1 ] = { Trace = Trace, Return = "", Prepare = Lua, FLAG = EXPADV_PREPARE }
		PreSequence[ #PreSequence + 1 ] = Operator.Compile( self, Trace, Quick( Param[3], "n" ), Quick( Inputs[I] .. (Param[2] ~= "_vr" and "[1]" or ""), Type ) )
	end
	
	if UseVarg then Inputs[#Inputs + 1] = "..." end

	table.insert( Inputs, 1, "Context" )

	local Sequence = self:Compile_SEQ( Trace, { self:Compile_SEQ( Trace, PreSequence ), Sequence } )

	local Lua = string.format( "function( %s )\nif !Context.Online then return end\n%s\n%send", table.concat( Inputs, "," ), Sequence.Prepare or "", Sequence.Inline or "" )

	return { Trace = Trace, Inline = Lua, Return = "f", FLAG = EXPADV_INLINE }
end


/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Arrays
   --- */

function Compiler:Compile_ARRAY( Trace, Type, Expressions )
	local Operator = self:LookUpOperator( "array", "s", "..." )

	if !Operator then
		self:TraceError( Trace, "No such operation { ... }" )
	end

	return Operator.Compile( self, Trace, Type, unpack( Expressions ) )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Tables
   --- */

function Compiler:Compile_TABLE( Trace, Expressions )
	local Operator = EXPADV.Functions[ "table(...)" ]
		
	if !Operator then
		self:TraceError( Trace, "No such operation { ... }" )
	end

	return Operator.Compile( self, Trace, unpack( Expressions ) )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Loops
   --- */

function Compiler:Compile_FOR( Trace, Class, AssInstr, Memory, Start, End, Step, Sequence )
	local Operator = self:LookUpClassOperator( Class.Short, "for", Start.Return, End.Return, Step.Return )

	if !Operator then
		self:TraceError( Trace, "No such loop 'for(%s = %s, %s, %s)'", self:NiceClass( Class.Short, Start.Return, End.Return, Step.Return ) )
	end

	local Lua = string.format( "%s\n%s\n%s\n%s", AssInstr.Prepare or "", AssInstr.Inline or "", Sequence.Prepare or "", Sequence.Inline or "" )
	
	local NewSequence = { Trace = Trace, Prepare = Lua, Return = "", FLAG = EXPADV_PREPARE }
	return Operator.Compile( self, Trace, Start, End, Step, NewSequence )
end

function Compiler:Compile_WHILE( Trace, Exp, Sequence )
	Exp = self:MakeVirtual( self:Compile_IS( Trace, Exp ) )

	local Operator = self:LookUpOperator( "while", "b" )

	return Operator.Compile( self, Trace, Exp, Sequence )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Get / Set Operators
   --- */

function Compiler:Compile_GET( Trace, Expression1, Expression2, ClassShort )
	local Operator = self:LookUpClassOperator( Expression1.Return, "get", Expression1.Return, Expression2.Return, ClassShort or "_vr" )

	if !Operator and ClassShort then
		self:TraceError( Trace, "Get operator (%s[%s,%s]) does not support %s", self:NiceClass( Expression1.Return, Expression2.Return, ClassShort, Expression1.Return ) )
	elseif !Operator then
		self:TraceError( Trace, "Get operator (%s[%s]) does not support %s", self:NiceClass( Expression1.Return, Expression2.Return, Expression1.Return ) )
	end

	return Operator.Compile( self, Trace, Expression1, Expression2, ClassShort )
end

function Compiler:Compile_SET( Trace, Expression1, Expression2, Expression3, ClassShort )
	if Short and Expression3.Return ~= ClassShort then
		Expression2 = self:Compile_CAST( Trace, ClassShort, Expression3, true )
	end

	local Operator = self:LookUpClassOperator( Expression1.Return, "set", Expression1.Return, Expression2.Return, Expression3.Return )

	if !Operator and ClassShort then
		self:TraceError( Trace, "Set operator (%s[%s,%s]=) does not support %s", self:NiceClass( Expression1.Return, Expression2.Return, Expression3.Return ) )
	elseif !Operator then
		self:TraceError( Trace, "Get operator (%s[%s]=) does not support %s", self:NiceClass( Expression1.Return, Expression2.Return, Expression3.Return ) )
	end

	return Operator.Compile( self, Trace, Expression1, Expression2, Expression3 )
end