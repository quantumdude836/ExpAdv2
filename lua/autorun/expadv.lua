include( "expadv/core.lua" )

if CLIENT then return end

AddCSLuaFile( "expadv/context.lua" )
AddCSLuaFile( "expadv/core.lua" )
AddCSLuaFile( "expadv/components.lua" )
AddCSLuaFile( "expadv/classes.lua" )
AddCSLuaFile( "expadv/operators.lua" )
AddCSLuaFile( "expadv/context.lua" )

AddCSLuaFile( "expadv/compiler/main.lua" )
AddCSLuaFile( "expadv/compiler/tokenizer.lua" )
AddCSLuaFile( "expadv/compiler/headers.lua" )
AddCSLuaFile( "expadv/compiler/parser.lua" )
AddCSLuaFile( "expadv/compiler/instructions.lua" )

AddCSLuaFile( "expadv/api/gcompute.lua" )
AddCSLuaFile( "includes/modules/von.lua" )

