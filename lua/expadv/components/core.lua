/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Client Print Operator
   --- */

if CLIENT then
	EXPADV.SharedOperators( )

	EXPADV.AddPreparedFunction( nil, "printColor", "...", "",[[
		-- if Context.player == $LocalPlayer( ) then
			@define Tbl = { @... }

			for K, Obj in pairs( @Tbl ) do
				if Obj[2] ~= "c" then
					@Tbl[K] = EXPADV.ToString( Obj[2], Obj[1] )
				else
					@Tbl[K] = Obj[1]
				end
			end

			$chat.AddText( $unpack( @Tbl ) )
		-- end
	]] )

	EXPADV.AddPreparedFunction( nil, "print", "...", "",[[
		if Context.player == $LocalPlayer( ) then
			@define Tbl = { @... }

			for K, Obj in pairs( @Tbl ) do
				@Tbl[K] = EXPADV.ToString( Obj[2], Obj[1] )
			end

			$chat.AddText( $unpack( @Tbl ) )
		end
	]] )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Server Print Operator
   --- */

if SERVER then
	EXPADV.SharedOperators( )
	
	EXPADV.AddPreparedFunction( nil, "printColor", "...", "",[[
		@define Tbl = { @... }
	
		for K, Obj in pairs( @Tbl ) do
			if Obj[2] ~= "c" then
				@Tbl[K] = EXPADV.ToString( Obj[2], Obj[1] )
			else
				@Tbl[K] = Obj[1]
			end
		end
	
		EXPADV.PrintColor( Context.player, @Tbl )
	]] )
	
	EXPADV.AddPreparedFunction( nil, "print", "...", "",[[
		@define Tbl = { @... }
	
		for K, Obj in pairs( @Tbl ) do
			@Tbl[K] = EXPADV.ToString( Obj[2], Obj[1] )
		end
	
		EXPADV.PrintColor( Context.player, @Tbl )
	]] )
end

if SERVER then
	util.AddNetworkString( "expadv.printcolor" )

	function EXPADV.PrintColor( Player, Tbl )
		net.Start( "expadv.printcolor" )
		net.WriteTable( Tbl )
		net.Send( Player )
	end

end

if CLIENT then
	net.Receive( "expadv.printcolor", function( )
		chat.AddText( unpack( net.ReadTable( ) ) )
	end )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Define boolean class
   --- */

EXPADV.SharedOperators( )

local Boolean = EXPADV.AddClass( nil, "boolean", "b" )
	  
	  Boolean:AddAlias( "bool" )

	  Boolean:DefaultAsLua( false )

if WireLib then
	Boolean:WireInput( "NUMBER", function( Context, MemoryRef )
		return Context.Memory[ MemoryRef ] and 1 or 0
	end ) 

	Boolean:WireOutput( "NUMBER", function( Context, MemoryRef, InValue )
		Context.Memory[ MemoryRef ] = (InValue ~= 0)
	end )
end

Boolean:AddVMOperator( "=", "n,b", "", function( Context, Trace, MemRef, Value )
	local Prev = Context.Memory[MemRef]
	Context.Memory[MemRef] = Value

	Context.Trigger[MemRef] = Context.Trigger[MemRef] or ( Prev ~= Value )
end )

EXPADV.AddInlineOperator( nil, "==", "b,b", "b", "(@value 1 == @value 2)" )
EXPADV.AddInlineOperator( nil, "!=", "b,b", "b", "(@value 1 != @value 2)" )

EXPADV.AddInlineOperator( nil, "is", "b", "b", "@value 1" )
EXPADV.AddInlineOperator( nil, "not", "b", "b", "!@value 1" )

EXPADV.AddInlineOperator( nil, "||", "b,b", "b", "(@value 1 or @value 2)" )

EXPADV.AddInlineOperator( nil, "&&", "b,b", "b", "(@value 1 and @value 2)" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Register variant class!
   --- */

local Variant = EXPADV.AddClass( nil, "variant", "vr" )
		
	  Variant:DefaultAsLua( { false, "b" } )

Variant:AddInlineOperator( "=", "n,vr", "", "Context.Memory[@Value 1] = @value 2" )

hook.Add( "Expadv.PostRegisterClass", "expad.variant", function( Name, Class )
	if !Class.LoadOnClient then
		EXPADV.ServerOperators( )
	elseif !Class.LoadOnServer then
		EXPADV.ClientOperators( )
	else EXPADV.SharedOperators( ) end

	EXPADV.AddInlineOperator( nil, "variant", Class.Short, "vr", "{ @value 1, @type 1 }" )

	EXPADV.AddInlineOperator( nil, Name, "vr", Class.Short, string.format( "( @value 1[2] == %q and @value 1[1] or Context:Throw(@trace, %q, \"Attempt to cast value \" .. EXPADV.TypeName(@value 1[2]) .. \" to %s \") )", Class.Short, "cast", Name ) )
end )	



/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Define function class
   --- */

EXPADV.SharedOperators( )

local FunctionClass = EXPADV.AddClass( nil, "function", "f" )
	  
FunctionClass:DefaultAsLua( "function( ) end" )

FunctionClass:AddPreparedOperator( "=", "n,f", "", "Context.Memory[@value 1] = @value 2" )

EXPADV.AddPreparedOperator( nil, "call", "f,s,...", "_vr", [[
	@define Return, Type = @value 1(@...)
	if @value 2 and @Type ~= @value 2 then
		Context:Throw( @trace, "invoke", string.format( "Invalid return value, %s expected got %s", @value 2, @Type ) )
end]], "@Return" )

EXPADV.AddException( nil, "invoke" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Define delegate class
   --- */

local DelgateClass = EXPADV.AddClass( nil, "delegate", "d" )

DelgateClass:AddPreparedOperator( "=", "n,d", "", "Context.Memory[@value 1] = @value 2" )

EXPADV.AddInlineOperator( nil, "delegate", "f", "d", "@value 1" )

EXPADV.AddInlineOperator( nil, "function", "d", "f", "@value 1" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Register exception class!
   --- */

local Class_Exception = EXPADV.AddClass( nil, "exception", "ex" )

Class_Exception:AddInlineOperator( "=", "n,ex", "", "Context.Memory[@value 1] = @value 2" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
@: Exceptions
--- */

EXPADV.AddException( nil, "cast" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
@: Events
--- */

EXPADV.SharedEvents( )
	
EXPADV.AddEvent( nil, "tick", "", "" )
EXPADV.AddEvent( nil, "think", "", "" )

EXPADV.ServerEvents( )
EXPADV.AddEvent( nil, "clientLoaded", "ply", "" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
@: Shared Hooks
--- */

hook.Add( "Tick", "Expav.Event", function( )
	EXPADV.CallEvent( "tick" )
end )

hook.Add( "Think", "Expav.Event", function( )
	EXPADV.CallEvent( "think" )
end )
