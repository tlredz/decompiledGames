local ContentProvider = game:GetService("ContentProvider")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CutsceneHelperFunctions = require(script.Parent.Parent.Parent.Parent.CutsceneHelperFunctions)
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local Tabs = require(ReplicatedStorage.Client.Tabs)
require(ReplicatedStorage.Packages.Trove)
local introCutscene1 = ReplicatedStorage.CutsceneAssets.ScrambleBossCutsceneAssets.IntroCutscene1
local v = {
	Enum.CoreGuiType.Backpack,
	Enum.CoreGuiType.Chat,
	Enum.CoreGuiType.PlayerList,
	Enum.CoreGuiType.Health,
	Enum.CoreGuiType.EmotesMenu
}
local currentCamera = Workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
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
	if v3 ~= nil then
		return
	end

	local v7 = {}
	v4 = Tabs.Active()

	for _, screenGui in localPlayer:WaitForChild("PlayerGui"):GetChildren() do
		if not (screenGui:IsA("ScreenGui") and screenGui.Name ~= "CutsceneUI" and screenGui.Enabled) then
			continue
		end

		v7[screenGui] = true
		screenGui.Enabled = false
	end

	v3 = v7
	pcall(function()
		localPlayer.PlayerGui.BottomUI.BottomFrame.Holder.List.Visible = false
	end)
	local coreGuiEnableds = {}

	for _, v8 in v do
		coreGuiEnableds[v8] = StarterGui:GetCoreGuiEnabled(v8)
		StarterGui:SetCoreGuiEnabled(v8, false)
	end

	v5 = coreGuiEnableds
end

local function restoreAllUi()
	local v7 = v3
	local v8 = v4
	v3 = nil
	v4 = nil

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
	local v9 = v5
	v5 = nil

	if v9 ~= nil then
		for k, v10 in v9 do
			StarterGui:SetCoreGuiEnabled(k, v10)
		end
	end

	return v8
end

local function hideCutsceneUi()
	if v2 == nil then
		v2 = HiddenUIHandler.Acquire()
	end

	hideAllUi()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreCutsceneUi()
	local v7 = restoreAllUi()
	local v8 = v2
	v2 = nil

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

local function setEmitting(folder, enabled: boolean)
	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
			continue
		end

		effect.Enabled = enabled
	end
end

local function emitBurst(folder)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")
		local emitDuration = emitter:GetAttribute("EmitDuration")

		if type(emitCount) == "number" and emitCount ~= 0 then
			emitter:Emit(emitCount)
		end

		if not (type(emitDuration) == "number" and emitDuration ~= 0) then
			continue
		end

		emitter.Enabled = true
		local v7 = emitter
		task.delay(emitDuration, function()
			v7.Enabled = false
		end)
	end
end

