local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage:WaitForChild("Modules", 10)
local zones = modules and modules:WaitForChild("Zones", 10)
local iceSkatingConfig = zones and zones:WaitForChild("IceSkatingConfig", 10)
local module = iceSkatingConfig and require(iceSkatingConfig)

if not (module and module.ENABLED) then
	return
end

local function debugPrint(...) end

local localPlayer = Players.LocalPlayer
local IceSkatingEffects = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Zones"):WaitForChild("IceSkatingEffects"))

-- equivalent calls inferred from this helper; original call sites unknown
local function waitForCharacterReady(instance)
	instance:WaitForChild("Humanoid", 10)
	instance:WaitForChild("HumanoidRootPart", 10)
	task.wait(0.1)
end

local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
waitForCharacterReady(character) -- equivalent call inferred; original call site unknown
IceSkatingEffects.Init(localPlayer, character)
IceSkatingEffects.StartWatchingOtherPlayers()

local function onIceSkatingEvent(p, value)
	if p == "Activate" then
		IceSkatingEffects.Activate(value or "Playground")
		debugPrint("[IceSkatingEffectsLoader] Activated preset:", value or "Playground")
	elseif p == "Deactivate" then
		IceSkatingEffects.Deactivate()
		debugPrint("[IceSkatingEffectsLoader] Deactivated")
	elseif p == "FreezeLevel" then
		IceSkatingEffects.FreezeLevel()
		debugPrint("[IceSkatingEffectsLoader] Level frozen by card!")
	elseif p == "UnfreezeLevel" then
		IceSkatingEffects.UnfreezeLevel()
		debugPrint("[IceSkatingEffectsLoader] Level unfrozen")
	end
end

local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function connectToRemote(remoteEvent)
	if flag then
		return
	end

	flag = true
	remoteEvent.OnClientEvent:Connect(onIceSkatingEvent)
	debugPrint("[IceSkatingEffectsLoader] Connected to IceSkatingToggle remote!")
end

local iceSkatingToggle = ReplicatedStorage:FindFirstChild("IceSkatingToggle")

if iceSkatingToggle and not flag then
	flag = true
	iceSkatingToggle.OnClientEvent:Connect(onIceSkatingEvent)
	debugPrint("[IceSkatingEffectsLoader] Connected to IceSkatingToggle remote!")
end

ReplicatedStorage.ChildAdded:Connect(function(remoteEvent)
	if remoteEvent.Name == "IceSkatingToggle" and remoteEvent:IsA("RemoteEvent") then
		connectToRemote(remoteEvent) -- equivalent call inferred; original call site unknown
	end
end)
task.spawn(function()
	task.wait(2)

	if IceSkatingEffects.IsActive() then
		debugPrint("[IceSkatingEffectsLoader] Already active - skipping modifier check")
		return
	end

	local cardModifiers = workspace:FindFirstChild("Info") and workspace.Info:FindFirstChild("CardModifiers")

	if cardModifiers then
		local iceSkatingEnabled = cardModifiers:FindFirstChild("IceSkatingEnabled")
		local iceSkatingPreset = cardModifiers:FindFirstChild("IceSkatingPreset")
		local iceSkatingFreezeFloors = cardModifiers:FindFirstChild("IceSkatingFreezeFloors")

		if iceSkatingEnabled and iceSkatingEnabled.Value then
			local value = iceSkatingPreset and iceSkatingPreset.Value or "Playground"
			IceSkatingEffects.Activate(value)
			debugPrint("[IceSkatingEffectsLoader] Restored ice skating from card modifier:", value)

			if iceSkatingFreezeFloors and iceSkatingFreezeFloors.Value then
				IceSkatingEffects.FreezeLevel()
				debugPrint("[IceSkatingEffectsLoader] Restored frozen level from card modifier")
			end
		end
	end
end)
localPlayer.CharacterAdded:Connect(function(character2)
	character = character2
	waitForCharacterReady(character2) -- equivalent call inferred; original call site unknown
	IceSkatingEffects.Init(localPlayer, character2)
	debugPrint("[IceSkatingEffectsLoader] Re-initialized for new character")
end)
debugPrint("[IceSkatingEffectsLoader] Ready!")