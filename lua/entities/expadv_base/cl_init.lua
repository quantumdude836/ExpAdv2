/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Base Class
   --- */

include( "shared.lua" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: [vNet] Receive Code
   --- */

local vNet = require( "vnet" ) -- Nope, You may not know what this is yet :D

function ENT:ReceivePackage( Package )
	local Received = Package:Table( )

	if Received.root then
		self.root = Received.root
		self.files = Received.files
	end

end