/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: ExpAdv Network Vars
   --- */

local v2 = debug.getregistry().Vector2

local function CheckValue(Type, Value)
	local ty = type(Value)

	if TYPE == "BOOL" then
		if Value == nil then return false end
		if ty ~= "boolean" then error("Tried to set ExpVar boolean to " .. ty .. ".", 3) end
	end

	if Type == "INT" then
		if Value == nil then return false end
		if ty ~= "number" then error("Tried to set ExpVar intiger to " .. ty .. ".", 3) end
		if Value - math.floor(Value) ~= 0 then error("Tried to set ExpVar of intiger to a float.", 3) end
	end

	if TYPE == "FLOAT" then
		if Value == nil then return false end
		if ty ~= "number" then error("Tried to set ExpVar float to " .. ty .. ".", 3) end
	end

	if TYPE == "STRING" then
		if Value == nil then return false end
		if ty ~= "string" then error("Tried to set ExpVar string to " .. ty .. ".", 3) end
	end

	if TYPE == "ENTITY" then
		if Value == nil then return false end
		if ty ~= "Entity" and ty ~= "Player" then error("Tried to set ExpVar entity to " .. ty .. ".", 3) end
	end

	if TYPE == "VECTOR" then
		if Value == nil then return false end
		if ty ~= "Vector" then error("Tried to set ExpVar vector to " .. ty .. ".", 3) end
	end

	if TYPE == "VECTOR2" then
		if Value == nil then return false end
		if ty ~= "table" and getmetatable(Value) ~= v2 then error("Tried to set ExpVar vector2 to " .. ty .. ".", 3) end
	end

	if TYPE == "ANGLE" then
		if Value == nil then return false end
		if ty ~= "Angle" then error("Tried to set ExpVar angle to " .. ty .. ".", 3) end
	end

	if TYPE == "TABLE" then
		if Value == nil then return false end
		if ty ~= "table" then error("Tried to set ExpVar table to " .. ty .. ".", 3) end
	end

	return true
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: ExpVars
	@: Yes, most of the types avalible might never be used, but its better then not having the option.
   --- */

local Updated = false
local SyncVars = { }
local ExpVars = { }

local function default() return {BOOLEAN = {}, FLOAT = {}, INT = {}, STRING = {}, ENTITY = {}, VECTOR = {}, VECTOR2 = {}, ANGLE = {}, TABLE = {}} end

function ENT:SetupExpVars()
	if self.__ExpVars then return self.__ExpVars end

	local entID = self:EntIndex()

	if ExpVars[entID] then
		self.__ExpVars = ExpVars[entID]
		return self.__ExpVars
	end

	self.__ExpVars = default()

	ExpVars[entID] = self.__ExpVars

	return self.__ExpVars
end

function ENT:AddExpVar(Type, ID, Name, Def)
	local ExpVars = self:SetupExpVars()

	local Values = ExpVars[Type]
	if !Values then error("Invalid Network Type " .. Type) end

	if Def ~= nil then self:SetExpVar(Type, ID, Def) end

	self["Set" .. Name] = function(self, Value) self:SetExpVar(Type, ID, Value) end
	self["Get" .. Name] = function(self, Value)  return Values[ID] or Value end
end

function ENT:SetExpVar(Type, ID, Value, Force)
	local Values = self:SetupExpVars()[Type]
	if !Values then error("Invalid Network Type " .. Type) end

	if Values[ID] == Value and !Force then return false end //This has not changed.

	CheckValue(Type, Value)
	
	Values[ID] = Value

	if CLIENT then return true end //Client doesnt sync.

	local EntIdx = self:EntIndex()
	local SyncData = SyncVars[EntIdx]

	if !SyncData then
		SyncData = {}
		SyncVars[EntIdx] = SyncData
	end

	if !SyncData[Type] then SyncData[Type] = {} end

	SyncData[Type][ID] = Value

	Updated = true

	return true
