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

				Context:Execute( "Timer " .. Name, Timer.Delegate, Timer.Inputs and unpack( Timer.Inputs ) or nil )

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

/* --- --------------------------------------------------------------------------------
	@: Some useful array sorting functions
   --- */

Component:AddPreparedFunction( "sortByDistanceVectors", "a,v", "", [[
	if @value 1.__type ~= "v" then self:Throw( @trace, "invoke", "sortByDistanceEntitys #1, entity array exspected." ) end
	$table.sort( @value 1,
		function( A, B )
			return A:Distance( @value2 ) < B:Distance( @value2 )
		end )
	]])

/* --- --------------------------------------------------------------------------------
	@: Rangers
   --- */

local Ranger = Component:AddClass( "ranger", "rd" )

Ranger:AddPreparedOperator( "=", "n,rd", "", "Context.Memory[@value 1] = @value 2" )

local Ranger = { Default_Zero = false, Ignore_World = false, Hit_Water = false, Ignore_Entities = false, Mins = false, Maxs = false }
Ranger.Result = { }

Ranger.__index = Ranger

setmetatable( Ranger, Ranger )

function Ranger.__call(  )
	return setmetatable( { Filter = { } }, Ranger )
end

function Ranger:AddFilter( Entity )
	if IsValid( Entity ) then
		self.Filter[ Entity ] = true
	end
end

function Ranger:Unfilter( Entity )
	if IsValid( Entity ) then
		self.Filter[ Entity ] = nil
	end
end

