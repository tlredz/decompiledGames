local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Promise = require(packages:WaitForChild("Promise"))
local Trove = require(packages:WaitForChild("Trove"))
local legacyControllers = ReplicatedStorage.client.legacyControllers
local CutsceneController = require(legacyControllers:WaitForChild("CutsceneController"))
local PlayerController = require(legacyControllers:WaitForChild("PlayerController"))
local localPlayer = Players.LocalPlayer

local function getSounds()
	local sounds = {}

	for _, sound in script.wrench:GetChildren() do
		if sound:IsA("Sound") then
			table.insert(sounds, sound)
		end
	end

	return sounds
end

local function getSoundDuration(items)
	local total = 0

	for _, item in items do
		total += (item.TimeLength > 0 and item.TimeLength or 1) + 0.35
	end

	return total
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPlayerState(flag: boolean)
	PlayerController:ToggleControls(not flag)
	ProximityPromptService.Enabled = not flag
end

return {
	Start = function(_, p)
		return Promise.new(function(callback)
			if p ~= localPlayer then
				return callback()
			end

			local maid = Trove.new()
			local sounds = getSounds()
			local total = 0

			for _, sound in sounds do
				total += (sound.TimeLength > 0 and sound.TimeLength or 1) + 0.35
			end

			local v = total + 1 + 0.5 + 1.5
			setPlayerState(true) -- equivalent call inferred; original call site unknown
			maid:Add(function()
				setPlayerState(false) -- equivalent call inferred; original call site unknown
			end)
			CutsceneController:DisableAllScreens(v)
			task.spawn(function()
				CutsceneController:FadeToggle(1, true)
			end)
			task.wait(1)

			for _, sound in sounds do
				sound:Play()
				task.wait((sound.TimeLength > 0 and sound.TimeLength or 1) + 0.35)
			end

			task.wait(0.5)
			CutsceneController:FadeToggle(1.5, false)
			task.wait(1.5)
			maid:Destroy()
			callback()
		end)
	end
}