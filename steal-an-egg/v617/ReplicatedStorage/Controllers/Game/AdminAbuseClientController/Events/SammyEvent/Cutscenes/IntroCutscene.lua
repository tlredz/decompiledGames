local ContentProvider = game:GetService("ContentProvider")
game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
require(ReplicatedStorage.Client.Modules.BulkFade)
local CutsceneHelperFunctions = require(script.Parent.Parent.Parent.Parent.CutsceneHelperFunctions)
require(ReplicatedStorage.Packages.Trove)
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local Tabs = require(ReplicatedStorage.Client.Tabs)
require(ReplicatedStorage.Shared.Remotes)
local currentCamera = Workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local sammyEventIntroRigs = ReplicatedStorage.CutsceneAssets.SammyEventIntroRigs
local sammyEventIntroVFX = ReplicatedStorage.CutsceneAssets.SammyEventIntroVFX
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = {
	Enum.CoreGuiType.Backpack,
	Enum.CoreGuiType.Chat,
	Enum.CoreGuiType.PlayerList,
	Enum.CoreGuiType.Health,
	Enum.CoreGuiType.EmotesMenu
}
local v6 = {}

local function restoreCamera()
	TweenService:Create(currentCamera, TweenInfo.new(0), {
		FieldOfView = 70
	}):Play()
	currentCamera.FieldOfView = 70
	currentCamera.CameraType = Enum.CameraType.Custom
	currentCamera.CameraSubject = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") or nil
	localPlayer.ReplicationFocus = nil
end

local function hideAllUi()
	if v2 ~= nil then
		return
	end

	local v7 = {}
	v3 = Tabs.Active()

	for _, screenGui in localPlayer:WaitForChild("PlayerGui"):GetChildren() do
		if not (screenGui:IsA("ScreenGui") and screenGui.Name ~= "UI_NAME" and screenGui.Enabled) then
			continue
		end

		v7[screenGui] = true
		screenGui.Enabled = false
	end

	v2 = v7
	pcall(function()
		localPlayer.PlayerGui.BottomUI.BottomFrame.Holder.List.Visible = false
	end)
	local coreGuiEnableds = {}

	for _, v8 in v5 do
		coreGuiEnableds[v8] = StarterGui:GetCoreGuiEnabled(v8)
		StarterGui:SetCoreGuiEnabled(v8, false)
	end

	v4 = coreGuiEnableds
end

local function restoreAllUi()
	local v7 = v2
	local v8 = v3
	v2 = nil
	v3 = nil

	if v7 ~= nil then
		for k in v7 do
			if k.Parent ~= nil and k.Name ~= v8 then
				k.Enabled = true
			end
		end
	end

	pcall(function()
		localPlayer.PlayerGui.BottomUI.BottomFrame.Holder.List.Visible = true
	end)
	local v9 = v4
	v4 = nil

	if v9 ~= nil then
		for k, v10 in v9 do
			StarterGui:SetCoreGuiEnabled(k, v10)
		end
	end

	return v8
end

local function hideCutsceneUi()
	if v == nil then
		v = HiddenUIHandler.Acquire()
	end

	hideAllUi()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreCutsceneUi()
	local v7 = restoreAllUi()
	local v8 = v
	v = nil

	if v8 ~= nil then
		v8()
	end

	if v7 ~= nil then
		Tabs.Activate(v7, {
			instant = true
		})
	end
end

local function setTransparency(items, p: number?)
	for _, part in items do
		if not part:IsA("BasePart") then
			continue
		end

		if not part:GetAttribute("OriginalTransparency") then
			part:SetAttribute("OriginalTransparency", part.Transparency)
		end

		part.Transparency = p or part:GetAttribute("OriginalTransparency")
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreGuard(p, parent)
	v6[p] = nil
	local guard = parent:FindFirstChild("Guard")

	if guard ~= nil and guard ~= p then
		return
	end

	p.Parent = parent
end

local function hideAllGuardsAndNests(maid)
	for _, child in game.Workspace.World.Areas.GuardAreas:GetChildren(), nil, nil do
		local guard = child.Guard
		v6[guard] = child
		guard.Parent = nil
		local nests = child:FindFirstChild("Nests")
		local descendants = nests and nests:GetDescendants()

		if descendants then
			setTransparency(descendants, 1)
		end

		local parent = child
		maid:Add(function()
			restoreGuard(guard, parent) -- equivalent call inferred; original call site unknown

			if nests then
				setTransparency(descendants)
			end
		end)
	end
