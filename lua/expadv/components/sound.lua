/* --- --------------------------------------------------------------------------------
	@: Sound Component
	@: Author: Ripmax
   --- */

local Component = EXPADV.AddComponent("sound", true)

Component.Author = "Ripmax"
Component.Description = "Allows for sound to be played."

Component:CreateSetting("maximumsounds", 10)

function Component:OnRegisterContext(Context) Context.Data.Sound = {} Context.Data.SoundCount = 0 end

function Component:OnUnregisterContext(Context) if(Context.Data.Sound) then for k, v in pairs(Context.Data.Sound) do v:Stop() end end end

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
	
	Context.Data.SoundCount = Context.Data.SoundCount + 1
end

local function playSound(Context, Ent, Duration, Index, Fade, File)
	if(!Ent || !IsValid(Ent)) then Ent = Context.entity end
	local maxsounds = Component:ReadSetting("maximumsounds", 10)
	
	if(File:match("[\"?]")) then return end
	File = string.Trim(File)
	File = File:gsub("\\", "/")
	if(type(Index) == "number") then Index = math.floor(Index) end
	
	if(Context.Data.SoundCount >= maxsounds) then return end
	
	if(Context.Data.Sound[Index]) then stopSound(Context, Index, 0) end
	
	local newSound = CreateSound(Ent, File)
	Context.Data.Sound[Index] = newSound
	newSound:Play()
	Context.Data.SoundCount = Context.Data.SoundCount + 1
	
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

Component:AddVMFunction("soundVolume", "n,n", "", function(Context, Trace, Index, Volume) if(Context.Data.Sound[Index]) then Context.Data.Sound[Index]:ChangeVolume(math.Clamp(math.abs(Volume), 0, 1), 0) end end)
Component:AddVMFunction("soundVolume", "n,n,n", "", function(Context, Trace, Index, Volume, Fade) if(Context.Data.Sound[Index]) then Context.Data.Sound[Index]:ChangeVolume(math.Clamp(math.abs(Volume), 0, 1), math.abs(Fade)) end end)
Component:AddFunctionHelper("soundVolume", "n,n", "Sets the volume of the given sound, 0-1")
Component:AddFunctionHelper("soundVolume", "n,n,n", "Sets the volume of the given sound, 0-1, specifying a fade duration.")

Component:AddVMFunction("soundPitch", "n,n", "", function(Context, Trace, Index, Pitch) if(Context.Data.Sound[Index]) then Context.Data.Sound[Index]:ChangePitch(math.Clamp(math.abs(Pitch), 0, 255), 0) end end)
Component:AddVMFunction("soundPitch", "n,n,n", "", function(Context, Trace, Index, Pitch, Fade) if(Context.Data.Sound[Index]) then Context.Data.Sound[Index]:ChangePitch(math.Clamp(math.abs(Pitch), 0, 255), math.abs(Fade)) end end)
Component:AddFunctionHelper("soundPitch", "n,n", "Sets the pitch of the given sound, 0-255")
Component:AddFunctionHelper("soundPitch", "n,n,n", "Sets the pitch of the given sound, 0-255, specifying a fade duration.")

Component:AddInlineFunction("soundDuration", "s", "n", "$SoundDuration(@value 1)")
Component:AddFunctionHelper("soundDuration", "s", "Returns the duration of the given sound.")

Component:AddVMFunction("soundStopAll", "", "", function(Context, Trace) for k, v in pairs(Context.Data.Sound) do v:Stop() timer.Remove("EA2Gate-" .. Context.entity:EntIndex() .. ";STOPSound_" .. k) Context.Data.SoundCount = 0 end end)
Component:AddFunctionHelper("soundStopAll", "", "Stops all sounds from the chip.")
