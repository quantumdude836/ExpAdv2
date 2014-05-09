/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Create A Base Compoent
   --- */

EXPADV.BaseCompoent = { Default_Enabled = false }

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Class Support
   --- */

function EXPADV.BaseCompoent:AddClass( Name, Short )
	return EXPADV.AddClass( self, Name, Short )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Operator Support
   --- */

function EXPADV.BaseCompoent:AddInlineOperator( Name, Input, Return, Inline )
	return EXPADV.AddInlineOperator( self, Name, Input, Return, Inline )
end

function EXPADV.BaseCompoent:AddPreparedOperator( Name, Input, Return, Prepare, Inline )
	return EXPADV.AddPreparedOperator( self, Name, Input, Return, Prepare, Inline )
end

function EXPADV.BaseCompoent:AddVMOperator( Name, Input, Return, Function ) -- function( Trace, Context, ... )
	return EXPADV.AddVMOperator( self, Name, Input, Return, Function )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Function Support
   --- */

function EXPADV.BaseCompoent:AddInlineFunction( Name, Input, Return, Inline )
	return EXPADV.AddInlineFunction( self, Name, Input, Return, Inline )
end

function EXPADV.BaseCompoent:AddPreparedFunction( Name, Input, Return, Prepare, Inline )
	return EXPADV.AddPreparedFunction( self, Name, Input, Return, Prepare, Inline )
end

function EXPADV.BaseCompoent:AddVMFunction( Name, Input, Return, Function ) -- function( Trace, Context, ... )
	return EXPADV.AddVMFunction( self, Name, Input, Return, Function )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Function Helper Data
   --- */

function EXPADV.BaseCompoent:AddFunctionHelper( Name, Input, Description )
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
	local Component = setmetatable( { Name = Name, Default_Enabled = Enabled }, EXPADV.BaseCompoent )

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
			Component.Enabled = Default_Enabled
			EXPADV.Config.EnabledComponents[ Component.Name ] = Default_Enabled
		end

		if !Component.Enabled then return end

		if Component.OnEnable then Component.OnEnable( ) end

		EXPADV.Components[ Component.Name ] = Component
	end

end