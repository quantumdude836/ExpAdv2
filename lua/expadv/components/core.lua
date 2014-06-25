-- Temporary string print!
	EXPADV.AddFunctionHelper( nil, "print", "s", "Prints to owners/clients chat." )

	EXPADV.AddVMFunction( nil, "print", "s", "", function( Context, Trace, String )
		if !Context.Print then return MsgN( String ) end
		Context.Print( Trace, String ) -- NOT PERMANANT!
	end )

