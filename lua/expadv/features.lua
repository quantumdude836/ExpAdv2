/* --- --------------------------------------------------------------------------------
	@: Features 
   --- */

local Temp_Features = { }

function EXPADV.AddFeature( Component, Name, Description )
	Temp_Features[#Temp_Features + 1] = {
		Component = Component,
		Description = Description,
		Name = Name
	}
end

function EXPADV.LoadFeatures( )
	EXPADV.Features = { }

	EXPADV.CallHook( "PreLoadFeatures" )

	for I = 1, #Temp_Features do

		local Feature = Temp_Features[I]
		if Feature.Component and !Feature.Component.Enabled then continue end

		EXPADV.Features[Feature.Name] = Feature.Description or "N/A"
	end
end

/* --- --------------------------------------------------------------------------------
	@: Events
   --- */

hook.Add( "Expadv.PreLoadEvents", "expadv.features", function( )
	EXPADV.ClientEvents( )
	EXPADV.AddEvent( nil, "playerEnableFeature", "ply", "" )
	EXPADV.AddEvent( nil, "playerDisableFeature", "ply", "" )
end )

/* --- --------------------------------------------------------------------------------
	@: Build A Database
   --- */

if CLIENT then

	hook.Add( "Expadv.PostLoadCore", "expadv.features", function( )
		if !sql.TableExists( "expadv_features" ) then
			sql.Query( "CREATE TABLE expadv_features (steam text);" )
		end

		local Colums = { }
		local Status = sql.Query( "PRAGMA table_info(expadv_features);" )

		for I = 1, #Status do
			Colum = Status[I]
			Colums[Colum.name] = Colum
		end

		sql.Begin( )

		for Key, Value in pairs( EXPADV.Features ) do
			local Feature = sql.SQLStr(Key)
			
			if Colums[Feature] then continue end

			sql.Query( "ALTER TABLE expadv_features ADD COLUMN " .. Feature .. " INT;" )
		end

		sql.Commit( )
	end )

	function EXPADV.SetAccessToFeature( Player, Feature, bBool )
		if !EXPADV.Features[Feature] then return end
		local Steam = Player and Player:SteamID() or "GLOBAL"
		sql.Query( string.format( "UPDATE expadv_features SET %s = %i WHERE steam = %s;", sql.SQLStr(Feature), bBool or 1 and 0, sql.SQLStr(Steam) )  )
	end

	function EXPADV.GetAccessToFeature( Player, Feature )
		if !EXPADV.Features[Feature] then return false end
		local Steam = Player and Player:SteamID() or "GLOBAL"
		return tobool( sql.QueryValue( string.format( "SELECT %s FROM expadv_features WHERE steam = %s;", sql.SQLStr(Feature), sql.SQLStr(Steam) )  ) )
	end

	function EXPADV.SetAcessToFeatureForEntity( Entity, Feature, bBool )
		if !Entity.Features then Entity.Features = { } end

		Entity.Features[Feature] = bBool
	end

	function EXPADV.GetAcessToFeatureForEntity( Entity, Feature )
		if !Entity.Features then return false end

		return Entity.Features[Feature] or false
	end
 
	function EXPADV.CanAccessFeature( Entity, Feature )

		if Entity.player == LocalPlayer() then return true end

		if !EXPADV.Features[Feature] then return false end

		if EXPADV.GetAccessToFeature( nil, Feature ) then return true end

		if EXPADV.GetAccessToFeature( Entity.player, Feature ) then return true end

		if EXPADV.GetAcessToFeatureForEntity( Entity, Feature ) then return true end

		if EXPADV.PPCheck( Player, Entity ) then return true end

		return false
	end
end
