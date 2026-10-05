local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local localPlayer = Players.LocalPlayer
local info = workspace:WaitForChild("Info")
local zones = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Zones")
local HauntedGalaConfig = require(zones:WaitForChild("HauntedGalaConfig"))
local HauntedGalaArt = require(zones:WaitForChild("HauntedGalaArt"))
local ACTIVE_ATTRIBUTE = HauntedGalaConfig.ACTIVE_ATTRIBUTE
local MODE_ATTRIBUTE = HauntedGalaConfig.MODE_ATTRIBUTE

-- equivalent calls inferred from this helper; original call sites unknown
local function syncState()
	if info:GetAttribute(ACTIVE_ATTRIBUTE) then
		HauntedGalaArt.Activate(info:GetAttribute(MODE_ATTRIBUTE))
	else
		HauntedGalaArt.Deactivate()
	end
end

local function playIntroMusic()
	local INTRO_MUSIC = HauntedGalaConfig.INTRO_MUSIC

	if type(INTRO_MUSIC.SoundId) ~= "string" or INTRO_MUSIC.SoundId == "" then
		return
	end

	local success, result = pcall(function()
		local sound = Instance.new("Sound")
		sound.Name = "HauntedGalaIntro"
		sound.SoundId = INTRO_MUSIC.SoundId
		sound.Volume = tonumber(INTRO_MUSIC.Volume) or 0.7
		sound.Parent = SoundService
		sound.Ended:Once(function()
			sound:Destroy()
		end)
		sound:Play()
		Debris:AddItem(sound, 60)
	end)

	if not success then
		warn("[HauntedGala] intro music failed to play:", result)
	end
end

info:GetAttributeChangedSignal(ACTIVE_ATTRIBUTE):Connect(function()
	if info:GetAttribute(ACTIVE_ATTRIBUTE) then
		playIntroMusic()
	end

	syncState() -- equivalent call inferred; original call site unknown
end)
info:GetAttributeChangedSignal(MODE_ATTRIBUTE):Connect(syncState)
syncState() -- equivalent call inferred; original call site unknown
localPlayer.CharacterAdded:Connect(function()
	if not info:GetAttribute(ACTIVE_ATTRIBUTE) then
		return
	end

	task.wait(1)

	if not info:GetAttribute(ACTIVE_ATTRIBUTE) then
		return
	end

	HauntedGalaArt.OnRespawn()
end)