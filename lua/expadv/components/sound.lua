/* --- --------------------------------------------------------------------------------
	@: Sound Component
	@: Author: Ripmax
   --- */

local Component = EXPADV.AddComponent("sound", true)

Component.Author = "Ripmax"
Component.Description = "Allows for sound to be played."

Component:CreateSetting("maximumsounds", 10)

local function stopSound(Context, Index, Fade)
	if(!Context.Data.Sound[Index]) then return end
	
	local sound = Context.Data.Sound[Index]
	if(Fade > 0) then
		sound:FadeOut(Fade)
		timer.Simple(Fade, function() stopSound(Index, 0) end)
	else
		sound:Stop()
		if(type(Index) == "number") then Index = math.floor(Index) end
		Context.Data.Sound[Index] = nil
	end
end

local function playSound(Context, Ent, Duration, Index, Fade, File)
	if(!Ent || !IsValid(Ent)) then Ent = Context.entity end
	local maxsounds = Component:ReadSetting("maximumsounds", 10)
	
	if(File:match("[\"?]")) then return end
	File = string.Trim(File)
	File = File:gsub("\\", "/")
	if(type(Index) == "number") then Index = math.floor(Index) end
	
	Context.Data.Sound = {} or Context.Data.Sound
	
	if(#Context.Data.Sound >= maxsounds) then return end
	
	if(Context.Data.Sound[Index]) then stopSound(Context, Index, 0) end
	
	local newSound = CreateSound(Ent, File)
	Context.Data.Sound[Index] = newSound
	newSound:Play()
	
	Ent:CallOnRemove("EA2EntDelete_STOPSound", function() stopSound(Context, Index, 0) end)
	
	if(Duration == 0 and Fade == 0) then return end
	timer.Create("EA2Gate-" .. Context.entity:EntIndex() .. ";STOPSound_" .. Index, Duration, 0, function() stopSound(Context, Index, Fade) end)
end

EXPADV.ServerOperators()

Component:AddVMFunction("soundPlay", "n,n,s", "", function(Context, Trace, Index, Duration, File) playSound(Context, Context.entity, math.abs(Duration), math.abs(Index), 0, File) end)
Component:AddVMFunction("soundPlay", "e:n,n,s", "", function(Context, Trace, Ent, Index, Duration, File) playSound(Context, Ent, math.abs(Duration), math.abs(Index), 0, File) end)
Component:AddVMFunction("soundPlay", "n,n,n,s", "", function(Context, Trace, Index, Duration, Fade, File) playSound(Context, Context.entity, math.abs(Duration), math.abs(Index), math.abs(Fade), File) end)
Component:AddVMFunction("soundPlay", "e:n,n,n,s", "", function(Context, Trace, Ent, Index, Duration, Fade, File) playSound(Context, Ent, math.abs(Duration), math.abs(Index), math.abs(Fade), File) end)
Component:AddFunctionHelper("soundPlay", "n,n,s", "Play a sound from the chip.")
Component:AddFunctionHelper("soundPlay", "e:n,n,s", "Play a sound from the given entity.")
Component:AddFunctionHelper("soundPlay", "n,n,n,s", "Play a sound from the chip, specifying a fade duration.")
Component:AddFunctionHelper("soundPlay", "e:n,n,n,s", "Play a sound from the given entity, specifying a fade duration.")

Component:AddVMFunction("soundStop", "n", "", function(Context, Trace, Index) stopSound(Context, Index, 0) end)
Component:AddVMFunction("soundStop", "n,n", "", function(Context, Trace, Index, Fade) stopSound(Context, Index, math.abs(Fade)) end)
Component:AddFunctionHelper("soundStop", "n", "Stop the sound of the given index.")
Component:AddFunctionHelper("soundStop", "n,n", "Stop the sound of the given index, specifying a fade duration.")

Component:AddPreparedFunction("soundVolume", "n,n", "", "Context.Data.Sound[@value 1]:ChangeVolume(math.Clamp(math.abs(@value 2), 0, 1), 0)")
Component:AddPreparedFunction("soundVolume", "n,n,n", "", "Context.Data.Sound[@value 1]:ChangeVolume(math.Clamp(math.abs(@value 2), 0, 1), math.abs(@value 3))")
Component:AddFunctionHelper("soundVolume", "n,n", "Sets the volume of the given sound, 0-1")
Component:AddFunctionHelper("soundVolume", "n,n,n", "Sets the volume of the given sound, 0-1, specifying a fade duration.")

Component:AddPreparedFunction("soundPitch", "n,n", "", "Context.Data.Sound[@value 1]:ChangePitch(math.Clamp(math.abs(@value 2), 0, 255), 0)")
Component:AddPreparedFunction("soundPitch", "n,n,n", "", "Context.Data.Sound[@value 1]:ChangePitch(math.Clamp(math.abs(@value 2), 0, 255), math.abs(@value 3))")
Component:AddFunctionHelper("soundPitch", "n,n", "Sets the pitch of the given sound, 0-255")
Component:AddFunctionHelper("soundPitch", "n,n,n", "Sets the pitch of the given sound, 0-255, specifying a fade duration.")

Component:AddInlineFunction("soundDuration", "s", "n", "$SoundDuration(@value 1)")
Component:AddFunctionHelper("soundDuration", "s", "Returns the duration of the given sound.")

Component:AddVMFunction("soundStopAll", "", "", function(Context, Trace) for k, v in pairs(Context.Data.Sound) do v:Stop() timer.Remove("EA2Gate-" .. Context.entity:EntIndex() .. ";STOPSound_" .. k) end end)
Component:AddFunctionHelper("soundStopAll", "", "Stops all sounds from the chip.")
