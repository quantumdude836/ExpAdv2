/* --- --------------------------------------------------------------------------------
	@: Entity Component
   --- */

local Component = EXPADV.AddComponent( "net", true )

/* --- --------------------------------------------------------------------------------
	@: Base Stream Object
	@: This should not have extra data type, avalible.
	@: If you require a stream object to contain more then basic types,
	@: then you should extend a new object from this one (like the netstream object).
   --- */

local StreamObject = Component:AddClass( "stream", "st" )

StreamObject:DefaultAsLua( { V = { }, T = { }, R = 0, W = 0 } )

/* --- --------------------------------------------------------------------------------
	@: Operators
   --- */

Component:AddInlineFunction( "stream", "", "st", "{ V = { }, T = { }, R = 0, W = 0 }" )

Component:AddPreparedOperator( "=", "st,n", "", "Context.Memory[@value 2] = @value 1" )

Component:AddInlineOperator( "#", "st", "n", "(@value 1.Write - @value 1.R)")

/* --- --------------------------------------------------------------------------------
	@: Read Methods
   --- */

EXPADV.SharedOperators( )

Component:AddVMFunction( "writeNumber", "st:n", "", function( Context, Trace, Stream, Obj )
	Stream.W = Stream.W + 1
	if Stream.W >= 128 then Context:Throw( Trace, "stream", "Failed to write number to stream, maxamum stream size achived (128)" ) end
	Stream.V[Stream.W] = Obj
	Stream.T[Stream.W] = "n"
end )

Component:AddVMFunction( "writeString", "st:s", "", function( Context, Trace, Stream, Obj )
	Stream.W = Stream.W + 1
	if Stream.W >= 128 then Context:Throw( Trace, "stream", "Failed to write string to stream, maxamum stream size achived (128)" ) end
	Stream.V[Stream.W] = Obj
	Stream.T[Stream.W] = "s"
end )

Component:AddVMFunction( "writeEntity", "st:e", "", function( Context, Trace, Stream, Obj )
	Stream.W = Stream.W + 1
	if Stream.W >= 128 then Context:Throw( Trace, "stream", "Failed to write entity to stream, maxamum stream size achived (128)" ) end
	Stream.V[Stream.W] = Obj
	Stream.T[Stream.W] = "e"
end )

Component:AddVMFunction( "writePlayer", "st:ply", "", function( Context, Trace, Stream, Obj )
	Stream.W = Stream.W + 1
	if Stream.W >= 128 then Context:Throw( Trace, "stream", "Failed to write entity to stream, maxamum stream size achived (128)" ) end
	Stream.V[Stream.W] = Obj
	Stream.T[Stream.W] = "e"
end )

Component:AddVMFunction( "writeVector", "st:v", "", function( Context, Trace, Stream, Obj )
	Stream.W = Stream.W + 1
	if Stream.W >= 128 then Context:Throw( Trace, "stream", "Failed to write vector to stream, maxamum stream size achived (128)" ) end
	Stream.V[Stream.W] = Obj
	Stream.T[Stream.W] = "v"
end )

Component:AddVMFunction( "writeAngle", "st:a", "", function( Context, Trace, Stream, Obj )
	Stream.W = Stream.W + 1
	if Stream.W >= 128 then Context:Throw( Trace, "stream", "Failed to write angle to stream, maxamum stream size achived (128)" ) end
	Stream.V[Stream.W] = Obj
	Stream.T[Stream.W] = "a"
end )

Component:AddVMFunction( "writeColor", "st:c", "", function( Context, Trace, Stream, Obj )
	Stream.W = Stream.W + 1
	if Stream.W >= 128 then Context:Throw( Trace, "stream", "Failed to write color to stream, maxamum stream size achived (128)" ) end
	Stream.V[Stream.W] = Color( Obj[1], Obj[2], Obj[3], Obj[4] )
	Stream.T[Stream.W] = "c"
end )

/* --- --------------------------------------------------------------------------------
	@: Read Methods
   --- */

Component:AddVMFunction( "readNumber", "st:", "n", function( Context, Trace, Stream )
	Stream.R = Stream.R + 1
	
	if !Stream.T[Stream.R] then
		Context:Throw( Trace, "stream", "Failed to read number from stream, stream returned void." )
	elseif Stream.T[Stream.R] ~= "n" then
		Context:Throw( Trace, "stream", "Failed to read number from stream, stream returned " .. EXPADV.TypeName( Stream.T[Stream.R] )  .. "." )
	end

	return Stream.V[Stream.R]
end )

Component:AddVMFunction( "readString", "st:", "s", function( Context, Trace, Stream )
	Stream.R = Stream.R + 1
	
	if !Stream.T[Stream.R] then
		Context:Throw( Trace, "stream", "Failed to read string from stream, stream returned void." )
	elseif Stream.T[Stream.R] ~= "s" then
		Context:Throw( Trace, "stream", "Failed to read string from stream, stream returned " .. EXPADV.TypeName( Stream.T[Stream.R] )  .. "." )
	end

	return Stream.V[Stream.R]
end )

