local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Promise = require(packages:WaitForChild("Promise"))
require(packages:WaitForChild("Trove"))
require(packages:WaitForChild("Observers"))
local legacyControllers = ReplicatedStorage.client.legacyControllers
local CutsceneController = require(legacyControllers:WaitForChild("CutsceneController"))
local PlayerController = require(legacyControllers:WaitForChild("PlayerController"))
require(ReplicatedStorage.shared.modules.HideInstances)
local localPlayer = Players.LocalPlayer

-- equivalent calls inferred from this helper; original call sites unknown
local function setPlayerState(player, p, anchored)
	local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	humanoidRootPart.Anchored = anchored
	PlayerController:ToggleControls(not p)
	ProximityPromptService.Enabled = not p
end

return {
	Start = function(_, p, instance)
		if p == localPlayer then
			return Promise.new(function(callback, _, _)
				setPlayerState(p, true, true) -- equivalent call inferred; original call site unknown
				CutsceneController:ShowBars(8.8, 0.1, 0.1)
				workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
				workspace.CurrentCamera.FieldOfView = 50
				workspace.CurrentCamera.CFrame = CFrame.lookAt(
					(instance.PrimaryPart.CFrame * CFrame.new(0, 0, -25)).Position,
					instance.PrimaryPart.Position
				)
				local tween = TweenService:Create(workspace.CurrentCamera, TweenInfo.new(8, Enum.EasingStyle.Linear), {
					CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0, 0, 15)
				})
				tween:Play()
				tween.Completed:Wait()
				workspace.CurrentCamera.FieldOfView = 70
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
				setPlayerState(p, false, false) -- equivalent call inferred; original call site unknown
				callback()
			end)
		end

		return Promise.resolve()
	end
}