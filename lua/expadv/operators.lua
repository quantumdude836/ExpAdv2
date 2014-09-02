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
	local Operator = { 
		LoadOnClient = LoadOnClient,
		LoadOnServer = LoadOnServer,

		Component = Component,
		Name = Name,
		Input = Input,
		Return = Return,
		Inline = Inline,
		FLAG = EXPADV_INLINE
	}

	Temp_Operators[ #Temp_Operators + 1 ] = Operator
	return Operator
end

function EXPADV.AddPreparedOperator( Component, Name, Input, Return, Prepare, Inline )
	local Operator = { 
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

	Temp_Operators[ #Temp_Operators + 1 ] = Operator
	return Operator
end

function EXPADV.AddVMOperator( Component, Name, Input, Return, Function )
	local Operator = { 
		LoadOnClient = LoadOnClient,
		LoadOnServer = LoadOnServer,
		 
		Component = Component,
		Name = Name,
		Input = Input,
		Return = Return,
		Function = Function,
		FLAG = EXPADV_FUNCTION
	}

	Temp_Operators[ #Temp_Operators + 1 ] = Operator
	return Operator
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Load our operators
   --- */

function EXPADV.LoadOperators( )
	EXPADV.Operators = { }
	EXPADV.Class_Operators = { }

	EXPADV.CallHook( "PreLoadOperators" )

	for I = 1, #Temp_Operators do
		local Operator = Temp_Operators[I]

		-- Checks if the operator requires an enabled component.
		if Operator.Component and !Operator.Component.Enabled then continue end

		-- 
		if Operator.AttachedClass and Operator.AttachedClass ~= "" then
			local Class = EXPADV.GetClass( Operator.AttachedClass, false, true )

			if !Class then
				MsgN( string.format( "Skipped operator: %s(%s), Attached to invalid class %q.", Operator.Name, Operator.Input, Operator.AttachedClass ) )
				continue
			end

			Operator.AttachedClass = Class.Short
		end

		-- First of all, Check the return type!
		if Operator.Return and Operator.Return == "" then
			Operator.Return = nil

			if Operator.FLAG == EXPADV_INLINE then
				MsgN( string.format( "Skipped operator: %s(%s), Inline operators can't return void.", Operator.Name, Operator.Input ) )
				continue
			end

		elseif Operator.Return and Operator.Return == "..." then
			
			Operator.ReturnsVarg = true

		else
			local Class = EXPADV.GetClass( Operator.Return, false, true )
			
			if !Class then 
				MsgN( string.format( "Skipped operator: %s(%s), Invalid return class %s.", Operator.Name, Operator.Input, Operator.Return ) )
				continue
			end

			if !Class.LoadOnServer and Operator.LoadOnServer then
				MsgN( string.format( "Skipped operator: %s(%s), return class %s is not avalible on server.", Operator.Name, Operator.Input, Operator.Return ) )
				continue
			elseif !Class.LoadOnClient and Operator.LoadOnClient then
				MsgN( string.format( "Skipped operator: %s(%s), return class %s is not avalible on clients.", Operator.Name, Operator.Input, Operator.Return ) )
				continue
			end

			Operator.Return = Class.Short
		end

		-- Second we check the input types, and build our signatures!
		local ShouldNotLoad, TotalInputs = false, 0

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

					Signature[ #Signature + 1 ] = "..."
					Operator.UsesVarg = true
					break
				elseif Input == "?" then
					TotalInputs = TotalInputs + 1
					continue
				end

				-- Next, check for valid input classes.
				local Class = EXPADV.GetClass( Input, false, true )
				
				if !Class then 
					MsgN( string.format( "Skipped operator: %s(%s), Invalid class for parameter #%i %s.", Operator.Name, Operator.Input, I, Input ) )
					ShouldNotLoad = true
					break
				end

				if !Class.LoadOnServer and Operator.LoadOnServer then
					MsgN( string.format( "Skipped operator: %s(%s), parameter #%i %s is not avalible on server.", Operator.Name, Operator.Input, I, Class.Name ) )
					ShouldNotLoad = true
					break
				elseif !Class.LoadOnClient and Operator.LoadOnClient then
					MsgN( string.format( "Skipped operator: %s(%s), parameter #%i %s is not avalible on clients.", Operator.Name, Operator.Input, I, Class.Name ) )
					ShouldNotLoad = true
					break
				end

				Signature[ #Signature + 1 ] = Class.Short
				TotalInputs = TotalInputs + 1
			end

			Operator.Input = Signature
			Operator.InputCount = TotalInputs
			Operator.Signature = string.format( "%s(%s)", Operator.Name, table.concat( Signature, "" ) )

			--if Operator.UsesVarg then Operator.InputCount = Operator.InputCount - 1 end
		else
			Operator.Input = { }
			Operator.InputCount = 0
			Operator.Signature = string.format( "%s()", Operator.Name )
		end

		-- Do we still need to load this?
		if ShouldNotLoad then continue end

		--MsgN( "Built Operator: " .. Operator.Signature )

		-- Lets build this operator.
		EXPADV.BuildLuaOperator( Operator )

		if !Operator.AttachedClass then
			EXPADV.Operators[ Operator.Signature ] = Operator
		else
			local ClassOperators = EXPADV.Class_Operators[Operator.AttachedClass]

			if !ClassOperators then
				ClassOperators = { }
				EXPADV.Class_Operators[Operator.AttachedClass] = ClassOperators
			end

			ClassOperators[ Operator.Signature ] = Operator
		end
	end

	EXPADV.CallHook( "PostLoadOperators" )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Register our functions
   --- */

local Func_Alias
local Temp_Functions = { }

function EXPADV.AddInlineFunction( Component, Name, Input, Return, Inline )
	Func_Alias = { }

	Temp_Functions[ #Temp_Functions + 1 ] = {  
		LoadOnClient = LoadOnClient,
		LoadOnServer = LoadOnServer,
		
		Component = Component,
		Name = Name,
		Input = Input,
		Return = Return,
		Inline = Inline,
		Aliases = Func_Alias,
		FLAG = EXPADV_INLINE
	}
end

function EXPADV.AddPreparedFunction( Component, Name, Input, Return, Prepare, Inline )
	Func_Alias = { }

	Temp_Functions[ #Temp_Functions + 1 ] = {  
		LoadOnClient = LoadOnClient,
		LoadOnServer = LoadOnServer,
		
		Component = Component,
		Name = Name,
		Input = Input,
		Return = Return,
		Prepare = Prepare,
		Inline = Inline,
		Aliases = Func_Alias,
		FLAG = Inline and EXPADV_INLINEPREPARE or EXPADV_PREPARE
	}
end

function EXPADV.AddVMFunction( Component, Name, Input, Return, Function )
	Func_Alias = { }

	Temp_Functions[ #Temp_Functions + 1 ] = {  
		LoadOnClient = LoadOnClient,
		LoadOnServer = LoadOnServer,
		
		Component = Component,
		Name = Name,
		Input = Input,
		Return = Return,
		Function = Function,
		Aliases = Func_Alias,
		FLAG = EXPADV_FUNCTION
	}
end

function EXPADV.AddFunctionAlias( Name, Input )
	Func_Alias[ #Func_Alias + 1 ] = { Name = Name, Input = Input }
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
	@: Load our functions
   --- */

function EXPADV.LoadFunctions( )
	EXPADV.Functions = { }

	EXPADV.CallHook( "PreLoadFunctions" )

	for I = 1, #Temp_Functions do
		local Operator = Temp_Functions[I]

		-- Checks if the operator requires an enabled component.
		if Operator.Component and !Operator.Component.Enabled then continue end

		-- First of all, Check the return type!
		if Operator.Return and Operator.Return == "" then
			Operator.Return = nil

			if Operator.FLAG == EXPADV_INLINE then
				MsgN( string.format( "Skipped operator: %s(%s), Inline operators can't return void.", Operator.Name, Operator.Input ) )
				continue
			end

		elseif Operator.Return and Operator.Return == "..." then
			Operator.ReturnsVarg = true
		else
			local Class = EXPADV.GetClass( Operator.Return, false, true )
			
			if !Class then 
				MsgN( string.format( "Skipped function: %s(%s), Invalid return class %s.", Operator.Name, Operator.Input, Operator.Return ) )
				continue
			end

			if !Class.LoadOnServer and Operator.LoadOnServer then
				MsgN( string.format( "Skipped function: %s(%s), return class %s is not avalible on server.", Operator.Name, Operator.Input, Operator.Return ) )
				continue
			elseif !Class.LoadOnClient and Operator.LoadOnClient then
				MsgN( string.format( "Skipped function: %s(%s), return class %s is not avalible on clients.", Operator.Name, Operator.Input, Operator.Return ) )
				continue
			end

			Operator.Return = Class.Short
		end

		-- Second we check the input types, and build our signatures!
		local ShouldNotLoad = false

		if Operator.Input and Operator.Input ~= "" then
			
			local Signature = { }

			local Start, End = string.find( Operator.Input, "^()[a-z0-9]+():" )

			if Start then
				local Meta = string.sub( Operator.Input, 1, End - 1 )

				Operator.Method = true

				Operator.Input = string.sub( Operator.Input, End + 1 )

				-- Next, check for valid input classes.
				local Class = EXPADV.GetClass( Meta, false, true )
				
				if !Class then 
					MsgN( string.format( "Skipped function: %s(%s), Invalid class for method %s (%s).", Operator.Name, Operator.Input, Input, Meta ) )
					continue
				end

				if !Class.LoadOnServer and Operator.LoadOnServer then
					MsgN( string.format( "Skipped function: %s(%s), method class %s is not avalible on server.", Operator.Name, Operator.Input, Class.Name ) )
					continue
				elseif !Class.LoadOnClient and Operator.LoadOnClient then
					MsgN( string.format( "Skipped function: %s(%s), method class %s is not avalible on clients.", Operator.Name, Operator.Input, Class.Name ) )
					continue
				end

				Signature[1] = Class.Short
				Signature[2] = ":"
			end

			if Operator.Input and Operator.Input ~= "" then 
				for I, Input in pairs( string.Explode( ",", Operator.Input ) ) do

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
						MsgN( string.format( "Skipped function: %s(%s), Invalid class for parameter #%i (%s).", Operator.Name, Operator.Input, I, Input ) )
						ShouldNotLoad = true
						break
					end

					if !Class.LoadOnServer and Operator.LoadOnServer then
						MsgN( string.format( "Skipped function: %s(%s), parameter #%i %s is not avalible on server.", Operator.Name, Operator.Input, I, Class.Name ) )
						ShouldNotLoad = true
						break
					elseif !Class.LoadOnClient and Operator.LoadOnClient then
						MsgN( string.format( "Skipped function: %s(%s), parameter #%i %s is not avalible on clients.", Operator.Name, Operator.Input, I, Class.Name ) )
						ShouldNotLoad = true
						break
					end

					Signature[ #Signature + 1 ] = Class.Short
				end
			end
			
			Operator.Signature = string.format( "%s(%s)", Operator.Name, table.concat( Signature, "" ) )
			if Operator.Method then table.remove( Signature, 2 ) end

			Operator.Input = Signature
			Operator.InputCount = #Signature

			if Operator.UsesVarg then Operator.InputCount = Operator.InputCount - 1 end
		else
			Operator.Input = { }
			Operator.InputCount = 0
			Operator.Signature = string.format( "%s()", Operator.Name )
		end

		-- Do we still need to load this?
		if ShouldNotLoad then continue end

		-- MsgN( "Built Function: " .. Operator.Signature )

		-- Lets build this operator.
		EXPADV.BuildLuaOperator( Operator )

		EXPADV.Functions[ Operator.Signature ] = Operator

		EXPADV.LoadFunctionAliases( Operator )
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

	EXPADV.CallHook( "PostLoadFunctions" )
end

function EXPADV.LoadFunctionAliases( Operator )
	
	EXPADV.CallHook( "PreLoadAliases" )

	for _, Alias in pairs( Operator.Aliases ) do
		local ShouldNotLoad = false

		local Signature = { }
		
		if Alias.Input and Alias.Input ~= "" then

			local Start, End = string.find( Alias.Input, "^()[a-z0-9]+():" )

			if Start then
				local Meta = string.sub( Alias.Input, Start, End - 1 )

				Alias.Input = string.sub( Alias.Input, End + 1 )

				local Class = EXPADV.GetClass( Meta, false, true )
				if !Class then
					continue
				elseif !Class.LoadOnServer and Operator.LoadOnServer then
					continue
				elseif !Class.LoadOnClient and Operator.LoadOnClient then
					continue
				end

				Signature[1] = Class.Short .. ":"
			end

			for I, Input in pairs( string.Explode( ",", Alias.Input ) ) do

				if Input == "..." then
					ShouldNotLoad = true
					break
				end

				local Class = EXPADV.GetClass( Input, false, true )
				
				if !Class then 
					ShouldNotLoad = true
					break
				end

				if !Class.LoadOnServer and Operator.LoadOnServer then
					ShouldNotLoad = true
					break
				elseif !Class.LoadOnClient and Operator.LoadOnClient then
					ShouldNotLoad = true
					break
				end

				Signature[ #Signature + 1 ] = Class.Short
			end
		end

		EXPADV.Functions[ string.format( "%s(%s)", Alias.Name, table.concat( Signature, "" ) ) ] = Operator
	end

	EXPADV.CallHook( "PostLoadAliases" )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Server and Client Operator Checks
   --- */

function EXPADV.CanBuildOperator( Compiler, Trace, Operator )
	if Compiler.IsServerScript and Compiler.IsClientScript then
		if !Operator.LoadOnServer then
			Compiler:TraceError( Trace, "%s is clientside only and can not appear in shared scripts.", Operator.Signature )
		elseif !Operator.LoadOnClient then
			Compiler:TraceError( Trace, "%s is serverside only and can not appear in shared scripts.", Operator.Signature )
		end
	elseif Compiler.IsServerScript and !Operator.LoadOnServer then
		Compiler:TraceError( Trace, "%s Must not appear in serverside scripts.", Operator.Signature )
	elseif  Compiler.IsClientScript and !Operator.LoadOnClient then
		Compiler:TraceError( Trace, "%s Must not appear in clientside scripts.", Operator.Signature )
	end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: 
   --- */

function EXPADV.Interprit( Operator, Compiler, Line )
	if Operator.Component then
		local Settings = { }

		for StartPos, EndPos in string.gmatch( Line, "()@setting [a-zA-Z_0-9]+()" ) do
			Settings[ #Settings + 1 ] = { StartPos, EndPos }
		end

		for I = #Settings, 1, -1 do
			local Start, End = unpack( Settings[I] )
			local Setting = Operator.Component:ReadSetting( string.sub( Line, Start + 9, End - 1 ), nil )
			Line = string.sub( Line, 1, Start - 1 ) .. EXPADV.ToLua(Setting) .. string.sub( Line, End - 1 )
		end
	end
	
	local Imports = { }

	for StartPos, EndPos in string.gmatch( Line, "()%$[a-zA-Z0-9_]+()" ) do
		Imports[ #Imports + 1 ] = { StartPos, EndPos }
	end

	for I = #Imports, 1, -1 do
		local Start, End = unpack( Imports[I] )
		local Variable = string.sub( Line, Start + 1, End - 1 )

		Line = string.sub( Line, 1, Start - 1 ) .. Variable .. string.sub( Line, End )
		Compiler.Enviroment[Variable] = _G[Variable]
	end

	return Line
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

			if !Instruction then
				Arguments[I] = "nil"

			elseif isstring( Instruction ) then

				Arguments[I] = "\"" .. Instruction .. "\""

			elseif isnumber( Instruction ) then

				Arguments[I] = Instruction

			elseif Instruction.FLAG == EXPADV_FUNCTION then
				error( "Compiler is yet to support virtuals" )

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
		
		local InlineArgs = #Arguments >= 1 and table.concat( Arguments, "," ) or "nil"

		local Inline = string.format( "Context.Instructions[%i]( Context, %s, %s )", ID, Compiler:CompileTrace( Trace ), InlineArgs )
	
		local Instruction = Compiler:NewLuaInstruction( Trace, Operator, table.concat( Prepare, "\n" ), Inline )
		
		Instruction.IsRaw = true
		
		return Instruction
	end
end

function EXPADV.BuildLuaOperator( Operator )
	if Operator.FLAG == EXPADV_FUNCTION then
		return EXPADV.BuildVMOperator( Operator )
	end

	Operator.Compile = function( Compiler, Trace, ... )
		EXPADV.CanBuildOperator( Compiler, Trace, Operator )

		local Trace = table.Copy( Trace )
		local Inputs, Preperation = { ... }, { }

		local OpPrepare, OpInline = Operator.Prepare, Operator.Inline

		for I = Operator.InputCount, 1, -1 do

			local Input = Inputs[I]
			local InputInline, InputPrepare, InputReturn = "nil", ""
			
			if Input then
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
					InputInline = "nil" -- This should never happen!
					InputReturn = nil -- This should result in void.
					
					if Input.FLAG == EXPADV_PREPARE or Input.FLAG == EXPADV_INLINEPREPARE then
						InputPrepare = Input.Prepare
					end

				elseif Input.FLAG == EXPADV_FUNCTION then
					--InputInline = Compiler:VMToLua( Input )
					--InputReturn = Input.Return
					error( "Compiler is yet to support virtuals" )
				elseif Input.FLAG == EXPADV_INLINE then
					InputInline = Input.Inline
					InputReturn = Input.Return
				elseif Input.FLAG == EXPADV_PREPARE then
					InputInline = "nil"
					InputPrepare = Input.Prepare
					InputReturn = Input.Return
				else
					InputInline = Input.Inline
					InputPrepare = Input.Prepare
					InputReturn = Input.Return
				end

				-- Lets see if we need to localize the inline
				if Uses >= 2 and !Input.IsRaw and !string.StartWith( InputInline, "Context.Definitions" ) then
					local Defined = Compiler:DefineVariable( )
					InputPrepare = string.format( "%s\n%s = %s", InputPrepare, Defined, InputInline )
					InputInline = Defined
				end
			end

			-- Place inputs into generated code
			if Operator.FLAG == EXPADV_PREPARE or Operator.FLAG == EXPADV_INLINEPREPARE then
				OpPrepare = string.gsub( OpPrepare, "@value " .. I, InputInline )
				OpPrepare = string.gsub( OpPrepare, "@type " .. I, Format( "%q", InputReturn or Operator.Input[I] or "void" ) )
			end

			if Operator.FLAG == EXPADV_INLINE or Operator.FLAG == EXPADV_INLINEPREPARE then
				OpInline = string.gsub( OpInline, "@value " .. I, InputInline )
				OpInline = string.gsub( OpInline, "@type " .. I, Format( "%q", InputReturn or Operator.Input[I] ) )
			end

			-- Now we handel preperation.
			if Operator.FLAG == EXPADV_PREPARE or Operator.FLAG == EXPADV_INLINEPREPARE then

				-- First check for manual prepare
				if string.find( OpPrepare, "@prepare " .. I ) then
					OpPrepare = string.gsub( OpPrepare, "@prepare " .. I, InputPrepare )
				elseif InputPrepare ~= "" then
					-- Ok, now prepare this ourself.
					table.insert( Preperation, 1, InputPrepare )
				end

			end
		end

		-- Now we handel any varargs!
		if Operator.UsesVarg and #Inputs > Operator.InputCount then
			if ( OpPrepare and string.find( OpPrepare, "(@%.%.%.)" ) ) or ( OpInline and string.find( OpInline, "(@%.%.%.)" ) ) then
				local VAPrepare, VAInline = { }, { }

				for I = Operator.InputCount + 1, #Inputs do
					local Input = Inputs[I]
					 
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
					table.insert( Preperation, table.concat( VAPrepare, "\n" ) )
					-- OpPrepare = (OpPrepare or "") .. "\n" .. table.concat( VAPrepare, "\n" )
				end

				if Operator.FLAG == EXPADV_PREPARE or Operator.FLAG == EXPADV_INLINEPREPARE then
					OpPrepare = string.gsub( OpPrepare, "(@%.%.%.)", table.concat( VAInline, "," ) )
				end

				if Operator.FLAG == EXPADV_INLINE or Operator.FLAG == EXPADV_INLINEPREPARE then
					OpInline = string.gsub( OpInline, "(@%.%.%.)", table.concat( VAInline, "," ) )
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
				OpPrepare = string.format( "local Trace = %s\n%s", Trace, OpPrepare or "" )
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

			for StartPos, EndPos, Assigned in string.gmatch( OpPrepare, "()@define [a-zA-Z_0-9%%, \t]+()(=?)" ) do
				DefinedLines[ #DefinedLines + 1 ] = { StartPos, EndPos, Assigned }
			end

			for I = #DefinedLines, 1, -1 do -- Work backwards, so we dont break our preparation.
				local NewLine = { }
				local Start, End, Assigned = unpack( DefinedLines[I] ) -- Oh God unpack, meh.
				local Line = string.sub( OpPrepare, Start + 8, End - 1  )

				for Name in string.gmatch( Line, "([a-zA-Z0-9_]+)" ) do
					local Lua = Compiler:DefineVariable( )

					NewLine[ #NewLine + 1 ] = Lua

					Definitions[ "@" .. Name ] = Lua
				end

				local Insert = Assigned and table.concat( NewLine, "," ) or " "
				
				OpPrepare = string.sub( OpPrepare, 1, Start - 1 ) .. Insert .. string.sub( OpPrepare, End - 1 )
			end

			OpPrepare = string.gsub( OpPrepare, "(@[a-zA-Z0-9_]+)", Definitions )
	
			OpPrepare = EXPADV.Interprit( Operator, Compiler, OpPrepare )
		end

		-- Now lets format the inline
		if Operator.FLAG == EXPADV_INLINE or Operator.FLAG == EXPADV_INLINEPREPARE then
			-- Replace the locals in our prepare!
			OpInline = string.gsub( OpInline, "(@[a-zA-Z0-9_]+)", Definitions )

			OpInline = EXPADV.Interprit( Operator, Compiler, OpInline )
		end

		if OpPrepare and OpPrepare ~= "" then
			Preperation[#Preperation + 1] = OpPrepare
		end

		local PreperedLines = #Preperation >= 1 and table.concat( Preperation, "\n" ) or nil

		return Compiler:NewLuaInstruction( Trace, Operator, PreperedLines, OpInline )
	end
end