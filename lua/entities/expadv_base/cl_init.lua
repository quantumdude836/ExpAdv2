/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Base Class
   --- */

include( "shared.lua" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: [vNet] Receive Code
   --- */

function ENT:ReceivePackage( Package )
	self.player = Package:Entity( )

	self.root = Package:String( )
	
	self.files = Package:Table( )

	self:CompileScript( self.root, self.files )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Fake Entity
		-- Because entitys out of pvs don't exist!
   --- */

--[[This is retarded :D
local __ENT = ENT

function EXPADV.GetVirtualEntity( ID )
	local Context = EXPADV.GetEntityContext( ID )

	if !Context then return end

	if IsValid( Context.Entity ) then return Context.Entity end

	return setmetatable( { 
		IsValid = function( ) return true end,
		EntIndex = function( ) return ID end,
		GetOwner = function( ) return Context.player end,

		Context = Context,
		player = Context.player

	}, __ENT )
end]]

