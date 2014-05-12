local Compiler = EXPADV.Compiler

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Token Checking
   --- */


function Compiler:HasTokens( )
	return self.PrepToken ~= nil
end

function Compiler:CurrentToken( Type )
	return ( self.Token and ( self.TokenType == Type ) )
end

function Compiler:AcceptToken( Type, Type2, ... )
	if self.PrepToken and ( self.PrepTokenType == Type ) then
		self:NextToken( )
		return true
	elseif Type2 then
		return self:AcceptToken( Type2, ... )
	end
	
	return false
end

function Compiler:CheckToken( Type, Type2, ... )
	if self.PrepToken and ( self.PrepTokenType == Type ) then
		return true
	elseif Type2 then
		return self:CheckToken( Type2, ... )
	end
	
	return false
end

function Compiler:RequireToken( Type, Message, ... )
	if !self:AcceptToken( Type ) then
		self:TokenError( Message, ... )
	end
end

function Compiler:ExcludeToken( Type, Message, ... )
	if self:AcceptToken( Type ) then
		self:TokenError( Message, ... )
	end
end

function Compiler:ExcludeWhiteSpace( Type, ... )
	if !self:HasTokens( ) then 
		self:TokenError( Message, ... )
	end
end

function Compiler:ExcludeVarArg( )
	self:ExcludeToken( "varg", "Invalid use of vararg (...)" )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Seperators
   --- */
   
function Compiler:AcceptSeperator( )
	if self:AcceptToken( "sep" ) then
		self.LastSeperator = true
		
		while self:AcceptToken( "sep" ) do
			-- Nom all these seperators!
		end
	end

	return self.LastSeperator
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Expressions
   --- */

function Compiler:ExpressionError( Trace )
	self:ExcludeWhiteSpace( "Further input required at end of code, incomplete expression" )

	self:TokenError( "Unexpected symbol found (%s)", self.PrepTokenName )
end

function Compiler:GetValue( Trace )

	-- Prefixs:
		if self:AcceptToken( "add" ) then
			self:ExcludeWhiteSpace( "Identity operator (+) must not be succeeded by whitespace" )
			return self:GetValue( Trace )

		elseif self:AcceptToken( "sub" ) then
			self:ExcludeWhiteSpace( "Negation operator (-) must not be succeeded by whitespace" )
			return self:Compile_NEG( Trace, self:Expression( Trace ) )
		
		elseif self:AcceptToken( "not" ) then
			self:ExcludeWhiteSpace( "Logical not operator (!) must not be succeeded by whitespace" )
			return self:Compile_NOT( Trace, self:Expression( Trace ) )
			
		elseif self:AcceptToken( "len" ) then
			self:ExcludeWhiteSpace( "length operator (#) must not be succeeded by whitespace" )
			return self:Compile_LEN( Trace, self:Expression( Trace ) )
		end

	-- Raw Values:
		if self:AcceptToken( "tre" ) then
			return self:Compile_BOOL( self:GetTokenTrace( Trace ), true )
		elseif self:AcceptToken( "fls" ) then
			return self:Compile_BOOL( self:GetTokenTrace( Trace ), false )
		elseif self:AcceptToken( "num" ) then
			return self:Compile_NUM( self:GetTokenTrace( Trace ), self.TokenData )
		end

	-- Varibles:
end