end

local function restoreAllGuardsAndNests()
	for k, v7 in v6 do
		restoreGuard(k, v7) -- equivalent call inferred; original call site unknown
		local nests = v7:FindFirstChild("Nests")
		local descendants = nests and nests:GetDescendants()

		if descendants then
			setTransparency(descendants)
		end
	end
end

return function(maid)
	local helperFunctions = CutsceneHelperFunctions.GetHelperFunctions(maid)
	local setProperty = helperFunctions.SetProperty
	local tweenProperty = helperFunctions.TweenProperty
	local _ = helperFunctions.PlaySequenceAsync
	local loadAnimationIntoRig = helperFunctions.LoadAnimationIntoRig
	local cutsceneUI = localPlayer.PlayerGui.CutsceneUI
	local cutsceneMusic = script.CutsceneMusic
	local black = cutsceneUI.Black
	local vignette = cutsceneUI.Vignette
	local v7 = nil
	local clone = nil
	local samCam = nil
	local v8 = {
		[0] = {
			setProperty("Workspace.CurrentCamera.FieldOfView", 45),
			tweenProperty("Workspace.CurrentCamera.FieldOfView", TweenInfo.new(0.75, Enum.EasingStyle.Linear), 35),
			setProperty(
				"Workspace.CurrentCamera.CFrame",
				CFrame.new(
					3796.665,
					86.7965,
					-386.4179,
					-0.9931,
					0.0378,
					-0.1106,
					-0,
					0.9463,
					0.3233,
					0.1169,
					0.3211,
					-0.9398
				)
			),
			tweenProperty(
				"Workspace.CurrentCamera.CFrame",
				TweenInfo.new(8.516666666666667, Enum.EasingStyle.Linear),
				CFrame.new(
					3753.5005,
					75.0279,
					-354.4407,
					0.0198,
					-0.0393,
					-0.999,
					0.0055,
					0.9992,
					-0.0392,
					0.9998,
					-0.0047,
					0.02
				)
			),
			function()
				local glitch = clone.Sammy.HypnoFace.Glitch

				for _, effect in pairs(glitch:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = false
				end

				local hearts = v7.Hearts

				for _, effect in pairs(hearts:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = true
				end
			end,
			setProperty("PlayerGui.CutsceneUI.Black.BackgroundTransparency", 0),
			tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.9833333333333333, Enum.EasingStyle.Linear),
				1
			),
			setProperty("PlayerGui.CutsceneUI.Black.BackgroundColor3", Color3.new(0, 0, 0)),
			setProperty("Lighting.Close.Enabled", false),
			setProperty("Lighting.Far.Enabled", true),
			setProperty("PlayerGui.CutsceneUI.Vignette.ImageColor3", Color3.new(0, 0, 0)),
			tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageColor3",
				TweenInfo.new(9.683333333333334, Enum.EasingStyle.Linear),
				Color3.new(0.36618, 1, 0.258824)
			),
			setProperty("PlayerGui.CutsceneUI.Vignette.ImageTransparency", 1),
			setProperty("Lighting.Glitch.TintColor", Color3.new(1, 1, 1)),
			setProperty("Lighting.Glitch.Brightness", 0),
			setProperty("Lighting.Glitch.Saturation", 0),
			setProperty("Lighting.Glitch.Contrast", 0),
			setProperty("Lighting.CutsceneBlur.Enabled", true),
			setProperty("Lighting.CutsceneBlur.Size", 2),
			setProperty(
				"Workspace.SammyEventIntroVFX.Hearts.CFrame",
				CFrame.new(3808.9578, 71.9718, -354.5645, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			),
			tweenProperty(
				"Workspace.SammyEventIntroVFX.Hearts.CFrame",
				TweenInfo.new(0.7666666666666667, Enum.EasingStyle.Linear),
				CFrame.new(3804.4009, 71.9718, -354.5645, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			),
			setProperty("Workspace.SammyEventIntroVFX.Dome.BlackDome.Color", Color3.new(0.180392, 0.388235, 0.168627)),
			tweenProperty(
				"Workspace.SammyEventIntroVFX.Dome.BlackDome.Color",
				TweenInfo.new(9.85, Enum.EasingStyle.Linear),
				Color3.new(0, 0, 0)
			),
			setProperty("Workspace.SammyEventIntroVFX.Dome.BlackDome.Transparency", 1),
			setProperty(
				"Workspace.SammyEventIntroVFX.Dome.BlackDome.CFrame",
				CFrame.new(3750.9365, 76.2239, -354.1235, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			)
		},
		[18] = { function()
				local aura = v7.Aura

				for _, effect in pairs(aura:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = false
				end
			end },
		[46] = { tweenProperty(
				"Workspace.SammyEventIntroVFX.Hearts.CFrame",
				TweenInfo.new(2.2333333333333334, Enum.EasingStyle.Linear),
				CFrame.new(3790.2185, 71.9718, -354.5645, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			) },
		[180] = {
			tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				45
			),
			tweenProperty(
				"Workspace.SammyEventIntroVFX.Hearts.CFrame",
				TweenInfo.new(1.5, Enum.EasingStyle.Linear),
				CFrame.new(3780.9097, 71.9718, -354.5645, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			)
		},
		[181] = { setProperty("Lighting.Close.Enabled", true), setProperty("Lighting.Far.Enabled", false) },
		[271] = { setProperty("Lighting.Close.Enabled", false), setProperty("Lighting.Far.Enabled", true) },
		[273] = { function()
				local hearts = workspace.SammyEventIntroVFX.Hearts

				for _, effect in pairs(hearts:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = false
				end
			end },
		[361] = { tweenProperty("Workspace.CurrentCamera.FieldOfView", TweenInfo.new(0.6, Enum.EasingStyle.Sine), 50) },
		[397] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(1.8833333333333333, Enum.EasingStyle.Sine),
				55
			) },
		[433] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.4, Enum.EasingStyle.Linear), 15) },
		[457] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(1.05, Enum.EasingStyle.Linear), 4) },
		[510] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Sine),
				47.5
			) },
		[511] = {
			tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				45
			),
			tweenProperty(
				"Workspace.CurrentCamera.CFrame",
				TweenInfo.new(12.483333333333333, Enum.EasingStyle.Linear),
				CFrame.new(
					3771.3481,
					69.0059,
					-377.0066,
					-0.1228,
					-0.0156,
					-0.9923,
					-0.0066,
					0.9999,
					-0.0149,
					0.9924,
					0.0047,
					-0.1228
				)
			)
		},
		[543] = { function()
				local exclaim = v7.Exclaim

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in pairs(exclaim:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local emitCount = emitter:GetAttribute("EmitCount")
					local emitDuration = emitter:GetAttribute("EmitDuration")

					if check(emitCount) then
						emitter:Emit(emitCount)
					end

					if not check(emitDuration) then
						continue
					end

					emitter.Enabled = true
					local v11 = emitter
					task.delay(emitDuration, function()
						v11.Enabled = false
					end)
				end
			end },
		[579] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.13333333333333333, Enum.EasingStyle.Linear),
				15
			) },
		[581] = { tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.9666666666666667, Enum.EasingStyle.Linear),
				0
			) },
		[587] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.9833333333333333, Enum.EasingStyle.Linear),
				4
			) },
		[591] = {
			tweenProperty(
				"Workspace.SammyEventIntroVFX.Dome.BlackDome.Color",
				TweenInfo.new(1.15, Enum.EasingStyle.Linear),
				Color3.new(0.180392, 0.388235, 0.168627)
			),
			tweenProperty(
				"Workspace.SammyEventIntroVFX.Dome.BlackDome.Transparency",
				TweenInfo.new(0.5333333333333333, Enum.EasingStyle.Linear),
				0
			)
		},
		[606] = { function()
				local blackDome = v7.Dome.BlackDome

				for _, effect in pairs(blackDome:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = true
				end
			end },
		[657] = { function()
				local glitch = clone.Sammy.HypnoFace.Glitch

				for _, effect in pairs(glitch:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = true
				end
			end },
		[661] = {
			tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(2.316666666666667, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				95
			),
			function()
				samCam = clone.Sammy.SammyFacecam.SamCam
			end,
			tweenProperty("Lighting.Glitch.Saturation", TweenInfo.new(0.6, Enum.EasingStyle.Linear), -2)
		},
		[697] = { tweenProperty(
				"Lighting.Glitch.Contrast",
				TweenInfo.new(0.36666666666666664, Enum.EasingStyle.Linear),
				-2
			) },
		[734] = { tweenProperty(
				"Lighting.Glitch.Saturation",
				TweenInfo.new(0.36666666666666664, Enum.EasingStyle.Linear),
				2
			) },
		[756] = {
			tweenProperty("Lighting.Glitch.Saturation", TweenInfo.new(0.7333333333333333, Enum.EasingStyle.Linear), -3),
			tweenProperty("Lighting.Glitch.Contrast", TweenInfo.new(0.7333333333333333, Enum.EasingStyle.Linear), 0)
		},
		[769] = { tweenProperty(
				"Lighting.Glitch.TintColor",
				TweenInfo.new(0.5166666666666667, Enum.EasingStyle.Linear),
				Color3.new(0.421552, 1, 0.34902)
			) },
		[795] = { function()
				local glitch = clone.Sammy.HypnoFace.Glitch

				for _, effect in pairs(glitch:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = false
				end
			end },
		[800] = {
			tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				70
			),
			tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				0
			),
			tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundColor3",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				Color3.new(0.0884083, 0.133333, 0.0522876)
			),
			tweenProperty(
				"Lighting.Glitch.TintColor",
				TweenInfo.new(0.5666666666666667, Enum.EasingStyle.Linear),
				Color3.new(1, 1, 1)
			),
			tweenProperty(
				"Lighting.Glitch.Saturation",
				TweenInfo.new(0.5666666666666667, Enum.EasingStyle.Linear),
				-1.1
			)
		},
		[801] = {
			tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				68.85742
			),
			function()
				samCam = clone["Camera Rig"].Cam
			end
		},
		[806] = {
			tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.8666666666666667, Enum.EasingStyle.Linear),
				1
			),
			tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundColor3",
				TweenInfo.new(6.883333333333334, Enum.EasingStyle.Linear),
				Color3.new(0, 0, 0)
			)
		},
		[822] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				63.71582
			) },
		[834] = { tweenProperty("Lighting.Glitch.Saturation", TweenInfo.new(0.7, Enum.EasingStyle.Linear), 0) },
		[835] = {
			tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageColor3",
				TweenInfo.new(0.38333333333333336, Enum.EasingStyle.Linear),
				Color3.new(0, 0, 0)
			),
			tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.5166666666666667, Enum.EasingStyle.Linear), 7.5)
		},
		[867] = { function()
				local blackDome = v7.Dome.BlackDome

				for _, effect in pairs(blackDome:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = false
				end
			end },
		[995] = { function()
				local aura = v7.Aura

				for _, effect in pairs(aura:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = true
				end
			end },
		[1013] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				25
			) },
		[1014] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(4.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				22.80357
			) },
		[1098] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(1.5833333333333333, Enum.EasingStyle.Linear),
				4
			) },
		[1219] = { tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.6833333333333333, Enum.EasingStyle.Linear),
				0
			) }
	}
	return {
		Run = function()
			local v9 = false
			xpcall(hideCutsceneUi, warn)
			maid:Add(function()
				if not v9 then
					restoreCutsceneUi() -- equivalent call inferred; original call site unknown
					v9 = true
				end
			end)
			local areaEggSlotsClient = Workspace:FindFirstChild("AreaEggSlotsClient")
			pcall(function()
				areaEggSlotsClient.Parent = ReplicatedStorage
				maid:Add(function()
					areaEggSlotsClient.Parent = Workspace
				end)
			end)
			hideAllGuardsAndNests(maid)
			local clones = {}

			for _, child in script.LightingAssets:GetChildren() do
				if Lighting:FindFirstChild(child.Name) then
					continue
				end

				local clone2 = child:Clone()
				clone2.Parent = Lighting
				maid:Add(clone2)
				table.insert(clones, clone2)
			end

			cutsceneUI.Enabled = true
			black.BackgroundTransparency = 1
			black.Visible = true
			vignette.Visible = false
			maid:Add(function()
				vignette.Visible = false
				vignette.ImageTransparency = 1
			end)
			local clone2 = sammyEventIntroVFX:Clone()
			clone2.Parent = Workspace
			v7 = clone2
			maid:Add(clone2)
			TweenService:Create(black, TweenInfo.new(0.1), {
				BackgroundTransparency = 0
			}):Play()
			maid:Add(function()
				black.BackgroundTransparency = 1
				black.Visible = false
			end)
			clone = sammyEventIntroRigs:Clone()

			for _, model in clone:GetChildren() do
				if model:IsA("Model") and model.PrimaryPart then
					model.PrimaryPart.Anchored = true
				end
			end

			clone.Parent = workspace
			maid:Add(clone)
			local animations = {}

			for _, child in clone:GetChildren() do
				local animation = child:FindFirstChildOfClass("Animation")

				if animation then
					table.insert(animations, animation)
				end
			end

			ContentProvider:PreloadAsync(animations)
			local v10 = {}

			for _, child in clone:GetChildren() do
				local animation = child:FindFirstChildOfClass("Animation")

				if animation then
					v10[child] = loadAnimationIntoRig(child, animation.AnimationId)
				end
			end

			for _, child in v7:GetChildren() do
				local animation = child:FindFirstChildOfClass("Animation")

				if animation then
					v10[child] = loadAnimationIntoRig(child, animation.AnimationId)
				end
			end

			local v11 = true
			maid:Add(function()
				v11 = false
			end)
			maid:Add(function()
				if not v11 then
					return
				end

				restoreCamera()
			end)

			for _, v12 in v10 do
				v12:Play(0)
			end

			local v12 = v10[clone["Camera Rig"]]
			assert(v12, "Camera Rig needs an Animation")
			local v13 = os.clock() + 2

			while v11 and v12.TimePosition <= 0 and os.clock() < v13 do
				RunService.RenderStepped:Wait()
			end

			cutsceneMusic:Play()
			samCam = clone["Camera Rig"].Cam
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if not v11 then
					renderSteppedConnection:Disconnect()
					return
				end

				currentCamera.CameraType = Enum.CameraType.Scriptable
				localPlayer.ReplicationFocus = samCam
				currentCamera.Focus = samCam.CFrame
				currentCamera.CFrame = samCam.CFrame
			end)
			local v14 = {}
			local total = 0
			local v15 = 0.1
			local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				total += dt
				v15 -= 0.1

				if v15 <= 0 then
					v15 = 0.1

					for _, v16 in v10 do
						if not (v16.IsPlaying and math.abs(total - v16.TimePosition) >= 0.1) then
							continue
						end

						local v17 = v16
						xpcall(function()
							v17.TimePosition = total
						end, warn)
					end
				end

				if cutsceneMusic.TimePosition < total - 0.001 then
					cutsceneMusic.PlaybackSpeed = 1.01
				else
					local timePosition = cutsceneMusic.TimePosition

					if total + 0.001 < timePosition then
						cutsceneMusic.PlaybackSpeed = 0.99
					else
						cutsceneMusic.PlaybackSpeed = 1
					end
				end

				for i = 0, 9 do
					local v16 = math.floor(total * 60 - i)

					if not v8[v16] or v14[v16] then
						continue
					end

					v14[v16] = true

					for _, callback in v8[v16] do
						task.spawn(callback)
					end
				end
			end)
			maid:Add(heartbeatConnection)
			TweenService:Create(black, TweenInfo.new(0.5), {
				BackgroundTransparency = 1
			}):Play()
			task.wait(21.516666666666666)
			heartbeatConnection:Disconnect()
			xpcall(function()
				clone2:Destroy()
			end, warn)
			v11 = false
			vignette.Visible = false
			xpcall(function()
				for _, v16 in clones do
					v16:Destroy()
				end
			end, warn)
			xpcall(function()
				clone:Destroy()
			end, warn)
			xpcall(restoreCamera, warn)
			TweenService:Create(black, TweenInfo.new(0.5), {
				BackgroundTransparency = 1
			}):Play()
			task.wait(0.5)
			black.Visible = false
			vignette.Visible = false
			pcall(function()
				areaEggSlotsClient.Parent = Workspace
			end)
			xpcall(function()
				restoreCutsceneUi() -- equivalent call inferred; original call site unknown
				v9 = true
			end, warn)
		end
	}
end