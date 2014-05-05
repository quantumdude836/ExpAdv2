local LEMON_INLINE = 1
local LEMON_PREPARE = 2
local LEMON_INLINEPREPARE = 3
local LEMON_FUNCTION = 4

/* ---
	@: Register our operators!
   --- */

local Temp_Operators = { }

function AddInlineOperator( Component, Name, Input, Return, Inline )
	Temp_Operators[ #Temp_Operators + 1 ] = { 
		Component = Component,
		Name = Name,
		Input = Input,
		Return = Return,
		Inline = Inline,
		FLAG = LEMON_INLINE
	}
end

function AddPreparedOperator( Component, Name, Input, Return, Prepare, Inline )
	Temp_Operators[ #Temp_Operators + 1 ] = { 
		Component = Component,
		Name = Name,
		Input = Input,
		Return = Return,
		Prepare = Prepare,
		Inline = Inline,
		FLAG = Inline and LEMON_INLINEPREPARE or LEMON_PREPARE
	}
end

function AddPreparedOperator( Component, Name, Input, Return, Function )
	Temp_Operators[ #Temp_Operators + 1 ] = { 
		Component = Component,
		Name = Name,
		Input = Input,
		Return = Return,
		Function = Function,
		FLAG = LEMON_FUNCTION
	}
end

/* ---
	@: Load out operators
   --- */

Operators = { }

