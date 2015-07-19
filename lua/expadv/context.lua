/* --- --------------------------------------------------------------------------------
	@: Create A Context object
   --- */

EXPADV.RootContext = { __deph = 0 }

EXPADV.RootContext.__index = EXPADV.RootContext

/* --- --------------------------------------------------------------------------------
	@: A few things that we need local.
   --- */

pcall = pcall
setmetatable = setmetatable

/* --- --------------------------------------------------------------------------------
	@: Now we need a way to build this object
   --- */
   
-- Builds a new context from a compilers instance.
function EXPADV.BuildNewContext( Instance, Player, Entity ) -- Table, Player, Entity
	local Context = setmetatable( { player = Player, entity = Entity, Online = false }, EXPADV.RootContext )

	Context.Trigger = { }
	Context.TrigMan = { }
	Context.Changed = { }

	Context.Memory = {  }
	Context.Delta = {  }

	Context.Data = { }
	Context.Definitions = { }
	
	Context.Cells = Instance.Cells or { }
	Context.Strings = Instance.Strings or { }
	Context.Traces = Instance.Traces or { }
	Context.Instructions = Instance.VMInstructions or { }
	Context.Enviroment = Instance.Enviroment or error( "No safe guard.", 0 )

	Context.Status = {
		Soft = 0,
		Tick = 0,
		Tick_Counter = 0,
		Average = 0,
		Memory = 0,
	}

	return Context
end

/* --- --------------------------------------------------------------------------------
	@: SandBox
   --- */
function EXPADV.RootContext:SandBox()
	local Env = {}
	for k,v in pairs(self.Enviroment) do Env[k] = v end
	return setmetatable(Env, EXPADV.BaseEnv)
end

/* --- --------------------------------------------------------------------------------
	@: Executeion
   --- */

EXPADV.Updates = { }

local SysTime = SysTime
local debug_sethook = debug.sethook

-- Has to be called before an execution,
-- All quota managment depends on this!
function EXPADV.RootContext:PreExecute(op_counter)
	local Status = self.Status

	if !op_counter then
		op_counter = function( )
			if (SysTime() - Status.BenchMark) * 1000000 > expadv_tick_cpu then
				debug.sethook()
				error( { Trace = {0,0}, Quota = true, Msg = Message, Context = Context }, 0 )
			end
		end
	end

	Status.HookFunc = op_counter
	Status.MemoryMark = collectgarbage("count")
	Status.BenchMark = SysTime( )
	debug_sethook( op_counter, "", 500 )
end

-- Should always be called after an execution.
-- Otherwise things will break.
function EXPADV.RootContext:PostExecute()
	debug_sethook( )

	local Status = self.Status
	Status.Tick = Status.Tick + (SysTime() - Status.BenchMark)
	Status.Memory = Status.Memory + (collectgarbage("count") - Status.MemoryMark)
end

function EXPADV.RootContext:CheckExecutionQuota()
	local Status = self.Status

	if Status.Tick * 1000000 > expadv_tick_cpu then

		if IsValid( self.entity ) then self.entity:HitTickQuota( ) end
		
		self:ShutDown( true )

		return false

	elseif Status.Memory > expadv_memorylimit then
		self.entity:ScriptError( "Memory limit exceeded" )

		self:ShutDown( true )

		return false
	end

	return true
end

