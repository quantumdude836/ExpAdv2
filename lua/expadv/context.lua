/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Create A Context object
   --- */

EXPADV.RootContext = { }

EXPADV.RootContext.__index = EXPADV.RootContext

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Now we need a way to build this object
   --- */

function EXPADV.BuildNewContext( Player, Entity )
	local Context = setmetatable( { player = Player, entity = Entity }, EXPADV.RootContext )

	Context.Memory = { }
	Context.Delta = { }
	Context.Trigger = { }
	Context.Changed = { }

	Context.Strings = { }
	Context.Dinfinitions = { }
	Context.VMInstructions = { }

	return Context
end

function EXPADV.RootContext:Push( Cells )
	-- if self.__deph > 50 then self:Throw( ) end -- TODO!

	local Memory = {
		__index = fucntion( Table, Key ) return Cells[Key] and rawget( Table, Key ) or self.Memory[Key] end,
		__newindex = fucntion( Table, Key, Value ) if Cells[Key] then rawset( Table, Key, Value ) else self.Memory[Key] = Value end
	}; setmetatable( Memory, Memory )

	local Delta = {
		__index = fucntion( Table, Key ) return Cells[Key] and rawget( Table, Key ) or self.Memory[Key] end,
		__newindex = fucntion( Table, Key, Value ) if Cells[Key] then rawset( Table, Key, Value ) else self.Memory[Key] = Value end
	}; setmetatable( Delta, Delta )

	local Changed = {
		__index = fucntion( Table, Key ) return Cells[Key] and rawget( Table, Key ) or self.Memory[Key] end,
		__newindex = fucntion( Table, Key, Value ) if Cells[Key] then rawset( Table, Key, Value ) else self.Memory[Key] = Value end
	}; setmetatable( Changed, Changed )

	local Context = {
		__deph = self.__deph + 1,
		__parent = self.__parent or self,
		__index = fucntion( Table, Key ) return rawget( Table, Key ) or self[Key] end,
		__newindex = fucntion( Table, Key, Value ) Table.__parent[Key] = Value end
	}; setmetatable( Context, Context )

	return Context
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: We call these before and after execution.
   --- */

function EXPADV.RootContext:PreExecute( )
	EXPADV.EXECUTOR = self

	-- TODO: Lua debug hook

	collectgarbage( "stop" )
end

function EXPADV.RootContext:PostExecute( )
	EXPADV.EXECUTOR = nil

	self.Dinfinitions = { }

	-- TODO: Remove Lua debug hook

	collectgarbage( "restart" )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: This is how we safly call executions.
   --- */

function EXPADV.RootContext:Execute( Location, Operation, ... )
	
	self:PreExecute( )

	--TODO:

	self:PostExecute( )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Context registery.
   --- */

