/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Events
   --- */

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Events
   --- */

local Temp_Events = { }

function EXPADV.AddEvent( Component, Name, Input, Return )
	Temp_Events[ #Temp_Events + 1 ] = {  
		LoadOnClient = LoadOnClient,
		LoadOnServer = LoadOnServer,
		
		Component = Component,
		Name = Name,
		Input = Input,
		Return = Return
	}
end

function EXPADV.LoadEvents( )
	EXPADV.Events = { }

	for I = 1, #Temp_Events do
		local Event = Temp_Events[I]

		-- Checks if the operator requires an enabled component.
		if Event.Component and !Event.Component.Enabled then continue end

		-- First of all, Check the return type!
		if Event.Return and Event.Return == "" then
			Event.Return = nil
		elseif Event.Return and Event.Return == "..." then
			MsgN( string.format( "Skipped event %s, can not return var arg.", Event.Name ) )
			continue
		else
			local Class = EXPADV.GetClass( Event.Return, false, true )
			
			if !Class then 
				MsgN( string.format( "Skipped event: %s(%s), Invalid return class %s.", Event.Name, Event.Input, Event.Return ) )
				continue
			end

			if !Class.LoadOnServer and Event.LoadOnServer then
				MsgN( string.format( "Skipped event: %s(%s), return class %s is not avalible on server.", Event.Name, Event.Input, Event.Return ) )
				continue
			elseif !Class.LoadOnClient and Event.LoadOnClient then
				MsgN( string.format( "Skipped event: %s(%s), return class %s is not avalible on clients.", Event.Name, Event.Input, Event.Return ) )
				continue
			end

		end

		-- Second we check the input types, and build our signatures!
		local ShouldNotLoad = false

		if Event.Input and Event.Input ~= "" then
			local Signature = { }

			for I, Input in pairs( string.Explode( ",", Event.Input ) ) do

				-- First lets check for varargs.
				if Input == "..." then
					MsgN( string.format( "Skipped event: %s(%s), vararg (...) must not appear inside event parameters.", Operator.Name, Operator.Input ) )
					break
				end

				-- Next, check for valid input classes.
				local Class = EXPADV.GetClass( Input, false, true )
				
				if !Class then 
					MsgN( string.format( "Skipped event: %s(%s), Invalid class for parameter #%i %s.", Event.Name, Event.Input, I, Input ) )
					ShouldNotLoad = true
					break
				end

				if !Class.LoadOnServer and Event.LoadOnServer then
					MsgN( string.format( "Skipped event: %s(%s), parameter #%i %s is not avalible on server.", Event.Name, Event.Input, I, Class.Name ) )
					ShouldNotLoad = true
					break
				elseif !Class.LoadOnClient and Event.LoadOnClient then
					MsgN( string.format( "Skipped event: %s(%s), parameter #%i %s is not avalible on clients.", Event.Name, Event.Input, I, Class.Name ) )
					ShouldNotLoad = true
					break
				end

				Signature[ I ] = Class.Short
			end

			Event.Input = Signature
			Event.InputCount = #Signature
			Event.Signature = string.format( "%s(%s)", Event.Name, table.concat( Signature, "" ) )
		else
			Event.Input = { }
			Event.InputCount = 0
			Event.Signature = string.format( "%s()", Event.Name )
		end

		-- Do we still need to load this?
		if ShouldNotLoad then continue end

		MsgN( "Registered Event: " .. Event.Signature )

		EXPADV.Events[ Event.Name ] = Event
	end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Event Interface
   --- */

function EXPADV.CallEvent( Name, ... )

end

function EXPADV.CallPlayerEvent( Player, Name, ... )
	
end

function EXPADV.CallPlayerReturnableEvent( Player, Name, ... )

end