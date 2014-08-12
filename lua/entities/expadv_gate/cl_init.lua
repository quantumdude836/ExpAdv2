/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Client
   --- */

include( "shared.lua" )

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Print Outs
   --- */

function ENT:OnLuaError( Context, Msg )
	chat.AddText( Color( 150, 150, 0 ), "[" .. self.player:Name( ) .. "] ", Color( 255, 0, 0 ), "Expresion Advanced - Error: ", Color( 255, 255, 255 ), Msg )
end

function ENT:OnScriptError( Context, Msg )
	chat.AddText( Color( 150, 150, 0 ), "[" .. self.player:Name( ) .. "] ", Color( 255, 0, 0 ), "Expresion Advanced - Script Error: ", Color( 255, 255, 255 ), Msg )
end

function ENT:OnUncatchedException( Context, Exception )
	chat.AddText( Color( 150, 150, 0 ), "[" .. self.player:Name( ) .. "] ", Color( 255, 0, 0 ), "Expresion Advanced - Uncatched exception: ", Color( 255, 255, 255 ), Exception.Exception, " -> ", Exception.Msg )
end

function ENT:OnCompileError( ErMsg, Compiler )
	chat.AddText( Color( 150, 150, 0 ), "[" .. self.player:Name( ) .. "] ", Color( 255, 0, 0 ), "Expresion Advanced - Validate Error: ", Color( 255, 255, 255 ), ErMsg )
end

function ENT:OnShutDown( Context )
	chat.AddText( Color( 255, 0, 0 ), "Expresion Advanced - ShutDown: ", Color( 255, 255, 255 ), tostring( self ) )
end