if !EXPADV then return ErrorNoHalt( "Expression Advanced 2, Failed to load tool." ) end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Language
   --- */

if CLIENT then
	language.Add( "Tool.expadv2.name", "Expression Advanced 01000000" )
	language.Add( "Tool.expadv2.desc", "Creats an ingame scriptable entity." )
	language.Add( "Tool.expadv2.help", "TODO - Replace me!" )
	language.Add( "Tool.expadv2.0", "TODO - Fuck me!." )
	
	language.Add( "sboxlimit_expadv", "Expression Advanced entity limit reached." )
	language.Add( "Undone_expadv", "Expression Advanced - Removed." )
	language.Add( "Cleanup_expadv", "Expression Advanced - Removed." )
	language.Add( "Cleaned_expadvs", "Expression Advanced - Removed all entitys." )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Tool Information
   --- */

if WireLib then
	TOOL.Name						= "Expression Advanced 2"
	TOOL.Category					= "Wire - Control"
	TOOL.Wire_MultiCategories		= "Chips, Gates"
	TOOL.Tab						= "Wire"
else
	TOOL.Name						= "Expression Advanced 2"
	TOOL.Category					= "Scriptable"
	TOOL.Tab						= "Tools"
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Cvars
   --- */

TOOL.ClientConVar.Model 		= "models/lemongate/lemongate.mdl"
TOOL.ClientConVar.Weldworld 	= 0
TOOL.ClientConVar.Frozen		= 0

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Model List
   --- */

list.Set( "expadv2.models", "models/lemongate/lemongate.mdl", { } )

if WireLib then
	list.Set( "expadv2.models", "models/bull/gates/processor.mdl", { } )
	list.Set( "expadv2.models", "models/expression 2/cpu_controller.mdl", { } )
	list.Set( "expadv2.models", "models/expression 2/cpu_expression.mdl", { } )
	list.Set( "expadv2.models", "models/expression 2/cpu_interface.mdl", { } )
	list.Set( "expadv2.models", "models/expression 2/cpu_microchip.mdl", { } )
	list.Set( "expadv2.models", "models/expression 2/cpu_processor.mdl", { } )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Clean up
   --- */

cleanup.Register( "expadv" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Utility
   --- */

local function IsExpAdv( Entity )
	if !IsValid( Entity ) then return false end
	return Entity.Base == "expadv_base"
end -- TODO: Use somthing other then base class comparason.

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Right Click
   --- */

function TOOL:RightClick( Trace )
	if !IsValid( Trace.Entity ) then
		self:GetOwner( ):SendLua( "EXPADV.Editor.Open( )" )
		return false
	end
end