function Ranger:DoTrace( Start, End, Distance )
	if Distance then
		End = Start + ( End:GetNormalized( ) * Distance )
	end
	
	self.Start = Start
	self.End = End
	
	local Filter = { }
	local Ignore_World = self.Ignore_World
	local TraceData = { start = Start, endpos = End, filter = Filter }
	
	if !self.FilterFunc then
		for Entity, _ in pairs( self.Filter ) do
			Filter[ #Filter + 1 ] = Entity
		end
	else
		Filter = self.FilterFunc
	end
	
	if self.Hit_Water then
		if !self.Ignore_Entities then
			TraceData.mask = -1
		elseif Ignore_World then
			Ignore_World = false
			TraceData.mask = MASK_WATER
		else
			TraceData.mask = Bor( MASK_WATER, CONTENTS_SOLID )
		end
	elseif self.Ignore_Entities then
		if Ignore_World then
			Ignore_World = false
			TraceData.mask = 0
		else
			TraceData.mask = MASK_NPCWORLDSTATIC
		end
	end
	
	local Trace
	
	if self.Mins and self.Maxs then
		TraceData.mins = self.Mins
		TraceData.maxs = self.Maxs
		
		Trace = TraceHull( TraceData )
	else
		Trace = TraceLine( TraceData )
	end
	
	if Ignore_World and Trace.HitWorld then
		Trace.HitPos = self.Default_Zero and Start or End
		Trace.HitWorld = false
		Trace.Hit = false
	elseif self.Default_Zero and !Trace.Hit then
		Trace.HitPos = Start
	end
	
	self.Result = Trace
end

function Ranger.__tostring( Table )
	return "Ranger"
end

Component:AddVMFunction( "ranger", "", "rd", function( ) return setmetatable( { Filter = { } }, Ranger ) end )

-- Set up a ranger.
Component:AddPreparedFunction( "ignoreEntities", "rd:b", "", "@value 1.Ignore_Entities = @value 2" )

Component:AddPreparedFunction( "defaultZero", "rd:b", "", "@value 1.Default_Zero = @value 2" )

Component:AddPreparedFunction( "ignoreWorld", "rd:b", "", "@value 1.Ignore_World = @value 2" )

Component:AddPreparedFunction( "hitWater", "rd:b", "", "@value 1.Hit_Water = @value 2" )

-- Get
Component:AddPreparedFunction( "ignoreEntities", "rd:", "b", "@value 1.Ignore_Entities" )

Component:AddPreparedFunction( "defaultZero", "rd:", "b", "@value 1.Default_Zero" )

Component:AddPreparedFunction( "ignoreWorld", "rd:", "b", "@value 1.Ignore_World" )

Component:AddPreparedFunction( "hitWater", "rd:", "b", "@value 1.Hit_Water" )

-- Hull Trace
Component:AddPreparedFunction( "setHull", "rd:v,v", "", [[
	@value 1.Mins = @value 2
	@value 1.Maxs = @value 3
]] )

Component:AddPreparedFunction( "noHull", "rd:", "", [[
	@value 1.Mins = false
	@value 1.Maxs = false
]] )

Component:AddInlineFunction( "mins", "rd:", "v", "( @value 1.Mins or Vector( 0, 0, 0 ) )" )

Component:AddInlineFunction( "maxs", "rd:", "v", "( @value 1.Maxs or Vector( 0, 0, 0 ) )" )

-- Do Trace

Component:AddPreparedFunction( "fire", "rd:v,v", "", "@value 1:DoTrace( @value 2, @value 3 )" )

Component:AddPreparedFunction( "fire", "rd:v,v,n", "", "@value 1:DoTrace( @value 2, @value 3, @value 4 )" )

Component:AddPreparedFunction( "fire", "rd:", "", [[
if ( @value 1.Start and @value 1.End ) then
	@value 1:DoTrace( @value 1.Start, @value 1.End )
end]] )

-- Start and End

Component:AddInlineFunction( "start", "rd:", "v", "(@value 1.Start or Vector( 0, 0, 0 ))" )

Component:AddInlineFunction( "end", "rd:", "v", "(@value 1.End or Vector( 0, 0, 0 ))" )

-- Filter

Component:AddPreparedFunction( "filter", "rd:e", "", "@value 1:AddFilter( @value 2 )" )

Component:AddPreparedFunction( "unfilter", "rd:e", "", "@value 1:Unfilter( @value 2 )" )

Component:AddPreparedFunction( "clearFilter", "rd:", "", "@value 1.Filter = { }\n@value 1.FilterFunc = nil" )

Component:AddInlineFunction( "setFilter", "rd:d", "", "@value 1.FilterFunc = @value 2" )

-- Results:

Component:AddInlineFunction( "entity", "rd:", "e", "( @value 1.Result.Entity or Entity(0) )" )

-- Boolean
	Component:AddInlineFunction( "hit", "rd:", "b", "( @value 1.Result.Hit or false )" )

	Component:AddInlineFunction( "hitSky", "rd:", "b", "( @value 1.Result.HitSky or false )" )
	
	Component:AddInlineFunction( "hitNoDraw", "rd:", "b", "( @value 1.Result.HitNoDraw or false )" )

	Component:AddInlineFunction( "hitWorld", "rd:", "b", "( @value 1.Result.HitWorld or false )" )

	Component:AddInlineFunction( "hitNoneWorld", "rd:", "b", "( @value 1.Result.HitNonWorld or false )" )
	
	Component:AddInlineFunction( "startSolid", "rd:", "b", "( @value 1.Result.StartSolid or false )" )

-- Vector
	Component:AddInlineFunction( "hitPos", "rd:", "v", "( @value 1.Result.HitPos or Vector( 0, 0, 0 ) )" )

	Component:AddInlineFunction( "hitNormal", "rd:", "v", "( @value 1.Result.HitNormal or Vector( 0, 0, 0 ) )" )

	Component:AddInlineFunction( "normal", "rd:", "v", "( @value 1.Result.Normal or Vector( 0, 0, 0 ) )" )

-- Number
	
	Component:AddInlineFunction( "fraction", "rd:", "n", "( @value 1.Result.Fraction or 0 )" )
	
	Component:AddInlineFunction( "fractionLeftSolid", "rd:", "n", "( @value 1.Result.FractionLeftSolid or 0 )" )
	
	Component:AddInlineFunction( "hitGroup", "rd:", "n", "( @value 1.Result.HitGroup or 0 )" )
	
	Component:AddInlineFunction( "hitBox", "rd:", "n", "( @value 1.Result.HitBox or 0 )" )
	
	Component:AddInlineFunction( "hitPhysics", "rd:", "n", "( @value 1.Result.PhysicsBone or 0 )" )
	
	Component:AddInlineFunction( "hitBoxbone", "rd:", "n", "( @value 1.Result.HitBoxBone or 0 )" )
	
	Component:AddInlineFunction( "materialType", "rd:", "n", "( @value 1.Result.MatType or 0 )" )
	
	Component:AddInlineFunction( "distance", "rd:", "n", "@value 1.Start:Distance( @value 1.Result.HitPos or @value 1.Start )" )
	
-- String
	
	Component:AddInlineFunction( "hitTexture", "rd:", "s", "( @value 1.Result.HitTexture or \"\" )" )

-- Clear

Component:AddPreparedFunction( "clear", "rd:", "", "@value 1.Result = nil" )

/* --- --------------------------------------------------------------------------------
	@: HTTP
   --- */

Component:AddPreparedFunction( "httpRequest", "s,d,d", "", [[$http.Fetch( @value 1,
	function( Body )
		Context:Execute( "http success callback", @value 2, { Body, "s" } )
	end, function( )
		Context:Execute( "http fail callback", @value 1 )
	end
)]] )

Component:AddPreparedFunction( "httpPostRequest", "s,t,d,d", "", [[$http.Post( @value 1, @value 2.Data,
	function( Body )
		Context:Execute( "http success callback", @value 3, { Body, "s" } )
	end, function( )
		Context:Execute( "http fail callback", @value 4 )
	end
)]] )