/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Peripheral Base Class
   --- */

ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"

ENT.PrintName       = "Expression Advanced Peripheral"
ENT.Author          = "Rusketh"
ENT.Contact         = "WM/FacePunch"

ENT.IsPeripheral	 		= true

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Need away to set up this peripheral :D
   --- */

function ENT:CreatePeripheral( Name )
	self.IsPeripheral = true
	self.PeripheralName = Name
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Client must always know about this entity.
   --- */

function ENT:UpdateTransmitState( )	
	return TRANSMIT_ALWAYS
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Datatable so client knows what operates this.
   --- */

function ENT:SetupDataTables( )
	self:NetworkVar( "Entity", 0, "ExpAdv" )
	self:NetworkVar( "Int", 0, "PeripheralSlot" )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Automaticaly Unlink this Peripheral
   --- */

function ENT:OnRemove( )
	local ExpAdv = self:GetExpAdv( )

	if IsValid( ExpAdv ) then
		ExpAdv:RemovePeripheral( self )
	end
end
