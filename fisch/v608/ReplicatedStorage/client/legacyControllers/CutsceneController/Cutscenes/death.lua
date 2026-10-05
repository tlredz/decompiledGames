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
local _ = Players.LocalPlayer
local HideInstances = require(ReplicatedStorage.shared.modules.HideInstances)
local CutsceneController = require(ReplicatedStorage.client.legacyControllers.CutsceneController)
local PlayerController = require(ReplicatedStorage.client.legacyControllers.PlayerController)
local LightingController = require(ReplicatedStorage.client.legacyControllers.LightingController)
require(ReplicatedStorage.client.legacyControllers.HudController)
require(ReplicatedStorage.client.modules.moonliteCutscene)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
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
	Start = function(_, player, value: string?, instance)
		local maid = Trove.new()
		return Promise.new(function(callback, _, _)
			local _ = player.Character

			if player ~= localPlayer then
				return callback()
			end

			ContentProvider:PreloadAsync({ script.sounds })
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
				task.defer(function()
					LightingController.UpdateLighting(0)
				end)
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
			LightingController.UpdateLighting(0)
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
			local parent = maid:Add(script.placeholder:Clone())
			local clone

			if typeof(instance) == "Instance" then
				local archivable = instance.Archivable

				if not archivable then
					instance.Archivable = true
				end

				clone = instance:Clone()

				if clone:IsA("Model") and clone:GetExtentsSize().Magnitude > 8 then
					clone:ScaleTo(clone:GetScale() * (8 / clone:GetExtentsSize().Magnitude))
				end

				clone:PivotTo(script.props.Sleepy:GetPivot())

				if not archivable then
					instance.Archivable = false
				end
			else
				clone = script.props:FindFirstChild(instance or "Sleepy"):Clone()
			end

			clone.Parent = parent
			parent.Parent = workspace
			ContentProvider:PreloadAsync({ script.sounds, parent })
			workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
			workspace.CurrentCamera.CFrame = CFrame.new(19.488, 3076.249, -5.654) * CFrame.fromOrientation(
				-0.11965977351673124,
				-2.65618168202513,
				0
			)
			task.wait(2)

			if localPlayer.Character and localPlayer.Character == instance then
				ReplicatedStorage.events.drown:FireServer()
			end

			for _, v3 in parent:QueryDescendants("ParticleEmitter") do
				v3:Emit(v3:GetAttribute("EmitCount"))
			end

			for _, child in script.sounds:GetChildren() do
				child:Play()
			end

			task.wait(0.5)

			for _, child in script.sounds:GetChildren() do
				child:Stop()
			end

			local v3 = maid:Add(script.ScreenGui:Clone())
			v3.TextLabel.Text = value or "meow"
			v3.Enabled = true
			v3.Parent = playerGui
			task.wait(3)
			CutsceneController:FadeToggle(3, false)
			maid:Destroy()
			callback()
		end):catch(warn):finally(function()
			maid:Destroy()
		end)
	end
}