return function(maid)
	local helperFunctions = CutsceneHelperFunctions.GetHelperFunctions(maid)
	local setProperty = helperFunctions.SetProperty
	local tweenProperty = helperFunctions.TweenProperty
	local loadAnimationIntoRig = helperFunctions.LoadAnimationIntoRig
	local cutsceneUI = localPlayer.PlayerGui.CutsceneUI
	local black = cutsceneUI.Black
	local vignette = cutsceneUI.Vignette
	local v7 = nil
	local v8 = {
		[0] = {
			setProperty(
				"Workspace.CurrentCamera.CFrame",
				CFrame.new(
					-5252.8594,
					-234.99,
					2545.4341,
					0.791,
					0.1643,
					-0.5893,
					-0,
					0.9633,
					0.2685,
					0.6118,
					-0.2124,
					0.762
				)
			),
			setProperty("Workspace.CurrentCamera.FieldOfView", 30),
			function()
				setEmitting(v7.MainPortal, false)
			end,
			setProperty("Lighting.DepthOfField.Enabled", true),
			setProperty("Lighting.DepthOfField.InFocusRadius", 10),
			setProperty("Lighting.DepthOfField.FocusDistance", 5),
			setProperty("Lighting.CutsceneBlur.Enabled", true),
			setProperty("Lighting.CutsceneBlur.Size", 10),
			tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.18333333333333332, Enum.EasingStyle.Linear), 2),
			setProperty("PlayerGui.CutsceneUI.Black.BackgroundTransparency", 1),
			setProperty("PlayerGui.CutsceneUI.Black.BackgroundColor3", Color3.new(0, 0, 0)),
			tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundColor3",
				TweenInfo.new(14.633333333333333, Enum.EasingStyle.Linear),
				Color3.new(0.596974, 1, 0.384314)
			),
			setProperty("PlayerGui.CutsceneUI.Vignette.ImageTransparency", 1),
			setProperty("PlayerGui.CutsceneUI.Vignette.Visible", true),
			setProperty("Lighting.CrazyBrock.Enabled", false),
			setProperty("Lighting.CrazyBrock.Saturation", -0.5),
			tweenProperty(
				"Lighting.CrazyBrock.Saturation",
				TweenInfo.new(10.583333333333334, Enum.EasingStyle.Linear),
				0
			),
			setProperty("Lighting.CrazyBrock.Contrast", 0.7),
			tweenProperty("Lighting.CrazyBrock.Contrast", TweenInfo.new(10.583333333333334, Enum.EasingStyle.Linear), 0),
			setProperty("Lighting.CrazyBrock.TintColor", Color3.new(0.698039, 1, 0.643137)),
			tweenProperty(
				"Lighting.CrazyBrock.TintColor",
				TweenInfo.new(10.583333333333334, Enum.EasingStyle.Linear),
				Color3.new(1, 1, 1)
			),
			setProperty("Lighting.CrazyBrock.Brightness", -0.1),
			tweenProperty(
				"Lighting.CrazyBrock.Brightness",
				TweenInfo.new(10.583333333333334, Enum.EasingStyle.Linear),
				0
			),
			setProperty("Lighting.WhiteGreen.Enabled", false),
			setProperty("Lighting.BlackGreen.Enabled", false),
			setProperty(
				"Workspace.ScrambleBossIntro1Rigs.BenRigWithHandles.Highlight.FillColor",
				Color3.new(0.392157, 1, 0.254902)
			),
			tweenProperty(
				"Workspace.ScrambleBossIntro1Rigs.BenRigWithHandles.Highlight.FillColor",
				TweenInfo.new(14.433333333333334, Enum.EasingStyle.Linear),
				Color3.new(0, 0, 0)
			),
			setProperty("Workspace.ScrambleBossIntro1Rigs.BenRigWithHandles.Highlight.Enabled", false),
			setProperty(
				"Workspace.ScrambleBossIntro1Rigs.HatRig.Highlight.FillColor",
				Color3.new(0.392157, 1, 0.254902)
			),
			tweenProperty(
				"Workspace.ScrambleBossIntro1Rigs.HatRig.Highlight.FillColor",
				TweenInfo.new(14.433333333333334, Enum.EasingStyle.Linear),
				Color3.new(0, 0, 0)
			),
			setProperty("Workspace.ScrambleBossIntro1Rigs.HatRig.Highlight.Enabled", false),
			setProperty(
				"Workspace.ScrambleBossIntro1Rigs.BrockkodileHeadRig.Highlight.FillColor",
				Color3.new(0.392157, 1, 0.254902)
			),
			tweenProperty(
				"Workspace.ScrambleBossIntro1Rigs.BrockkodileHeadRig.Highlight.FillColor",
				TweenInfo.new(14.433333333333334, Enum.EasingStyle.Linear),
				Color3.new(0, 0, 0)
			),
			setProperty("Workspace.ScrambleBossIntro1Rigs.BrockkodileHeadRig.Highlight.Enabled", false)
		},
		[87] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.03333333333333333, Enum.EasingStyle.Linear),
				15
			) },
		[89] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.16666666666666666, Enum.EasingStyle.Linear),
				5
			) },
		[114] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.06666666666666667, Enum.EasingStyle.Linear),
				15
			) },
		[115] = { function()
				emitBurst(v7.Smoke)
			end },
		[118] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.45, Enum.EasingStyle.Linear), 2) },
		[263] = { tweenProperty(
				"Lighting.DepthOfField.FocusDistance",
				TweenInfo.new(0.03333333333333333, Enum.EasingStyle.Linear),
				0
			) },
		[265] = { tweenProperty(
				"Lighting.DepthOfField.FocusDistance",
				TweenInfo.new(15.7, Enum.EasingStyle.Linear),
				5
			) },
		[298] = { function()
				setEmitting(v7.ClawPortal1, true)
			end },
		[381] = { function()
				setEmitting(v7.ClawPortal2, true)
			end },
		[397] = { function()
				setEmitting(v7.ClawPortal3, true)
			end },
		[501] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.6166666666666667, Enum.EasingStyle.Linear),
				10
			) },
		[538] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(1.5666666666666667, Enum.EasingStyle.Linear),
				7
			) },
		[632] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.4666666666666667, Enum.EasingStyle.Linear),
				4
			) },
		[635] = {
			tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.4666666666666667, Enum.EasingStyle.Linear),
				0
			),
			setProperty("Lighting.CrazyBrock.Enabled", true),
			tweenProperty(
				"Lighting.CrazyBrock.Saturation",
				TweenInfo.new(0.4666666666666667, Enum.EasingStyle.Linear),
				-0.5
			),
			tweenProperty(
				"Lighting.CrazyBrock.Contrast",
				TweenInfo.new(0.4666666666666667, Enum.EasingStyle.Linear),
				0.7
			),
			tweenProperty(
				"Lighting.CrazyBrock.TintColor",
				TweenInfo.new(0.4666666666666667, Enum.EasingStyle.Linear),
				Color3.new(0.698039, 1, 0.643137)
			),
			tweenProperty(
				"Lighting.CrazyBrock.Brightness",
				TweenInfo.new(0.4666666666666667, Enum.EasingStyle.Linear),
				-0.1
			)
		},
		[726] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.2, Enum.EasingStyle.Linear), 10) },
		[738] = {
			tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.11666666666666667, Enum.EasingStyle.Linear), 5),
			tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.08333333333333333, Enum.EasingStyle.Linear),
				1
			),
			tweenProperty(
				"Lighting.CrazyBrock.Saturation",
				TweenInfo.new(0.08333333333333333, Enum.EasingStyle.Linear),
				0
			),
			tweenProperty(
				"Lighting.CrazyBrock.Contrast",
				TweenInfo.new(0.08333333333333333, Enum.EasingStyle.Linear),
				0
			),
			tweenProperty(
				"Lighting.CrazyBrock.TintColor",
				TweenInfo.new(0.08333333333333333, Enum.EasingStyle.Linear),
				Color3.new(1, 1, 1)
			),
			tweenProperty(
				"Lighting.CrazyBrock.Brightness",
				TweenInfo.new(0.08333333333333333, Enum.EasingStyle.Linear),
				0
			)
		},
		[754] = { function()
				setEmitting(v7.ClawPortal1, false)
				setEmitting(v7.ClawPortal2, false)
				setEmitting(v7.ClawPortal3, false)
				setEmitting(v7.MainPortal, true)
			end },
		[814] = { tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.45, Enum.EasingStyle.Linear),
				0
			) },
		[859] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.21666666666666667, Enum.EasingStyle.Linear),
				25
			) },
		[866] = {
			setProperty("Lighting.BlackGreen.Enabled", true),
			setProperty("Workspace.ScrambleBossIntro1Rigs.BenRigWithHandles.Highlight.Enabled", true),
			setProperty("Workspace.ScrambleBossIntro1Rigs.HatRig.Highlight.Enabled", true),
			setProperty("Workspace.ScrambleBossIntro1Rigs.BrockkodileHeadRig.Highlight.Enabled", true)
		},
		[867] = {
			tweenProperty(
				"Workspace.ScrambleBossIntro1Rigs.BenRigWithHandles.Highlight.FillColor",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				Color3.new(0.392157, 1, 0.254902)
			),
			tweenProperty(
				"Workspace.ScrambleBossIntro1Rigs.HatRig.Highlight.FillColor",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				Color3.new(0.392157, 1, 0.254902)
			),
			tweenProperty(
				"Workspace.ScrambleBossIntro1Rigs.BrockkodileHeadRig.Highlight.FillColor",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				Color3.new(0.392157, 1, 0.254902)
			)
		},
		[868] = { setProperty("Lighting.WhiteGreen.Enabled", true), setProperty("Lighting.BlackGreen.Enabled", false) },
		[869] = {
			tweenProperty(
				"Workspace.ScrambleBossIntro1Rigs.BenRigWithHandles.Highlight.FillColor",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				Color3.new(0, 0, 0)
			),
			tweenProperty(
				"Workspace.ScrambleBossIntro1Rigs.HatRig.Highlight.FillColor",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				Color3.new(0, 0, 0)
			),
			tweenProperty(
				"Workspace.ScrambleBossIntro1Rigs.BrockkodileHeadRig.Highlight.FillColor",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				Color3.new(0, 0, 0)
			)
		},
		[870] = { setProperty("Lighting.WhiteGreen.Enabled", false), setProperty("Lighting.BlackGreen.Enabled", true) },
		[871] = {
			tweenProperty(
				"Workspace.ScrambleBossIntro1Rigs.BenRigWithHandles.Highlight.FillColor",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				Color3.new(0.392157, 1, 0.254902)
			),
			tweenProperty(
				"Workspace.ScrambleBossIntro1Rigs.HatRig.Highlight.FillColor",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				Color3.new(0.392157, 1, 0.254902)
			),
			tweenProperty(
				"Workspace.ScrambleBossIntro1Rigs.BrockkodileHeadRig.Highlight.FillColor",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				Color3.new(0.392157, 1, 0.254902)
			)
		},
		[872] = { setProperty("Lighting.WhiteGreen.Enabled", true), setProperty("Lighting.BlackGreen.Enabled", false) },
		[873] = {
			tweenProperty(
				"Workspace.ScrambleBossIntro1Rigs.BenRigWithHandles.Highlight.FillColor",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				Color3.new(0, 0, 0)
			),
			tweenProperty(
				"Workspace.ScrambleBossIntro1Rigs.HatRig.Highlight.FillColor",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				Color3.new(0, 0, 0)
			),
			tweenProperty(
				"Workspace.ScrambleBossIntro1Rigs.BrockkodileHeadRig.Highlight.FillColor",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				Color3.new(0, 0, 0)
			)
		},
		[874] = { setProperty("Lighting.WhiteGreen.Enabled", false), setProperty("Lighting.BlackGreen.Enabled", true) },
		[876] = {
			setProperty("Lighting.BlackGreen.Enabled", false),
			setProperty("Workspace.ScrambleBossIntro1Rigs.BenRigWithHandles.Highlight.Enabled", false),
			setProperty("Workspace.ScrambleBossIntro1Rigs.HatRig.Highlight.Enabled", false),
			setProperty("Workspace.ScrambleBossIntro1Rigs.BrockkodileHeadRig.Highlight.Enabled", false)
		},
		[877] = { tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				0
			) },
		[880] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.21666666666666667, Enum.EasingStyle.Linear),
				5
			) },
		[881] = { tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.2, Enum.EasingStyle.Linear),
				1
			) },
		[893] = { tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundColor3",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				Color3.new(0, 0, 0)
			) },
		[934] = { tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.23333333333333334, Enum.EasingStyle.Linear),
				0
			) },
		[1207] = { tweenProperty(
				"Lighting.DepthOfField.FocusDistance",
				TweenInfo.new(0.35, Enum.EasingStyle.Linear),
				20
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

			for _, child in introCutscene1.LightingAssets:GetChildren() do
				if Lighting:FindFirstChild(child.Name) then
					continue
				end

				local clone = child:Clone()
				clone.Parent = Lighting
				maid:Add(clone)
				table.insert(clones, clone)
			end

			cutsceneUI.Enabled = true
			black.BackgroundTransparency = 1
			black.Visible = true
			vignette.Visible = false
			maid:Add(function()
				vignette.Visible = false
				vignette.ImageTransparency = 1
			end)
			local clone = introCutscene1.ScrambleBossIntro1VFX:Clone()
			clone.Parent = Workspace
			v7 = clone
			maid:Add(clone)
			local clone2 = introCutscene1.ScrambleBossIntro1WorkspaceAssets:Clone()
			clone2.Parent = Workspace
			maid:Add(clone2)
			local clone3 = introCutscene1.CutsceneMusic:Clone()
			clone3.Parent = SoundService
			maid:Add(clone3)
			TweenService:Create(black, TweenInfo.new(0.1), {
				BackgroundTransparency = 0
			}):Play()
			maid:Add(function()
				black.BackgroundTransparency = 1
				black.BackgroundColor3 = Color3.new(0, 0, 0)
				black.Visible = false
			end)
			local clone4 = introCutscene1.ScrambleBossIntro1Rigs:Clone()

			for _, model in clone4:GetChildren() do
				if model:IsA("Model") and model.PrimaryPart then
					model.PrimaryPart.Anchored = true
				end
			end

			clone4.Parent = Workspace
			maid:Add(clone4)
			local animations = {}

			for _, child in clone4:GetChildren() do
				local animation = child:FindFirstChildOfClass("Animation")

				if animation then
					table.insert(animations, animation)
				end
			end

			ContentProvider:PreloadAsync(animations)
			local v10 = {}

			for _, child in clone4:GetChildren() do
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

			local v12 = v10[clone4.HumanoidCameraRig]
			assert(v12, "HumanoidCameraRig needs an Animation")
			local v13 = os.clock() + 2

			while v11 and v12.TimePosition <= 0 and os.clock() < v13 do
				RunService.RenderStepped:Wait()
			end

			clone3:Play()
			local torso = clone4.HumanoidCameraRig.Torso
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if not v11 then
					renderSteppedConnection:Disconnect()
					return
				end

				currentCamera.CameraType = Enum.CameraType.Scriptable
				localPlayer.ReplicationFocus = torso
				currentCamera.Focus = torso.CFrame
				currentCamera.CFrame = torso.CFrame
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
						if not (v16.IsPlaying and math.abs(total - v16.TimePosition) >= 0.4) then
							continue
						end

						local v17 = v16
						xpcall(function()
							v17.TimePosition = total
						end, warn)
					end
				end

				if clone3.TimePosition < total - 0.001 then
					clone3.PlaybackSpeed = 1.01
				else
					local timePosition = clone3.TimePosition

					if total + 0.001 < timePosition then
						clone3.PlaybackSpeed = 0.99
					else
						clone3.PlaybackSpeed = 1
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
			task.wait(16.966666666666665)
			heartbeatConnection:Disconnect()
			xpcall(function()
				clone:Destroy()
			end, warn)
			xpcall(function()
				clone2:Destroy()
			end, warn)
			xpcall(function()
				clone3:Destroy()
			end, warn)
			v11 = false
			vignette.Visible = false
			xpcall(function()
				for _, v16 in clones do
					v16:Destroy()
				end
			end, warn)
			xpcall(function()
				clone4:Destroy()
			end, warn)
			xpcall(restoreCamera, warn)
			task.wait(0.5)
			vignette.Visible = false
			pcall(function()
				areaEggSlotsClient.Parent = Workspace
			end)
			xpcall(function()
				restoreCutsceneUi() -- equivalent call inferred; original call site unknown
				v9 = true
			end, warn)
			restoreAllGuardsAndNests()
		end
	}
end