EXPADV_INLINE = 1
EXPADV_PREPARE = 2
EXPADV_INLINEPREPARE = 3
EXPADV_FUNCTION = 4

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Server -> Client control.
   --- */

local LoadOnServer = true

local LoadOnClient = true

function EXPADV.ServerOperators( )
	LoadOnServer = true

	LoadOnClient = false
end

function EXPADV.ClientOperators( )
	LoadOnClient = true

	LoadOnServer = false
end

function EXPADV.SharedOperators( )
	LoadOnClient = true

	LoadOnServer = true
end

EXPADV.BaseClassObj.LoadOnClient = true
/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Register our operators!
   --- */

local Temp_Operators = { }

function EXPADV.AddInlineOperator( Component, Name, Input, Return, Inline )
	Temp_Operators[ #Temp_Operators + 1 ] = { 
		LoadOnClient = LoadOnClient,
		LoadOnServer = LoadOnServer,

		Component = Component,
		Name = Name,
		Input = Input,
		Return = Return,
		Inline = Inline,
		FLAG = EXPADV_INLINE
	}
end

function EXPADV.AddPreparedOperator( Component, Name, Input, Return, Prepare, Inline )
	Temp_Operators[ #Temp_Operators + 1 ] = { 
		LoadOnClient = LoadOnClient,
		LoadOnServer = LoadOnServer,
		 
		Component = Component,
		Name = Name,
		Input = Input,
		Return = Return,
		Prepare = Prepare,
		Inline = Inline,
		FLAG = Inline and EXPADV_INLINEPREPARE or EXPADV_PREPARE
	}
end

function EXPADV.AddVMOperator( Component, Name, Input, Return, Function )
	Temp_Operators[ #Temp_Operators + 1 ] = { 
		LoadOnClient = LoadOnClient,
		LoadOnServer = LoadOnServer,
		 
		Component = Component,
		Name = Name,
		Input = Input,
		Return = Return,
		Function = Function,
		FLAG = EXPADV_FUNCTION
	}
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Load out operators
   --- */

function EXPADV.LoadOperators( )
	EXPADV.Operators = { }

	for I = 1, #Temp_Operators do
		local Operator = Temp_Operators[I]

		-- Checks if the operator requires an enabled component.
		if Operator.Component and !Operator.Component.Enabled then continue end

		-- First of all, Check the return type!
		if Operator.Return and Operator.Return == "" then
			
			if Operator.FLAG == EXPADV_INLINE then
				MsgN( string.format( "Skipped operator: %s(%s), Inline operators can't return void.", Operator.Name, Operator.Input ) )
				continue
			end

			Operator.Return = nil

		elseif Operator.Return and Operator.Return == "..." then
			
			Operator.ReturnsVarg = true

		else
			local Class = EXPADV.GetClass( Operator.Return, false, true )
			
			if !Class then 
				MsgN( string.format( "Skipped operator: %s(%s), Invalid return class %s.", Operator.Name, Operator.Input, Operator.Return ) )
				continue
			end

		end

		-- Second we check the input types, and build our signatures!
		local ShouldNotLoad = false

		if Operator.Input and Operator.Input ~= "" then
			local Signature = { }

			for I, Input in pairs( string.Explode( ",", Operator.Input ) ) do //string.gmatch( Operator.Input, "()([%w%?!%*]+)%s*([%[%]]?)()" ) do

				-- First lets check for varargs.
				if Input == "..." then
					
					if I ~= #string.Explode( ",", Operator.Input ) then 
						ShouldNotLoad = true
						MsgN( string.format( "Skipped operator: %s(%s), vararg (...) must appear as at end of parameters.", Operator.Name, Operator.Input ) )
						break
					end

					Signature[ I ] = "..."
					Operator.UsesVarg = true
					break
				end

				-- Next, check for valid input classes.
				local Class = EXPADV.GetClass( Input, false, true )
				
				if !Class then 
					ShouldNotLoad = true
					MsgN( string.format( "Skipped operator: %s(%s), Invalid class for parameter #%i %s.", Operator.Name, Operator.Input, I, Input ) )
					break
				end

				Signature[ I ] = Class.Short
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

		MsgN( "Built Operator: " .. Operator.Signature )

		-- Lets build this operator.
		EXPADV.BuildLuaOperator( Operator )

		EXPADV.Operators[ Operator.Signature ] = Operator
	end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Register our functions
   --- */

local Temp_Functions = { }

function EXPADV.AddInlineFunction( Component, Name, Input, Return, Inline )
	Temp_Functions[ #Temp_Functions + 1 ] = {  
		LoadOnClient = LoadOnClient,
		LoadOnServer = LoadOnServer,
		
		Component = Component,
		Name = Name,
		Input = Input,
		Return = Return,
		Inline = Inline,
		FLAG = EXPADV_INLINE
	}
