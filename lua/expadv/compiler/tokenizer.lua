local Compiler = EXPADV.Compiler

/* --- --------------------------------------------------------------------------------
	@: Chars
   --- */

function Compiler:SkipChar( )
	if self.Len >= self.Pos then
		if self.Char == "\n" then
			self.ReadLine = self.ReadLine + 1
			self.ReadChar = 1
		else
			self.ReadChar = self.ReadChar + 1
		end

		self.Pos = self.Pos + 1
		self.Char = self.Buffer:sub( self.Pos, self.Pos )
	else
		self.Char = nil
	end
end

function Compiler:NextChar( )
	self.ReadData = self.ReadData .. self.Char
	self:SkipChar( )
end

/* --- --------------------------------------------------------------------------------
	@: Patterns
   --- */

function Compiler:NextPattern( Pattern, Exact )
	if self.Char then
		local Start, End, String = self.Buffer:find( Pattern, self.Pos, Exact )
		if Start == self.Pos then
			String = String or self.Buffer:sub( Start, End )

			self.Pos = End + 1
			self.PatternMatch = String
			self.ReadData = self.ReadData .. String
			
			if self.Pos > self.Len then
				self.Char = nil
			else
				self.Char = self.Buffer[self.Pos]
			end

			local Lines = string.Explode( "\n", String )
			if #Lines > 1 then
				self.ReadLine = self.ReadLine + #Lines - 1
				self.ReadChar = #Lines[ #Lines ] + 1
			else
				self.ReadChar = self.ReadChar + #Lines[ #Lines ]
			end

			return true
		end
	end

	return false
end

function Compiler:ManualPattern( Pattern, Exact )
	local Start, End, String = self.Buffer:find( Pattern, self.Pos, Exact )
	
	if Start == self.Pos then
		return String or self.Buffer:sub( Start, End )
	end
end

function Compiler:SkipSpaces( )
	self:NextPattern( "^[%s\n]*" )

	self.ReadData = ""

	return self.PatternMatch
end

/* --- --------------------------------------------------------------------------------
	@: Token Jumping
   --- */

function Compiler:GoToToken( I )
	local RealPos = self.TokenPos
	
	if I > 1 then
		self.TokenPos = I - 1
		self:NextToken( )
	end
	
	return RealPos
end

function Compiler:PrevToken( )
	self.TokenPos = self.TokenPos - 2
	self:NextToken( ) -- Cus i'm cool like that =D
end

/* --- --------------------------------------------------------------------------------
	@: Tokenizer Main
   --- */

function Compiler:StartTokenizer( )
	self.Char = ""
	self.ReadData = ""
	self.ReadChar = 1
	self.ReadLine = 1

	self.Tokens = { }
	self.TokenPos = 0
	self.TokenLine = 0
	self.TokenChar = 0

	self:NextChar( )
	self:NextToken( )
end

function Compiler:NextToken( )

	if self.TokenPos >= 1 then
		if !self.Tokens[ self.TokenPos ] then
			self.Tokens[ self.TokenPos ] = self:GetNextToken( )
		end

		self.Token = self.Tokens[ self.TokenPos ]
	end

	self.TokenPos = self.TokenPos + 1

	if !self.Tokens[ self.TokenPos ] then
		self.Tokens[ self.TokenPos ] = self:GetNextToken( )
	end

	self.PrepToken = self.Tokens[ self.TokenPos ]

	---------------------------------------------------------

	-- MsgN( "TokenPos: ", self.TokenPos )

	if self.Token then
		self.TokenData = self.Token[1]
		self.TokenType = self.Token[2]
		self.TokenName = self.Token[3]
		self.TokenLine = self.Token[4]
		self.TokenChar = self.Token[5]

		-- MsgN( "Current Token: ", self.TokenType )
	end

	if self.PrepToken then
		self.PrepTokenData = self.PrepToken[1]
		self.PrepTokenType = self.PrepToken[2]
		self.PrepTokenName = self.PrepToken[3]
		self.PrepTokenLine = self.PrepToken[4]

		-- MsgN( "Prep Token: ", self.PrepTokenType )#
	else
		self.PrepTokenData = nil
		self.PrepTokenType = nil
		self.PrepTokenName = nil
		self.PrepTokenLine = nil
	end

