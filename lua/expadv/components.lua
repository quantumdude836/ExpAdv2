/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Create A Base Compoent
   --- */

EXPADV.EXPADV_BaseComponent = { Default_Enabled = false }

EXPADV.EXPADV_BaseComponent.__index = EXPADV.EXPADV_BaseComponent

local BaseComponent = EXPADV.EXPADV_BaseComponent

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Class Support
   --- */

function BaseComponent:AddClass( Name, Short )
	return EXPADV.AddClass( self, Name, Short )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Operator Support
   --- */

function BaseComponent:AddInlineOperator( Name, Input, Return, Inline )
	return EXPADV.AddInlineOperator( self, Name, Input, Return, Inline )
end

function BaseComponent:AddPreparedOperator( Name, Input, Return, Prepare, Inline )
	return EXPADV.AddPreparedOperator( self, Name, Input, Return, Prepare, Inline )
end

function BaseComponent:AddVMOperator( Name, Input, Return, Function ) -- function( Trace, Context, ... )
	return EXPADV.AddVMOperator( self, Name, Input, Return, Function )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Function Support
   --- */

function BaseComponent:AddInlineFunction( Name, Input, Return, Inline )
	return EXPADV.AddInlineFunction( self, Name, Input, Return, Inline )
end

function BaseComponent:AddPreparedFunction( Name, Input, Return, Prepare, Inline )
	return EXPADV.AddPreparedFunction( self, Name, Input, Return, Prepare, Inline )
end

function BaseComponent:AddVMFunction( Name, Input, Return, Function ) -- function( Trace, Context, ... )
	return EXPADV.AddVMFunction( self, Name, Input, Return, Function )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Function Helper Data
   --- */

function BaseComponent:AddFunctionHelper( Name, Input, Description )
	return EXPADV.AddFunctionHelper( self, Name, Input, Description )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Component Settings
   --- */

   -- TODO

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: New Component
   --- */

local Temp_Components = { }

function EXPADV.AddComponent( Name, Enabled )
	local Component = setmetatable( { Name = Name, Default_Enabled = Enabled }, BaseComponent )

	Temp_Components[Name] = Component

	return Component
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Load Components
   --- */

function EXPADV.LoadComponents( )
	EXPADV.Components = { }

	for _, Component in pairs( Temp_Components ) do

		if EXPADV.Config.EnabledComponents[ Component.Name ] ~= nil then
			Component.Enabled = EXPADV.Config.EnabledComponents[ Component.Name ]
		else
			Component.Enabled = Component.Default_Enabled
			EXPADV.Config.EnabledComponents[ Component.Name ] = Component.Default_Enabled
		end

		if !Component.Enabled then
			MsgN( "Skipping component: " .. Component.Name )
			continue
		end

		MsgN( "Registered component: " .. Component.Name )

		if Component.OnEnable then Component.OnEnable( ) end

		EXPADV.Components[ Component.Name ] = Component
	end

end