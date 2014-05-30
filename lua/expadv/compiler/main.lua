/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Compiler NameSpace:
   --- */

EXPADV.Compiler = { }

EXPADV.Compiler.__index = EXPADV.Compiler

local Compiler = EXPADV.Compiler

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: First teach the compiler, our tokens.
   --- */

Compiler.RawTokens = {

	--MATH:

		{ "+", "add", "addition" },
		{ "-", "sub", "subtract" },
		{ "*", "mul", "multiplier" },
		{ "/", "div", "division" },
		{ "%", "mod", "modulus" },
		{ "^", "exp", "power" },
		{ "=", "ass", "assign" },
		{ "+=", "aadd", "increase" },
		{ "-=", "asub", "decrease" },
		{ "*=", "amul", "multiplier" },
		{ "/=", "adiv", "division" },
		{ "++", "inc", "increment" },
		{ "--", "dec", "decrement" },

	-- COMPARISON:

		{ "==", "eq", "equal" },
		{ "!=", "neq", "unequal" },
		{ "<", "lth", "less" },
		{ "<=", "leq", "less or equal" },
		{ ">", "gth", "greater" },
		{ ">=", "geq", "greater or equal" },

	-- BITWISE:

		{ "&", "band", "and" },
		{ "|", "bor", "or" },
		{ "^^", "bxor", "or" },
		{ ">>", "bshr", ">>" },
		{ "<<", "bshl", "<<" },

	-- CONDITION:

		{ "!", "not", "not" },
		{ "&&", "and", "and" },
		{ "||", "or", "or" },

	-- SYMBOLS:
		
		{ "?", "qsm", "?" },
		{ ":", "col", "colon" },
		{ ";", "sep", "semicolon" },
		{ ",", "com", "comma" },
		{ "$", "dlt", "delta" },
		{ "#", "len", "length" },
		{ "~", "cng", "changed" },
		{ "->", "wc", "connect" },
		{ ".", "prd", "period" },

	-- BRACKETS:

		{ "(", "lpa", "left parenthesis" },
		{ ")", "rpa", "right parenthesis" },
		{ "{", "lcb", "left curly bracket" },
		{ "}", "rcb", "right curly bracket" },
		{ "[", "lsb", "left square bracket" },
		{ "]", "rsb", "right square bracket" },

	-- MISC:

		{ '@', "pred", "predictive operator" },
		{ "...", "varg", "varargs" },
}

--EXPADV.RunHook( "RegisterClass", Compiler.RawTokens )

table.sort( Compiler.RawTokens, function( Token, Token2 )
	return #Token[1] > #Token2[1]
end )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: First teach the compiler, our tokens.
   --- */

