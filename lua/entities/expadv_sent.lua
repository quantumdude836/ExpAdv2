/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Shared Info!
   --- */

AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "expadv_base"
ENT.ExpAdv 			= true
ENT.Scripted 		= true

function ENT:Initialize( )
	if SERVER then
		self:SetModel("models/lemongate/lemongate.mdl")
		self:PhysicsInit( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE )
		self.player = Entity(0)
	end
end

function ENT:MsgN(Msg, A, ...)
	if A then Msg = string.format(Msg, A, ...) end
	MsgN(string.format("[expadv_sent](%s): %s", self.SentPath, Msg))
end
/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: SetUp
   --- */

function ENT:Setup(Pos, Ang, File, Dir)
	self:SetPos(Pos or Vector(0, 0, 0))
	self:SetAngles(Ang or Angle(0, 0, 0))

	if !file.Exists(File, Dir) then
		return self:MsgN("ExpAdv - No such script " .. File)
	end
	
	self.SentPath = File
	self:LoadCodeFromPackage(file.Read(File, Dir), {})

	return self.Context
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Think
   --- */

function ENT:Think( )
	if self.NextThinkTime and self.NextThinkTime > CurTime( ) then return end
	self.NextThinkTime = CurTime( ) + 1

	if self.Compiler_Instance then
		if self.Compiler_Instance.Running then
			self.Compiler_Instance:Resume( )
		else
			self.Compiler_Instance = nil
		end
	end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Render
   --- */

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
		
		local Context = self.Context

		if !Context or !Context.Online then return end
			
		local Event = Context.event_drawScreen

		if !Event then return end

		cam.Start3D2D( self:GetPos() + (self:GetUp() * 2), self:GetAngles(), 1 )
			Context.In2DRender = true
			Context.Matrices = 0

			Context:Execute( "Event drawScreen", Event, 512, 512 )

			if Context.Matrices > 0 then
				for i=1, Context.Matrices do
					cam.PopModelMatrix( )
				end
			end
			
			Context.In2DRender = false
		cam.End3D2D( )
	end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Quota Stuffs
   --- */

function ENT:OnCompilerUpdate( Status )
	self:MsgN("Compiled %s%%", Status)
end

function ENT:StartUp( )
	self:MsgN("Started")
end

function ENT:HitTickQuota( )
	self:MsgN( "Tick Quota Exceeded.")
end

function ENT:HitHardQuota( )
	self:MsgN( "Hard Quota Exceeded." )
end

function ENT:OnCompileError( ErMsg, Compiler )
	self:MsgN(ErMsg)
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Loader
   --- */

if SERVER then
	file.CreateDir("expadv2/sents")

	function EXPADV.LoadSents()
		if EXPADV.Sents then
			for _, sent in pairs(EXPADV.Sents) do
				sent:Remove()
			end
		end

		EXPADV.Sents = {}

		MsgN("ExpAdv: Loading Sents.")

		local Scripts = file.Find( "expadv2/sents/*.txt", "DATA" )
		
		for _, File in pairs(Scripts) do
			local ent = ents.Create("expadv_sent")

			ent:Spawn()

			ent:Setup(nil, nil, string.format("expadv2/sents/%s", File), "DATA")

			ent:MsgN("Created.")

			table.insert(EXPADV.Sents, ent)
		end
	end

	hook.Add("PostCleanupMap", "expandv.sents", EXPADV.LoadSents)

	hook.Add("InitPostEntity", "expandv.sents", function()
		EXPADV.LoadSents()
		hook.Add("Expadv.PostLoadCore", "expandv.sents", EXPADV.LoadSents)
	end)
end