-- Handels the results from an execution.
-- PostExecute should always be called before this.
function EXPADV.RootContext:HandelResult(Ok, Result, ResultType)
	if !Ok and isstring( Result ) then
		if IsValid( self.entity ) then -- This is the only way, :(
			if Result:find("attempt to perform arithmetic on a nil value") then
				Result = "attempt to perform arithmetic on void"
			elseif Result:find("attempt to index a nil value") then
				Result = "attempt to reach void"
			elseif Result:find("attempt to call a nil value") then
				Result = "attempt to call void"
			end

			self.entity:ScriptError( Result )
		end
		
		self:ShutDown( )

		return false
	end

	if !Ok and Result.Terminate then
		return false
	end

	if Ok or Result.Exit then
		if !self:CheckExecutionQuota() then return false end
		
		EXPADV.Updates[self] = true

		return true, Result, ResultType
	end

	if !IsValid( self.entity ) then
		-- Do nothing :P
	elseif Result.Quota then
		self.entity:HitTickQuota( )
	elseif Result.Script then
		self.entity:ScriptError( Result )
	elseif Result.Exception then
		self.entity:Exception( Result )
	end

	self:ShutDown( )

	return false
end

-- Safely execute a function on this context.
function EXPADV.RootContext:Execute( Location, Operation, ... ) -- String, Function, ...
	self:PreExecute()

	local Ok, Result, ResultType = pcall( Operation, self, ... )

	self:PostExecute()

	return self:HandelResult(Ok, Result, ResultType)
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Call Event
   --- */

function EXPADV.RootContext:CallEvent( Name, ... )	
	if !self.Online then return false, nil end

	local Event = self[ "event_" .. Name ]
	
	if !Event then return end

	return self:Execute( "Event " .. Name, Event, ... )
end

/* --- --------------------------------------------------------------------------------
	@: Breakouts
   --- */

-- Exits the currently executing code.
function EXPADV.RootContext:Exit( )
	error( { Exit = true, Context = self }, 0 )
end

-- Used to shut down the gate internally.
function EXPADV.RootContext:Terminate( )
	error( { Terminate = true, Context = self }, 0 )
end

-- Throws an exception
function EXPADV.RootContext:Throw( Trace, Name, Message ) -- Table, String, String
	error( { Trace = Trace, Exception = Name, Msg = Message, Context = self }, 0 )
end

-- Throws a script error, and shuts down the context.
function EXPADV.RootContext:ScriptError( Trace, Message ) -- Table, String
	error( { Trace = Trace, Script = true, Msg = Message, Context = self }, 0 )
end

/* --- --------------------------------------------------------------------------------
	@: Staring / Stopping
   --- */

-- Runs the root execution of the code.
function EXPADV.RootContext:StartUp( Execution ) -- Function
	self.Online = true

	EXPADV.RegisterContext( self )

	EXPADV.CallHook( "StartUp", self )

	if IsValid( self.entity ) then self.entity:StartUp( ) end

	local ok, a, b = self:Execute( "Root", Execution, self )
	if !ok then return ok, a, b end

	EXPADV.CallHook( "PostStartUp", self )
	return ok, a, b
end

-- Shuts down the context and execution.
function EXPADV.RootContext:ShutDown( bNoLast )
	if !self.Online then return end

	if not bNoLast then self:CallEvent("last") end 

	self.Online = false

	EXPADV.UnregisterContext( self )

	EXPADV.CallHook( "ShutDown", self )

	if IsValid( self.entity ) then self.entity:ShutDown( ) end
end

/* --- --------------------------------------------------------------------------------
	@: Context registery.
--- */
   
local Registery = EXPADV.CONTEXT_REGISTERY or { }

EXPADV.CONTEXT_REGISTERY = Registery

function EXPADV.RegisterContext( Context )
	Registery[Context] = Context

	EXPADV.CallHook( "RegisterContext", Context )
end

function EXPADV.UnregisterContext( Context )
	Registery[Context] = nil

	EXPADV.CallHook( "UnregisterContext", Context )
end

/* --- --------------------------------------------------------------------------------
	@: Context Updating.
   --- */

hook.Add( "Tick", "ExpAdv2.Update", function( )
	for Context, _ in pairs( EXPADV.Updates ) do
		if !IsValid( Context.entity ) then continue end

		local Ok, Msg = pcall( Context.entity.UpdateTick, Context.entity )

		if !Ok then
			Context.entity:LuaError( Msg )
			Context:ShutDown( )
		else
			EXPADV.CallHook( "UpdateContext", Context )
		end
	end

	EXPADV.CallHook( "PostUpdateAll", EXPADV.Updates )

	EXPADV.Updates = { }
end )

/* --- --------------------------------------------------------------------------------
	@: Context Monitoring.
   --- */

EXPADV_STATE_COMPILE = -1
EXPADV_STATE_OFFLINE = 0
EXPADV_STATE_ONLINE = 1
EXPADV_STATE_ALERT = 2
EXPADV_STATE_CRASHED = 3
EXPADV_STATE_BURNED = 4

local NextHook = 0

hook.Add( "Tick", "ExpAdv2.Performance", function( )
	if CurTime() > NextHook then
		NextHook = CurTime() + 0.030303

		for Context, _ in pairs( EXPADV.CONTEXT_REGISTERY ) do
			if !Context.Online then continue end
			
			if IsValid(Context.entity) and Context.entity.CalculateOps then
				Context.entity.CalculateOps(Context.entity, Context)
			end
		end
	end
end )


/* --- --------------------------------------------------------------------------------
	@: Reloading.
   --- */

hook.Add( "Expadv.UnloadCore", "expadv.context", function( )
	for Context, _ in pairs( Registery ) do
		Context:ShutDown( )
	end
end )
