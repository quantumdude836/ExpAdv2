local Component = EXPADV.AddComponent( "Coroutine" , true )

Component.Author = "Rusketh"

Component.Description = "Adds coroutines that you can yield and resume."

/*--------------------------------------------------------------------------------------------------------------------*/

local create = coroutine.create
local resume = coroutine.resume
local yield = coroutine.yield
local wait  = coroutine.wait
local status = coroutine.status

/*--------------------------------------------------------------------------------------------------------------------*/

Component:AddException( "coroutine" )

local function throw(Context, Trace, Where)
	Context:Throw(Trace, "coroutine", "Tryed to " .. Where .. " outside of coroutine.")
end

/*--------------------------------------------------------------------------------------------------------------------*/

local PauseThread

local _context, _running, _ops, _ex = nil, nil, false, false

EXPADV.coroutine = {}

EXPADV.coroutine.context = function() return _context end

EXPADV.coroutine.running = function() return _running end

EXPADV.coroutine.needsops = function() return _ops end

/*--------------------------------------------------------------------------------------------------------------------*/

EXPADV.SharedOperators( )

Component:AddInlineFunction("isDead", "cr:", "b", "($coroutine.status(@value 1) == \"dead\")")

Component:AddInlineFunction("isSuspended", "cr:", "b", "($coroutine.status(@value 1) == \"suspended\")")

Component:AddInlineFunction("isRunning", "cr:", "b", "($coroutine.status(@value 1) == \"running\")")

/*--------------------------------------------------------------------------------------------------------------------*/

local CreateThread = function(Context, Trace, Function)
	return create(function(...) return Function(Context, ...) end)
end

Component:AddVMFunction("coroutine", "d", "cr", CreateThread)

/*--------------------------------------------------------------------------------------------------------------------*/

local ResumeThread = function(Context, Trace, Thread, ...)
	local c, t, o = _context, _running, _ops

	_context, _running, _ops = Context, Thread, false

	coroutine.wait = PauseThread

	local b, e = resume(Thread, ...)

	if !b then
		if isstring(e) then Context:Throw(Trace, "coroutine", e) end
		error(e, 0)
	end

	coroutine.wait = wait

	_context, _running, _ops = c, t, o
end

EXPADV.coroutine.resume = function(c, t, ...) return ResumeThread(c, nil, t,...) end

Component:AddVMFunction("resume", "cr:", "", ResumeThread)

Component:AddVMFunction("resume", "cr:...", "", ResumeThread)

/*--------------------------------------------------------------------------------------------------------------------*/

-- Used to run code from an external thread like nextbot.
-- This will use the origonal coroutine.wait and prevent invalid use.

EXPADV.coroutine.resume2 = function(c, t, ...)
	local e = _ex
	
	e = true

	ResumeThread(c, nil, t,...)

	_ex = e
end

/*--------------------------------------------------------------------------------------------------------------------*/

local ExecuteThread = function (Context, Thread, ...)
	local c, t, o = _context, _running, _ops

	_context, _running, _ops = Context, Thread, true
	
	coroutine.wait = PauseThread

	Context:PreExecute()

	local ok, res, typ = pcall( resume, Thread, ... )

	Context:PostExecute()

	local _, b = Context:HandelResult(ok, res, typ)

	coroutine.wait = wait

	_context, _running, _ops = c, t, o

	return b or false
end

EXPADV.coroutine.execute = ExecuteThread

/*--------------------------------------------------------------------------------------------------------------------*/

Component:AddVMFunction("inCoroutine", "", "b", function(Context, Trace)
	if !_running then return false end
	return true
end)

Component:AddVMFunction("getCoroutine", "", "cr", function(Context, Trace)
	if !_running then throw(Context, Trace, "getCoroutine") end
	return _running
end)

/*--------------------------------------------------------------------------------------------------------------------*/

local YieldThread = function()
	if _ops then
		_context:PostExecute()
		if !_context:CheckExecutionQuota() then
			_context:Terminate()
		end
	end

	yield()

	if _ops then
		_context:PreExecute()
	end
end

EXPADV.coroutine.yield = YieldThread

Component:AddVMFunction("yield", "", "b", function(Context, Trace)
	if !_running then throw(Context, Trace, "yield") end
	YieldThread()
end)

/*--------------------------------------------------------------------------------------------------------------------*/

PauseThread = function(time)
	if _ops then
		_context:PostExecute()
		if !_context:CheckExecutionQuota() then
			_context:Terminate()
		end
	end

	wait(time)

	if _ops then
		_context:PreExecute()
	end
end

EXPADV.coroutine.wait = PauseThread

/*--------------------------------------------------------------------------------------------------------------------*/

Component:AddVMFunction( "sleep", "n", "", function(Context, Trace, Time)
	local thread = _running

	if !thread then throw(Context, Trace, "sleep") end

	-- This thread is from nextbot or somthing.
	if _ex then return PauseThread(Time) end

	timer.Simple( Time, function( )
		if IsValid(Context.entity) and Context.entity:IsRunning( ) then
			ExecuteThread(Context, thread)
		end
	end )

	YieldThread()
end )

/*--------------------------------------------------------------------------------------------------------------------*/

local _waiting = {}

EXPADV.coroutine.getwaiting = function(event) return _waiting[event] end

Component:AddVMFunction( "wait", "s", "", function( Context, Trace, Event )
	local thread = _running

	if !thread then throw(Context, Trace, "sleep") end
	
	if _ex then Context:Throw(Trace, "coroutine", "Tryed to wait outside of waitable coroutine.") end

	if !EXPADV.Events[Event] then Context:Throw( Trace, "coroutine", "Tryed to wait for non existing event " .. Event .. ".") end

	local tbl = _waiting[Event]

	if !tbl then
		tbl = {}
		_waiting[Event] = tbl
	end
	
	tbl[#tbl + 1] = {
		context = _context,
		thread = _running
	}

	YieldThread()
end )

hook.Add("Expadv.PostEvent", "expadv.threads", function(flag, name, first, ...)
	local ply = nil

	if flag > EXPADV_EVENT_NORMAL then ply, name = name, first end
	
	local tbl = _waiting[Event]

	if tbl then
		for i = 1, #tbl do
			local v = tbl[i]

			if IsValid(v.context.entity) and v.context.entity:IsRunning( ) then
				ExecuteThread(v.context, v.thread)
			end
		end

		_waiting[Event] = nil
	end
end)

/*--------------------------------------------------------------------------------------------------------------------*/

Component:AddFunctionHelper( "coroutine", "d", "Creates a coroutine of the given function." )
Component:AddFunctionHelper( "sleep", "n", "Pauses the current coroutine for N seconds." )
Component:AddFunctionHelper( "wait", "s", "Pauses the current coroutine until event S is called." )
Component:AddFunctionHelper( "getCoroutine", "", "Returns the current coroutine or throws exception." )
Component:AddFunctionHelper( "inCoroutine", "", "Returns true is executing inside a coroutine." )
Component:AddFunctionHelper( "yield", "", "Yields the current coroutine to be resumed later." )
Component:AddFunctionHelper( "resume", "cr:", "Resumes/starts a coroutine." )
Component:AddFunctionHelper( "resume", "cr:...", "Resumes/start the given coroutine and passes the given params." )
Component:AddFunctionHelper( "status", "cr:", "Returns the status of a coroutine." )

/*--------------------------------------------------------------------------------------------------------------------*/

local Class = Component:AddClass( "coroutine" , "cr" )

Class:StringBuilder( function( Obj ) return "Coroutine" end )

Class:AddPreparedOperator( "=", "n,cr", "", "Context.Memory[@value 1] = @value 2" )