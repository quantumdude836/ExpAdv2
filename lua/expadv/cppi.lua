/* --- --------------------------------------------------------------------------------
	@: CPPI support - Prop Protection intigration.
   --- */

if CPPI then
	function EXPADV.GetOwner( Entity )
		if !IsValid( Entity ) then return end

		local Owner = Entity:CPPIGetOwner( )
		if !IsValid( Owner ) then return end

		return Owner
	end

	function EXPADV.IsOwner( Entity, Player )
		if !IsValid( Entity ) or !IsValid( Player ) then return false end

		local Owner = Entity:CPPIGetOwner( )
		return IsValid( Owner ) and Owner == Player
	end

	function EXPADV.IsFriend( Friend, Player )
		if !IsValid( Friend ) or !IsValid( Player ) then return false end

		if Friend == Player then return true end

		local Friends = Owner:CPPIGetFriends( )

		if type( Friends ) == "table" then 
			for _, Friend in pairs( Friends ) do
				if Friend == Player then return true end
			end
		end

		return false
	end

	function EXPADV.PPCheck( Entity, Player )
		if !IsValid( Entity ) or !IsValid( Player ) then return false end

		local Owner = Entity:CPPIGetOwner( )
		if !IsValid( Owner ) then return false end

		return Owner == Player or EXPADV.IsFriend( Player, Owner )
	end

	return -- Cave Johnson, we're done here!
end

/* --- --------------------------------------------------------------------------------
	@: Ok, Looks like we need our own PP.
   --- */

local UIDCach = { } -- Because UniqueID is slow and isn't cached, Fix it *KILLBURN*
local ObjectOwners, Friends = { }, { }

function EXPADV.GetOwner( Entity )
	if !IsValid( Entity ) or !ObjectOwners[Entity] then return end

	local Owner = player.GetByUniqueID( ObjectOwners[Entity] )
	if !IsValid( Owner ) then return end

	return Owner
end

function EXPADV.IsOwner( Entity, Player )
	if !IsValid( Entity ) or !IsValid( Player ) then return false end

	local Owner = EXPADV.GetOwner( Entity )
	return IsValid( Owner ) and Owner == Player
end

function EXPADV.IsFriend( Friend, Player )
	if !IsValid( Friend ) or !IsValid( Player ) then return false end

	UIDCach[Player] = UIDCach[Player] or Player:UniqueID( )

	if !Friends[ UIDCach[Player] ] then
		return Friend == Player
	end

	UIDCach[Friend] = UIDCach[Friend] or Friend:UniqueID( )

	return Friends[ UIDCach[Player] ][ UIDCach[Friend] ] or false
end

function EXPADV.PPCheck( Entity, Player )
	if !IsValid( Entity ) or !IsValid( Player ) then return false end

	local Owner = EXPADV.GetOwner( Entity )
	if !IsValid( Owner ) then return false end

	return Owner == Player or EXPADV.IsFriend( Player, Owner )
end

/* --- --------------------------------------------------------------------------------
	@: Ok, now we need to controll our pp.
   --- */

   -- TODO: This!

/* --- --------------------------------------------------------------------------------
	@: Lets keep our hooks neatly down here.
   --- */

hook.Add( "PlayerSpawnedRagdoll", "Expadv.PropProtect", function( Player, Model, Entity )
	UIDCach[Player] = UIDCach[Player] or Player:UniqueID( )
	ObjectOwners[Entity] = UIDCach[Player]
end )

hook.Add( "PlayerSpawnedProp", "Expadv.PropProtect", function( Player, Model, Entity )
	UIDCach[Player] = UIDCach[Player] or Player:UniqueID( )
	ObjectOwners[Entity] = UIDCach[Player]
end )

hook.Add( "PlayerSpawnedEffect", "Expadv.PropProtect", function( Player, Model, Entity )
	UIDCach[Player] = UIDCach[Player] or Player:UniqueID( )
	ObjectOwners[Entity] = UIDCach[Player]
end )

hook.Add( "PlayerSpawnedVehicle", "Expadv.PropProtect", function( Player, Entity )
	UIDCach[Player] = UIDCach[Player] or Player:UniqueID( )
	ObjectOwners[Entity] = UIDCach[Player]
end )

hook.Add( "PlayerSpawnedNPC", "Expadv.PropProtect", function( Player, Entity )
	UIDCach[Player] = UIDCach[Player] or Player:UniqueID( )
	ObjectOwners[Entity] = UIDCach[Player]
end )

hook.Add( "PlayerSpawnedSENT", "Expadv.PropProtect", function( Player, Entity )
	UIDCach[Player] = UIDCach[Player] or Player:UniqueID( )
	ObjectOwners[Entity] = UIDCach[Player]
end )