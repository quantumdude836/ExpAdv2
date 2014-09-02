/* --- --------------------------------------------------------------------------------
	@: Peripheral Syetm
   --- */

local Component = EXPADV.AddComponent( "peripheral", true )

/* --- --------------------------------------------------------------------------------
	@: Entity Class
   --- */

local Peripheral = Component:AddClass( "peripheral", "ph" )

Peripheral:ExtendClass( "e" )

/* --- --------------------------------------------------------------------------------
	@: Casting
   --- */

Component:AddInlineOperator( "entity", "ph", "e", "@value 1" )

Component:AddPreparedOperator( "peripheral", "e", "ph", [[
	if !(IsValid(@value 1) and @value 1.IsPeripheral) then @value 1 = Entity(0) end
]], "@value 1" ) -- Because '@value 1' appears multiple times, the compiler turns it into a defintion, so we can use it as such.

/* --- --------------------------------------------------------------------------------
	@: Basic Methods
   --- */

Component:AddInlineFunction( "getType", "ph:", "s", "(IsValid(@value 1) and @value 1.PeripheralName or \"\")" )

Component:AddInlineFunction( "getSlot", "ph:", "n", "(IsValid(@value 1) and @value 1:GetPeripheralSlot(0) or 0)" )

/* --- --------------------------------------------------------------------------------
	@: Get Peripherals
   --- */

Component:AddInlineFunction( "getPeripheral", "n", "ph", "(Context.entity.Peripherals and (Context.entity.Peripherals[@value 1] or Entity(0)) or Entity(0))" )

Component:AddInlineFunction( "getToalPeripherals", "", "n", "(Context.entity.Peripherals and (#Context.entity.Peripherals) or 0)" )

/* --- --------------------------------------------------------------------------------
	@: Perpheral Registery
   --- */

EXPADV.Peripherals = { }

function EXPADV.AddPeripheral( Name, Class, Spawn, Models, ToolMenu )
	EXPADV.Peripherals[Name] = {Name = Name, Class = Class, Models = Models, Spawn = SERVER and Spawn or nil, ToolPanel = CLIENT and ToolMenu or nil}
end

/* --- --------------------------------------------------------------------------------
	@: Screen Peripheral
   --- */

local function MakeScreen( ) end

local ScreenModels = { "models/props_junk/TrafficCone001a.mdl" }

if WireMod then
	for Model, Info in pairs( WireGPU_Monitors ) do
		MsgN( "Added WireScreen for ExpAdv: ", Model )
		table.insert( ScreenModels, Model )
	end
end

EXPADV.AddPeripheral( "Screen", "expadv_screen", MakeScreen, ScreenModels )

EXPADV.AddPeripheral( "Wanker", "expadv_screen", MakeScreen, { "models/props_combine/breenchair.mdl" } )

EXPADV.AddPeripheral( "Nope", "expadv_screen", MakeScreen )