end

function EXPADV.AddPreparedFunction( Component, Name, Input, Return, Prepare, Inline )
	Temp_Functions[ #Temp_Functions + 1 ] = {  
		LoadOnClient = LoadOnClient,
		LoadOnServer = LoadOnServer,
		
		Component = Component,
		Name = Name,
		Input = Input,
		Return = Return,
		Prepare = Prepare,
		Inline = Inline,
		FLAG = Inline and EXPADV_INLINEPREPARE or EXPADV_PREPARE
	}
end

function EXPADV.AddVMFunction( Component, Name, Input, Return, Function )
	Temp_Functions[ #Temp_Functions + 1 ] = {  
		LoadOnClient = LoadOnClient,
		LoadOnServer = LoadOnServer,
		
		Component = Component,
		Name = Name,
		Input = Input,
		Return = Return,
		Function = Function,
		FLAG = EXPADV_FUNCTION
	}
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Helper Support
   --- */

local Temp_HelperData = { }

function EXPADV.AddFunctionHelper( Component, Name, Input, Description )
	if SERVER then return end

	Temp_HelperData[#Temp_HelperData + 1] = {
		Component = Component,
		Name = Name,
		Input = Input,
		Description = Description
	}
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Load out functions
   --- */

function EXPADV.LoadFunctions( )
	EXPADV.Functions = { }

	for I = 1, #Temp_Functions do
		local Operator = Temp_Functions[I]

		-- Checks if the operator requires an enabled component.
		if Operator.Component and !Operator.Component.Enabled then continue end

		-- First of all, Check the return type!
		if Operator.Return and Operator.Return == "" then
			if Operator.FLAG == EXPADV_INLINE then continue end
			Operator.Return = nil -- ^ Inlined operators must return somthing!
		elseif Operator.Return and Operator.Return == "..." then
			Operator.ReturnsVarg = true
		else
			local Class = EXPADV.GetClass( Operator.Return, false, true )
			if !Class then continue end
		end

		-- Second we check the input types, and build our signatures!
		local ShouldNotLoad = false

		if Operator.Input and Operator.Input ~= "" then
			
			local Signature = { }

			local Start, End = string.find( Operator.Input, "^()[a-z0-9]+():" )

			if Start then
				local Meta = string.sub( Operator.Input, Start, End - 1 )

				Operator.Input = string.sub( Operator.Input, End + 1 )

				-- Next, check for valid input classes.
				local Class = EXPADV.GetClass( Meta, false, true )
				
				if !Class then 
					ShouldNotLoad = true
					continue
				end

				Signature[1] = Class.Short .. ":"
			end

			for I, Input in pairs( string.Explode( ",", Operator.Input ) ) do //string.gmatch( Operator.Input, "()([%w%?!%*]+)%s*([%[%]]?)()" ) do

				-- First lets check for varargs.
				if Input == "..." then
					
					if I ~= #string.Explode( ",", Operator.Input ) then 
						ShouldNotLoad = true
						break -- Vararg is in the wrong place =(
					end

					Signature[ #Signature + 1 ] = "..."
					Operator.UsesVarg = true
					break
				end

				-- Next, check for valid input classes.
				local Class = EXPADV.GetClass( Input, false, true )
				
				if !Class then 
					ShouldNotLoad = true
					break
				end

				Signature[ #Signature + 1 ] = Class.Short
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

		MsgN( "Built Function: " .. Operator.Signature )

		-- Lets build this operator.
		EXPADV.BuildLuaOperator( Operator )

		EXPADV.Functions[ Operator.Signature ] = Operator
	end

	if CLIENT then

		for I = 1, #Temp_HelperData do
			local Helper = Temp_HelperData[I]
			
			if Helper.Component and !Helper.Component.Enabled then continue end

			local Signature = string.format( "%s(%s)", Helper.Name, Helper.Input or "" )

			local Operator = EXPADV.Functions[Signature]

			if !Operator then continue end

			Operator.Description = Helper.Description
		end

	end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Server and Client Operator Checks
   --- */

function EXPADV.CanBuildOperator( Compiler, Trace, Operator )
	if Compiler.IsServerScript and !Operator.LoadOnServer then
		Compiler:TraceError( Trace, "%s Must not appear in serverside scripts.", Operator.Signature )
	elseif  Compiler.IsClientScript and !Operator.LoadOnClient then
		Compiler:TraceError( Trace, "%s Must not appear in clientside scripts.", Operator.Signature )
	end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Operator to Lua
   --- */

function EXPADV.BuildVMOperator( Operator )
	function Operator.Compile( Compiler, Trace, ... )
		EXPADV.CanBuildOperator( Compiler, Trace, Operator )

		local Instructions = { ... }
		local Arguments, Prepare = { }, { }

		for I = 1, Operator.InputCount do
			local Instruction = Instructions[I]

			if isstring( Instruction ) then

				Arguments[I] = "\"" .. Instruction .. "\""

			elseif isnumber( Instruction ) then

				Arguments[I] = Instruction

			elseif Instruction.FLAG == EXPADV_FUNCTION then
				-- TODO: Figure this one out later

			elseif Instruction.FLAG == EXPADV_INLINE then

				Arguments[I] = Instruction.Inline

			elseif Instruction.FLAG == EXPADV_PREPARE then

				Prepare[ #Prepare + 1 ] = Instruction.Prepare

			else
				Arguments[I] = Instruction.Inline

				Prepare[ #Prepare + 1 ] = Instruction.Prepare
			end

		end

		local ID = #Compiler.VMInstructions + 1
		
		Compiler.VMInstructions[ID] = Operator.Function
		
		local Inline = string.format( "Context.Instructions[%i]( Context, %s, %s )", ID, Compiler:CompileTrace( Trace ), table.concat( Arguments, "," ) )
	
		return Compiler:NewLuaInstruction( Trace, Operator, table.concat( Prepare, "\n" ), Inline )
	end
end

function EXPADV.BuildLuaOperator( Operator )
	if Operator.FLAG == EXPADV_FUNCTION then
		return EXPADV.BuildVMOperator( Operator )
	end

	Operator.Compile = function( Compiler, Trace, ... )
		EXPADV.CanBuildOperator( Compiler, Trace, Operator )

		local Trace = table.Copy( Trace )
		local Inputs = { ... }

		local OpPrepare, OpInline = Operator.Prepare, Operator.Inline

		for I = Operator.InputCount, 1, -1 do
			local Input = Inputs[I]
			local InputInline, InputPrepare = "nil", ""
			
			-- How meany times do we need this Var?
			local Uses = 0

			if Operator.FLAG == EXPADV_INLINE or Operator.FLAG == EXPADV_INLINEPREPARE then
				local _, Add = string.gsub( OpInline, "@value " .. I, "" )
				Uses = Add
			end

			if Operator.FLAG == EXPADV_PREPARE or Operator.FLAG == EXPADV_INLINEPREPARE then
				local _, Add = string.gsub( OpPrepare, "@value " .. I, "" )
				Uses = Uses + Add
			end

			-- Generate the inline and preperation.
			if Uses == 0 then
				InputInline = nil -- This should never happen!
			elseif Input.FLAG == EXPADV_FUNCTION then
				InputInline = Compiler:VMToLua( Input )

			elseif Input.FLAG == EXPADV_INLINE then
				InputInline = Input.Inline

			elseif Input.FLAG == EXPADV_PREPARE then
				InputInline = nil
				InputPrepare = Input.Prepare
			else
				InputInline = Input.Inline
				InputPrepare = Input.Prepare
			end

			-- Lets see if we need to localize the inline
			if Uses >= 2 and !Input.IsRaw and !string.StartWith( InputInline, "Context.Dinfinitions" ) then
				local Local = Compiler:NextLocal( )
				InputPrepare = string.format( "%s\nContext.Dinfinitions[%s] = %s", InputPrepare, Local, InputInline )
				InputInline = string.format( "Context.Dinfinitions[%s]", Local )
			end

			-- Place inputs into generated code
			if Operator.FLAG == EXPADV_PREPARE or Operator.FLAG == EXPADV_INLINEPREPARE then
				OpPrepare = string.gsub( OpPrepare, "@value " .. I, InputInline )
				OpPrepare = string.gsub( OpPrepare, "@type " .. I, Format( "%q", Input.Return or Operator.Input[I] ) )
			end

			if Operator.FLAG == EXPADV_INLINE or Operator.FLAG == EXPADV_INLINEPREPARE then
				OpInline = string.gsub( OpInline, "@value " .. I, InputInline )
				OpInline = string.gsub( OpInline, "@type " .. I, Format( "%q", Input.Return or Operator.Input[I] ) )
			end

			-- Now we handel preperation.
			if Operator.FLAG == EXPADV_PREPARE or Operator.FLAG == EXPADV_INLINEPREPARE then

				-- First check for manual prepare
				if string.find( OpPrepare, "@prepare " .. I ) then
					OpPrepare = string.gsub( OpPrepare, "@prepare " .. I, InputPrepare )
				else
					-- Ok, now prepare this ourself.
					OpPrepare = OpPrepare .. "\n" .. InputPrepare
				end

			end
		end

		-- Now we handel any varargs!
		if Operator.UsesVarg and #Inputs > Operator.InputCount then
			if ( OpPrepare and string.find( OpPrepare, "(@%.%.%.)" ) ) or ( OpInline and string.find( OpInline, "(@%.%.%.)" ) ) then
				local VAPrepare, VAInline = { }, { }

				for I = Operator.InputCount + 1, #Inputs do
					local Input = Input[I]

					if Input.FLAG == EXPADV_FUNCTION then
						VAInline[ #VAInline + 1 ] = string.format( "{%s,%q}", Compiler:VMToLua( Input ), Input.Return or "NIL" )
					elseif Input.FLAG == EXPADV_INLINE then
						VAInline[ #VAInline + 1 ] = string.format( "{%s,%q}", Input.Inline, Input.Return or "NIL" )
					elseif Input.FLAG == EXPADV_PREPARE then
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

				if Operator.FLAG == EXPADV_PREPARE or Operator.FLAG == EXPADV_INLINEPREPARE then
					OpPrepare = string.gsub( OpPrepare, "(@%.%.%.)" .. I, table.concat( VAInline, "," ) )
				end

				if Operator.FLAG == EXPADV_INLINE or Operator.FLAG == EXPADV_INLINEPREPARE then
					OpInline = string.gsub( OpInline, "(@%.%.%.)" .. I, table.concat( VAInline, "," ) )
				end

			end
		end

		-- Now lets check cpu time, note we will let the trace system below, insert our traces.
		if Operator.FLAG == EXPADV_PREPARE or Operator.FLAG == EXPADV_INLINEPREPARE then
			OpPrepare = string.gsub( OpPrepare, "@cpu", "Context:UpdateCPUQuota( @trace )" )
		end

		--Now lets handel traces!
		local Uses = 0

		if Operator.FLAG == EXPADV_INLINE or Operator.FLAG == EXPADV_INLINEPREPARE then
			local _, Add = string.gsub( OpInline, "@trace", "" )
			Uses = Add
		end

		if Operator.FLAG == EXPADV_PREPARE or Operator.FLAG == EXPADV_INLINEPREPARE then
			local _, Add = string.gsub( OpPrepare, "@trace", "" )
			Uses = Uses + Add
		end

		if Uses >= 1 then
			local Trace = Compiler:CompileTrace( Trace )

			if Uses >= 2 then
				OpPrepare = string.forma( "local Trace = %s\n%s", Trace, OpPrepare or "" )
				Trace = "Trace"
			end

			if Operator.FLAG == EXPADV_PREPARE or Operator.FLAG == EXPADV_INLINEPREPARE then
				OpPrepare = string.gsub( OpPrepare, "@trace", Trace )
			end

			if Operator.FLAG == EXPADV_INLINE or Operator.FLAG == EXPADV_INLINEPREPARE then
				OpInline = string.gsub( OpInline, "@trace", Trace )
			end
		end

		-- Oh god, now we need to format our preperation.
		local Definitions = { }

		if Operator.FLAG == EXPADV_PREPARE or Operator.FLAG == EXPADV_INLINEPREPARE then
			local DefinedLines = { }

			for StartPos, EndPos in string.gmatch( OpPrepare, "()@define [a-zA-Z_0-9%%, \t]+()" ) do
				DefinedLines[ #DefinedLines + 1 ] = { StartPos, EndPos }
			end

			for I = #DefinedLines, 1, -1 do -- Work backwards, so we dont break our preparation.
				local NewLine = { }
				local Start, End = unpack( DefinedLines[I] ) -- Oh God unpack, meh.
				local Line = string.sub( OpPrepare, Start + 8, End - 1  )

				for Name in string.gmatch( Line, "([a-zA-Z0-9_]+)" ) do
					local Lua = Compiler:DefineVariable( )

					NewLine[ #NewLine + 1 ] = Lua

					Definitions[ "@" .. Name ] = Lua
				end

				OpPrepare = string.sub( OpPrepare, 1, Start - 1 ) .. table.concat( NewLine, "," ) .. string.sub( OpPrepare, End - 1 )
			end

			OpPrepare = string.gsub( OpPrepare, "(@[a-zA-Z0-9_]+)", Definitions )

			--TODO: Externals!

			--TODO: Imports!
		end

		-- Now lets format the inline
		if Operator.FLAG == EXPADV_INLINE or Operator.FLAG == EXPADV_INLINEPREPARE then
			-- Replace the locals in our prepare!
			OpInline = string.gsub( OpInline, "(@[a-zA-Z0-9_]+)", Definitions )

			--TODO: Externals!

			--TODO: Imports!
		end

		return Compiler:NewLuaInstruction( Trace, Operator, OpPrepare, OpInline )
	end
end
