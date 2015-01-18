/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Base Class
   --- */

ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"

ENT.PrintName       = "Expression Advanced 2"
ENT.Author          = "Rusketh"
ENT.Contact         = "WM/FacePunch"
ENT.ExpAdv 			= true

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: IsExpAdv2
   --- */

local meta = FindMetaTable( "Entity" )

function meta:IsExpAdv( ) return false end

function ENT:IsExpAdv( ) return true end

AccessorFunc(ENT, "GateName", "GateName", FORCE_STRING)

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Initalize Entity
   --- */

function ENT:Initialize( )
	if SERVER then

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )

		self:SetUseType( SIMPLE_USE )

		if WireLib then
			self.Inputs = WireLib.CreateInputs( self, { } )
			self.Outputs = WireLib.CreateOutputs( self, { } )
		end
	end

	self:ResetStatus( )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Status
   --- */

function ENT:ResetStatus( ) end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Client must always know about this entity.
   --- */

function ENT:UpdateTransmitState( )	
	return TRANSMIT_ALWAYS
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Context Look Up
		-- More useful clientside tbh :D
   --- */

local ContextFromEntID = { }

function EXPADV.GetEntityContext( ID )
	return ContextFromEntID[ ID ]
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: 
   --- */

function ENT:IsRunning( )
	return self.Context ~= nil and self.Context.Online
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Context Callbacks
   --- */

function ENT:StartUp( ) end
function ENT:ShutDown( ) end
function ENT:HitTickQuota( ) end
function ENT:HitHardQuota( ) end
function ENT:LuaError( Msg ) end
function ENT:ScriptError( Msg ) end
function ENT:Exception( Exception ) end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: WirePort Trigger
   --- */

function ENT:UpdateTick( )
	if WireLib and SERVER then self:TriggerOutputs( ) end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Context
   --- */

function ENT:GetContext( )
	return self.Context
end

function ENT:OnContextCreated( Context )
	-- For usage of derived classes only!
	-- Return true to disable context callbacks.
end

function ENT:PostStartUp( )
	-- For usage of derived classes only!
	-- Return true to disable context callbacks.
end

function ENT:CreateContext( Instance, Player )
	local Context = EXPADV.BuildNewContext( Instance, Player, self )

	self:OnContextCreated( Context )

	ContextFromEntID[ self:EntIndex( ) ] = Context

	self.Context = Context

	return Context
end

function ENT:OnRemove( )
	hook.Remove( "PlayerInitialSpawn", self )

	if !self:IsRunning( ) then return end
	
	self.Context:ShutDown( )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Compiler
   --- */

function ENT:CompileScript(Root, Files)

	if self:IsRunning( ) then
		self.Context:ShutDown( )
		EXPADV.UnregisterContext( self.Context )
	end
	
	if !Root or Root == "" then
		return self:ScriptError( "No code submited, compiler exited." )
	end

	local Status, Instance, Instruction = EXPADV.SolidCompile(Root, Files)

	if !Status then self:OnCompileError(Instance) end
	
	return true, Instance, self:BuildInstance( Instance, Instruction )
end

function ENT:OnCompileError( ErMsg, Compiler ) end

function ENT:BuildInstance( Instance, Instruction )
	
	local Native = table.concat( {
		"return function( Context )",
		"setfenv( 1, Context.Enviroment )",
			Instruction.Prepare or "",
			Instruction.Inline or "",
		"end"
	}, "\n" )
	
	file.Write( "expadv_compile.txt", Native )
	
	local Compiled = CompileString( Native, "EXPADV2", false )

	if isstring( Compiled ) then
		return self:OnCompileError( Compiled, Instance )
	end

	local Context = self:CreateContext( Instance, self.player )
	
	self.Cells = Instance.Cells 

	local Ok, Error = pcall( function( )
		if WireLib and SERVER then
			self:BuildInputs( self.Cells, Instance.InPorts )
			self:BuildOutputs( self.Cells, Instance.OutPorts )
			self:LoadFromInputs( self.Cells )
		end

		Context:StartUp( Compiled( ) )

		self:PostStartUp( Context )

		if SERVER and self.PastedFromDupe then self:CallEvent( "dupePasted" ) end
	end )

	if !Ok then
		MsgN( "ExpAdv2 Statup Error: ", Error )
		return self:OnCompileError( Error )
	end

	if CLIENT then EXPADV.SendCodeLoaded(self) end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Call Event
   --- */

function ENT:CallEvent( Name, ... )	
	if !self:IsRunning( ) then return false, nil end

	local Event = self.Context[ "event_" .. Name ]
	if !Event then return end

	return self.Context:Execute( "Event " .. Name, Event, ... )
end
 
/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Context Menu
   --- */

local function Filter( self, Entity, Player )
	if !(IsValid( Entity ) and Entity.ExpAdv) then return false end
	if CLIENT then return true end
	
	if !gamemode.Call( "CanProperty", Player, "expadv", Entity ) then
		return false -- Somthing denied access!
	end

	return true
end

local function MenuOpen( ContextMenu, Option, Entity, Trace )
	local SubMenu = Option:AddSubMenu( )

	SubMenu:AddOption( "Restart Client",
		function( )
			Entity:CompileScript( Entity.root, Entity.files )
		end )

	EXPADV.CallHook( "OpenContextMenu", Entity, SubMenu, Trace, Option )
end

properties.Add( "expadv", {
	MenuLabel = "Expression Advanced",
	MenuIcon  = "fugue/gear.png",
	Order = 999,
	Filter = Filter,
	MenuOpen = MenuOpen,
	Action = function( ) end,
} ) -- We wont use recieve here, Send it yourself :D