function LoadOperators( )
	for I = 1, #Temp_Operators do
		local Operator = Temp_Operators[I]

		-- Checks if the operator requires an enabled component.
		if Operator.Component and !Operator.Component.Enabled then continue end

		-- First of all, Check the return type!
		if Operator.Return and Operator.Return == "" then
			if Operator.FLAG = LEMON_INLINE then continue end
			Operator.Return = nil -- ^ Inlined operators must return somthing!
		elseif Operator.Return and Operator.Return == "..." then
			Operator.ReturnsVarg = true
		else
			local Class = GetClass( Operator.Return, false, true )
			if !Class then continue end -- return Class does not exits!
		end

		-- Second we check the input types, and build our signatures!
		local ShouldNotLoad = false

		if Operator.Input and Operator.Input ~= "" then
			local Signature = { }

			for I, Input in string.gmatch( Operator.Input, "()([%w%?!%*]+)%s*([%[%]]?)()" ) do

				-- First lets check for varargs.
				if Input == "..." then
					
					if I ~= #string.Explode( ",", Operator.Input ) then 
						ShouldNotLoad = true
						break -- Vararg is in the wrong place =(
					end

					Signature[ I + 1 ] = "..."
					Operator.UsesVarg = true
					break
				end

				-- Next, check for valid input classes.
				local Class = GetClass( Input, false, true )
				
				if !Class then 
					ShouldNotLoad = true
					break
				end

				Signature[ I + 1 ] = Class.Short
			end

			Operator.Input = Signature
			Operator.InputCount = #Signature
			Operator.Signature = string.format( "%s(%s)", Operator.Name, table.concat( Signature, "" ) )

			if Operator.UsesVarg then Operator.InputCount = Operator.InputCount - 1 end
		else
			Operator.Input = { }
			Operator.InputCount = 0
			Operator.Signature = string.format( "%s()", Operator.Name )
		end

		-- Do we still need to load this?
		if ShouldNotLoad then continue end

		-- Lets build this operator.
		BuildLuaOperator( Operator )

		Operators[Operator.Signature] = Operator
	end
end

/* ---
	@: Operator to Lua
   --- */

function BuildVMOperator( Operator )
	if Operator.InputCount == 0 then
		return function( Compiler, Trace )
			return Compiler:NewVMInstruction( Trace, Operator, Operator.Function )
		end
	end

	return function( Compiler, Trace, ... )
		local Inputs = { Compiler:CompileTrace( Trace ), "Context" }

		for I = Operator.InputCount, 1, -1 do
			local Input = Operator.Input[I]

			if isnumber( Input ) then
				Inputs[I + 2] = Input
			elseif isstring( Input ) then
				Inputs[I + 2] = "\"" .. Input .. "\""
			elseif Input.FLAG == LEMON_FUNCTION then
				Inputs[I + 2] = Compiler:VMToLua( Input.Function )
				continue
			elseif Input.FLAG == LEMON_INLINE then

				if string.StartWith( Input.Inline, "Context.Locals" ) then
					Inputs[I + 2] = Input.Inline
					continue
				end -- Already a varible

				local O, E = pcall( RunString, "setfenv(1, LEMON_COMPILER_ENV ); LEMON_NATIVE = function( Trace, Context ) " .. Input.Inline .. " end")
				if !O then self:Error( "Failed to compile instruction: %s -> %s", Operator.Signature, E ) end
				
				Inputs[I + 2] = Compiler:VMToLua( LEMON_NATIVE )
				LEMON_NATIVE = nil
			elseif Input.FLAG == LEMON_PREPARE then
				local O, E = pcall( RunString, "setfenv(1, LEMON_COMPILER_ENV ); LEMON_NATIVE = function( Trace, Context )\n" .. Input.Prepare .. "\nend")
				if !O then self:Error( "Failed to compile instruction: %s -> %s", Operator.Signature, E ) end
				
				Inputs[I + 2] = Compiler:VMToLua( LEMON_NATIVE )
				LEMON_NATIVE = nil
			else
				local O, E = pcall( RunString, "setfenv(1, LEMON_COMPILER_ENV ); LEMON_NATIVE = function( Trace, Context )\n" .. Input.Prepare .. "\n" .. "return " .. Input.Inline .. "\nend")
				if !O then self:Error( "Failed to compile instruction: %s -> %s", Operator.Signature, E ) end

				Inputs[I + 2] = Compiler:VMToLua( LEMON_NATIVE )
				LEMON_NATIVE = nil
			end
		end

		return Compiler:NewVMInstruction( Trace, Operator, Operator.Function, Inputs )
	end
end

function BuildLuaOperator( Operator )
	if Operator.FLAG == LEMON_FUNCTION then
		return BuildVMOperator( Operator )
	end

	return function( Compiler, Trace, ... )
		local Trace = table.Copy( Trace )
		local Inputs = { ... }

		local OpPrepare, OpInline = Operator.Prepare, Operator.Inline

		for I = Operator.InputCount, 1, -1 do
			local Input = Inputs.Input[I]
			local InputInline, InputPrepare = "nil", ""
			
			-- How meany times do we need this Var?
			local Uses = 0

			if Operator.FLAG == LEMON_INLINE or Operator.FLAG == LEMON_INLINEPREPARE then
				local _, Add = string.gsub( OpInline, "value %%" .. I, "" )
				Uses = Add
			end

			if Operator.FLAG == LEMON_PREPARE or Operator.FLAG == LEMON_INLINEPREPARE then
				local _, Add = string.gsub( OpPrepare, "value %%" .. I, "" )
				Uses = Uses + Add
			end

			-- Generate the inline and preperation.
			if Uses == 0 then
				InputInline = nil -- This should never happen!
			elseif Input.FLAG == LEMON_FUNCTION then
				InputInline = Compiler:VMToLua( Input )

			elseif Input.FLAG == LEMON_INLINE then
				InputInline = Input.Inline

			elseif Input.FLAG == LEMON_PREPARE then
				InputInline = nil
				InputPrepare = Input.Prepare
			else
				InputInline = Input.Inline
				InputPrepare = Input.Prepare
			end

			-- Here we deal with inlining anything, that needs to be inlined!
			if Input.FLAG == LEMON_INLINE or Input.FLAG == LEMON_INLINEPREPARE then
				
				-- If Inline is used more then once, then we need to make it local.
				if Uses >= 2 and InputInline then
					
					-- First we check to see if it is local, before we localise it.
					if !string.StartWith( InputInline, "Context.Locals" ) then
						local Local = Compiler:NextLocal( )
						InputPrepare = string.format( "%s\nContext.Locals[%s] = %s", InputPrepare, Local, InputInline )
						InputInline = string.format( "Context.Locals[%s]", Local )
					end
				end

				-- Place the inputs into the generated code.
				if Input.FLAG == LEMON_PREPARE or Input.FLAG == LEMON_INLINEPREPARE then
					OpPrepare = string.gsub( OpPrepare, "value %%" .. I, InputInline )
					OpPrepare = string.gsub( OpPrepare, "type %%" .. I, Format( "%q", Input.Return or Operator.Input[I] ) )
				end

				if Input.FLAG == LEMON_INLINE or Input.FLAG == LEMON_INLINEPREPARE then
					OpInline = string.gsub( OpInline, "value %%" .. I, InputInline )
					OpInline = string.gsub( OpInline, "type %%" .. I, Format( "%q", Input.Return or Operator.Input[I] ) )
				end
			end

			-- Now we handel preperation.
			if Input.FLAG == LEMON_PREPARE or Input.FLAG == LEMON_INLINEPREPARE then

				-- First check for manual prepare
				if string.find( OpPrepare, "prepare %%" .. I ) then
					OpPrepare = string.gsub( OpPrepare, "prepare %%" .. I, InputPrepare )
				else
					-- Ok, now prepare this ourself.
					OpPrepare = OpPrepare .. "\n" .. InputPrepare
				end

			end
		end

		-- Now we handel any varargs!
		if Operator.UsesVarg and #Inputs > Operator.InputCount then
			if ( OpPrepare and string.find( OpPrepare, "(%%%.%.%.)" ) ) or ( OpInline and string.find( OpInline, "(%%%.%.%.)" ) ) then
				local VAPrepare, VAInline = { }, { }

				for I = Operator.InputCount + 1, #Inputs do
					local Input = Inputs.Input[I]

					if Input.FLAG == LEMON_FUNCTION then
						VAInline[ #VAInline + 1 ] = string.format( "{%s,%q}", Compiler:VMToLua( Input ), Input.Return or "NIL" )
					elseif Input.FLAG == LEMON_INLINE then
						VAInline[ #VAInline + 1 ] = string.format( "{%s,%q}", Input.Inline, Input.Return or "NIL" )
					elseif Input.FLAG == LEMON_PREPARE then
						InputInline = "{nil,\"NIL\"}"
						VAPrepare[ #VAPrepare + 1 ] = Input.Prepare
					else
						VAInline[ #VAInline + 1 ] = string.format( "{%s,%q}", Input.Inline, Input.Return or "NIL" )
						VAPrepare[ #VAPrepare + 1 ] = Input.Prepare
					end
				end

				-- Preare the varargs preperation statments.
				if #VAPrepare >= 1 then
					OpPrepare = (OpPrepare or "") .. "\n" .. table.concat( VAPrepare, "\n" )
				end

				if Input.FLAG == LEMON_PREPARE or Input.FLAG == LEMON_INLINEPREPARE then
					OpPrepare = string.gsub( OpPrepare, "(%%%.%.%.)" .. I, table.concat( VAInline, "," ) )
				end

				if Input.FLAG == LEMON_INLINE or Input.FLAG == LEMON_INLINEPREPARE then
					OpInline = string.gsub( OpInline, "(%%%.%.%.)" .. I, table.concat( VAInline, "," ) )
				end

			end
		end

		-- Now lets check cpu time, note we will let the trace system below, insert our traces.
		if Input.FLAG == LEMON_PREPARE or Input.FLAG == LEMON_INLINEPREPARE then
			OpPrepare = string.gsub( OpPrepare, "%%cpu", "Context:UpdateBenchMark( %%trace )" )
		end

		--Now lets handel traces!
		local Uses = 0

		if Operator.FLAG == LEMON_INLINE or Operator.FLAG == LEMON_INLINEPREPARE then
			local _, Add = string.gsub( OpInline, "%%trace", "" )
			Uses = Add
		end

		if Operator.FLAG == LEMON_PREPARE or Operator.FLAG == LEMON_INLINEPREPARE then
			local _, Add = string.gsub( OpPrepare, "%%trace", "" )
			Uses = Uses + Add
		end

		if Uses >= 1 then
			local Trace = Compiler:CompileTrace( Trace )

			if Uses >= 2 then
				OpPrepare = string.forma( "local Trace = %s\n%s", Trace, OpPrepare or "" )
				Trace = "Trace"
			end

			if Input.FLAG == LEMON_PREPARE or Input.FLAG == LEMON_INLINEPREPARE then
				OpPrepare = string.gsub( OpPrepare, "%%trace", Trace )
			end

			if Input.FLAG == LEMON_INLINE or Input.FLAG == LEMON_INLINEPREPARE then
				OpInline = string.gsub( OpInline, "%%trace", Trace )
			end
		end

		-- Oh god, now we need to format our preperation.
		local Local_Values = { }

		if Input.FLAG == LEMON_PREPARE or Input.FLAG == LEMON_INLINEPREPARE then
			local NewLines, Spaces = { }, 0
			local OldLines = string.Explode( "[\n;]", OpPrepare, true )

			for I = 1, #OldLines do
				--First lets remove spacing!
				local Line = string.Trim( string.Trim( OldLines[I], " " ), "\t" )

				-- Now lets find the locals!
				if string.StartWith( Line, "local ") then
					local NewLine = Line

					for Variable in string.gmatch( Line, "(%%[a-zA-Z0-9_]+)" ) do
						local Local = string.format( "Context.Locals[%s]", Compiler:NextLocal( ) )
						Local_Values[ Variable ] = Local

						NewLine = string.gsub( NewLine, "%" .. Variable, Local )
					end

					if NewLine ~= Line then
						NewLine = string.sub( NewLine, 7, #NewLine ) -- Strip of local!
						NewLines[ #NewLines + 1 ] = string.rep( " ", Spaces ) .. NewLine
					else
						NewLines[ #NewLines + 1 ] = string.rep( " ", Spaces ) .. Line
					end
				-- Anything ending with 'do' or 'then' needs to indent.
				elseif string.EndsWith( Line, "then") or string.EndsWith( Line, "do") then
					NewLines[ #NewLines + 1 ] = string.rep( " ", Spaces ) .. Line
					Spaces = Spaces + 1
				
				-- Functions need to indent too.
				elseif string.StartWith( Line, "function") and !string.EndsWith( Line, "end") then
					NewLines[ #NewLines + 1 ] = string.rep( " ", Spaces ) .. Line
					Spaces = Spaces + 1

				-- Anything ending with 'end' needs to unindent.
				elseif string.StartWith( Line, "end") then
					Spaces = Spaces - 1
					NewLines[ #NewLines + 1 ] = string.rep( " ", Spaces ) .. Line
				
				else -- Now we just indent as normal!
					NewLines[ #NewLines + 1 ] = string.rep( " ", Spaces ) .. Line
				end

				-- Rebuild the new lines.
				OpPrepare = table.concat( NewLines, "\n" )

				-- Replace the locals in our prepare!
				OpPrepare = string.gsub( OpPrepare, "(%%[a-zA-Z0-9_]+)", Local_Values )

				--TODO: Externals!

				--TODO: Imports!
			end
		end

		-- Now lets format the inline
		if Operator.FLAG == LEMON_INLINE or Operator.FLAG == LEMON_INLINEPREPARE then
			-- Replace the locals in our prepare!
			OpInline = string.gsub( OpInline, "(%%[a-zA-Z0-9_]+)", Local_Values )

			--TODO: Externals!

			--TODO: Imports!
		end

		return Compiler:NewLuaInstruction( Trace, Operator, OpPrepare, OpInline )
	end
end

/* ---
	@: This should not be here!
   --- */

function Compiler:VMToLua( Instruction )
	if Instruction.FLAG ~= LEMON_FUNCTION then
		self:TokenError( "COMPILER: VMToLua recieved a Lua instruction." )
	end

	local ID = #self.VMInstructions + 1
	self.VMInstructions[ID] = Instruction.Function
	return string.format( "Context.Instructions[%i]( %s )", ID, table.concat( Instruction.Inputs, "," ) )
end

function Compiler:NewLuaInstruction( Trace, Operator, Prepare, Inline )
	local Flag = LEMON_INLINEPREPARE

	if !Prepare or Prepare == "" then
		Flag = LEMON_INLINE
	elseif !Inline or Inline == "" then
		Flag = LEMON_PREPARE
	end

	return {
		Trace = Trace
		Inline = Inline,
		Prepare = Prepare,
		Return = Operator.Return,
		FLAG = Flag
	}
end

function Compiler:NewVMInstruction( Trace, Operator, Function, Inputs )
	return {
		Trace = Trace
		Function = Function,
		Return = Operator.Return,
		Inputs = Inputs or { self:CompileTrace( Trace ), "Context" },
		FLAG = Operator.FLAG
	}
end