include( "tokenizer.lua" )
include( "parser.lua" )
include( "instructions.lua" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Error Functions.
   --- */

function Compiler:GetTokenTrace( Trace )
	if !Trace then return { self.ReadLine, self.ReadChar } end
	return { self.ReadLine, self.ReadChar } -- TODO: this!
end

function Compiler:CompileTrace( Trace )
	return -- TODO: this!
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Error Functions:
   --- */

function Compiler:Error( Offset, Message, A, ... )
	if A then Message = Format( Message, A, ... ) end
	error( Format( "%s at line %i, char %i", Message, self.ReadLine, self.ReadChar + Offset ), 0 )
end

function Compiler:TraceError( Trace, ... )
	if type( Trace ) ~= "table" then
		print( Trace, ... )
		debug.Trace( )
	end
	
	self.ReadLine, self.ReadChar = Trace[1], Trace[2]
	self:Error( 0, ... )
end

function Compiler:TokenError( ... )
	self:TraceError( self:GetTokenTrace( ), ... )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Class functions:
   --- */

function Compiler:NiceClass( Name, Name2, ... )
	local Class = EXPADV.GetClass( Name )
	
	Name = Class and Class.Name or "void"

	if Name2 then return Name, self:NiceClass( Name2, ... ) end

	return Name
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Instruction based functions:
   --- */

function Compiler:VMToLua( Instruction )
	if Instruction.FLAG ~= EXPADV_FUNCTION then
		self:TokenError( "COMPILER: VMToLua recieved a Lua instruction." )
	end

	local ID = #self.VMInstructions + 1
	self.VMInstructions[ID] = Instruction.Function
	return string.format( "Context.Instructions[%i]( %s )", ID, table.concat( Instruction.Inputs, "," ) )
end

function Compiler:NewLuaInstruction( Trace, Operator, Prepare, Inline )
	local Flag = EXPADV_INLINEPREPARE

	if !Prepare or Prepare == "" then
		Flag = EXPADV_INLINE
	elseif !Inline or Inline == "" then
		Flag = EXPADV_PREPARE
	end

	return {
		Trace = Trace,
		Inline = Inline,
		Prepare = Prepare,
		Return = Operator.Return,
		FLAG = Flag
	}
end

function Compiler:NewVMInstruction( Trace, Operator, Function, Inputs )
	return {
		Trace = Trace,
		Function = Function,
		Return = Operator.Return,
		Inputs = Inputs or { self:CompileTrace( Trace ), "Context" },
		Evaluated = true,
		FLAG = Operator.FLAG
	}
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Classes.
   --- */
function Compiler:GetClass( Trace, ClassName, bNoError )

	local Class = EXPADV.GetClass( ClassName )
	if !Class and bNoError then return end

	if !Class or Class.Name ~= ClassName then
		if bNoError then return end
		self:TraceError( Trace, "No such class %q", ClassName or "WTF" )
	end

	return Class
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Scope Management.
   --- */

function Compiler:BuildScopes( )
	self.ScopeID = 1
	self.Global, self.Scope = { }, { }
	self.Scopes = { [0] = self.Global, self.Scope }

	self.MemoryRef = 0
end

function Compiler:PushScope( )
	self.Scope = { }
	self.ScopeID = self.ScopeID + 1
	self.Scopes[ self.ScopeID ] = self.Scope
end

function Compiler:PopScope( )
	self.Scopes[ self.ScopeID ] = nil

	self.ScopeID = self.ScopeID - 1
	self.Scope = self.Scopes[ self.ScopeID ]
	self.Prediction = self.Predictions[ self.ScopeID ]
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Memory, Loop, Lambda - Deph
   --- */

   function Compiler:PushMemory( )
   		self.MemoryDeph = self.MemoryDeph + 1
   		self.FreshMemory[ self.MemoryDeph ] = { }
   end

   function Compiler:PopMemory( )
   		self.FreshMemory[ self.MemoryDeph ] = nil
   		self.MemoryDeph = self.MemoryDeph - 1
   end

   function Compiler:PushLoopDeph( )
   		self:PushMemory( )
   		self.LoopDeph = self.LoopDeph + 1
   end

   function Compiler:PopLoopDeph( )
   		self:PopMemory( )
   		self.LoopDeph = self.LoopDeph - 1
   end

   function Compiler:PushLambdaDeph( )
		self:PushMemory( )
   		self.LambdaDeph = self.LambdaDeph + 1
   end

   function Compiler:PopLambdaDeph( )
   		self:PopMemory( )
   		self.LambdaDeph = self.LambdaDeph - 1
   end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Memory Cells
   --- */

function Compiler:NextMemoryRef( )
	self.MemoryRef= self.MemoryRef + 1
	return self.MemoryRef
end

function Compiler:TestCell( Trace, MemRef, ClassShort, Variable )
	local Cell = self.Cells[ MemRef ]

	if !Cell and Variable then
		self:TraceError( Trace, "%s of type %s does not exist", Variable, self:NiceClass( ClassShort ) )
	elseif Cell.Return ~= ClassShort and Variable then
		self:TraceError( Trace, "%s of type %s can not be assigned as %s", Variable, self:NiceClass( Cell.Return, ClassShort ) )
	else
		return true
	end
end

function Compiler:FindCell( Trace, Variable, bError )
	for Scope = self.ScopeID, 0, -1 do
		local MemRef = self.Scopes[ Scope ][ Variable ]

		if MemRef then return MemRef, Scope end
	end

	if !bError then return end

	self:TraceError( Trace, "Variable %s does not exist.", Variable )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Memory Cells
   --- */

function Compiler:CreateVariable( Trace, Variable, Class, Modifier )
	local ClassObj = istable( Class ) and Class or self:GetClass( Trace, Class, false )

	if !Modifier then
		local MemRef = self.Scope[ Variable ]

		if MemRef then
			return self:TestCell( Trace, MemRef, Class, Variable )
		end

		MemRef = self:NextMemoryRef( )

		self.Scope[Variable] = MemRef

		self.Cells[ MemRef ] = { Memory = MemRef, Scope = self.ScopeID, Return = ClassObj.Short, ClassObj = ClassObj, Modifier = nil }

		if self.MemoryDeph > 0 then
			self.FreshMemory[self.MemoryDeph][MemRef] = MemRef
		end -- This is declaired as fresh memory!

		return self.Cells[ MemRef ]
	end

	if Modifier == "static" then
		local MemRef = self.Scope[ Variable ]

		if MemRef then
			return self:TestCell( Trace, MemRef, Class, Variable )
		end

		MemRef = self:NextMemoryRef( )

		self.Scope[Variable] = MemRef

		self.Cells[ MemRef ] = { Memory = MemRef, Scope = self.ScopeID, Return = ClassObj.Short, ClassObj = ClassObj, Modifier = "static" }

		return self.Cells[ MemRef ]
	end

	if Modifier == "global" then
		local MemRef = self.Global[ Variable ]

		if MemRef then
			self:TestCell( Trace, MemRef, Class, Variable )
		else
			MemRef = self:NextMemoryRef( )

			self.Global[ MemRef ] = { Memory = MemRef, Scope = 0, Return = ClassObj.Short, ClassObj = ClassObj, Modifier = "global" }
		end

		if self.Scope[ Variable ] then
			self:TraceError( Trace, "Global variable %s conflicts with %s %s", Variable, self.Cells[ self.Scope[ Variable ] ].Modifier or "variable", Variable )
		end

		self.Scope[ Variable ] = MemRef

		return self.Global[ MemRef ]
	end

	if WireLib then
		if Modifier == "input" or Modifier == "output" then
			if Variable[1] ~= Variable[1]:upper( ) then
				self:TraceError( "Wire %s's require captialization.", Modifier )
			end
		end

		if Modifier == "input" then
			if !ClassObject.Wire_In_Type then
				self:TraceError( "Wire inputs of class %q are not supported.", Class )
			end

			local MemRef = self.InPorts[ Variable ]

			if MemRef then
				self:TestCell( Trace, MemRef, Class, Variable )
			else
				MemRef = self:NextMemoryRef( )

				self.InPorts[ MemRef ] = { Memory = MemRef, Scope = 0, Return = ClassObj.Short, ClassObj = ClassObj, Modifier = "input" }
			end

			if self.Scope[ Variable ] then
				self:TraceError( Trace, "Wire input %s conflicts with %s %s", Variable, self.Cells[ self.Scope[ Variable ] ].Modifier or "variable", Variable )
			end

			self.Scope[ Variable ] = MemRef

			return self.InPorts[ MemRef ]
		end

		if Modifier == "output" then
			if !ClassObject.Wire_In_Type then
				self:TraceError( "Wire outputs of class %q are not supported.", Class )
			end

			local MemRef = self.OutPorts[ Variable ]

			if MemRef then
				self:TestCell( Trace, MemRef, Class, Variable )
			else
				MemRef = self:NextMemoryRef( )

				self.OutPorts[ MemRef ] = { Memory = MemRef, Scope = 0, Return = ClassObj.Short, ClassObj = ClassObj, Modifier = "output" }
			end

			if self.Scope[ Variable ] then
				self:TraceError( Trace, "Wire outport %s conflicts with %s %s", Variable, self.Cells[ self.Scope[ Variable ] ].Modifier or "variable", Variable )
			end

			self.Scope[ Variable ] = MemRef

			return self.OutPorts[ MemRef ]
		end

	end

	self:TraceError( Trace, "unkown modifier %q", Modifier )
end

function Compiler:IsInput( Trace, MemRef )
	return self.InPorts[MemRef] ~= nil
end

function Compiler:IsOutput( Trace, MemRef )
	return self.OutPorts[MemRef] ~= nil
end


/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Operator Look Up
   --- */

function Compiler:LookUpOperator( Name, First, ... )
	if !First then
		return EXPADV.Operators[Name .. "()"]
	end

	local Op = EXPADV.Operators[ string.format( "%s(%s)", Name, table.concat( { First, ... }, "" ) ) ]
	if Op then return Op end

	local Class = EXPADV.GetClass( First )
	if !Class or !Class.DerivedClass then return end

	return self:LookUpOperator( Name, DerivedClass.Short, ... )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Compile Code
   --- */

local Coroutines = { }

local function SoftCompile( self, Script, Files, bIsClientSide, OnError, OnSucess )

	-- Client and Server
		self.IsServerScript = !bIsClientSide
		self.IsClientScript = bIsClientSide or false

	-- Instance:
		self.Pos = 0
		self.Len = #Script
		self.Strings = { }
		self.Buffer = Script
		self.Files = Files or { }
		self.Enviroment = { }
		EXPADV.COMPILER_ENV = self.Enviroment
		
	-- Tokenizer:
		self.TokenPos = -1
		self.Char = ""
		self.ReadData = ""
		self.ReadChar = 1
		self.ReadLine = 1

	-- Memory:
		self:BuildScopes( )

		self.Cells = { }
		self.InPorts = { }
		self.OutPorts = { }

		self.FreshMemory = { }
		self.MemoryDeph = 0
		self.LambdaDeph = 0
		self.LoopDeph = 0

	-- Operators:
		
	-- Run:
		self:NextChar( )
		self.Tokens = { self:GetNextToken( ), self:GetNextToken( ) }
		self:NextToken( )

	-- Wait for next tick to begin:
		-- coroutine.yield( )

	-- Ok, Run the compiler.
		local Compiled, Instruction = pcall( self.Sequence, self, { 0, 0 } )

	-- Finish!
		Coroutines[self] = nil -- Because we compile inside a coroutine now =D

		if !Compiled then return OnError( Instruction ) end

		return OnSucess( self, Instruction )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Compiler Handeler, From now on we will compile over time!
   --- */

/*hook.Add( "Tick", "ExpAdv.Compile", function( )
	for Instance, Coroutine in pairs( Coroutines ) do
		Instance.Yield = SysTime( ) + 1--0.001

		EXPADV.COMPILER_ENV = Instance.Enviroment

		coroutine.resume( Coroutine )

		EXPADV.COMPILER_ENV = nil
	end
end )*/

function EXPADV.Compile( Script, Files, bIsClientSide, OnError, OnSucess )
	local self = setmetatable( { }, Compiler )
	
	SoftCompile( self, Script, Files, bIsClientSide, OnError, OnSucess )

	return self
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Some Extra Stuff
   --- */

function Compiler:PercentCompiled( )
	if self.Pos <= 0 or self.Len <= 0 then return 0 end
	return self.Pos / self.Len * 100
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Example Compiler Usage
   --- */
if SERVER then
	concommand.Add( "ask", function( Player, _, Args )
		local Code = table.concat( Args, " " )

		local function OnError( Error )
			MsgN( "Compiler, Failed -> " .. Error )
		end

		local function OnSucess( Instance, Instruction )
			MsgN( "Executed: " .. Code )

			local Context = EXPADV.BuildNewContext( Player, Player )

			local Execute = CompileString(
					[[return function( Context )
						]] .. ( Instruction.Prepare or "" ) .. [[
						]] .. ( Instruction.Inline or "" ) .. [[
					end]],
			"EXPADV2", false )

			Execute( Context )
		end

		EXPADV.Compile( Code, { }, false, OnError, OnSucess )
	end )
end