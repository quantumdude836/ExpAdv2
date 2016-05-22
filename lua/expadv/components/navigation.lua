/* -----------------------------------------------------------------------------------
	@: NavMesh and CNavArea.
   --- */

local Component = EXPADV.AddComponent( "navigation", true )

Component.Author = "Rusketh"
Component.Description = "This component helps with pathing and navigation."


EXPADV.ServerOperators( )

/* -----------------------------------------------------------------------------------
	@: Class
   --- */

local NavObj = Component:AddClass( "area" , "cna" )

NavObj:MakeServerOnly( )

NavObj:AddPreparedOperator( "=", "n,cna", "", "Context.Memory[@value 1] = @value 2" )

/* -----------------------------------------------------------------------------------
	@: NavMesh Functions
   --- */

local Areas = {}

Component:AddVMFunction( "getMapArea", "n", "cna",
	function(Context, Trace, ID)
		if Areas[ID] then return Areas[ID] end

		local Area = navmesh.GetNavAreaByID(ID)
		Areas[ID] = Area
		return Area
	end)
Component:AddFunctionHelper( "getMapArea", "n", "Returns the Navigation Area by the given ID." )

Component:AddInlineFunction( "countMapAreas", "", "n", "$navmesh.GetNavAreaCount()" )
Component:AddFunctionHelper( "countMapAreas", "", "Returns the count of how many Navigation Areas are currently loaded in the map." )

Component:AddInlineFunction( "getMapArea", "v,n", "cna", "$navmesh.GetNavArea(@value 1, @value 2)" )
Component:AddFunctionHelper( "getMapArea", "v,n", "Returns the Navigation Area contained in this position that also satisfies the elevation limit." )

Component:AddPreparedFunction( "findMapArea", "v,n,n,n", "ar", [[
	@define Array = $navmesh.Find( @value 1, @value 2, @value 3, @value 4 )
	if !@Array then @Array = {} end
	@Array.__type = "_cna"
]], "@Array" )
Component:AddFunctionHelper( "findMapArea", "v,n,n,n", "Returns an array of areas within distance; (The position to search around, Radius to search within, Maximum fall distance allowed, Maximum jump height allowed)." )

/* -----------------------------------------------------------------------------------
	@: CNavArea Functions
   --- */

Component:AddInlineFunction( "id", "cna:", "n", "(@value 1 and @value 1:GetID() or -1)" )
Component:AddFunctionHelper( "id", "cna:", "Returns this area's unique ID." )

Component:AddInlineFunction( "contains", "cna:v", "b", "(@value 1 and @value 1:Contains(@value 2))" )
Component:AddFunctionHelper( "contains", "cna:v", "Returns whether this Navigation Area contains the given vector." )

Component:AddInlineFunction( "closestPointOnArea", "cna:v", "v", "(@value 1 and @value 1:GetClosestPointOnArea(@value 2) or Vector(0,0,0))" )
Component:AddFunctionHelper( "closestPointOnArea", "cna:v", "Returns whether this Navigation Area contains the given vector." )

Component:AddInlineFunction( "getCorner", "cna:n", "v", "(@value 1 and @value 1:GetCorner(math.Clamp(math.floor(@value 2), 1, 4) - 1) or Vector(0, 0, 0))" )
Component:AddFunctionHelper( "getCorner", "cna:n", "Returns the position for the corner of a navigation area (1 - 4)." )

Component:AddPreparedFunction( "exposedSpots", "cna:", "ar", [[
	@define Array = {}

	if @value 1 then @Array = @value 1:GetExposedSpots( ) end

	@Array.__type = "v"
]], "@Array" )
Component:AddFunctionHelper( "exposedSpots", "cna:", "Returns an array of very bad hiding spots in this area." )

Component:AddPreparedFunction( "hidingSpots", "cna:", "ar", [[
	@define Array = {}

	if @value 1 then @Array = @value 1:GetHidingSpots( ) end

	@Array.__type = "v"
]], "@Array" )
Component:AddFunctionHelper( "hidingSpots", "cna:", "Returns an array of good hiding spots in this area." )

Component:AddInlineFunction( "getSize", "cna:", "v2", "(@value 1 and Vector2(@value 1:GetSizeX(), @value 1:GetSizeY()) or Vector2(0,0))" )
Component:AddFunctionHelper( "getSize", "cna:", "Returns the width (x) and height (y) of this Navigation Area." )

Component:AddInlineFunction( "getZ", "cna:v", "n", "(@value 1 and @value 1:GetZ(@value 2) or 0)" )
Component:AddFunctionHelper( "getZ", "cna:v", "Returns the elevation of this Nav Area at the given position (Z is ignored)." )

Component:AddInlineFunction( "getZ", "cna:v2", "n", "(@value 1 and @value 1:GetZ(Vector(@value 2.x, @value 2.y)) or 0)" )
Component:AddFunctionHelper( "getZ", "cna:v2", "Returns the elevation of this Nav Area at the given position." )

Component:AddInlineFunction( "isCoplanar", "cna:cna", "b", "(@value 1 and @value 1:IsCoplanar(@value 2))" )
Component:AddFunctionHelper( "isCoplanar", "cna:cna", "Whether this Navigation Area is in the same plane as the given one." )

Component:AddInlineFunction( "isFlat", "cna:", "b", "(@value 1 and @value 1:IsFlat())" )
Component:AddFunctionHelper( "isFlat", "cna:", "Returns if this Navigation Area is flat within the tolerance of the nav_coplanar_slope_limit_displacement and nav_coplanar_slope_limit convars." )

Component:AddInlineFunction( "isSquare", "cna:", "b", "(@value 1 and @value 1:IsRoughlySquare())" )
Component:AddFunctionHelper( "isSquare", "cna:", "Returns if this Navigation Area is shaped like a square." )

Component:AddInlineFunction( "isUnderwater", "cna:", "b", "(@value 1 and @value 1:IsUnderwater())" )
Component:AddFunctionHelper( "isUnderwater", "cna:", "Returns if this Navigation Area is underwater or not." )

Component:AddInlineFunction( "isOverlapping", "cna:v,n", "b", "(@value 1 and @value 1:IsOverlapping(@value 1, @value 2))" )
Component:AddFunctionHelper( "isOverlapping", "cna:v,n", "Returns if this position overlaps the Navigation Area within the given tolerance (use 0 for no tolerance)." )

Component:AddInlineFunction( "isVisible", "cna:v", "b", "(@value 1 and @value 1:IsVisible(@value 2))" )
Component:AddFunctionHelper( "isVisible", "cna:v", "Returns whether we can be seen from the given position." )
-- TODO: ^This returns a second argument (vector).
