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
local LightingController = require(ReplicatedStorage.Controllers.Game.LightingController)
local Tabs = require(ReplicatedStorage.Client.Tabs)
require(ReplicatedStorage.Packages.Trove)
local outroCutscene1 = ReplicatedStorage.CutsceneAssets.ScrambleBossCutsceneAssets.OutroCutscene1
local v = {
	Enum.CoreGuiType.Backpack,
	Enum.CoreGuiType.Chat,
	Enum.CoreGuiType.PlayerList,
	Enum.CoreGuiType.Health,
	Enum.CoreGuiType.EmotesMenu
}
local v2 = { "Sky", "Atmosphere" }
local currentCamera = Workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = {}

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
	if v4 ~= nil then
		return
	end

	local v8 = {}
	v5 = Tabs.Active()

	for _, screenGui in localPlayer:WaitForChild("PlayerGui"):GetChildren() do
		if not (screenGui:IsA("ScreenGui") and screenGui.Name ~= "CutsceneUI" and screenGui.Enabled) then
			continue
		end

		v8[screenGui] = true
		screenGui.Enabled = false
	end

	v4 = v8
	pcall(function()
		localPlayer.PlayerGui.BottomUI.BottomFrame.Holder.List.Visible = false
	end)
	local coreGuiEnableds = {}

	for _, v9 in v do
		coreGuiEnableds[v9] = StarterGui:GetCoreGuiEnabled(v9)
		StarterGui:SetCoreGuiEnabled(v9, false)
	end

	v6 = coreGuiEnableds
end

local function restoreAllUi()
	local v8 = v4
	local v9 = v5
	v4 = nil
	v5 = nil

	if v8 ~= nil then
		for k in v8 do
			if k.Parent ~= nil and k.Name ~= v9 then
				k.Enabled = true
			end
		end
	end

	pcall(function()
		localPlayer.PlayerGui.BottomUI.BottomFrame.Holder.List.Visible = true
	end)
	local v10 = v6
	v6 = nil

	if v10 ~= nil then
		for k, v11 in v10 do
			StarterGui:SetCoreGuiEnabled(k, v11)
		end
	end

	return v9
end

