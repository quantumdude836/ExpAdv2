/* ---
	@: Expression Advanced 2.
	@: Because the old one was shit.
	@: Team SpaceTown -> Rusketh, Oskar_
   --- */

/* ---
	@: To lua functions.
   --- */

local Lua_Cache, ToLua, ToLuaTable = { }

EXPADV.Lua_Cache = Lua_Cache

function ToLua( Value, bNoTables )
	if !Value then return "nil" end
	
	local Type = type(Value)
	
	if Type == "number" then
		return Value
	elseif Type == "string" then
		return string.Format( "%q", Value )
	elseif Type == "boolean" then
		return Value and "true" or "false"
	elseif Type == "table" and !bNoTables then
		return toLuaTable( Value )
	elseif Type == "function" and !NoTables then
		local Index = #__cache + 1
		Lua_Cache[Index] = Value
		return "EXPADV.Lua_Cache[" .. Index .. "]"
	end
end

EXPADV.ToLua = ToLua

/* ------------------------------------------------------------------------ */

function ToLuaTable( Table )
	local Lua = "{"
	
	for Key, Value in pairs(Table) do
		local kLua = toLua( Key, true )
		local vLua = toLua( Value )
		
		if !kLua then
			error("TableToLua invalid Key of type " .. type(Key))
		elseif !vLua then
			error("TableToLua invalid Value of type " .. type(Value))
		end
		
		Lua = Lua .. "[" .. kLua .. "] = " .. vLua .. ", "
	end
	
	return Lua .. "}"
end

EXPADV.ToLuaTable = ToLuaTable