local createVector = vector.create
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local Observers = require(ReplicatedStorage.packages.Observers)
require(ReplicatedStorage.packages.Moonlite)
local Promise = require(ReplicatedStorage.packages.Promise)
local Trove = require(ReplicatedStorage.packages.Trove)
local localPlayer = Players.LocalPlayer
local HideInstances = require(ReplicatedStorage.shared.modules.HideInstances)
local CutsceneController = require(ReplicatedStorage.client.legacyControllers.CutsceneController)
local PlayerController = require(ReplicatedStorage.client.legacyControllers.PlayerController)
require(ReplicatedStorage.client.legacyControllers.LightingController)
require(ReplicatedStorage.client.legacyControllers.HudController)
require(ReplicatedStorage.client.modules.moonliteCutscene)
local fx = require(ReplicatedStorage.shared.modules.fx)
local localPlayer2 = Players.LocalPlayer
localPlayer2:WaitForChild("PlayerGui")
local currentCamera = workspace.CurrentCamera

local function createTween(p, p2, p3)
	local tween = TweenService:Create(p, p2, p3)
	tween:Play()
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	return tween
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPlayerState(player, flag: boolean, anchored: boolean)
	PlayerController:ToggleControls(not flag)
	ProximityPromptService.Enabled = not flag
	local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	assert(humanoidRootPart:IsA("BasePart"))
	humanoidRootPart.Anchored = anchored
end

return {
	Start = function(_, player)
		local maid = Trove.new()
		return Promise.new(function(callback, _, _)
			local _ = player.Character

			if player ~= localPlayer2 then
				return callback()
			end

			maid:Add(Observers.observeCharacters(function(p, p2)
				if p == localPlayer then
					return function() end
				end

				return HideInstances(p2)
			end))
			setPlayerState(player, true, true) -- equivalent call inferred; original call site unknown
			maid:Add(function()
				setPlayerState(player, false, false) -- equivalent call inferred; original call site unknown
			end)
			CutsceneController:DisableAllScreens(function(p)
				maid:Add(p)
			end)
			maid:Add(function()
				currentCamera.CameraType = Enum.CameraType.Custom

				if not (currentCamera.CameraSubject and currentCamera.CameraSubject.Parent) then
					local character = Players.LocalPlayer.Character
					currentCamera.CameraSubject = character and character:FindFirstChildOfClass("Humanoid")
				end
			end)
			local v2 = maid:Add(script.NorthMeteorShowerScene:Clone())
			v2.Parent = workspace
			ContentProvider:PreloadAsync({ script.sounds, v2 })
			workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
			workspace.CurrentCamera.Focus = CFrame.new(19539.055, 675.136, 5304.655)

			for _, child in script.sounds.start:GetChildren() do
				child:Play()
			end

			TweenService:Create(
				workspace.CurrentCamera,
				TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					CFrame = CFrame.lookAt(
						workspace.CurrentCamera.CFrame.Position,
						createVector(19539.055, 675.136, 5304.655)
					)
				}
			):Play()
			TweenService:Create(v2.PrimaryPart, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				CFrame = CFrame.new((v2:GetPivot() * CFrame.new(0, 0, -1000)).Position) * v2.PrimaryPart.CFrame.Rotation
			}):Play()
			task.wait(4)
			CutsceneController:FadeToggle(0, true)
			task.wait(0.5)

			for _ = 1, 4 do
				fx:PlaySound(script.sounds.explode.explode, script, Random.new():NextNumber(0.5, 1.5))
				task.wait(0.125)
			end

			currentCamera.CameraType = Enum.CameraType.Custom
			v2:Destroy()
			task.wait(2)
			CutsceneController:FadeToggle(3, false)
			task.wait(2)
			maid:Destroy()
			callback()
		end):catch(warn):finally(function()
			maid:Destroy()
		end)
	end
}