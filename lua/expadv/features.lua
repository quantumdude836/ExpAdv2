/* --- --------------------------------------------------------------------------------
	@: Features 
   --- */

local Temp_Features = { }

function EXPADV.AddFeature( Component, Name, Description, Icon )
	Temp_Features[#Temp_Features + 1] = {
		Component = Component,
		Description = Description,
		Name = Name, Icon = Icon
	}
end

function EXPADV.LoadFeatures( )
	EXPADV.Features = { }

	EXPADV.CallHook( "PreLoadFeatures" )

	for I = 1, #Temp_Features do

		local Feature = Temp_Features[I]
		if Feature.Component and !Feature.Component.Enabled then continue end

		EXPADV.Features[Feature.Name] = Feature
	end
end

/* --- --------------------------------------------------------------------------------
	@: Events
   --- */

hook.Add( "Expadv.PreLoadEvents", "expadv.features",
	function( )
		EXPADV.ClientEvents( )
		EXPADV.AddEvent( nil, "enableFeature", "s", "" )
		EXPADV.AddEvent( nil, "disableFeature", "s", "" )
	end )

hook.Add( "Expadv.PreLoadFunctions", "expadv.features",
	function( )
		EXPADV.ClientOperators( )
		EXPADV.AddInlineFunction( nil, "canAccessFeature", "s", "b", "EXPADV.EntityCanAccessFeature(Context.entity, @value 1)")
	end )

if CLIENT then
	hook.Add( "Expadv.ChangeFeatureAccess", "expadv.features",
		function( Entity, Feature, Value)
			if Entity.Context and Entity.Context.Online then
				if Value then
					Entity:CallEvent("enableFeature", Feature)
				else
					Entity:CallEvent("disableFeature", Feature)
				end
			end
		end )
end

/* --- --------------------------------------------------------------------------------
	@: Build A Database
   --- */

if CLIENT then

	local DB = { }

	hook.Add( "Expadv.PostLoadCore", "expadv.features", function( )
		/*if !sql.TableExists( "expadv_features" ) then
			sql.Query( "CREATE TABLE expadv_features (steam text);" )
		end

		local Colums = { }
		local Status = sql.Query( "PRAGMA table_info(expadv_features);" )

		for I = 1, #Status do
			Colums[Status[I].name] = true
		end

		sql.Begin( )

		for Key, Value in pairs( EXPADV.Features ) do
			if Colums[Key] then continue end

			sql.Query( "ALTER TABLE expadv_features ADD COLUMN " .. sql.SQLStr(Key) .. " INT;" )
		end

		sql.Commit()*/

		//Once upone a time that was a database.

		if file.Exists("expadv/features.txt", "DATA") then
			DB = von.deserialize(file.Read("expadv/features.txt", "DATA") or "")
		end
	end )

