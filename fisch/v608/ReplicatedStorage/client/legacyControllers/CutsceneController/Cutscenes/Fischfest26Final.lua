local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local packages = ReplicatedStorage:WaitForChild("packages")
local Promise = require(packages:WaitForChild("Promise"))
require(packages:WaitForChild("Trove"))
require(packages:WaitForChild("Observers"))
local emit = require(ReplicatedStorage.packages.emit)
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
	Start = function(_, p, _)
		if p == localPlayer then
			return Promise.new(function(callback, _, _)
				setPlayerState(p, true, true) -- equivalent call inferred; original call site unknown
				workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
				workspace.CurrentCamera.FieldOfView = 50
				workspace.CurrentCamera.CFrame = CFrame.new(-23955.105, 2641.397, -4561.604) * CFrame.fromOrientation(
					-0.3933274002294421,
					2.5908540081229825,
					0
				)
				local tween = TweenService:Create(workspace.CurrentCamera, TweenInfo.new(8, Enum.EasingStyle.Sine), {
					CFrame = CFrame.new(-24146.523, 2865.945, -4929.141) * CFrame.fromOrientation(
						-0.11328932174695193,
						2.340853046067315,
						0
					)
				})
				tween:Play()
				tween.Completed:Wait()
				local clone = script.fireworks:Clone()
				clone.Parent = workspace.active.debrisfx
				ContentProvider:PreloadAsync({ clone })
				pcall(function()
					for _, child in clone:GetChildren() do
						emit.emit(child)
						child.Firework:Play()
						task.wait(0.5)
					end
				end)
				task.wait(2)
				CutsceneController:FadeWithSaneFuckingArgumentsFuckThisShit(3, 3)
				task.wait(3)
				workspace.CurrentCamera.FieldOfView = 70
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
				setPlayerState(p, false, false) -- equivalent call inferred; original call site unknown
				callback()
			end)
		end

		return Promise.resolve()
	end
}