end

function Compiler:PopToken( )
	self.Pos = self.TokenPos
	self.ReadChar = self.TokenChar
	self.ReadLine = self.TokenLine
	self.Tokens[ self.TokenPos ] = nil
	self:PrevToken( )
end

/* --- --------------------------------------------------------------------------------
	@: Build Tokens
   --- */

function Compiler:NewToken( Type, Name )
	local Token = { self.ReadData, Type, Name, self.ReadLine, self.ReadChar, self.Pos }
	
	self.ReadData = ""
	
	return Token
end

/* --- --------------------------------------------------------------------------------
	@: Comments
   --- */

function Compiler:SkipComments( )
	local Style

	if self:NextPattern( "//", true ) then
		Style = "\n"
	elseif self:NextPattern( "/*", true ) then
		Style = "*/"
	end

	if Style then
		while !self:NextPattern( Style, true ) do
			if !self.Char then 
				if Style == "*/" then
					self:Error( 0, "Un-terminated multi line comment (/*)", 0 )
				else 
					break 
				end 
			end

			self:SkipChar( )

			-- TODO: Yeild protection.
		end

		self.ReadData = ""

		self.SkipToken = true
	end
end

/* --- --------------------------------------------------------------------------------
	@: Token Generator
   --- */

function Compiler:StringToken( StrChar )
	local Escape = false
	self:SkipChar( )

	while self.Char do
		if self.Char == "\n" then
			
			if StrChar == "'" then
				self:NextChar( )
			else
				break -- End of Line.
			end

		elseif !Escape then
			
			if self.Char == StrChar then
				break -- End of string.
			elseif self.Char == "\\" then
				Escape = true
				self:SkipChar( ) -- Escape Sequence.
			else
				self:NextChar( )
			end

		elseif self.Char == "\\" then
			Escape = false
			self:NextChar( )

		elseif self.Char == StrChar then
			Escape = false
			self:NextChar( )

		elseif self.Char == "n" then
			Escape = false
			self.Char = "\n"
			self:NextChar( )

		elseif self.Char == "t" then
			Escape = false
			self.Char = "\t"
			self:NextChar( )

		elseif self.Char == "r" then
			Escape = false
			self.Char = "\r"
			self:NextChar( )

		elseif self:ManualPattern( "^([0-9]+)" ) then
			
			local Num = tonumber( self.PatternMatch )
			if !Num or Num < 0 or Num > 255 then
				self:Error( 0, "Invalid char (%s)", Num or "?" )
			end

			Escape = false
			self.Pos = self.Pos - 1
			self.ReadData = self.ReadData .. string.char( Num )

			self:SkipChar( )
		else
			self:Error( 0, "Unfinished escape sequence (\\%s)", self.Char )
		end
	end

	if self.Char and self.Char == StrChar then
		self:SkipChar( )
		return self:NewToken( "str", "String" )
	end


	local String = self.ReadData

	if #String > 10 then
		String = string.sub(self.ReadData, 0, 10) .. "..."
	end

	self:Error( 0, "Unterminated string (\"%s)", String )
end

/* ---------------------------------------------------------------------------------------------------------------------------------------------- */

local AddedWords = { }

function Compiler.AddWordToken( Word, Type, Desc )
	AddedWords[Word] = { Type, Desc }
end

/* ---------------------------------------------------------------------------------------------------------------------------------------------- */


