/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Directives
   --- */

local LoadOnServer = true
local LoadOnClient = true

function EXPADV.ServerDirective( Component, Name, Function )
	LoadOnServer = true
	LoadOnClient = false

	return EXPADV.AddDirective( Component, Name, Function )
end

function EXPADV.ClientDirective( Component, Name, Function )
	LoadOnClient = true
	LoadOnServer = false

	return EXPADV.AddDirective( Component, Name, Function )
end

function EXPADV.SharedDirective( Component, Name, Function )
	LoadOnClient = true
	LoadOnServer = true

	return EXPADV.AddDirective( Component, Name, Function )
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: Add A Directive
   --- */

local Directives = { }

function EXPADV.AddDirective( Component, Name, Function )
	Directives[Name] = {
		LoadOnClient = LoadOnClient,
		LoadOnServer = LoadOnServer,

		Component = Component,
		Name =  Name,
		Compile = Function,
	}
end

EXPADV.Directives = { }

function EXPADV.LoadDirectives( )
	EXPADV.Directives = { }

	EXPADV.CallHook( "PreLoadDirectives" )

	for Name, Directive in pairs( Directives ) do
		if Directive.Component and !Directive.Component.Enabled then continue end
		EXPADV.Directives[Name] = Directive
	end
end

/* --- ----------------------------------------------------------------------------------------------------------------------------------------------
	@: DEFAULT DIRECTIVES!
   --- */

EXPADV.AddDirective( nil, "define", function( Compiler, Trace )
	-- Right now we use this function, to compile this directive :D

	Compiler:RequireToken( "var", "Name of defintion expected, after @define:")

	local Name = Compiler.TokenData
	local Exp = Compiler:Expression( Trace )

	if !Exp.Return or Exp.Return == "" then
		Compiler:TraceError( Trace, "Defined Expression must not return void.")
	end

	Compiler.InstructionMemory[ Compiler.ScopeID ][Name] = Exp
end )