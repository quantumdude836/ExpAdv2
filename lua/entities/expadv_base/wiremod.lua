/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Wire Mod
   --- */

if !WireLib then return end

local function SortPorts( PortA, PortB )
	local TypeA = PortA[2] or "NORMAL"
	local TypeB = PortB[2] or "NORMAL"

	if TypeA ~= TypeB then
		if TypeA == "NORMAL" then
			return true
		elseif TypeB == "NORMAL" then
			return false
		end

		return TypeA < TypeB
	else
		return PortA[1] < PortB[1]
	end
end

function ENT:BuildInputs( Cells, Ports )
	local Unsorted = { }

	for Variable, Reference in pairs( Ports ) do
		local Cell = Cells[ Reference ]
		Unsorted[ #Unsorted + 1 ] = { Variable, Cell.ClassObj.Wire_In_Type }
	end

	table.sort( Unsorted, SortPorts )

	local Names = { }
	local Types = { }

	for I = 1, #Unsorted do
		local Port = Unsorted[I]
		Names[I] = Port[1]
		Types[I] = Port[2]
	end

	local OldPorts = self.Inputs

	self.InPorts = Ports
	self.DupeInPorts = { Names, Types }
	self.Inputs = WireLib.AdjustSpecialInputs( self, Names, Types )
end


function ENT:BuildOutputs( Cells, Ports )
	local OutClick = { }
	local Unsorted = { }

	for Variable, Reference in pairs( Ports ) do
		local Cell = Cells[ Reference ]
		Unsorted[ #Unsorted + 1 ] = { Variable, Cell.ClassObj.Wire_Out_Type }

		if Cell.ClassObj.HasUpdateCheck then
			OutClick[ Reference ] = Variable
		end
	end

	table.sort( Unsorted, SortPorts )

	local Names = { }
	local Types = { }

	for I = 1, #Unsorted do
		local Port = Unsorted[I]
		Names[I] = Port[1]
		Types[I] = Port[2]
	end

	local OldPorts = self.Outputs

	self.OutPorts = Ports
	self.OutClick = OutClickt
	self.DupeOutPorts = { Names, Types }

	self.Outputs = WireLib.AdjustSpecialOutputs( self, Names, Types )

	if self.extended then
		WireLib.CreateWirelinkOutput( self.player, self, { true } )
	end -- ^ Re-attaches the wirelink :D
end

function ENT:LoadFromInputs( Cells )
	--Note: This will load inports into memory!

	local Context = self.Context
	
	for Name, Port in pairs( self.Inputs ) do
		local MemRef = self.InPorts[ Name ]
		if !MemRef then continue end

		local Class = Cells[MemRef].ClassObj
		if Port.Type ~= Class.Wire_In_Type then continue end

		Class.Wire_In_Util( Context, MemRef, Port.Value )
	end
end

function ENT:TriggerInput( Key, Value )
	local Context = self.Context
	if !self.Context then return end

	local Reference = self.InPorts[ Key ]
	local Cell = self.Cells[ Reference ]

	if !Cell then return end

	Cell.ClassObj.Wire_In_Util( self.Context, Reference, Value )
	Context.Trigger[ Reference ] = true

	self:CallEvent( "trigger", Key, Cell.ClassObj.Name )

	Context.Trigger[ Reference ] = false
end

function ENT:TriggerOutputs( )
		local Context = self.Context
		if !self.Context then return end

		local Cells = self.Cells

		for Name, Reference in pairs( self.OutPorts ) do
			local Class = Cells[ Reference ].ClassObj

			if Context.Memory[ Reference ] == nil then
				continue
			elseif Context.Trigger[ Reference ] then
				local Value = Class.Wire_Out_Util( Context, Reference )
				WireLib.TriggerOutput( self, Name, Value )
			elseif Context.OutClick[ Reference ] then
				local Val = Context.Memory[ Reference ]

				if Val and Val.HasChanged then
					Val.HasChanged = nil
					local Value = Class.Wire_Out_Util( Context, Reference )
					WireLib.TriggerOutput( self, Name, Value )
				end
			end
		end
end
