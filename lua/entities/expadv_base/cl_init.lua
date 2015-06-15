/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Base Class
   --- */

include( "shared.lua" )
include( "vars.lua" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Receive Code
   --- */
   
function ENT:ReceiveScript(script, owner)
	self.root = script
	self.files = {}
	self.player = owner

	if script ~= "" then
		self:CompileScript( self.root, self.files )
	end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Render
   --- */


function ENT:Draw( )
	self:DrawModel()
end

function ENT:GetOverlayPos( )
	return self:GetPos( )
end
