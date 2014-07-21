local Compiler = EXPADV.Compiler

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Directives - Parser Main
   --- */

function Compiler:Start( Trace )

	local Files, CL_Files, CL_Trace = { }, { }

	while self:AcceptToken( "lth" ) do
		local Trace = self:GetTokenTrace( )

		self:RequireToken( "var", "Incomplete script header" ) 

		local Header, Value = self.TokenData

		if self:AcceptToken( "str" ) then
			Value = self.TokenData
		end

		self:RequireToken( "gth", "Incomplete script header." )

		----------------------------------------------------------

		if Header == "client" and !Value then
			self.IsServerScript = false
			self.IsClientScript = true

		elseif Header == "client" then
			
			if self.CL_RootPath then
				self:TraceError( Trace, "Script header cleint must not appear twice" )
			end
			
			CL_Trace = Trace
			self.CL_RootPath = Value

		elseif !Value then

			self:TraceError( Trace, "Invalid script header %s", self.TokenData )

		elseif Header == "include" then
			
			if self.IsServerScript then
				Files[ Value ] = Trace
			else
				CL_Files[ Value ] = Trace
			end

		elseif Header == "model" then
			self.GateModel = Value
		elseif Header == "name" then
			self.GateName = Value
		else
			self:TraceError( Trace, "Invalid script header %s", self.TokenData )
		end

	end

	-----------------------------------------------------------------------------
	 
	local Instructions = { }

	if self.IsServerScript then
		for Path, Trace in pairs( Files ) do
			if !self.Files[ Path ] and !file.Exists( Path .. ".txt" ) then
				self:TraceError( Trace, "No such file %q", Path )
			end

			self.Files[ Path ] = self.Files[ Path ] or file.Read( Path .. ".txt" )

			table.insert( self:Include( Trace, Path, self.Files[ Path ] ) )
		end

		if self.CL_RootPath then
			local Path = self.CL_RootPath

			if !self.CL_Files[ Path ] and !file.Exists( Path .. ".txt" ) then
				self:TraceError( CL_Trace, "No such file %q", Path )
			end

			self.CL_Files[ Path ] = self.CL_Files[ Path ] or file.Read( Path .. ".txt" )

			local Instance = setmetatable( { }, Compiler )

			EXPADV.SoftCompile( Instance, self.CL_Files[ Path ], self.CL_Files, true,
				function( ErMsg )
					self:TraceError( CL_Trace, "Client: " .. ErMsg )
				end, function ( )
					-- Do nothing
				end
			) -- Ok, so now we just compile this too!
		end
	end

	if self.IsClientScript then
		for Path, Trace in pairs( CL_Files ) do
			if !self.CL_Files[ Path ] and !file.Exists( Path .. ".txt" ) then
				self:TraceError( Trace, "No such file %q", self.TokenData )
			end

			self.CL_Files[ Path ] = self.CL_Files[ Path ] or file.Read( Path .. ".txt" )

			table.insert( self:Include( Trace, Path, self.CL_Files[ Path ] ) )
		end
	end

	table.insert( Instructions, self:Sequence( Trace ) )

	return self:Compile_SEQ( Trace, Instructions )
end

function Compiler:Include( Trace, Path, File )
	local Pos = self.Pos;			self.Pos = 0
	local Len = self.Len;			self.Len = #File
	local Buffer = self.Buffer; 	self.Buffer = File
	
	local Char 			= self.Char
	local ReadData 		= self.ReadData
	local ReadChar 		= self.ReadChar
	local ReadLine 		= self.ReadLine
	local Tokens 		= self.Tokens
	local TokenPos 		= self.TokenPos
	local TokenLine 	= self.TokenLine
	local TokenChar 	= self.TokenChar

	self:StartTokenizer( )

	local Compiled, Instruction = pcall( self.Main, self, { 0, 0 } )

	if !Compiled then self:TraceError( Trace, "Include: " .. Instruction ) end

	self.Pos 		= Pos
	self.Len 		= Len
	self.Buffer 	= Buffer
	self.Char 		= Char 		
	self.ReadData 	= ReadData 
	self.ReadChar 	= ReadChar 
	self.ReadLine 	= ReadLine 
	self.Tokens 	= Tokens 	
	self.TokenPos 	= TokenPos 
	self.TokenLine 	= TokenLine
	self.TokenChar 	= TokenChar

	return Instruction
end
