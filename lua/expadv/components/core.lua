-- Temporary string print!
	EXPADV.AddFunctionHelper( nil, "print", "s", "Prints to owners/clients chat." )

	EXPADV.AddPreparedFunction( nil, "print", "s", "", "print(@value 1)" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: CORE COMPOENT! - NOT REGISTERED AS COMPONENT!
   --- */

EXPADV.SharedOperators( )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Define boolean class
   --- */

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

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Register variant class!
   --- */

local Variant = EXPADV.AddClass( nil, "variant", "vr" )
		
	  Variant:DefaultAsLua( { false, "b" } )

hook.Add( "Expadv.PostRegisterClass", "expad.variant", function( Name, Class )
	if !Class.LoadOnClient then EXPADV.ServerOperators( ) elseif !Class.LoadOnServer then EXPADV.ClientOperators( ) else EXPADV.SharedOperators( ) end

	EXPADV.AddInlineOperator( nil, "variant", Class.Short, "vr", "{ @value 1, @type 1 }" )

	EXPADV.AddInlineOperator( nil, Name, "vr", Class.Short, string.format( "( @value 1[2] == %q and @value 1[1] or Context:Throw(@trace, %q, \"Attempt to cast value \" .. EXPADV.TypeName(@value 1[2]) .. \" to %s \") )", Class.Short, "cast", Name ) )
end )	


/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Register exception class!
   --- */

local Class_Exception = EXPADV.AddClass( nil, "exception", "ex" )

-- TODO

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
@: Exceptions
--- */

EXPADV.AddException( nil, "cast" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
@: Events
--- */

EXPADV.AddEvent( nil, "tick", "", "" )

hook.Add( "Tick", "Expav.Event", function( ) EXPADV.CallEvent( "tick" ) end )

EXPADV.AddEvent( nil, "think", "", "" )

hook.Add( "Think", "Expav.Event", function( ) EXPADV.CallEvent( "think" ) end )

