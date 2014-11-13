/* --- --------------------------------------------------------------------------------
	@: Table Component
	@: E2 Tables suck, Lets do this correctly :D
   --- */

local Component = EXPADV.AddComponent( "tables" , true )

Component.Author = "Rusketh"
Component.Description = "Adds a slow but powerful table object."

Component:AddException( "table" )

/* --- --------------------------------------------------------------------------------
	@: Default Table Obj
   --- */

local DEFAULT_TABLE = { Data = { }, Types = { }, Look = { }, Size = 0, Count = 0, HasChanged = false }

/* --- --------------------------------------------------------------------------------
	@: Result Tables
   --- */

function EXPADV.ResultTable( Type, Data )
	local Types, Look = { }, { }
	for I = 1, #Data do Types[I] = Type; Look[I] = I; end
	return { Data = { }, Types = Types, Look = Look, Size = #Data, Count = #Data, HasChanged = false }
end

/* --- --------------------------------------------------------------------------------
	@: Table Class
   --- */

local Table = Component:AddClass( "table" , "t" )

Table:DefaultAsLua( DEFAULT_TABLE )

Table:StringBuilder( function( Table ) return string.format( "table[%s/%s]", Table.Count, Table.Size ) end )

Table:UsesHasChanged( )

/* --- --------------------------------------------------------------------------------
	@: Basic Operators
   --- */

EXPADV.SharedOperators( )

Table:AddVMOperator( "=", "n,t", "", function( Context, Trace, MemRef, Value )
	Context.Memory[MemRef] = Value
end ) -- Keeping this virtual, becuase i might need to add to it later :D

Component:AddInlineOperator( "#","t","n", "@value 1.Count" )


/* --- --------------------------------------------------------------------------------
	@: Basic functions
   --- */

Component:AddInlineFunction( "table", "", "t", "{ Data = { }, Types = { }, Look = { }, Size = 0, Count = 0, HasChanged = false }" )
Component:AddFunctionHelper( "table", "", "Creates a new table." )

Component:AddInlineFunction( "size", "t:", "n", "@value 1.Size" )
Component:AddInlineFunction( "count", "t:", "n", "@value 1.Count" )

Component:AddFunctionHelper( "size", "t:", "Returns the amount of entries in a table." )
Component:AddFunctionHelper( "count", "t:", "Returns the lengh of the tables array element." )

Component:AddInlineFunction( "type", "t:n", "s", "EXPADV.TypeName(@value 1.Types[@value 2])" )
Component:AddInlineFunction( "type", "t:s", "s", "EXPADV.TypeName(@value 1.Types[@value 2])" )
Component:AddInlineFunction( "type", "t:e", "s", "EXPADV.TypeName(@value 1.Types[@value 2])" )

Component:AddFunctionHelper( "type", "t:n", "Returns the type of obect stored in table at index." )
Component:AddFunctionHelper( "type", "t:s", "Returns the type of obect stored in table at index." )
Component:AddFunctionHelper( "type", "t:e", "Returns the type of obect stored in table at index." )

Component:AddInlineFunction( "exists", "t:n", "b", "(@value 1.Types[@value 2] ~= nil)" )
Component:AddInlineFunction( "exists", "t:s", "b", "(@value 1.Types[@value 2] ~= nil)" )
Component:AddInlineFunction( "exists", "t:e", "b", "(@value 1.Types[@value 2] ~= nil)" )

Component:AddFunctionHelper( "exists", "t:n", "Returns true if obect stored in table at index is not void." )
Component:AddFunctionHelper( "exists", "t:s", "Returns true if obect stored in table at index is not void." )
Component:AddFunctionHelper( "exists", "t:e", "Returns true if obect stored in table at index is not void." )

/* --- --------------------------------------------------------------------------------
	@: Unpack to vararg
   --- */

local Unpack

function Unpack( Context, Trace, Table, Index )
	local Object = Table.Data[Index or 1]

	if Object ~= nil then return end
	
	return { Object, Table.Types[Index] }, Unpack( Context, Trace, Table, (Index or 1) + 1 )
end


Component:AddVMFunction( "unpack", "t", "...", Unpack )
Component:AddVMFunction( "unpack", "t,n", "...", Unpack )

Component:AddFunctionHelper( "unpack", "t", "Unpacks the array element of a table to a vararg." )
Component:AddFunctionHelper( "unpack", "t,n", "Unpacks the array element of a table to a vararg, staring at index N." )

/* --- --------------------------------------------------------------------------------
	@: Concat
   --- */

Component:AddVMFunction( "concat", "t,s", "s",
	function( Context, Trace, Table, Sep )
		local Result = {}

		for I = 1, #Table.Data do Result[I] = EXPADV.ToString( Table.Types[I], Table.Data[I] ) end

		return string.Implode( Sep, Result )
	end )

Component:AddFunctionHelper( "concat", "t,s", "concatinates the array element of a table to a string using a seperator." )

/* --- --------------------------------------------------------------------------------
	@: Itorators
   --- */

Component:AddPreparedFunction( "numberKeys", "t:", "ar", [[
	@define Array = { __type = "n" }
	for _, Index in pairs( @value 1.Look ) do
		if @value 1.Types[Index] == "n" then
			@Array[@Array + 1] = @value 1.Data[Index]
		end
	end
]], "@Array" )

Component:AddPreparedFunction( "stringKeys", "t:", "ar", [[
	@define Array = { __type = "s" }
	for _, Index in pairs( @value 1.Look ) do
		if @value 1.Types[Index] == "s" then
			@Array[@Array + 1] = @value 1.Data[Index]
		end
	end
]], "@Array" )

Component:AddPreparedFunction( "entityKeys", "t:", "ar", [[
	@define Array = { __type = "e" }
	for _, Index in pairs( @value 1.Look ) do
		if @value 1.Types[Index] == "e" then
			@Array[@Array + 1] = @value 1.Data[Index]
		end
	end
]], "@Array" )

/* --- --------------------------------------------------------------------------------
	@: Variant Get Operators
   --- */

	local Get = function( Context, Trace, Table, Index, _ )
			local Object = Table.Data[Index]
			
			if Object == nil then
				Context:Throw( Trace, "table", string.format( "Attempt reach %s at index %s of table, result reached void.", Name, Index ) )
			else
				return { Object, Table.Types[Index] }
			end
	end
	
	Table:AddVMOperator( "get", "t,n,vr", "vr", Get )
	Table:AddVMOperator( "get", "t,s,vr", "vr", Get )
	Table:AddVMOperator( "get", "t,e,vr", "vr", Get )

/* --- --------------------------------------------------------------------------------
	@: Variant Set Operators
   --- */

	local Set = function( Context, Trace, Table, Index, Value )
		local Data = Table.Data
		local Old = Data[Index]

		if Old == nil then Table.Size = Table.Size + 1 end

		if Old ~= Value then Table.HasChanged = true end

		Data[Index] = Value[1]

		Table.Types[Index] = Value[2]

		Table.Look[Index] = Index

		Table.Count = #Data

		return Value
	end

	Table:AddVMOperator( "set", "t,n,vr", "", Set )
	Table:AddVMOperator( "set", "t,s,vr", "", Set )
	Table:AddVMOperator( "set", "t,e,vr", "", Set )

/* --- --------------------------------------------------------------------------------
	@: Variant insert functions
   --- */

   Component:AddVMFunction( "insert", "t:vr", "",
		function( Context, Trace, Table, Value )
			local Data = Table.Data

			table.insert( Data, Value[1] )
			table.insert( Table.Types, Value[2] )

			Table.Count = #Data

			Table.Size = Table.Size + 1

			Table.Look[Table.Count] = Table.Count
			
			Table.HasChanged = true
		end )

	Component:AddVMFunction( "insert", "t:n,vr", "",
		function( Context, Trace, Table, Index, Value )
			local Data = Table.Data

			table.insert( Data, Index, Value[1] )
			table.insert( Table.Types, Index, Value[2] )

			Table.Look[Index] = Index
			
			Table.HasChanged = true
			
			Table.Count = #Data
			
			Table.Size = Table.Size + 1
		end )

	Component:AddFunctionHelper( "insert", "t:vr", "Inserts variants object to the top of the tables array element." ) 
	Component:AddFunctionHelper( "insert", "t:n,vr", "Inserts %variants object tables array element at index, pushing all higher index up." )

/* --- --------------------------------------------------------------------------------
	@: The remove function, shall return a variant
   --- */

	local Remove = function( Context, Trace, Table, Index )
		local Data = Table.Data

		local Types = Table.Types

		local Old = Data[Index]
		
		if Old ~= nil then
			Table.Size = Table.Size - 1
			Table.HasChanged = true
		end
		
		local Value = Data[Index] or 0
		local Type = Types[Index] or "n"
		
		Data[Index] = nil

		Types[Index] = nil

		Table.Look[Index] = nil
		
		Table.Count = #Data
		
		return { Value, Type }
	end

	Component:AddVMFunction( "remove", "t:n", "vr", Remove )
	Component:AddVMFunction( "remove", "t:s", "vr", Remove )
	Component:AddVMFunction( "remove", "t:e", "vr", Remove )

	Component:AddFunctionHelper( "remove", "t:n", "Removes value at index of table, the removed object is returned as variant." ) 
	Component:AddFunctionHelper( "remove", "t:s", "Removes value at index of table, the removed object is returned as variant." ) 
	Component:AddFunctionHelper( "remove", "t:e", "Removes value at index of table, the removed object is returned as variant." ) 

/* --- --------------------------------------------------------------------------------
	@: Shift is basicaly the same, but it pops
   --- */

    Component:AddVMFunction( "shift", "t:n", "vr",
	   	function( Context, Trace, Table, Index )
			local Data = Table.Data

			local Types = Table.Types

			local Old = Data[Index]
			
			if Old ~= nil then
				Table.Size = Table.Size - 1
				Table.HasChanged = true
			end
			
			local Value = table.remove( Data, Index ) or 0
			local Type = table.remove( Types, Index ) or "n"
			
			table.remove( Table.Look, Index )
			
			Table.Count = #Data

			return { Value, Type }
		end )

    Component:AddFunctionHelper( "shift", "t:n", "Removes value at index of table, the removed object is returned as variant." )

/* --- --------------------------------------------------------------------------------
	@: We need to add support for every class :D
   --- */

function Component:OnPostRegisterClass( Name, Class )

	EXPADV.SharedOperators( )

	if Name == "generic" or Name == "variant" or Name == "function" then return end

	/* --- --------------------------------------------------------------------------------
		@: Get Operators
   	   --- */

		local Get = function( Context, Trace, Table, Index, _ )
				local Object = Table.Data[Index]
				
				if Object == nil then
					if Class.CreateNew then return Class.CreateNew( ) end
					Context:Throw( Trace, "table", string.format( "Attempt reach %s at index %s of table, result reached void.", Name, Index ) )
				
				elseif Table.Types[Index] == Class.Short then
					return Object

				else
					Context:Throw( Trace, "table", string.format( "Attempt reach %s at index %s of table, result reached %s.", Name, Index, EXPADV.TypeName( Table.Types[Index] ) ) )
				end
		end
		
		Table:AddVMOperator( "get", "t,n," .. Class.Short, Class.Short, Get )
		Table:AddVMOperator( "get", "t,s," .. Class.Short, Class.Short, Get )
		Table:AddVMOperator( "get", "t,e," .. Class.Short, Class.Short, Get )

	/* --- --------------------------------------------------------------------------------
		@: Set Operators
   	   --- */

   		local Set = function( Context, Trace, Table, Index, Value )
			local Data = Table.Data
			local Old = Data[Index]

			if Old == nil then Table.Size = Table.Size + 1 end

			if Old ~= Value then Table.HasChanged = true end

			Data[Index] = Value

			Table.Types[Index] = Class.Short

			Table.Look[Index] = Index

			Table.Count = #Data

			return Value
		end

		Table:AddVMOperator( "set", "t,n," .. Class.Short, "", Set )
		Table:AddVMOperator( "set", "t,s," .. Class.Short, "", Set )
		Table:AddVMOperator( "set", "t,e," .. Class.Short, "", Set )

	/* --- --------------------------------------------------------------------------------
		@: Insert Function
   	   --- */

   		Component:AddVMFunction( "insert", "t:" .. Class.Short, "",
   			function( Context, Trace, Table, Value )
				local Data = Table.Data

				table.insert( Data, Value )
				table.insert( Table.Types, Class.Short )

				Table.Count = #Data

				Table.Size = Table.Size + 1

				Table.Look[Table.Count] = Table.Count
				
				Table.HasChanged = true
			end )

   		Component:AddVMFunction( "insert", "t:n," .. Class.Short, "",
   			function( Context, Trace, Table, Index, Value )
				local Data = Table.Data

				table.insert( Data, Index, Value )
				table.insert( Table.Types, Index, Class.Short )

				Table.Look[Index] = Index
				
				Table.HasChanged = true
				
				Table.Count = #Data
				
				Table.Size = Table.Size + 1
			end )

   		Component:AddFunctionHelper( "insert", "t:" .. Class.Short, string.format( "Inserts %s to the top of the tables array element.", Class.Short ) )
   		Component:AddFunctionHelper( "insert", "t:n," .. Class.Short, string.format( "Inserts %s tables array element at index, pushing all higher index up.", Class.Short ) )

end

/* --- --------------------------------------------------------------------------------
	@: Now for the complicated stuff:
	@: Lets try adding a sort function :P
   --- */

	Component:AddVMFunction( "sort", "t:d", "t",
		function( Context, Trace, Table, Function )

			local Types, Data, Look = Table.Types, Table.Data, { }
			for K, V in pairs( Table.Look ) do Look[K] = V end

			local function Sort( A, B )
				local Boolean, Type = Sort_Function( Context, {Data[A], Types[A]}, {Data[B], Types[B]} )

				if Type != "b" then
					Sort_Context:Throw( Trace, "invoke", "Table sort function returned " .. EXPADV.TypeName( Type ) .. ", boolean expected." )
				end

				return Boolean or false
			end

			local NewData, NewTypes, NewLook = { }, { }, { }

			for _, Index in pairs( Look ) do
				NewData[Index] = Data[Index]
				NewTypes[Index] = Types[Index]
				NewLook[Index] = Index
			end

			return { Data = NewData, Types = NewTypes, Look = NewLook, Size = Table.Size, Count = #Data, HasChanged = true }
		end )

	Component:AddFunctionHelper( "sort", "t:d", "Takes a table and sorts it, the returned table will be sorted by the provided delegate and all indexs will be numberic. The delegate will be called with 2 variants that are values on the table, return true if the first is bigger then the second this delegate must return a boolean." )

/* --- --------------------------------------------------------------------------------
	@: Now for a way to build a filled table
   --- */

	Component:AddGeneratedFunction( "table", "...", "t", function( Operator, Compiler, Trace, ... )
		local Inputs = { ... }
		local Preperation = { }
		local Values, Types, Look = { }, { }, { }
		
		for I = 1, #Inputs, 1 do
			local Input = Inputs[I]

			if Input.FLAG == EXPADV_PREPARE or Input.FLAG == EXPADV_INLINEPREPARE then
				Preperation[#Preperation + 1] = Input.Prepare
			end

			if Input.FLAG == EXPADV_INLINE or Input.FLAG == EXPADV_INLINEPREPARE then
				Values[I] = Input.Inline
			end

			Types[I] = string.format( "%q", Input.Return )

			Look[I] = I
		end

		local LuaInline = "{ Data = { %s }, Types = { %s }, Look = { %s }, Size = %i, Count = %i, HasChanged = false }"

		LuaInline = string.format( LuaInline, table.concat( Values, "," ), table.concat( Types, "," ), table.concat( Look, "," ), #Values, #Values )

		return { Trace = Trace, Inline = LuaInline, Prepare = table.concat( Preperation, "\n" ), Return = "t", FLAG = EXPADV_INLINEPREPARE }
	end )