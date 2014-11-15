/* --- --------------------------------------------------------------------------------
	@: Context Component
	@: Author: Ripmax
   --- */

local Component = EXPADV.AddComponent( "context", true )

Component.Author = "Ripmax"
Component.Description = "Allows adding to the context menu."

function Component:OnRegisterContext(Context) Context.Data.CustomMenus = {} end

EXPADV.ClientOperators()

Component:AddPreparedFunction("addContextMenu", "s,d", "", [[Context.Data.CustomMenus[string.Trim(string.lower(@value 1))] = {Name = @value 1, Callback = @value 2}]])
Component:AddFunctionHelper("addContextMenu", "s,d", "Adds an option to the chip's context menu.")

function Component:OnOpenContextMenu( Entity, Menu, Trace, Option )
	local Context = Entity.Context
	for k, v in pairs(Context.Data.CustomMenus) do
		Menu:AddOption(v.Name, function() v.Callback(Context) end)
	end
end