local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Omni = require(ReplicatedStorage:WaitForChild("Omni"))

local function PlayMusics()
	for _, sound in Omni.Services.SoundService.Musics:GetChildren() do
		if not sound:IsA("Sound") then
			continue
		end

		sound.Looped = false
		sound:Play()
		sound.Ended:Wait()
	end
end

local Music = {
	Refresh = function()
		for _, sound in Omni.Services.SoundService.Musics:GetChildren() do
			if not sound:IsA("Sound") then
				continue
			end

			local original = sound:GetAttribute("Original") or sound.Volume

			if not sound:GetAttribute("Original") then
				sound:SetAttribute("Original", original)
			end

			sound.Volume = original * ((Omni.Data.Settings["Music Volume"] or 100) / 100)
		end
	end
}

for _, sound in Omni.Services.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Sounds"):WaitForChild("Musics"):GetChildren() do
	if not sound:IsA("Sound") then
		continue
	end

	local clone = sound:Clone()
	clone.Parent = Omni.Services.SoundService.Musics
end

Music.Refresh()
Omni.Libs.ThreadSaver.New(function()
	while task.wait() do
		PlayMusics()
	end
end)
Omni:OnDataChanged({ "Settings" }, Music.Refresh)
return Music