function Compiler:Expression( Trace )
	MsgN( "Compiling Expression" )

	local _ExprnRoot = self.ExpressionRoot
	self.ExpressionRoot = self:GetTokenTrace( Trace )

	-- Casting Operator:
		local CastCheck = self:ManualPattern( "%(()[a-z][A-Z0-9]+()%)" )

		if CastCheck then
			self:TokenError( "Casting is not yet supported :(" )
		end

	-- Group Equation:
		if self:AcceptToken( "lpa" ) then
			local Expresion = self:Expression( Trace )

			self:RequireToken( "rpa", "Right parenthesis ( )) missing, to close grouped equation." )
			
			self.ExpressionRoot = _ExprnRoot

			return Expresion
		end

	-- Get First Expression
		local Expresion = self:GetValue( Trace )

	-- Error, if no expression.
		if !Expresion then return self:ExpressionError( Trace ) end

	-- Check against vararg:
		if Expresion.Return == "..." then
			self.ExpressionRoot = _ExprnRoot

			return Expresion
		end

	-- Operators
		if self:AcceptToken( "or" ) then
			Expresion = self:Compile_OR( Trace, Expresion, self:Expression( Trace ) )
		elseif self:AcceptToken( "and" ) then
			Expresion = self:Compile_AND( Trace, Expresion, self:Expression( Trace ) )
		elseif self:AcceptToken( "bor" ) then
			Expresion = self:Compile_BOR( Trace, Expresion, self:Expression( Trace ) )
		elseif self:AcceptToken( "band" ) then
			Expresion = self:Compile_BAND( Trace, Expresion, self:Expression( Trace ) )
		elseif self:AcceptToken( "bxor" ) then
			Expresion = self:Compile_BXOR( Trace, Expresion, self:Expression( Trace ) )
		elseif self:AcceptToken( "eq" ) then
			Expresion = self:Compile_EQ( Trace, Expresion, self:Expression( Trace ) )
		elseif self:AcceptToken( "neg" ) then
			Expresion = self:Compile_NEG( Trace, Expresion, self:Expression( Trace ) )
		elseif self:AcceptToken( "gth" ) then
			Expresion = self:Compile_GTH( Trace, Expresion, self:Expression( Trace ) )
		elseif self:AcceptToken( "lth" ) then
			Expresion = self:Compile_LTH( Trace, Expresion, self:Expression( Trace ) )
		elseif self:AcceptToken( "geq" ) then
			Expresion = self:Compile_GEQ( Trace, Expresion, self:Expression( Trace ) )
		elseif self:AcceptToken( "leq" ) then
			Expresion = self:Compile_LEQ( Trace, Expresion, self:Expression( Trace ) )
		elseif self:AcceptToken( "bshr" ) then
			Expresion = self:Compile_BSHR( Trace, Expresion, self:Expression( Trace ) )
		elseif self:AcceptToken( "bshl" ) then
			Expresion = self:Compile_BSHL( Trace, Expresion, self:Expression( Trace ) )
		elseif self:AcceptToken( "add" ) then
			Expresion = self:Compile_ADD( Trace, Expresion, self:Expression( Trace ) )
		elseif self:AcceptToken( "sub" ) then
			Expresion = self:Compile_SUB( Trace, Expresion, self:Expression( Trace ) )
		elseif self:AcceptToken( "mul" ) then
			Expresion = self:Compile_MUL( Trace, Expresion, self:Expression( Trace ) )
		elseif self:AcceptToken( "div" ) then
			Expresion = self:Compile_DIV( Trace, Expresion, self:Expression( Trace ) )
		elseif self:AcceptToken( "mod" ) then
			Expresion = self:Compile_MOD( Trace, Expresion, self:Expression( Trace ) )
		elseif self:AcceptToken( "exp" ) then
			Expresion = self:Compile_EXP( Trace, Expresion, self:Expression( Trace ) )
		elseif self:AcceptToken( "qsm" ) then
			local Expresion2 = self:Expression( Trace ) -- Ha Ha, Expression 2 :D

			self:RequireToken( "col", "colon (:) expected for tinary operator." ) -- TODO: This error message is shit.

			Expresion = self:Compile_TIN( Trace, Expresion, Expresion2, self:Expression( Trace ) )
		end

	-- Error, if no expression.
		if !Expresion then return self:ExpressionError( Trace ) end

	-- TODO: Generate calls and indexing.


	-- With that we have a complete expression.
		self.ExpressionRoot = _ExprnRoot

		return Expresion
end