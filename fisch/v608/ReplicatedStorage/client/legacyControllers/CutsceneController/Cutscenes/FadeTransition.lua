local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
game:GetService("TweenService")
local packages = ReplicatedStorage:WaitForChild("packages")
require(packages:WaitForChild("Trove"))
local Promise = require(packages:WaitForChild("Promise"))
local legacyControllers = ReplicatedStorage.client.legacyControllers
local CutsceneController = require(legacyControllers:WaitForChild("CutsceneController"))
local PlayerController = require(legacyControllers:WaitForChild("PlayerController"))
local localPlayer = Players.LocalPlayer
return {
	Start = function(_, player)
		return Promise.new(function(callback, _, _)
			local character = player.Character

			if not character then
				callback()
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				callback()
			end

			local humanoid = character:FindFirstChild("Humanoid")

			if not humanoid then
				callback()
			end

			if not humanoid:FindFirstChild("Animator") then
				callback()
			end

			local v = player == localPlayer

			if v == true then
				PlayerController:ToggleControls(false)
				CutsceneController:DisableAllScreens(2)
				ProximityPromptService.Enabled = false
			end

			if v == true then
				CutsceneController:Fade(5, 0.4, 0.4)
			end

			wait(5)

			if v == true then
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			end

			if v == true then
				PlayerController:ToggleControls(true)
				humanoidRootPart.Anchored = false
				ProximityPromptService.Enabled = true
			end

			callback()
		end)
	end
}