end

//We shouldnt need this, But i shall add it anyway.
function ENT:GetExpVar(Type, ID, Def)
	local Values = self.__ExpVars[Type]
	if !Values then error("Invalid Network Type " .. Type) end
	return Values[ID] or Def
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Server 
   --- */

if SERVER then
	util.AddNetworkString("expadv.vars")

	local function writeVars(vars)
		for eid, types in pairs(vars) do
			net.WriteUInt(eid, 16)

			if !types.BOOLEAN then
				net.WriteBit(false)
			else
				net.WriteBit(true)

				for id, val in pairs(types.BOOLEAN) do
					net.WriteUInt(id, 8)
					net.WriteBit(val)
				end 

				net.WriteUInt(0, 8)
			end
			
			if !types.FLOAT then
				net.WriteBit(false)
			else
				net.WriteBit(true)

				for id, val in pairs(types.FLOAT) do

					net.WriteUInt(id, 8)
					net.WriteFloat(val)
				end 

				net.WriteUInt(0, 8)
			end

			if !types.INT then
				net.WriteBit(false)
			else
				net.WriteBit(true)

				for id, val in pairs(types.INT) do

					net.WriteUInt(id, 8)
					net.WriteInt(val, 32)
				end 

				net.WriteUInt(0, 8)
			end

			if !types.STRING then
				net.WriteBit(false)
			else
				net.WriteBit(true)

				for id, val in pairs(types.STRING) do
					net.WriteUInt(id, 8)
					net.WriteString(val)
				end 

				net.WriteUInt(0, 8)
			end

			if !types.ENTITY then
				net.WriteBit(false)
			else
				net.WriteBit(true)

				for id, val in pairs(types.ENTITY) do
					net.WriteUInt(id, 8)
					net.WriteUInt(val:EntIndex(), 16)
				end 

				net.WriteUInt(0, 8)
			end

			if !types.VECTOR then
				net.WriteBit(false)
			else
				net.WriteBit(true)

				for id, val in pairs(types.VECTOR) do
					net.WriteUInt(id, 8)
					net.WriteVector(val)
				end 

				net.WriteUInt(0, 8)
			end

			if !types.VECTOR2 then
				net.WriteBit(false)
			else
				net.WriteBit(true)

				for id, val in pairs(types.VECTOR2) do
					net.WriteUInt(id, 8)
					net.WriteFloat(val.x)
					net.WriteFloat(val.y)
				end 

				net.WriteUInt(0, 8)
			end

			if !types.ANGLE then
				net.WriteBit(false)
			else
				net.WriteBit(true)

				for id, val in pairs(types.ANGLE) do
					net.WriteUInt(id, 8)
					net.WriteAngle(val)
				end 

				net.WriteUInt(0, 8)
			end

			if !types.TABLE then
				net.WriteBit(false)
			else
				net.WriteBit(true)

				for id, val in pairs(types.TABLE) do
					net.WriteUInt(id, 8)
					net.WriteTable(val)
				end 

				net.WriteUInt(0, 8)
			end
		end

		net.WriteUInt(0, 16)
	end

	hook.Add("Think", "expadv.vars", function()
		if Updated then
			net.Start("expadv.vars")
				net.WriteBit(false)
				writeVars(SyncVars)
			net.Broadcast()

			SyncVars, Updated = {}, false
		end
	end)

	hook.Add("PlayerInitalSpawn", "expadv.vars", function(player)
		net.Start("expadv.vars")
			net.WriteBit(true)
			writeVars(ExpVars)
		net.Send(player)
	end)
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Client 
   --- */

