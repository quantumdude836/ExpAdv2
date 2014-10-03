/* --- --------------------------------------------------------------------------------
	@: Utility Component
   --- */

local Component = EXPADV.AddComponent( "utility", true )

/* --- --------------------------------------------------------------------------------
	@: Add A user hook system, They can add hooks to extend events, manualy.
	@: This add no default hook, and shall encourage poeple to add there own.
   --- */

Component:AddVMFunction( "hookAdd", "s,s,d", "", function( Context, Trace, Hook, Name, Function )
		local Data = Context.Data
		local Hooks = Data.hooks

		if !Hooks then
			Hooks = { }
			Data.hooks = Hooks
		end

		if !Hooks[Hook] then Hooks[Hook] = { } end

		Hooks[Hook][Name] = Function
	end )

Component:AddVMFunction( "hookRemove", "s,s", "", function( Context, Trace, Hook, Name )
		local Hooks = Context.Data.hooks

		if !Hooks or !Hooks[Hook] then return end

		Hooks[Hook][Name] = nil
	end )

Component:AddVMFunction( "hookCall", "s,...", "", function( Context, Trace, Hook, ... )
		local Hooks = Context.Data.hooks

		if !Hooks or !Hooks[Hook] then return end

		for _, Delegate in pairs( Hooks[Hook] ) do
			Delegate( Context, ... )
		end
	end )

Component:AddFunctionHelper( "hookAdd", "s,s,d", "Adds a user defined hook with a unique name, witch will run the delagte when called." )
Component:AddFunctionHelper( "hookRemove", "s,s", "Removes a user defined hook with the given unique name." )
Component:AddFunctionHelper( "hookCall", "s,...", "Calls the named hook, passing its arguments to all hooks defined using hookAdd(n,n,d)." )

/* --- --------------------------------------------------------------------------------
	@: Add a simple timer system.
   --- */

Component:AddVMFunction( "timerCreate", "s,n,n,d,...", "", function( Context, Trace, Name, Delay, Reps, Delegate, ... )
		local Data = Context.Data
		Data.Timers = Data.Timers or { }

		Data.Timers[Name] = {
			Trace = Trace,
			Delay = Delay,
			Next = CurTime( ) + Delay,
			Paused = false,
			Reps = Reps,
			Count = 0,
			Delegate = Delegate,
			Inputs = { ... },
		}
	end )

EXPADV.AddFunctionAlias( "timerCreate", "s,n,n,d" )

Component:AddVMFunction( "timerStop", "s", "", function( Context, Trace, Name )
		local Data = Context.Data
		
		if !Data.Timers then return end

		Data.Timers[Name] = nil
	end )

Component:AddVMFunction( "timerPause", "s", "", function( Context, Trace, Name )
		local Data = Context.Data
		
		if !Data.Timers or !Data.Timers[Name] then return end

		Data.Timers[Name].Paused = true
	end )

Component:AddVMFunction( "timerResume", "s", "", function( Context, Trace, Name )
		local Data = Context.Data
		
		if !Data.Timers or !Data.Timers[Name] then return end

		Data.Timers[Name].Paused = false
	end )

Component:AddFunctionHelper( "timerCreate", "s,n,n,d,...", "Add a timer, with a unique name (Params: Name, Delay, Repitions, Delegate, Pass Though ... )" )
Component:AddFunctionHelper( "timerStop", "s", "Removes the timer with then given name." )
Component:AddFunctionHelper( "timerPause", "s", "Pauses the timer with then given name." )
Component:AddFunctionHelper( "timerResume", "s", "Resumed the timer with then given name." )

hook.Add( "Think", "expadv.timers", function( )
	
	for _, Context in pairs( EXPADV.CONTEXT_REGISTERY ) do
		if !Context.Online then continue end

		local Timers = Context.Data.Timers
		if !Timers then return end

		local Count, time = 0, CurTime( )

		for Name, Timer in pairs( Timers ) do
			Count = Count + 1

			if Timer.Paused then continue end

			if time <= Timer.Next then

				Timer.Next = time + Timer.Delay

				if Timer.Reps != 0 then
					Timer.Count = Timer.Count + 1

					if Timer.Count > Timer.Reps then
						Timers[Name] = nil
					end
				end

				Context:Execute( "Timer " .. Name, Timer.Delegate, Context, Timer.Inputs and unpack( Timer.Inputs ) or nil )

			end

			if Count > 100 then break end
		end

		if Count > 100 then 
			-- Todo: Error this entity!
		end
	end
end )

/* --- --------------------------------------------------------------------------------
	@: Need some time functions.
   --- */

Component:AddInlineFunction( "curTime", "", "n", "$CurTime( )" )

Component:AddInlineFunction( "realtime", "", "n", "$RealTime( )" )

Component:AddInlineFunction( "sysTime", "", "n", "$SysTime( )" )

Component:AddInlineFunction( "time", "s", "n", "$tonumber( $os.date(\"!*t\")[ @value 1 ] or 0 )" )
