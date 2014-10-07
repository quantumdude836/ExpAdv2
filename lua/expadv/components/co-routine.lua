/* --- --------------------------------------------------------------------------------
    @: Resume
   --- */

local function resume( Context, Coroutine, ... )
	return coroutine.resume( Coroutine, ... )
end

/* --- --------------------------------------------------------------------------------
    @: Coroutine Component
   --- */

local Component = EXPADV.AddComponent( "Coroutine" , true )

Component:AddException( "coroutine" )

local CoRoutine = Component:AddClass( "coroutine" , "cr" )

CoRoutine:StringBuilder( function( Obj ) return "Coroutine" end )

EXPADV.SharedOperators( )

CoRoutine:AddPreparedOperator( "=", "n,cr", "", "Context.Memory[@value 1] = @value 2" )

/* --- --------------------------------------------------------------------------------
    @: Functions
   --- */

Component:AddVMFunction( "coroutine", "d", "cr",
	function( Context, Trace, Delegate )
		return coroutine.create( function( ... )
			Delegate( Context, ... )
		end )
	end )

Component:AddInlineFunction( "status", "cr:", "s", "$coroutine.status( @value 1 )" )

Component:AddInlineFunction( "getCoroutine", "", "cr", [[( $coroutine.running( ) or Context:Throw( @trace, "coroutine", "Used getCoroutine( ) outside coroutine." ) )]] )

Component:AddPreparedFunction( "resume", "cr:", "b", "Context.Status.BenchMark = $SysTime( )", "$coroutine.resume( @value 1 )" )

Component:AddPreparedFunction( "resume", "cr:...", "b", "Context.Status.BenchMark = $SysTime( )", "$coroutine.resume( @value 1, @... )" )

Component:AddPreparedFunction( "yield", "", "", [[if !$coroutine.running( ) then Context:Throw( @trace, "coroutine", "Used yield( ) outside coroutine." ) else yield( ) end]] )

Component:AddVMFunction( "sleep", "n", "",
	function( Context, Trace, Value )
		local CoRoutine = coroutine.running( )
		if !CoRoutine then Context:Throw( Trace, "coroutine", "Used sleed( N ) outside coroutine." ) end
		
		timer.Simple( Value, function( )
			if !IsValid( Context.entity ) or !Context.entity:IsRunning( ) then return end
			
			Context:Execute( nil, resume, CoRoutine )
		end )

		coroutine.yield( )
	end )

/* --- --------------------------------------------------------------------------------
    @: This is where we get hacky :D
   --- */

Component.Queue = { }

function Component:OnPostEvent( Flag, A, B, ... )
	local Name, Player, RunOn = A

	if Flag > EXPADV_EVENT_NORMAL then
		Name, Player = B, A
	end

	local Queue = self.Queue[Name]
	if !Queue or #Queue == 0 then return end

	local NewQueue = { }

	for I = 1, #Queue do
		local Context = Queue[I].Context

		if !IsValid( Context.entity ) or !Context.entity:IsRunning( ) then continue end

		if (Player and Player ~= Context.player) then
			table.insert( NewQueue, Queue[I] )
			continue
		end

		Context:Execute( nil, resume, Queue[I].Coroutine )
	end

	self.Queue[Name] = #NewQueue > 0 and NewQueue or nil
end


Component:AddVMFunction( "wait", "s", "",
	function( Context, Trace, Value )
		local CoRoutine = coroutine.running( )

		if !CoRoutine then Context:Throw( Trace, "coroutine", "Used sleed( N ) outside coroutine." ) end
		
		if !EXPADV.Events[ Name ] then Context:Throw( Trace, "coroutine", "No such event " .. Name ) end

		local Queue = Component.Queue[Name]

		if !Queue then Queue = { }; Component.Queue[Name] = Queue end

		table.insert( Queue, { Context = Context, Coroutine = CoRoutine } )

		coroutine.yield( )
	end )


		