Component:AddVMFunction( "readEntity", "st:", "e", function( Context, Trace, Stream )
	Stream.R = Stream.R + 1
	
	if !Stream.T[Stream.R] then
		Context:Throw( Trace, "stream", "Failed to read entity from stream, stream returned void." )
	elseif Stream.T[Stream.R] ~= "e" then
		Context:Throw( Trace, "stream", "Failed to read entity from stream, stream returned " .. EXPADV.TypeName( Stream.T[Stream.R] )  .. "." )
	end

	return Stream.V[Stream.R]
end )

Component:AddVMFunction( "readPlayer", "st:", "ply", function( Context, Trace, Stream )
	Stream.R = Stream.R + 1
	
	if !Stream.T[Stream.R] then
		Context:Throw( Trace, "stream", "Failed to read player from stream, stream returned void." )
	elseif Stream.T[Stream.R] ~= "e" then
		Context:Throw( Trace, "stream", "Failed to read player from stream, stream returned " .. EXPADV.TypeName( Stream.T[Stream.R] )  .. "." )
	end

	local Value = Stream.V[Stream.R]

	if !IsValid( Value ) or !Value:IsPlayer( ) then
		Context:Throw( Trace, "stream", "Failed to read player from stream, stream returned entity." )
	end

	return Value
end )

Component:AddVMFunction( "readVector", "st:", "v", function( Context, Trace, Stream )
	Stream.R = Stream.R + 1
	
	if !Stream.T[Stream.R] then
		Context:Throw( Trace, "stream", "Failed to read vector from stream, stream returned void." )
	elseif Stream.T[Stream.R] ~= "v" then
		Context:Throw( Trace, "stream", "Failed to read vector from stream, stream returned " .. EXPADV.TypeName( Stream.T[Stream.R] )  .. "." )
	end

	return Stream.V[Stream.R]
end )

Component:AddVMFunction( "readAngle", "st:", "a", function( Context, Trace, Stream )
	Stream.R = Stream.R + 1
	
	if !Stream.T[Stream.R] then
		Context:Throw( Trace, "stream", "Failed to read angle from stream, stream returned void." )
	elseif Stream.T[Stream.R] ~= "a" then
		Context:Throw( Trace, "stream", "Failed to read angle from stream, stream returned " .. EXPADV.TypeName( Stream.T[Stream.R] )  .. "." )
	end

	return Stream.V[Stream.R]
end )

Component:AddVMFunction( "readColor", "st:", "c", function( Context, Trace, Stream )
	Stream.R = Stream.R + 1
	
	if !Stream.T[Stream.R] then
		Context:Throw( Trace, "stream", "Failed to read color from stream, stream returned void." )
	elseif Stream.T[Stream.R] ~= "c" then
		Context:Throw( Trace, "stream", "Failed to read color from stream, stream returned " .. EXPADV.TypeName( Stream.T[Stream.R] )  .. "." )
	end

	local Value = Stream.V[Stream.R]

	return { Value.r, Value.g, Value.b, Value.a }
end )

/* --- --------------------------------------------------------------------------------
	@: Net Stream Object
   --- */

local NetObject = Component:AddClass( "netstream", "nst" )

NetObject:ExtendClass( "st" )

/* --- --------------------------------------------------------------------------------
	@: net Stream Operators
	@: All we really need here is a way to cast, this object from the stream() functions result.
   --- */

Component:AddInlineOperator( "netstream", "st", "nst", "@value 1")

/* --- --------------------------------------------------------------------------------
	@: Queuing Streams
   --- */

local HasQueued, NetQueue = false, { }

EXPADV.ServerOperators( )

Component:AddVMFunction( "netBroadcast", "nst:s", "", function( Context, Trace, Stream, Name )
	table.insert( NetQueue, { Context.entity, Name, Stream } ) -- Slow but meh!
	HasQueued = true
end )

/* --- --------------------------------------------------------------------------------
	@: Receiving
   --- */

EXPADV.ClientOperators( )

Component:AddPreparedFunction( "netReceive", "s,d", "", "Context.Data['net_' .. @value 1] = @value 2" )

/* --- --------------------------------------------------------------------------------
	@: Sending
   --- */

if SERVER then
	util.AddNetworkString( "expadv.netstream" )

	function Component:OnThink( )
		if !HasQueued then return end

		for _, Msg in pairs( NetQueue ) do
			local E, N, S = Msg[1], Msg[2], Msg[3]

			if IsValid( E ) and E:IsRunning( ) then
			
				net.Start( "expadv.netstream" )
					net.WriteEntity( E )
					net.WriteString( N )
					net.WriteTable( S.T )
					net.WriteTable( S.V )
				net.Broadcast( )
			end
		end

		HasQueued, NetQueue = false, { }
	end
end

/* --- --------------------------------------------------------------------------------
	@: Receiving
   --- */

if CLIENT then

	net.Receive( "expadv.netstream", function( )
		local E = net.ReadEntity( )
		local N = net.ReadString( )
		local T, V = net.ReadTable( ), net.ReadTable( )

		if IsValid( E ) and E:IsRunning( ) then
			
			local H = E.Context.Data["net_" .. N]
			MsgN( "-->", E, " - ", N, " - ", E:IsRunning( ), " - ", H )

			if !H then return end
			
			E.Context:Execute( "Net Receive " .. N, H, { { V = V, T = T, R = 0, W = #V } , "_nst" } )
		end
	end )
end