/* --- --------------------------------------------------------------------------------
	@: Use the Database
   --- */

	function EXPADV.SetAccessToFeature( Player, Feature, bBool )
		if !EXPADV.Features[Feature] then return end

		if IsValid(Player) then
			/*if tobool( sql.Query( string.format("IF EXISTS (SELECT * FROM expadv_features WHERE steam = `%s`", sql.SQLStr(Player:SteamID()) ))) then
				sql.Query( string.format( "UPDATE expadv_features SET %s = `%i` WHERE steam = `%s`;", sql.SQLStr(Feature, true), bBool and 1 or 0, sql.SQLStr(Player:SteamID()) )  )
			else
				sql.Query( string.format( "INSERT INTO expadv_features (steam, %s) VALUES (`%s`, `%i`);", sql.SQLStr(Player:SteamID()), sql.SQLStr(Feature), bBool and 1 or 0 )  )
			end*/

			//Once upone a time that was a database.

			local Steam = Player:SteamID()
			DB[Steam] = DB[Steam] or { }
			DB[Steam][Feature] = bBool and 1 or 0
			file.Write("expadv/features.txt", von.serialize( DB ) )
		end
	end

	function EXPADV.GetAccessToFeature( Player, Feature )
		if !EXPADV.Features[Feature] then return false end
		
		if IsValid(Player) then
			//return tobool( sql.QueryValue( string.format( "SELECT %s FROM expadv_features WHERE steam = `%s`;", sql.SQLStr(Feature), sql.SQLStr(Player:SteamID()) )  ) )
		
			local Steam = Player:SteamID()
			if DB[Steam] then
				return tobool(DB[Steam][Feature] or 0)
			end
		end

		return false
	end

	function EXPADV.SetGlobalAccessToFeature( Feature, bBool )
		if !EXPADV.Features[Feature] then return end
		
		/*if tobool( sql.Query( string.format("IF EXISTS (SELECT * FROM expadv_features WHERE steam = `%s`", sql.SQLStr("GLOBAL") ))) then
			sql.Query( string.format( "UPDATE expadv_features SET %s = %i WHERE steam = '%s';", sql.SQLStr(Feature), bBool and 1 or 0, sql.SQLStr("GLOBAL") )  )
		else
			sql.Query( string.format( "INSERT INTO expadv_features (steam, %s) VALUES (`%s`, `%i`);", sql.SQLStr("GLOBAL"), sql.SQLStr(Feature), bBool and 1 or 0 )  )
		end*/

		//Once upone a time that was a database.

		DB["GLOBAL"] = DB["GLOBAL"] or { }
		DB["GLOBAL"][Feature] = bBool and 1 or 0
		file.Write("expadv/features.txt", von.serialize( DB ) )
	end

	function EXPADV.GetGlobalAccessToFeature( Feature )
		if !EXPADV.Features[Feature] then return false end
		//return tobool( sql.QueryValue( string.format( "SELECT %s FROM expadv_features WHERE steam = `%s`;", sql.SQLStr(Feature), sql.SQLStr("GLOBAL") )  ) )
		
		if DB["GLOBAL"] then
			return tobool(DB["GLOBAL"][Feature] or 0)
		end

		return false
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

		if Entity.GetLinkedPod then
			local Pod = Entity:GetLinkedPod()

			if IsValid(Pod) and !(Pod:GetDriver() ~= LocalPlayer()) then
				return true
			end
		end

		if !EXPADV.Features[Feature] then return false end

		if EXPADV.GetGlobalAccessToFeature( Feature ) then return true end

		if EXPADV.GetAccessToFeature( Entity.player, Feature ) then return true end

		if EXPADV.GetAcessToFeatureForEntity( Entity, Feature ) then return true end

		--if EXPADV.PPCheck( Player, Entity ) then return true end

		return false
	end

/* --- --------------------------------------------------------------------------------
	@: Need a way to keep track of this.
   --- */

	local Memory = { }

	local function UpdateEntity(Entity, Feature)
		local Value = EXPADV.CanAccessFeature( Entity, Feature )

		Memory[Entity] = Memory[Entity] or { }

		if Value ~= Memory[Entity][Feature] then
			Memory[Entity][Feature] = Value
			EXPADV.CallHook("ChangeFeatureAccess", Entity, Feature, Value)
		end
	end

	function EXPADV.EntityCanAccessFeature(Entity, Feature)
		if !Memory[Entity] then return false end
		return Memory[Entity][Feature] or false
	end

