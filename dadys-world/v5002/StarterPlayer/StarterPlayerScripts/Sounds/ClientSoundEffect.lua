local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local localPlayer = Players.LocalPlayer
local v = nil
pcall(function()
	local modules = ReplicatedStorage:WaitForChild("Modules", 5)
	local audio = modules and modules:WaitForChild("Audio", 3)

	if audio then
		local SoundGroupManager = require(audio:WaitForChild("SoundGroupManager", 3))
		v = SoundGroupManager
	end
end)

if RunService:IsServer() then
	if not ReplicatedStorage:FindFirstChild("Events") then
		local folder = Instance.new("Folder")
		folder.Name = "Events"
		folder.Parent = ReplicatedStorage
	end

	if not ReplicatedStorage.Events:FindFirstChild("ClientSoundEffect") then
		local remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = "ClientSoundEffect"
		remoteEvent.Parent = ReplicatedStorage.Events
	end
end

local clientSoundEffect = ReplicatedStorage:WaitForChild("Events", 10):WaitForChild("ClientSoundEffect", 10)

if not clientSoundEffect then
	warn("ClientSoundEffect RemoteEvent not found! Sound effects may not play correctly.")
	return
end

local function onSoundEvent(soundId, value, humanoidRootPart)
	if typeof(soundId) ~= "string" then
		print("SOUND ID: ", soundId, " is not a string, please revise!")
		soundId = soundId.SoundId or ""
	end

	if not humanoidRootPart or typeof(humanoidRootPart) ~= "Instance" then
		local character = localPlayer.Character

		if character and character:FindFirstChild("HumanoidRootPart") then
			humanoidRootPart = character.HumanoidRootPart
		else
			humanoidRootPart = localPlayer:FindFirstChild("PlayerGui") or localPlayer
		end
	end

	local v2 = Audio:Play(soundId, {
		Volume = value or 1,
		Parent = humanoidRootPart
	})

	if v2 and v then
		v.AssignSound(v2, "SFX")
	end
end

clientSoundEffect.OnClientEvent:Connect(onSoundEvent)

local function setupAbilitySoundHandler()
	local abilityUsed = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("AbilityUsed")

	if abilityUsed then
		abilityUsed.OnClientEvent:Connect(function(p, _)
			if p and p.CustomAbilitySound and p.ClientOnlySound then
				onSoundEvent(p.CustomAbilitySound, 0.8)
			end
		end)
	end
end

Players.LocalPlayer.CharacterAdded:Connect(function()
	setupAbilitySoundHandler()
end)
setupAbilitySoundHandler()