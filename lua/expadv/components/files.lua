/* ---	--------------------------------------------------------------------------------
	@: Files
   ---	*/

require("vnet")

file.CreateDir( "expadv/files" )
file.CreateDir( "expadv/userfiles" )

local Component = EXPADV.AddComponent( "file" , true )

Component.Author = "Rusketh"
Component.Description = "Read and write files."

/* --- --------------------------------------------------------------------------------
	@: Settings
   --- */

Component:CreateSetting( "max_filesize", 300 )

/* --- --------------------------------------------------------------------------------
	@: functions
   --- */

EXPADV.SharedOperators()



local function GetValidPath( Context, Path )
	if Path:find( "..", 1, true ) then return false end

	local FilePath = string.GetPathFromFilename( Path )

	if FilePath == "" or FilePath == "/" then FilePath = nil end

	local FileName = string.GetFileFromFilename( Path )

	local Root

	if CLIENT and Context.player == LocalPlayer() then
		Root = "expadv2/files"
	elseif SERVER or Context.entity.EnableFileAccess then
		Root = "expadv2/userfiles/" .. string.gsub(Context.player:SteamID(), ":", "_")
	else
		return false
	end

	if bCreate then
		file.CreateDir(Root)

		if FilePath and !file.Exists(Root .. "/" .. FilePath, "DATA") then
			file.CreateDir(Root .. "/" .. FilePath)
		end
	end

	if FilePath  then
		return Root .. "/" .. FilePath .. "/" .. FileName
	end

	return Root .. "/" .. FileName
end

Component:AddVMFunction( "readFile", "s", "s",
	function( Context, Trace, Path )
		local ValidPath = GetValidPath( Context, Path, false )
		
		return ValidPath and file.Read( ValidPath ) or ""
	end )

Component:AddVMFunction( "writeFile", "s,s", "",
	function( Context, Trace, Path, File )
		if #File < Component:ReadSetting( "max_filesize", 300 ) then
			local ValidPath = GetValidPath( Context, Path, true )
			MsgN("Valid Path: ", ValidPath)
			if ValidPath then
				file.Write( ValidPath, File )
			end
		end
	end )

Component:AddVMFunction( "fileExists", "s", "b",
	function( Context, Trace, Path )
		local ValidPath = GetValidPath( Context, Path, true )
		
		return ValidPath and file.Exists( ValidPath, "DATA" ) or false
	end )

Component:AddVMFunction( "deleteFile", "s", "",
	function( Context, Trace, Path )
		local ValidPath = GetValidPath( Context, Path, true )
		
		if ValidPath then
			file.Delete( ValidPath )
		end
	end )

Component:AddVMFunction( "isDir", "s", "b",
	function( Context, Trace, Path )
		local ValidPath = GetValidPath( Context, Path, true )
		
		return ValidPath and file.IsDir( ValidPath, "DATA" ) or false
	end )

Component:AddVMFunction( "fileSize", "s", "n",
	function( Context, Trace, Path )
		local ValidPath = GetValidPath( Context, Path, true )
		
		return ValidPath and file.Size( ValidPath, "DATA" ) or 0
	end )

Component:AddVMFunction( "findFiles", "s,s", "ar",
	function( Context, Trace, FileName, Path )
		local ValidPath = GetValidPath( Context, Path, true )
		if !ValidPath then return {__type = "s"} end

		local Files, Folders = file.Find( FileName, ValidPath )
		Files.__type = "s"
		return Files
	end )

Component:AddVMFunction( "findFolders", "s,s", "ar",
	function( Context, Trace, FileName, Path )
		local ValidPath = GetValidPath( Context, Path, true )
		if !ValidPath then return {__type = "s"} end

		local Files, Folders = file.Find( FileName, ValidPath )
		Folders.__type = "s"
		return Folders
	end )

EXPADV.ClientOperators()
Component:AddInlineFunction( "canAccessFiles", "", "b", "(IsValid(Context.entity) and (Context.entity.EnableFileAccess or context.player == LocalPlayer()))" )
Component:AddFunctionHelper( "canAccessFiles", "", "Returns true if this entity can access files." )

/* -----------------------------------------------------------------------------------
	@: WIP Features.
   --- */

Component:AddFeature( "file access", "Read and save files.", "fugue/blue-folder-horizontal-open.png" )

EXPADV.SharedEvents( )
Component:AddEvent( "disableFileAccess", "", "" )
Component:AddEvent( "enableFileAccess", "", "" )

if CLIENT then
	function Component:OnChangeFeatureAccess(Entity, Feature, Value)
		if Feature == "file access" then
			if Value then
				Entity:CallEvent( "enableFileAccess" )
			else
				Entity:CallEvent( "disableFileAccess" )
			end
		end
	end
end

