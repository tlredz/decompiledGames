local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local Observers = require(ReplicatedStorage.packages.Observers)
require(ReplicatedStorage.packages.Moonlite)
local Promise = require(ReplicatedStorage.packages.Promise)
local Trove = require(ReplicatedStorage.packages.Trove)
local emit = require(ReplicatedStorage.packages.emit)
local _ = Players.LocalPlayer
local HideInstances = require(ReplicatedStorage.shared.modules.HideInstances)
local CutsceneController = require(ReplicatedStorage.client.legacyControllers.CutsceneController)
local PlayerController = require(ReplicatedStorage.client.legacyControllers.PlayerController)
local LightingController = require(ReplicatedStorage.client.legacyControllers.LightingController)
require(ReplicatedStorage.client.legacyControllers.HudController)
require(ReplicatedStorage.client.modules.moonliteCutscene)
local localPlayer = Players.LocalPlayer
localPlayer:WaitForChild("PlayerGui")
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

			if player ~= localPlayer then
				return callback()
			end

			maid:Add(Observers.observeCharacters(function(_, p)
				return HideInstances(p)
			end))
			task.spawn(function()
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
			end)
			maid:Add(function()
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
			end)
			maid:Add(LightingController.HookLighting:BindAtPriority(9999999, function(state)
				state.Lighting.ClockTime = 0
				state.Atmosphere.Density = 0
				state.ColorCorrectionEffect.Brightness = 0
				state.ColorCorrectionEffect.Saturation = 0
				state.ColorCorrectionEffect.Contrast = 0
				state.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
				state.ColorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
				state.BlurEffect.Size = 0
				state.Lighting.Brightness = 2
				state.DepthOfFieldEffect.FocusDistance = 999
				state.BloomEffect = table.clone(LightingController.Defaults.BloomEffect)
				return state
			end))
			setPlayerState(player, true, true) -- equivalent call inferred; original call site unknown
			maid:Add(function()
				setPlayerState(player, false, false) -- equivalent call inferred; original call site unknown
			end)
			CutsceneController:DisableAllScreens(function(p)
				maid:Add(p)
			end)
			maid:Add(function()
				currentCamera.FieldOfView = 70
				currentCamera.CameraType = Enum.CameraType.Custom

				if not (currentCamera.CameraSubject and currentCamera.CameraSubject.Parent) then
					local character = Players.LocalPlayer.Character
					currentCamera.CameraSubject = character and character:FindFirstChildOfClass("Humanoid")
				end
			end)
			local v2 = maid:Add(script.Scene:Clone())
			v2.Parent = workspace
			ContentProvider:PreloadAsync({ script.sounds, v2 })
			v2.Lullaby.Highlight.FillTransparency = 1
			workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
			workspace.CurrentCamera.CFrame = CFrame.new(19.488, 3076.249, -5.654) * CFrame.fromOrientation(
				-0.11965977351673124,
				-2.65618168202513,
				0
			)
			workspace.CurrentCamera.Focus = workspace.CurrentCamera.CFrame
			TweenService:Create(workspace.CurrentCamera, TweenInfo.new(1.9, Enum.EasingStyle.Quart), {
				FieldOfView = 50
			}):Play()
			task.wait(1)
			TweenService:Create(v2.Lullaby.Highlight, TweenInfo.new(1, Enum.EasingStyle.Linear), {
				FillTransparency = 0
			}):Play()
			task.wait(1)
			emit.emit(v2.VFX)

			for _, v3 in v2.Lullaby:QueryDescendants("BasePart, ParticleEmitter, Beam, Trail, Decal") do
				v3.LocalTransparencyModifier = 1
			end

			task.wait(3)
			CutsceneController:FadeToggle(3, false)
			maid:Destroy()
			callback()
		end):catch(warn):finally(function()
			maid:Destroy()
		end)
	end
}