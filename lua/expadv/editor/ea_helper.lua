/*============================================================================================================================================
	Expression-Advanced Derma
==============================================================================================================================================
	Name: EA_Helper
	Author: Oskar
============================================================================================================================================*/

local PANEL = { } 
local tHelperIndex = { } 

local string_lower = string.lower

// TODO: 
// Replace the ea_browser to a better visual representation
// Make the self.Syntax get a better string using the data avible instead of self.Data.Sig

function PANEL:Init( )
	self:ShowCloseButton( true ) 
	self:SetSizable( true ) 
	self:SetCanMaximize( false ) 
	self:SetMinWidth( 300 ) 
	self:SetMinHeight( 200 ) 
	self:SetIcon( "fugue/magnifier.png" )
	self:SetText( "Expression Advanced 2 helper" ) 
	self:SetSize( cookie.GetNumber( "eahelper_w", 400 ), cookie.GetNumber( "eahelper_h", 600 ) ) 
	self:SetPos( cookie.GetNumber( "eahelper_x", ScrW( ) / 2 - self:GetWide( ) / 2 ), cookie.GetNumber( "eahelper_y", ScrH( ) / 2 - self:GetTall( ) / 2 ) ) 
	
	self.Description = self:Add( "DTextEntry" ) 
	self.Description:Dock( BOTTOM ) 
	self.Description:DockMargin( 5, 0, 5, 5 ) 
	self.Description:SetMultiline( true ) 
	self.Description:SetNumeric( false ) 
	self.Description:SetEnabled( false ) 
	self.Description:SetTall( 70 ) 
	
	self.Syntax = self:Add( "DTextEntry" ) 
	self.Syntax:Dock( BOTTOM ) 
	self.Syntax:DockMargin( 5, 0, 5, 5 ) 
	self.Syntax:SetMultiline( false ) 
	self.Syntax:SetNumeric( false ) 
	self.Syntax:SetEnabled( false ) 
	
	-- self.Search = self:Add( "DTextEntry" ) 
	-- self.Search:Dock( TOP ) 
	-- self.Search:DockMargin( 5, 5, 5, 0 ) 
	-- self.Search:SetMultiline( false ) 
	-- self.Search.OnEnter = function( Search ) end 
	
	self.Browser = self:Add( "EA_Browser" ) 
	self.Browser:Dock( FILL ) 
	self.Browser:DockMargin( 5, 5, 5, 5 ) 
	
	self:SetupData( ) 
end

local function NodeClick( self )
	self.Description:SetText( self.Data.Description ) 
	self.Syntax:SetText( self.Data.Sig )
end

function PANEL:SetupData( )
	self.Browser:Clear( )
	
	for i = 1, #tHelperIndex do 
		local tData = tHelperIndex[i] 
		local dNode = self.Browser:AddNode( tData.Sig, "fugue/script.png" ) 
		dNode.Data = tData 
		dNode.DoClick = NodeClick
		dNode.Description = self.Description
		dNode.Syntax = self.Syntax
	end 
end

function PANEL:Close( )
	self:SetVisible( false ) 
	cookie.Set( "eahelper_x", self.x )
	cookie.Set( "eahelper_y", self.y )
	cookie.Set( "eahelper_w", self:GetWide( ) )
	cookie.Set( "eahelper_h", self:GetTall( ) )
end

vgui.Register( "EA_Helper", PANEL, "EA_Frame" ) 


/*============================================================================================================================================
	Helper Generator
============================================================================================================================================*/

for _, tData in pairs( EXPADV.Functions ) do 
	local tHelperData = { } 
	tHelperData.Name = tData.Name 
	tHelperData.Access = (tData.LoadOnServer and 1 or 0) + (tData.LoadOnClient and 2 or 0)
	tHelperData.Description = tData.Description or "No data." 
	tHelperData.ArgumentNames = tData.InputNames or { }
	tHelperData.Arguments = tData.Inputs or { } 
	tHelperData.Component = tData.Component and (tData.Component.Name or "core") or "core"
	tHelperData.Sig = tData.Signature
	
	-- if not tData.Component then print( tData.Signature ) end 
	
	
	tHelperIndex[#tHelperIndex + 1] = tHelperData
end 

table.sort( tHelperIndex, function( a, b )
	return string_lower( a.Name ) < string_lower( b.Name ) 
end ) 