if CLIENT then

	local function resetVars()
		if ExpVars then
			for eid, _ in pairs(ExpVars) do
				local entity = Entity(eid)

				if IsValid(entity) then
					entity.__ExpVars = nil
				end
			end
		end

		ExpVars = { }
	end
	
	net.Receive( "expadv.vars", function(len)
		if net.ReadBit() == 1 then resetVars() end

		local eid = net.ReadUInt(16)
		
		while eid > 0 do
			entity = Entity(eid)
			if !ExpVars[eid] then ExpVars[eid] = default() end

			if net.ReadBit() == 1 then
				local id = net.ReadUInt(8)

				while id > 0 do
					local val = net.ReadBit() == 1

					if !entity or !entity:IsValid() or !entity.__ExpVars then
						ExpVars[eid].BOOLEAN[id] = val
					else
						entity:SetExpVar("BOOLEAN", id, val)
					end

					id = net.ReadUInt(8)
				end
			end
			
			if net.ReadBit() == 1 then
				local id = net.ReadUInt(8)

				while id > 0 do
					local val = net.ReadFloat()

					if !entity or !entity:IsValid() or !entity.__ExpVars then
						ExpVars[eid].FLOAT[id] = val
					else
						entity:SetExpVar("FLOAT", id, val)
					end

					id = net.ReadUInt(8)
				end
			end
			
			if net.ReadBit() == 1 then
				local id = net.ReadUInt(8)

				while id > 0 do
					local val = net.ReadInt(32)

					if !entity or !entity:IsValid() or !entity.__ExpVars then
						ExpVars[eid].INT[id] = val
					else
						entity:SetExpVar("INT", id, val)
					end

					id = net.ReadUInt(8)
				end
			end
			
			if net.ReadBit() == 1 then
				local id = net.ReadUInt(8)

				while id > 0 do
					local val = net.ReadString()

					if !entity or !entity:IsValid() or !entity.__ExpVars then
						ExpVars[eid].STRING[id] = val
					else
						entity:SetExpVar("STRING", id, val)
					end

					id = net.ReadUInt(8)
				end
			end
			
			if net.ReadBit() == 1 then
				local id = net.ReadUInt(8)

				while id > 0 do
					local val = Entity(net.ReadUInt(16))

					if !entity or !entity:IsValid() or !entity.__ExpVars then
						ExpVars[eid].ENTITY[id] = val
					else
						entity:SetExpVar("ENTITY", id, val)
					end

					id = net.ReadUInt(8)
				end
			end
			
			if net.ReadBit() == 1 then
				local id = net.ReadUInt(8)

				while id > 0 do
					local val = net.ReadVector()

					if !entity or !entity:IsValid() or !entity.__ExpVars then
						ExpVars[eid].VECTOR[id] = val
					else
						entity:SetExpVar("VECTOR", id, val)
					end

					id = net.ReadUInt(8)
				end
			end
			
			if net.ReadBit() == 1 then
				local id = net.ReadUInt(8)

				while id > 0 do
					local val = Vector2(net.ReadFloat(), net.ReadFloat())

					if !entity or !entity:IsValid() or !entity.__ExpVars then
						ExpVars[eid].VECTOR2[id] = val
					else
						entity:SetExpVar("VECTOR2", id, val)
					end

					id = net.ReadUInt(8)
				end
			end
			
			if net.ReadBit() == 1 then
				local id = net.ReadUInt(8)

				while id > 0 do
					local val = net.ReadAngle()

					if !entity or !entity:IsValid() or !entity.__ExpVars then
						ExpVars[eid].ANGLE[id] = val
					else
						entity:SetExpVar("ANGLE", id, val)
					end

					id = net.ReadUInt(8)
				end
			end
			
			if net.ReadBit() == 1 then
				local id = net.ReadUInt(8)

				while id > 0 do
					local val = net.ReadTable()

					if !entity or !entity:IsValid() or !entity.__ExpVars then
						ExpVars[eid].TABLE[id] = val
					else
						entity:SetExpVar("TABLE", id, val)
					end

					id = net.ReadUInt(8)
				end
			end

			eid = net.ReadUInt(16)
		end
	end)
end