function Compiler:BuildToken( )
	-- NUMBER:

	if self:NextPattern( "^0x[%x]+" ) then
		self.ReadData = tonumber( self.ReadData ) or self:Error( 0, "Invalid number format (%s)", 0, self.ReadData )
		return self:NewToken( "num", "hex" )

	elseif self:NextPattern( "^0b[01]+" ) then
		self.ReadData = tonumber( self.ReadData:sub(3), 2 ) or self:Error( 0, "Invalid number format (%s)", 0, self.ReadData )
		return self:NewToken( "num", "bin" )

	elseif self:NextPattern( "^%d+%.?%d*" ) then
		self.ReadData = tonumber( self.ReadData ) or self:Error( 0, "Invalid number format (%s)", 0, self.ReadData )
		return self:NewToken( "num", "real" )

	-- STRING:

	elseif self.Char == '"' then
		return self:StringToken( '"' )
	elseif self.Char == "'" then
		return self:StringToken( "'" )
	
	elseif self:NextPattern( "^[a-zA-Z][a-zA-Z0-9_]*" ) then
		local RawData = self.ReadData

	-- KEYWORDS:

		if RawData == "if" then
			return self:NewToken( "if", "if" )
		elseif RawData == "elseif" then
			return self:NewToken( "eif", "elseif" )
		elseif RawData == "else" then
			return self:NewToken( "els", "else" )
		elseif RawData == "while" then
			return self:NewToken( "whl", "while")
		elseif RawData == "for" then
			return self:NewToken( "for", "for")
		elseif RawData == "foreach" then
			return self:NewToken( "each", "foreach")
		elseif RawData == "function" then
			return self:NewToken( "func", "function")
		elseif RawData == "method" then
			return self:NewToken( "meth", "method")
		elseif RawData == "switch" then
			return self:NewToken( "swh", "switch")
		elseif RawData == "case" then
			return self:NewToken( "cse", "case")
		elseif RawData == "default" then
			return self:NewToken( "dft", "default")
		elseif RawData == "event" then
			return self:NewToken( "evt", "event")
		elseif RawData == "try" then
			return self:NewToken( "try", "try")
		elseif RawData == "catch" then
			return self:NewToken( "cth", "catch")
		elseif RawData == "final" then
			return self:NewToken( "fnl", "final")
			
	-- RAW DATA:
		
		elseif RawData == "true" then
			return self:NewToken( "tre", "true")
		elseif RawData == "false" then
			return self:NewToken( "fls", "false")
		elseif RawData == "null" then
			return self:NewToken( "nll", "null")


	-- SUB KEYWORDS:

		elseif RawData == "break" then
			return self:NewToken( "brk", "break" )
		elseif RawData == "continue" then
			return self:NewToken( "cnt", "continue" )
		elseif RawData == "return" then
			return self:NewToken( "ret", "return" )

	-- DECLERATION:

		elseif RawData == "global" then
			return self:NewToken( "glo", "global" )
		elseif RawData == "input" then
			return self:NewToken( "in", "input" )
		elseif RawData == "output" then
			return self:NewToken( "out", "output" )
		elseif RawData == "static" then
			return self:NewToken( "stc", "static" )

	-- SERVER && CLIENT:

		elseif RawData == "server" then
			return self:NewToken( "sv", "server" )
		elseif RawData == "client" then
			return self:NewToken( "cl", "client" )

	-- ADDED WORDS:

		elseif AddedWords[RawData] then
			local TokenInfo = AddedWords[RawData]
			return self:NewToken( TokenInfo[1], TokenInfo[2] )
		end

	-- VARIABLE:

		return self:NewToken( "var", "variable")
	end
end

/* --- --------------------------------------------------------------------------------
	@: Get Token
   --- */

function Compiler:GetNextToken( )
	if self.Char then

		self:SkipSpaces( )

		self:SkipComments( )
		
		if self.SkipToken then
			self.SkipToken = false
			return self:GetNextToken( )
		end
		
		local Token = self:BuildToken( )
		
		if Token then return Token end
		
		for ClassName, Class in pairs( EXPADV.ClassAliases ) do -- EXPADV.Classes ) do
			if self:NextPattern( "%( *" .. ClassName .. " *%)" ) then
				self.ReadData = Class.Name --ClassName
				return self:NewToken( "cst", "cast" )
			end
		end

		for I = 1, #self.RawTokens do
			local Token = self.RawTokens[I]

			if self:NextPattern( Token[1], true ) then
				return self:NewToken( Token[2], Token[3] )
			end
		end
		
		if !self.Char or self.Char == "" then
			self.Char = nil
		else
			self:Error( 0, "Unknown syntax found (%s)", self.ReadData .. tostring(self.Char) )
		end
	end
end