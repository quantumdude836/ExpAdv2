require("vnet") //About time I used this.

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: ExpVars
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

	Values[ID] = Value

	if CLIENT then return true end //Client doesnt sync.

	local EntIdx = self:EntIndex()
	SyncVars[EntIdx] = SyncVars[EntIdx] or default()

	SyncVars[EntIdx][Type][ID] = Value

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

	hook.Add("Think", "expadv.vars", function()
		if !Updated then return end
		local Package = vnet.CreatePacket( "expadv.vars" )
		Package:Bool( false )
		Package:Table( SyncVars )
		Package:Broadcast( )
		Updated = false
		SyncVars = {}
	end)

	hook.Add("PlayerInitalSpawn", "expadv.vars", function(Player)
		local Package = vnet.CreatePacket( "expadv.vars" )
		Package:Bool( true )
		Package:Table( ExpVars )
		Package:AddTargets( { Player } )
		Package:Send( )
	end)
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Client 
   --- */

if CLIENT then
	vnet.Watch( "expadv.vars", function( Package )
			if Package:Bool( ) then
				ExpVars = Package:Table()
			else
				for ID, Vars in pairs(Package:Table()) do
					local ent = Entity(ID)

					for Type, Values in pairs(Vars) do
						for id, Value in pairs(Values) do
							if IsValid(ent) and ent.__ExpVars then
								ent:SetExpVar(Type, id, Value)
							else
								ExpVars[ID] = ExpVars[ID] or default()
								ExpVars[ID][Type][id] = Value
							end
						end
					end
				end
			end
		end, vnet.OPTION_WATCH_OVERRIDE )

end