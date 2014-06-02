-- Temporary string print!
	EXPADV.AddFunctionHelper( nil, "print", "s", "Prints to owners/clients chat." )

	EXPADV.AddVMFunction( nil, "print", "s", "", function( Context, Trace, String )
		print( String ) -- Temp!
	end )