/* --- --------------------------------------------------------------------------------
	@: Add Menu Option
   --- */
   	
   	function EXPADV.ShowFeatures(Entity)
   		if IsValid(EXPADV.FeaturesPanel) then
   			EXPADV.FeaturesPanel:Remove()
   		end

   		local Frame = vgui.Create( "EA_Frame" )
		Frame:SetText( "Expression Advanced 2 - Features" )
		Frame:SetSize( 300, 190 )
		Frame:DockPadding( 5, 24 + 5, 5, 5 )
		Frame:Center( )
		Frame:MakePopup( )

		EXPADV.FeaturesPanel = Frame

		local Owner = Entity.player or EXPADV.GetOwner(Entity)

		local Panel = Frame:Add("DPanel")
		Panel.Paint = function() end
		Panel:DockPadding(2, 2, 2, 2)
		Panel:SetTall(64)
		Panel:Dock(TOP)

		local Avitar = Panel:Add("AvatarImage")
		Avitar:SetSize(64, 64)
		Avitar:SetPlayer( Owner, 64 )
		Avitar:Dock(LEFT)

		local Label = Panel:Add("DLabel")
		Label:SetTextColor(Color(0,0,0))
		Label:SizeToContents()
		Label:DockMargin(2,2,2,2)
		Label:Dock(FILL)

		function Label.Think()
			if !IsValid(Entity) then return end
			local Counter = Entity.ClientTickQuota or 0
   			local Line = string.format( "Quota: %s, %i%% (usage %s @ %s us)", EXPADV.Shorten( Counter ), (Counter / expadv_hardquota) * 100, EXPADV.Shorten(Entity.ClientAverage or 0 ), EXPADV.Shorten(Entity.ClientStopWatch or 0) )
			Label:SetText(string.format("Owner: %s\nScript: %s\n%s\nEntity: %s", IsValid(Owner) and Owner:Name() or "Unkown", Entity:GetGateName() or "generic", Line, tostring(Entity)))
		end

		local GlobalPanel = Frame:Add("DPanel")
		GlobalPanel:SetTall(22)
		GlobalPanel:Dock(BOTTOM)
		GlobalPanel:DockPadding(2,2,2,2)

		function GlobalPanel:Paint()
			draw.SimpleText("Global:", "default", 5, 11, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end

		local PlayerPanel

		if Owner ~= LocalPlayer() then
			PlayerPanel = Frame:Add("DPanel")
			PlayerPanel:SetTall(22)
			PlayerPanel:Dock(BOTTOM)
			PlayerPanel:DockPadding(2,2,2,2)

			function PlayerPanel:Paint()
				draw.SimpleText("Owner:", "default", 5, 11, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			end
		end

		local EntityPanel = Frame:Add("DPanel")
		EntityPanel:SetTall(22)
		EntityPanel:Dock(BOTTOM)
		EntityPanel:DockPadding(2,2,2,2)

		function EntityPanel:Paint()
			draw.SimpleText("Entity:", "default", 5, 11, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end

		local IconsPanel = Frame:Add("DPanel")
		IconsPanel:SetTall(22)
		IconsPanel:Dock(BOTTOM)
		IconsPanel:DockPadding(2,2,2,2)

		function IconsPanel:Paint()
		end

		for Feature, Info in pairs(EXPADV.Features) do
			local Icon = IconsPanel:Add("DImageButton")
			Icon:SetSize(20,20)
			Icon:SetImage(Info.Icon or "fugue/bug.png")
			Icon:SetTooltip(string.format("%s: %s", Feature, Info.Description or ""))
			Icon:Dock(RIGHT)

			local EntBtn = EntityPanel:Add("DImageButton")
			EntBtn:SetSize(20,20)
			EntBtn:SetImage( EXPADV.GetAcessToFeatureForEntity( Entity, Feature ) and "fugue/tick.png" or "fugue/cross-script.png")
			EntBtn:SetTooltip(string.format("%s: %s", Feature, Info.Description or ""))
			EntBtn:Dock(RIGHT)

			if Owner ~= LocalPlayer() then
				local PlyBtn = PlayerPanel:Add("DImageButton")
				PlyBtn:SetSize(20,20)
				PlyBtn:SetImage(EXPADV.GetAccessToFeature( Owner, Feature ) and "fugue/tick.png" or "fugue/cross-script.png")
				PlyBtn:SetTooltip(string.format("%s: %s", Feature, Info.Description or ""))
				PlyBtn:Dock(RIGHT)
			end

			local GlobBtn = GlobalPanel:Add("DImageButton")
			GlobBtn:SetSize(20,20)
			GlobBtn:SetImage(EXPADV.GetGlobalAccessToFeature( Feature ) and "fugue/tick.png" or "fugue/cross-script.png")
			GlobBtn:SetTooltip(string.format("%s: %s", Feature, Info.Description or ""))
			GlobBtn:Dock(RIGHT)

			function EntBtn.DoClick()
				local Value = !EXPADV.GetAcessToFeatureForEntity( Entity, Feature )
				EXPADV.SetAcessToFeatureForEntity( Entity, Feature, Value )
				EntBtn:SetImage(Value and "fugue/tick.png" or "fugue/cross-script.png")
				UpdateEntity(Entity, Feature)
			end

			if Owner ~= LocalPlayer() then
				function PlyBtn.DoClick()
					local Value = !EXPADV.GetAccessToFeature( Owner, Feature )
					EXPADV.SetAccessToFeature( Owner, Feature, Value )
					PlyBtn:SetImage(Value and "fugue/tick.png" or "fugue/cross-script.png")
					
					for Context, _ in pairs( EXPADV.CONTEXT_REGISTERY ) do
						if !Context.Online then continue end
						if Context.player ~= Owner then return end
						UpdateEntity(Context.entity, Feature)
					end
				end
			end

			function GlobBtn.DoClick()
				local Value = !EXPADV.GetGlobalAccessToFeature( Feature )
				EXPADV.SetGlobalAccessToFeature( Feature, Value )
				GlobBtn:SetImage(Value and "fugue/tick.png" or "fugue/cross-script.png")
				
				for Context, _ in pairs( EXPADV.CONTEXT_REGISTERY ) do
					if !Context.Online then continue end
					UpdateEntity(Context.entity, Feature)
				end
			end
		end
   	end

/* --- --------------------------------------------------------------------------------
	@: Add Menu Option
   --- */

   hook.Add( "Expadv.OpenContextMenu", "expadv.features",
   		function( Entity, Menu, Trace, Option )
			Menu:AddOption("Show Features", function() EXPADV.ShowFeatures(Entity) end)
		end )
end