local function hideCutsceneUi()
	if v3 == nil then
		v3 = HiddenUIHandler.Acquire()
	end

	hideAllUi()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreCutsceneUi()
	local v8 = restoreAllUi()
	local v9 = v3
	v3 = nil

	if v9 ~= nil then
		v9()
	end

	if v8 ~= nil then
		Tabs.Activate(v8, {
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
	v7[p] = nil
	local guard = parent:FindFirstChild("Guard")

	if guard ~= nil and guard ~= p then
		return
	end

	p.Parent = parent
end

local function hideAllGuardsAndNests(maid)
	for _, child in game.Workspace.World.Areas.GuardAreas:GetChildren(), nil, nil do
		local guard = child.Guard
		v7[guard] = child
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
	for k, v8 in v7 do
		restoreGuard(k, v8) -- equivalent call inferred; original call site unknown
		local nests = v8:FindFirstChild("Nests")
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
		local v8 = emitter
		task.delay(emitDuration, function()
			v8.Enabled = false
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
	local v8 = nil
	local v9 = {
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
			setProperty("Workspace.CurrentCamera.FieldOfView", 25),
			function()
				setEmitting(v8.Dizzy, false)
			end,
			setProperty(
				"Workspace.ScrambleBossOutro1VFX.Flight.CFrame",
				CFrame.new(2491.416, 264.4008, 1463.5636, 0, 1, 0, 0, 0, -1, -1, 0, 0)
			),
			tweenProperty(
				"Workspace.ScrambleBossOutro1VFX.Flight.CFrame",
				TweenInfo.new(2.25, Enum.EasingStyle.Linear),
				CFrame.new(2491.416, 262.4489, 1466.665, 0, 1, 0, 0.5558, 0, -0.8313, -0.8313, 0, -0.5558)
			),
			setProperty("Workspace.ScrambleBossOutro1Rigs.DrScramble.Back.Transparency", 0),
			setProperty("Workspace.ScrambleBossOutro1Rigs.DrScramble.Body.Transparency", 0),
			setProperty("Workspace.ScrambleBossOutro1Rigs.DrScramble.Hair.Transparency", 0),
			setProperty("Workspace.ScrambleBossOutro1Rigs.DrScramble.HeadGrin.Transparency", 1),
			setProperty("Workspace.ScrambleBossOutro1Rigs.DrScramble.HeadLaugh.Transparency", 0),
			setProperty("Workspace.ScrambleBossOutro1Rigs.DrScramble.HeadSmile.Transparency", 1),
			setProperty("Workspace.ScrambleBossOutro1Rigs.BrockkodileHeadRig.BrockHeads.Angry.LeftEye.Transparency", 0),
			setProperty("Workspace.ScrambleBossOutro1Rigs.BrockkodileHeadRig.BrockHeads.Angry.RightEye.Transparency", 0),
			setProperty("PlayerGui.CutsceneUI.Black.BackgroundTransparency", 1),
			setProperty("PlayerGui.CutsceneUI.Black.BackgroundColor3", Color3.new(0, 0, 0)),
			tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundColor3",
				TweenInfo.new(13.533333333333333, Enum.EasingStyle.Linear),
				Color3.new(0.465771, 1, 0.223529)
			),
			setProperty("Lighting.DepthOfField.Enabled", true),
			setProperty("Lighting.DepthOfField.InFocusRadius", 10),
			setProperty("Lighting.DepthOfField.FocusDistance", 0.05),
			setProperty("Lighting.DepthOfField.NearIntensity", 0.75),
			setProperty(
				"Workspace.ScrambleBossOutro1VFX.Angry.AngryHead.CFrame",
				CFrame.new(2474.0251, 255.93, 1386.3206, -0.8877, 0, -0.4605, 0, 1, 0, 0.4605, 0, -0.8877)
			),
			setProperty("Workspace.ScrambleBossOutro1VFX.Angry.AngryHead.Transparency", 0),
			setProperty("Lighting.CutsceneBlur.Enabled", true),
			setProperty("Lighting.CutsceneBlur.Size", 2),
			setProperty("PlayerGui.CutsceneUI.Vignette.ImageTransparency", 1),
			setProperty("PlayerGui.CutsceneUI.Vignette.Visible", true),
			setProperty("Lighting.Brock.TintColor", Color3.new(1, 1, 1)),
			setProperty("Lighting.Brock.Enabled", true),
			setProperty("Lighting.Brock.Saturation", 0),
			setProperty("Lighting.Brock.Contrast", 0)
		},
		[28] = { tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.15, Enum.EasingStyle.Linear),
				0
			) },
		[108] = { function()
				emitBurst(v8.BatHit)
			end },
		[135] = { tweenProperty(
				"Workspace.ScrambleBossOutro1VFX.Flight.CFrame",
				TweenInfo.new(0.11666666666666667, Enum.EasingStyle.Linear),
				CFrame.new(
					2498.4275,
					284.1872,
					1493.1517,
					-0,
					0.9939,
					-0.1099,
					0.7073,
					-0.0777,
					-0.7026,
					-0.7069,
					-0.0777,
					-0.703
				)
			) },
		[136] = { tweenProperty(
				"Lighting.DepthOfField.InFocusRadius",
				TweenInfo.new(1.0333333333333334, Enum.EasingStyle.Linear),
				350
			) },
		[142] = { tweenProperty(
				"Workspace.ScrambleBossOutro1VFX.Flight.CFrame",
				TweenInfo.new(0.13333333333333333, Enum.EasingStyle.Linear),
				CFrame.new(
					2506.4163,
					314.5122,
					1526.4484,
					-0.0672,
					0.9973,
					-0.0301,
					0.2867,
					-0.0095,
					-0.958,
					-0.9557,
					-0.073,
					-0.2853
				)
			) },
		[150] = { tweenProperty(
				"Workspace.ScrambleBossOutro1VFX.Flight.CFrame",
				TweenInfo.new(0.11666666666666667, Enum.EasingStyle.Linear),
				CFrame.new(
					2513.6011,
					347.2467,
					1557.4293,
					-0.0884,
					0.9943,
					0.059,
					-0.1444,
					0.0458,
					-0.9885,
					-0.9856,
					-0.0959,
					0.1395
				)
			) },
		[154] = { tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.5833333333333334, Enum.EasingStyle.Linear),
				1
			) },
		[157] = { tweenProperty(
				"Workspace.ScrambleBossOutro1VFX.Flight.CFrame",
				TweenInfo.new(0.08333333333333333, Enum.EasingStyle.Linear),
				CFrame.new(
					2516.4177,
					403.7317,
					1583.1393,
					-0.1004,
					0.9943,
					0.035,
					0.1082,
					0.0458,
					-0.9931,
					-0.9891,
					-0.0959,
					-0.1121
				)
			) },
		[162] = { tweenProperty(
				"Workspace.ScrambleBossOutro1VFX.Flight.CFrame",
				TweenInfo.new(0.08333333333333333, Enum.EasingStyle.Linear),
				CFrame.new(
					2520.0452,
					465.6886,
					1612.6007,
					-0.1004,
					0.9946,
					-0.0273,
					0.1082,
					-0.0163,
					-0.994,
					-0.9891,
					-0.1027,
					-0.1059
				)
			) },
		[167] = { tweenProperty(
				"Workspace.ScrambleBossOutro1VFX.Flight.CFrame",
				TweenInfo.new(0.06666666666666667, Enum.EasingStyle.Linear),
				CFrame.new(
					2521.8628,
					512.4241,
					1635.2535,
					-0.1004,
					0.9946,
					-0.0273,
					0.1082,
					-0.0163,
					-0.994,
					-0.9891,
					-0.1027,
					-0.1059
				)
			) },
		[171] = { tweenProperty(
				"Workspace.ScrambleBossOutro1VFX.Flight.CFrame",
				TweenInfo.new(0.11666666666666667, Enum.EasingStyle.Linear),
				CFrame.new(
					2526.8145,
					595.5174,
					1673.1318,
					-0.1004,
					0.9898,
					-0.1012,
					0.1082,
					-0.0903,
					-0.99,
					-0.9891,
					-0.1103,
					-0.098
				)
			) },
		[178] = { tweenProperty(
				"Workspace.ScrambleBossOutro1VFX.Flight.CFrame",
				TweenInfo.new(0.55, Enum.EasingStyle.Linear),
				CFrame.new(
					2546.7251,
					980.5066,
					1857.8026,
					-0.0898,
					0.9898,
					-0.1107,
					0.2065,
					-0.0903,
					-0.9743,
					-0.9743,
					-0.1103,
					-0.1963
				)
			) },
		[198] = { tweenProperty(
				"Lighting.DepthOfField.InFocusRadius",
				TweenInfo.new(1.7166666666666666, Enum.EasingStyle.Linear),
				300
			) },
		[211] = { tweenProperty(
				"Workspace.ScrambleBossOutro1VFX.Flight.CFrame",
				TweenInfo.new(0.3, Enum.EasingStyle.Linear),
				CFrame.new(
					2556.2241,
					1220.0552,
					1979.5344,
					-0.0898,
					0.9898,
					-0.1107,
					0.2065,
					-0.0903,
					-0.9743,
					-0.9743,
					-0.1103,
					-0.1963
				)
			) },
		[229] = { tweenProperty(
				"Workspace.ScrambleBossOutro1VFX.Flight.CFrame",
				TweenInfo.new(1.2666666666666666, Enum.EasingStyle.Linear),
				CFrame.new(
					2586.7708,
					1301.2866,
					2038.6105,
					-0.0898,
					0.9898,
					-0.1107,
					0.2065,
					-0.0903,
					-0.9743,
					-0.9743,
					-0.1103,
					-0.1963
				)
			) },
		[230] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.1, Enum.EasingStyle.Linear), 15) },
		[236] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.11666666666666667, Enum.EasingStyle.Linear),
				3
			) },
		[243] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.43333333333333335, Enum.EasingStyle.Linear),
				2.98704
			) },
		[269] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.2, Enum.EasingStyle.Linear), 15) },
		[281] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.25, Enum.EasingStyle.Linear), 2) },
		[301] = { tweenProperty(
				"Lighting.DepthOfField.InFocusRadius",
				TweenInfo.new(0.75, Enum.EasingStyle.Linear),
				206.78572
			) },
		[308] = {
			tweenProperty(
				"Workspace.ScrambleBossOutro1Rigs.DrScramble.Back.Transparency",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				1
			),
			tweenProperty(
				"Workspace.ScrambleBossOutro1Rigs.DrScramble.Body.Transparency",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				1
			),
			tweenProperty(
				"Workspace.ScrambleBossOutro1Rigs.DrScramble.Hair.Transparency",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				1
			),
			tweenProperty(
				"Workspace.ScrambleBossOutro1Rigs.DrScramble.HeadLaugh.Transparency",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				1
			)
		},
		[309] = { function()
				emitBurst(v8.Star)
			end },
		[346] = { tweenProperty(
				"Lighting.DepthOfField.InFocusRadius",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				10
			) },
		[441] = { tweenProperty(
				"Lighting.DepthOfField.InFocusRadius",
				TweenInfo.new(0.26666666666666666, Enum.EasingStyle.Linear),
				45
			) },
		[453] = { tweenProperty(
				"Lighting.DepthOfField.NearIntensity",
				TweenInfo.new(0.5166666666666667, Enum.EasingStyle.Linear),
				15
			) },
		[461] = { tweenProperty(
				"Lighting.DepthOfField.FocusDistance",
				TweenInfo.new(0.38333333333333336, Enum.EasingStyle.Linear),
				15
			) },
		[484] = { tweenProperty(
				"Lighting.DepthOfField.NearIntensity",
				TweenInfo.new(0.7333333333333333, Enum.EasingStyle.Linear),
				1
			) },
		[528] = {
			tweenProperty(
				"Lighting.DepthOfField.InFocusRadius",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				5
			),
			tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				0
			)
		},
		[529] = {
			tweenProperty(
				"Lighting.DepthOfField.InFocusRadius",
				TweenInfo.new(11.383333333333333, Enum.EasingStyle.Linear),
				10
			),
			tweenProperty(
				"Lighting.Brock.TintColor",
				TweenInfo.new(1.9166666666666667, Enum.EasingStyle.Linear),
				Color3.new(0.658419, 1, 0.537255)
			),
			tweenProperty("Lighting.Brock.Saturation", TweenInfo.new(1.9166666666666667, Enum.EasingStyle.Linear), 3),
			tweenProperty("Lighting.Brock.Contrast", TweenInfo.new(1.9166666666666667, Enum.EasingStyle.Linear), 2)
		},
		[615] = { tweenProperty(
				"Workspace.ScrambleBossOutro1VFX.Angry.AngryHead.Transparency",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				1
			) },
		[670] = { tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				1
			) },
		[671] = { setProperty("Lighting.Brock.Enabled", false) },
		[805] = {
			tweenProperty(
				"Workspace.ScrambleBossOutro1Rigs.BrockkodileHeadRig.BrockHeads.Angry.LeftEye.Transparency",
				TweenInfo.new(0.11666666666666667, Enum.EasingStyle.Linear),
				1
			),
			tweenProperty(
				"Workspace.ScrambleBossOutro1Rigs.BrockkodileHeadRig.BrockHeads.Angry.RightEye.Transparency",
				TweenInfo.new(0.11666666666666667, Enum.EasingStyle.Linear),
				1
			)
		},
		[811] = {
			tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				0.8
			),
			tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				0
			)
		},
		[812] = { tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundColor3",
				TweenInfo.new(24.883333333333333, Enum.EasingStyle.Linear),
				Color3.new(0, 0, 0)
			) },
		[849] = {
			tweenProperty(
				"Workspace.ScrambleBossOutro1Rigs.BrockkodileHeadRig.BrockHeads.Angry.LeftEye.Transparency",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				0
			),
			tweenProperty(
				"Workspace.ScrambleBossOutro1Rigs.BrockkodileHeadRig.BrockHeads.Angry.RightEye.Transparency",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				0
			),
			tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				1
			),
			tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				1
			)
		},
		[860] = { function()
				emitBurst(v8.BatHit2)
				setEmitting(v8.Dizzy, true)
			end },
		[895] = {
			tweenProperty(
				"Workspace.ScrambleBossOutro1Rigs.BrockkodileHeadRig.BrockHeads.Angry.LeftEye.Transparency",
				TweenInfo.new(0.05, Enum.EasingStyle.Linear),
				1
			),
			tweenProperty(
				"Workspace.ScrambleBossOutro1Rigs.BrockkodileHeadRig.BrockHeads.Angry.RightEye.Transparency",
				TweenInfo.new(0.05, Enum.EasingStyle.Linear),
				1
			)
		},
		[1212] = { tweenProperty(
				"Lighting.DepthOfField.InFocusRadius",
				TweenInfo.new(0.16666666666666666, Enum.EasingStyle.Linear),
				45
			) },
		[1393] = { function()
				setEmitting(v8.Dizzy, false)
			end },
		[1658] = { tweenProperty(
				"Lighting.DepthOfField.InFocusRadius",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				15
			) },
		[1869] = { tweenProperty(
				"Lighting.DepthOfField.InFocusRadius",
				TweenInfo.new(0.16666666666666666, Enum.EasingStyle.Linear),
				35
			) },
		[2242] = { function()
				emitBurst(v8.Portal)
			end },
		[2303] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.21666666666666667, Enum.EasingStyle.Linear),
				15
			) },
		[2305] = {
			tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.25, Enum.EasingStyle.Linear),
				0
			),
			tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundColor3",
				TweenInfo.new(0.25, Enum.EasingStyle.Linear),
				Color3.new(0.515866, 1, 0.372549)
			)
		},
		[2320] = { tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundColor3",
				TweenInfo.new(0.4666666666666667, Enum.EasingStyle.Linear),
				Color3.new(0, 0, 0)
			) }
	}
	return {
		Run = function()
			local v10 = false
			xpcall(hideCutsceneUi, warn)
			maid:Add(function()
				if not v10 then
					restoreCutsceneUi() -- equivalent call inferred; original call site unknown
					v10 = true
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
			LightingController.Settle()
			local firstChildOfClasses = {}
			local v11 = false

			for _, className in v2 do
				local firstChildOfClass = Lighting:FindFirstChildOfClass(className)

				if firstChildOfClass == nil then
					continue
				end

				firstChildOfClass.Parent = nil
				table.insert(firstChildOfClasses, firstChildOfClass)
				local v12 = firstChildOfClass
				maid:Add(function()
					v12.Parent = Lighting
				end)
			end

			maid:Add(function()
				if not v11 then
					v11 = true
					LightingController.Settle()
				end
			end)
			local clones = {}

			for _, child in outroCutscene1.LightingAssets:GetChildren() do
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
			local clone = outroCutscene1.ScrambleBossOutro1VFX:Clone()
			clone.Parent = Workspace
			v8 = clone
			maid:Add(clone)
			local clone2 = outroCutscene1.ScrambleBossOutro1WorkspaceAssets:Clone()
			clone2.Parent = Workspace
			maid:Add(clone2)
			local clone3 = outroCutscene1.CutsceneMusic:Clone()
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
			local clone4 = outroCutscene1.ScrambleBossOutro1Rigs:Clone()

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
			local v12 = {}

			for _, child in clone4:GetChildren() do
				local animation = child:FindFirstChildOfClass("Animation")

				if animation then
					v12[child] = loadAnimationIntoRig(child, animation.AnimationId)
				end
			end

			local v13 = true
			maid:Add(function()
				v13 = false
			end)
			maid:Add(function()
				if not v13 then
					return
				end

				restoreCamera()
			end)

			for _, v14 in v12 do
				v14:Play(0)
			end

			local v14 = v12[clone4.HumanoidCameraRig]
			assert(v14, "HumanoidCameraRig needs an Animation")
			local v15 = os.clock() + 2

			while v13 and v14.TimePosition <= 0 and os.clock() < v15 do
				RunService.RenderStepped:Wait()
			end

			clone3:Play()
			local torso = clone4.HumanoidCameraRig.Torso
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if not v13 then
					renderSteppedConnection:Disconnect()
					return
				end

				currentCamera.CameraType = Enum.CameraType.Scriptable
				localPlayer.ReplicationFocus = torso
				currentCamera.Focus = torso.CFrame
				currentCamera.CFrame = torso.CFrame
			end)
			local v16 = {}
			local total = 0
			local v17 = 0.1
			local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				total += dt
				v17 -= 0.1

				if v17 <= 0 then
					v17 = 0.1

					for _, v18 in v12 do
						if not (v18.IsPlaying and math.abs(total - v18.TimePosition) >= 0.4) then
							continue
						end

						local v19 = v18
						xpcall(function()
							v19.TimePosition = total
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
					local v18 = math.floor(total * 60 - i)

					if not v9[v18] or v16[v18] then
						continue
					end

					v16[v18] = true

					for _, callback in v9[v18] do
						task.spawn(callback)
					end
				end
			end)
			maid:Add(heartbeatConnection)
			TweenService:Create(black, TweenInfo.new(0.5), {
				BackgroundTransparency = 1
			}):Play()
			task.wait(39.85)
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
			v13 = false
			vignette.Visible = false
			xpcall(function()
				for _, v18 in clones do
					v18:Destroy()
				end

				for _, v18 in firstChildOfClasses do
					v18.Parent = Lighting
				end

				v11 = true
				LightingController.Settle()
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
				v10 = true
			end, warn)
			restoreAllGuardsAndNests()
		end
	}
end