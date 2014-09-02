local Components = { }

function GetComponent( Name )
	if !Name then Name = "Core" end
	if istable( Name ) then Name = Name.Name end

	local Component = Components[Name]
	
	if !Component then
		Component = { }
		Components[Name] = Component
	end

	return Component
end

function GetClass( Component, Name )
	local Component = GetComponent( Component )
	
	if !Component.Classes then Component.Classes = { } end

	local Class = Component.Classes[Name]
	if !Class then
		Class = { }
		Component.Classes[Name] = Class
	end

	return Class
end

-----------------------------------------------------------------------------------

function Avalibility( Server, Client )
	if Server and Client then return "Shared" end
	if Server then return "Serverside" end
	if Client then return "Clientside" end
	return "Unkown"
end

function NamePerams( Perams, Start, Varg )
	local Names = { }

	for I = Start or 1, #Perams do
		Names[I] = EXPADV.TypeName( Perams[I] )
	end
	
	if Start then table.remove( Names, 1 ) end
	
	if Varg then table.insert( Names, "..." ) end

	return table.concat( Names, ", " )
end

-----------------------------------------------------------------------------------

function AddFunction( Component, Name, Perams, Varg, Return, Desc, Server, Client )
	local Component = GetComponent( Component )
	if !Component.Functions then Component.Functions = { } end

	local Line = string.format( "| %s(%s) || %s || %s || %s \n", Name, NamePerams( Perams, 1, Varg ), EXPADV.TypeName( Return ) or "Void", Avalibility( Server, Client ), Desc or "No description."  )
	table.insert( Component.Functions, Line )
end

-----------------------------------------------------------------------------------

function AddMethod( Component, Class, Name, Perams, Varg, Return, Desc, Server, Client )
	local ClassName = EXPADV.TypeName( Class )
	local Class = GetClass( Component, ClassName )
	if !Class.Methods then Class.Methods = { } end

	local Line = string.format( "| %s:%s(%s) || %s || %s || %s \n", ClassName, Name, NamePerams( Perams, 2, Varg ), EXPADV.TypeName( Return ) or "Void", Avalibility( Server, Client ), Desc or "No description."  )
	table.insert( Class.Methods, Line )
end

-----------------------------------------------------------------------------------

function AddEvent( Component, Name, Perams, Return, Desc, Server, Client )
	local Component = GetComponent( Component )
	if !Component.Events then Component.Events = { } end

	local Line = string.format( "| %s(%s) || %s || %s || %s \n", Name, NamePerams( Perams ), EXPADV.TypeName( Return ) or "Void", Avalibility( Server, Client ), Desc or "No description."  )
	table.insert( Component.Events, Line )
end

-----------------------------------------------------------------------------------

for _, Operator in pairs( EXPADV.Functions ) do
	if Operator.Method then
		local Perams = table.Copy( Operator.Input )
		AddMethod( Operator.Component, table.remove( Perams, 1 ), Operator.Name, Perams, Operator.UsesVarg, Operator.Return or "VOID", Operator.Description, Operator.LoadOnServer, Operator.LoadOnClient )
	else
		AddFunction( Operator.Component, Operator.Name, Operator.Input, Operator.UsesVarg, Operator.Return or "VOID", Operator.Description, Operator.LoadOnServer, Operator.LoadOnClient )
	end
end

-----------------------------------------------------------------------------------

for _, Event in pairs( EXPADV.Events ) do
	AddEvent( Event.Component, Event.Name, Event.Input, Event.Return or "VOID", Desc, Event.LoadOnServer, Event.LoadOnClient )
end

-----------------------------------------------------------------------------------

for _, Class in pairs( EXPADV.Classes ) do
	local Info = GetClass( Class.Component, Class.Name )

	local Artical = { string.format( "===%s===", Class.Name ) }
	
	if Class.DerivedClass and !Class.DeriveGeneric then
		local Extend = EXPADV.TypeName( Class.DerivedClass.Name )
		if Extend then table.insert( Artical, "Extends class " .. Extend ) end
	end

	if Info.Methods then
		table.insert( Artical, '====Methods====\n{|class="wikitable" style="text-align: left;"\n!|Method\n!|Return\n!|Availability\n!|Description\n|-' )
		table.insert( Artical, table.concat( Info.Methods, "|-\n" ) )
		table.insert( Artical, "|}" ) 
	end

	Info.Artical = Artical
end

-----------------------------------------------------------------------------------

local OutPut = { }

for _, Component in pairs( EXPADV.Components ) do
	local Info = GetComponent( Component )

	table.insert( OutPut, string.format( "=%s=", Component.Name ) )

	if Info.Classes then
		table.insert( OutPut, "==Classes==" )
		for _, Info in pairs( Info.Classes ) do
			if !Info.Artical then continue end
			table.insert( OutPut, table.concat( Info.Artical, "\n" ) )
		end
	end

	if Info.Functions then
		table.insert( OutPut, '==Functions==\n{|class="wikitable" style="text-align: left;"\n!|Function\n!|Return\n!|Availability\n!|Description\n|-' )
		table.insert( OutPut, table.concat( Info.Functions, "|-\n" ) )
		table.insert( OutPut, "|}" )
	end

	if Info.Events then
		table.insert( OutPut, '==Events==\n{|class="wikitable" style="text-align: left;"\n!|Event\n!|Return\n!|Availability\n!|Description\n|-' )
		table.insert( OutPut, table.concat( Info.Events, "|-\n" ) )
		table.insert( OutPut, "|}" )
	end
end

file.Write( "ea_wiki.txt", table.concat( OutPut, "\n" ) )