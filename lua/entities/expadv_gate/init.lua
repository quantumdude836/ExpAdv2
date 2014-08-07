/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: ExpAdv2 Entity!
   --- */

include( "shared.lua" )
AddCSLuaFile( "shared.lua" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Print Outs
   --- */

function ENT:OnLuaError( Context, Msg )
	EXPAD.PrintColor( self.player, Color( 255, 0, 0 ), "Expresion Advanced - Error: ", Color( 255, 255, 255 ), Msg )
end

function ENT:OnScriptError( Context, Msg )
	EXPAD.PrintColor( self.player, Color( 255, 0, 0 ), "Expresion Advanced - Script Error: ", Color( 255, 255, 255 ), Msg )
end

function ENT:OnUncatchedException( Context, Exception )
	EXPAD.PrintColor( self.player, Color( 255, 0, 0 ), "Expresion Advanced - Uncatched exception: ", Color( 255, 255, 255 ), Exception.Exception, " -> ", Execption.Msg )
end

function ENT:OnCompileError( ErMsg, Compiler )
	EXPAD.PrintColor( self.player, Color( 255, 0, 0 ), "Expresion Advanced - Validate Error: ", Color( 255, 255, 255 ), ErMsg )
end

-- function ENT:OnStartUp( Context ) end

-- function ENT:OnShutDown( Context ) end

-- function ENT:OnContextUpdate( Context ) end