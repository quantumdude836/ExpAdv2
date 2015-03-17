/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Base Class
   --- */

include( "shared.lua" )
include( "vars.lua" )
include( "wiremod.lua" )

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "vars.lua" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Receive Code
   --- */

function ENT:ReceiveScript(script, name)
	self.root = script
	self.files = {}

	if script ~= "" then
		self:CompileScript( self.root, self.files )

		timer.Simple(1, function()
			EXPADV.SendToClient(nil, self, script, self.player)
		end)

		hook.Add( "PlayerInitialSpawn", self, function(self, player)
			timer.Simple(5, function()
				if IsValid(player) then
					EXPADV.SendToClient(player, self, self.root, self.files) 
				end
			end)
		end)
	end

	self:SetGateName(name)
end

function ENT:OnClientLoaded( Ent, Ply )
	-- To be used by derived classes
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Duplicator Support
	@: To make it compatable with wirelib we need to borrow one of there functions.
	@: https://github.com/wiremod/wire/blob/master/lua/entities/base_wire_entity.lua#L386
   --- */

local function EntityLookup(CreatedEntities)
	return function(id, default)
		if id == nil then return default end
		if id == 0 then return game.GetWorld() end
		local ent = CreatedEntities[id] or (isnumber(id) and ents.GetByIndex(id))
		if IsValid(ent) then return ent else return default end
	end
end

function ENT:PreEntityCopy( )
	local DupeTable = WireLib and WireLib.BuildDupeInfo( self ) or { }
	
	DupeTable.GateName = self:GetGateName( )
	DupeTable.Root = self.root or ""
	DupeTable.Files = self.files or { }
	
	EXPADV.CallHook( "BuildDupeInfo", self, DupeTable )
	
	duplicator.StoreEntityModifier(self, "ExpAdvDupeInfo", DupeTable)
end

function ENT:PostEntityPaste( Player, Entity, CreatedEntities  )
	if !Entity.EntityMods then return end 
	
	local DupeTable = Entity.EntityMods.ExpAdvDupeInfo
	if !DupeTable then return end

	self.player = Player
	self.PastedFromDupe = true
	self:ReceiveScript(DupeTable.Root, DupeTable.GateName)

	local FromID = EntityLookup(CreatedEntities)

	if WireLib then
		WireLib.ApplyDupeInfo( Player, Entity, DupeTable, FromID )
	end
	
	EXPADV.CallHook( "PasteDupeInfo", self, DupeTable, FromID )
end

function ENT:ApplyDupePorts( InPorts, OutPorts )
	if !WireLib then return end

	if InPorts then
		self.DupeInPorts = OutPorts
		self.Inputs = WireLib.AdjustSpecialInputs( self, InPorts[1], InPorts[2] )
	end
	
	if OutPorts then
		self.DupeOutPorts = OutPorts
		self.Outputs = WireLib.AdjustSpecialOutputs( self, OutPorts[1], OutPorts[2] )
	end
end