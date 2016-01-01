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
		Unsorted[ #Unsorted + 1 ] = { Variable, Cell.ClassObj.Wire_in_type }
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
	local Unsorted = { }

	for Variable, Reference in pairs( Ports ) do
		local Cell = Cells[ Reference ]
		Unsorted[ #Unsorted + 1 ] = { Variable, Cell.ClassObj.Wire_out_type }
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
		if Port.Type ~= Class.Wire_in_type then continue end

		Context.Memory[MemRef] = EXPADV.ConvertFromWire(Class.Short, Port.Value, Context)
	end
end

function ENT:TriggerInput( Key, Value )
	local Context = self.Context
	if !Context then return end

	local Reference = self.InPorts[ Key ]
	local Cell = self.Cells[ Reference ]
	if !Cell then return end

	Context.Memory[Reference] = EXPADV.ConvertFromWire(Cell.ClassObj.Short, Value, Context)
	
	Context.Trigger[ Reference ] = true

	self:CallEvent( "trigger", Key, Cell.ClassObj.Name )

	Context.Trigger[Reference] = false

	if Cell.Client and Cell.ClassObj.ReadFromNet then
		self.SyncQueue[Reference] = true
		self.SyncQueued = true
	end
end

function ENT:TriggerOutputs( )
	local Context = self.Context
	if !Context then return end

	local Cells = self.Cells

	for Name, MemRef in pairs( self.OutPorts ) do
		local Class = Cells[MemRef].ClassObj
		local Value = Context.Memory[MemRef]

		if Value == nil then continue end
		//TODO: Possibly output default Value here :D
			
		if Context.Trigger[MemRef] or Context.TrigMan[Value] then
			local WireVal = EXPADV.ConvertToWire(Class.Short, Value, Context)
			
			WireLib.TriggerOutput( self, Name, WireVal )
		end
	end

	Context.TrigMan = {}
end
