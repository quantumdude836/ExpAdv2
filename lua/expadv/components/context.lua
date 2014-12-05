/* --- --------------------------------------------------------------------------------
	@: Context Component
	@: Author: Ripmax
	@: Comment: Rusketh doesn't like this.
   --- */

local Component = EXPADV.AddComponent( "context", true )

Component.Author = "Ripmax"
Component.Description = "Allows adding to the context menu."

function Component:OnRegisterContext(Context) Context.Data.CustomMenus = {} end

EXPADV.ClientOperators()

Component:AddPreparedFunction("addContextMenu", "s,s,d", "", [[Context.Data.CustomMenus[@value 1] = {Name = @value 2, Callback = @value 3}]])
Component:AddFunctionHelper("addContextMenu", "s,s,d", "Adds an option to the chip's context menu.")

Component:AddPreparedFunction("removeContextMenu", "s", "", [[table.remove(Context.Data.CustomMenus, @value 1]])
Component:AddFunctionHelper("removeContextMenu", "s", "Removes a custom option from the chip's context menu.")

function Component:OnOpenContextMenu( Entity, Menu, Trace, Option )
	local Context = Entity.Context
	for k, v in pairs(Context.Data.CustomMenus) do
		Menu:AddOption(v.Name, function() v.Callback(Context) end)
	end
end