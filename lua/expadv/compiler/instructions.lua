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

function Compiler:Compile_IS( Trace, Expresion1 )
	if Expresion1.Return == "b" then return Expresion1 end

	local Operator = self:LookUpOperator( "is", Expresion1.Return )

	if !Operator then self:TraceError( Trace, "%s can not be used as condition", self:NiceClass( Expresion1.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1 )
end

function Compiler:Compile_NOT( Trace, Expresion1 )
	local Operator = self:LookUpOperator( "not", Expresion1.Return )

	if !Operator then self:TraceError( Trace, "Operator does not support '!%s'", self:NiceClass( Expresion1.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1 )
end

function Compiler:Compile_LEN( Trace, Expresion1 )
	local Operator = self:LookUpOperator( "len", Expresion1.Return )

	if !Operator then self:TraceError( Trace, "Length operator does not support '#%s'", self:NiceClass( Expresion1.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1 )
end

function Compiler:Compile_NEG( Trace, Expresion1 )
	local Operator = self:LookUpOperator( "neg", Expresion1.Return )

	if !Operator then self:TraceError( Trace, "Negation operator does not support '-%s'", self:NiceClass( Expresion1.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1 )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Logical Operators
   --- */

function Compiler:Compile_OR( Trace, Expresion1, Expression2 )
	local Operator = self:LookUpOperator( "||", Expresion1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Logic operator (or) does not support '%s || %s'", self:NiceClass( Expresion1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1, self:MakeVirtual( Expression2 ) )
end

function Compiler:Compile_AND( Trace, Expresion1, Expression2 )
	local Operator = self:LookUpOperator( "&&", Expresion1.Return, Expression2.Return )

	if !Operator then self:TraceError( Trace, "Logic operator (and) does not support '%s && %s'", self:NiceClass( Expresion1.Return, Expression2.Return ) ) end

	return Operator.Compile( self, Trace, Expresion1, self:MakeVirtual( Expression2 ) )
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

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Arithmatic Operators
   --- */

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

	local Operator = self:LookUpOperator( "=" ..  Class, "n" )
	if Operator then return Operator.Compile( self, Trace, Quick( MemRef, "n" ) ) end
	
	local Operator = self:LookUpOperator( "=" ..  Class, "s" )
	if Operator then return Operator.Compile( self, Trace, Quick( Variable, "s" ) ) end
	
	return { Trace = Trace, Inline = string.format( "Context.Memory[%i]", MemRef ), Return = Class, FLAG = EXPADV_INLINE, IsRaw = true, Variable = Variable }
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

	return { Trace = Trace, Return = "", Prepare = table.concat( Sequence, "\n" ),FLAG = EXPADV_PREPARE, IsRaw = true }
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
	local _, VM_ID = self:MakeVirtual( Sequence )

	local Native = {
		"local Ok, Result = pcall( .Instructions[" .. VM_ID .. "], Context )",
		"if !Ok and istable( Result) and Result.Exception then",
		Catch.Prepare,
		[[elseif !Ok then
			error( Result, 0 )
		end]],
		Final and Final.Prepare or "",
		[[if Ok and Result ~= nil then
			return Result
		end]]
	}

	return { Trace = Trace, Return = "", Prepare = table.concat( Native, "\n" ), FLAG = EXPADV_PREPARE }
end

function Compiler:Compile_CATCH( Trace, MemRef, Accepted, Sequence, Catch )
	local Operator = self:LookUpOperator( "ex=", "n", "ex" )
	local Ass = Operator.Compile( self, Trace, { Trace = Trace, Inline = "Result", Return = "_ex", FLAG = EXPADV_INLINE, IsRaw = true } )

	local Condition = "true"

	if Listed then
		Condition = table.concat( Accepted, " == Result.Exception or " ) .. " == Result.Exception "
	end -- ^ Creates a conditon for each accepted exception type.

	local Native = {
		"if (" .. Condition .. ") then",
		Ass.Prepare,
		Sequence.Prepare or "",
		Sequence.Inline or "",
	}

	if Catch then
		Native[ #Native + 1 ] = "else" .. Catch.Prepare
	else
		Native[ #Native + 1 ] = [[else error( Result, 0 )end
		end]]
	end

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

	self:TestCell( Trace, MemRef, Expression.Return, Variable )
	
	local Operator = self:LookUpOperator( Expression.Return .. "=", "n", Expression.Return )
	
	if Operator then return Operator.Compile( self, Trace, Quick( MemRef, "n" ), Expression ) end

	local Operator = self:LookUpOperator( Expression.Return .. "=", "s", Expression.Return )
	
	if !Operator then self:TraceError( Trace, "Assigment operator (=) does not support 'var = %s'", self:NiceClass( Expression.Return ) ) end

	return Operator.Compile( self, Trace, Quick( Variable, "s" ), Expression )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Functions
   --- */

function Compiler:Compile_CALL( Trace, Expression, Expressions )
	local Operator = self:LookUpOperator( "call", Expression.Return, "..." )

	if !Operator then
		self:TraceError( Trace, "No such call operation, %s( ... )", self:NiceClass( Expression.Return ) )
	end

	local Instruction = Operator.Compile( self, Trace, Expression, unpack( Expressions ) )
	
	if Expression.Variable and Instruction.Return and Instruction.Return == "_vr" then
		local Pred = self.ReturnTypes[ self.ScopeID ][ Variable ]
		if Pred then Instruction = self:Compile_CAST( Trace, Pred, Instruction ) end
	end

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

		--MsgN( "Looking for: ", string.format( "%s(%s)", Variable, Signature ) )

		local Operator = EXPADV.Functions[ string.format( "%s(%s)", Variable, Signature ) ] or BestMatch
		
		if Operator then
			return Operator.Compile( self, Trace, unpack( Expressions ) )
		end
	end

	local Signature = table.concat( { self:NiceClass( unpack( Expressions ) ) }, "," )
	
	self:TraceError( Trace, "No such function %s(%s)", Variable, Signature )
end

function Compiler:Compile_METHOD( Trace, Expression, Method, Expressions )
	local Meta = Expression.Return
	
	if #Expressions == 0 then
		local Operator = EXPADV.Functions[Method .. "(" .. Meta .. ":)"] or EXPADV.Functions[Method .. "(" .. Meta .. ":...)"] -- Yes this does look dumb.
		
		if !Operator then self:TraceError( Trace, "No such method %s.%s()", self:NiceClass(Meta), Method ) end

		return Operator.Compile( self, Trace, Expression )
	else

		local Signature, BestMatch = Meta .. ":"

		for I = 1, #Expressions do
			local Match = string.format( "%s(%s...)", Method, Signature )

			if EXPADV.Functions[ Match ] then BestMatch = EXPADV.Functions[ Match ] end

			Signature = Signature .. Expressions[I].Return
		end

		MsgN( "Looking for: ", string.format( "%s(%s)", Method, Signature ) )

		local Operator = EXPADV.Functions[ string.format( "%s(%s)", Method, Signature ) ] or BestMatch
		
		if Operator then
			return Operator.Compile( self, Trace, Expression, unpack( Expressions ) )
		end
	end

	local Signature = table.concat( { self:NiceClass( unpack( Expressions ) ) }, "," )
	
	self:TraceError( Trace, "No such method %s.%s(%s)", self:NiceClass(Meta), Method, Signature )
end

function Compiler:Compile_LAMBDA( Trace, Params, UseVarg, Sequence, Memory )
	local Inputs, PreSequence = { }, { }

	-- { self.TokenData, Class.Short, MemRef }

	for I, Param in pairs( Params ) do
		local Type = Param[2]

		Inputs[I] = "IN_" .. I

		PreSequence[ #PreSequence + 1 ] = string.format( "if !IN_%i or IN_%i[1] == nil then", I, I )
		PreSequence[ #PreSequence + 1 ] = string.format( "Context:Throw(%s, \"invoke\", \"Invalid argument #%i, %s expected got void.\" )", self:CompileTrace( Trace ), I, self:NiceClass( Type ) )

		if Param[2] ~= "_vr" then
			PreSequence[ #PreSequence + 1 ] = string.format( "elseif IN_%i[2] ~= %q then", I, Type )
			PreSequence[ #PreSequence + 1 ] = string.format( "Context:Throw(%s, \"invoke\", \"Invalid argument #%i, %s expected got \" .. IN_%i[2] )", self:CompileTrace( Trace ), I, self:NiceClass( Type ), I )
		end

		PreSequence[ #PreSequence + 1 ] = "else"

			local Operator = self:LookUpOperator( Type .. "=", "n", Type )
			
			if Operator then
				Instruction = Operator.Compile( self, Trace, Quick( Param[3], "n" ), Quick( Inputs[I] .. "[1]", Type ) )

				PreSequence[ #PreSequence + 1 ] = Instruction.Prepare
				PreSequence[ #PreSequence + 1 ] = Instruction.Inline
			else

				local Operator = self:LookUpOperator( Type .. "=", "n", Type )

				if Operator then
					Instruction = Operator.Compile( self, Trace, Quick( Param[1], "s" ), Quick( Inputs[I] .. "[1]", Type ) )

					PreSequence[ #PreSequence + 1 ] = Instruction.Prepare
					PreSequence[ #PreSequence + 1 ] = Instruction.Inline
				else
					self:TraceError( Trace, "Invalid argument #%i, %s can not be used as function argument", I, self:NiceClass( Type ) )
				end
			end

		PreSequence[ #PreSequence + 1 ] = "end"
	end
	
	if UseVarg then Inputs[#Inputs + 1] = "..." end

	local Lua = table.concat( {
		"function(" .. table.concat( Inputs, "," ) .. ")",
		self:FlushMemory( Trace, Memory ),
		table.concat( PreSequence, "\n" ),
		Sequence.Prepare or "",
		Sequence.Inline or "",
		"end"
	}, "\n" )

	return { Trace = Trace, Inline = Lua, Return = "f", FLAG = EXPADV_INLINE }
end

function Compiler:Compile_RETURN( Trace, Expression )
	
	if self.Current_ReturnClass then
		if !Expression then
			self:TraceError( Trace, "function returns void, %s expected", self.Current_ReturnClass )
		
		elseif self.Current_ReturnClass == "_vr" and Expression.Return ~= "_vr" then
			Expression = self:Compile_CAST( Trace, "variant", Expression )
		
		elseif self.Current_ReturnClass ~= Expression.Return then
			self:TraceError( Trace, "function returns %s, %s expected", self.Current_ReturnClass )
		end

		Expression.Inline = string.format( "return %s, %q", Expression.Inline, Expression.Return )

		return Expression
	end

	return Quick( "return" )
end

function Compiler:Comile_EVENT_DEL( Trace, Name )
	return { Trace = Trace, Prepare = string.format( "Context.event_%s = nil", Name ), FLAG = EXPADV_PREPARE }
end

function Compiler:Compile_EVENT( Trace, Name, Params, UseVarg, Sequence, Memory )

	local Inputs, PreSequence = { }, { }

	-- { self.TokenData, Class.Short, MemRef }

	for I, Param in pairs( Params ) do
		local Type = Param[2]

		Inputs[I] = "IN_" .. I

		local Operator = self:LookUpOperator( Type .. "=", "n", Type )
		
		if Operator then
			Instruction = Operator.Compile( self, Trace, Quick( Param[3], "n" ), Quick( Inputs[I] .. "[1]", Type ) )
			
			PreSequence[ #PreSequence + 1 ] = Instruction.Prepare
			PreSequence[ #PreSequence + 1 ] = Instruction.Inline
		else

			local Operator = self:LookUpOperator( Type .. "=", "n", Type )

			if Operator then
				Instruction = Operator.Compile( self, Trace, Quick( Param[1], "s" ), Quick( Inputs[I] .. "[1]", Type ) )
--
				PreSequence[ #PreSequence + 1 ] = Instruction.Prepare
				PreSequence[ #PreSequence + 1 ] = Instruction.Inline
			else
				self:TraceError( Trace, "Invalid argument #%i, %s can not be used as event argument", I, self:NiceClass( Type ) )
			end
		end
	end
	
	if UseVarg then Inputs[#Inputs + 1] = "..." end

	local Lua = table.concat( {
		string.format( "Context.event_%s = function( %s )", Name, table.concat( Inputs, "," ) ),
		self:FlushMemory( Trace, Memory ),
		--table.concat( PreSequence, "\n" ),
		Sequence.Prepare or "",
		Sequence.Inline or "",
		"end"
	}, "\n" )

	return { Trace = Trace, Prepare = Lua, FLAG = EXPADV_PREPARE }
end

