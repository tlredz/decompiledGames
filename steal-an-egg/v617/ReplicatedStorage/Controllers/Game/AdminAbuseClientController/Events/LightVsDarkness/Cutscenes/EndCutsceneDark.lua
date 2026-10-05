local ContentProvider = game:GetService("ContentProvider")
game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local BulkFade = require(ReplicatedStorage.Client.Modules.BulkFade)
local CutsceneHelperFunctions = require(script.Parent.Parent.Parent.Parent.CutsceneHelperFunctions)
require(ReplicatedStorage.Packages.Trove)
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local Tabs = require(ReplicatedStorage.Client.Tabs)
require(ReplicatedStorage.Shared.Remotes)
local currentCamera = Workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local lightVsDarkCutsceneEndRigs = ReplicatedStorage.CutsceneAssets.LightVsDarkCutsceneEndRigs
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

local v7 = nil
local v8 = nil
local v9 = nil

local function hideZone12(maid)
	local zone12Props = game.Workspace.World.Build.Props:FindFirstChild("Zone12Props")

	if zone12Props then
		zone12Props.Parent = nil
		v7 = zone12Props
		maid:Add(function()
			zone12Props.Parent = game.Workspace.World.Build.Props
		end)
	end

	local board = game.Workspace.World.Areas.LightDark:FindFirstChild("Board")

	if board then
		board.Parent = nil
		v8 = board
		maid:Add(function()
			zone12Props.Parent = game.Workspace.World.Areas.LightDark
		end)
	end

	local lightDarkZone = game.Workspace.World.Build:FindFirstChild("LightDarkZone")

	if lightDarkZone then
		lightDarkZone.Parent = nil
		v9 = lightDarkZone
		maid:Add(function()
			lightDarkZone.Parent = game.Workspace.World.Build
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreZone12()
	if v7 then
		v7.Parent = game.Workspace.World.Build.Props
	end

	if v8 then
		v8.Parent = game.Workspace.World.Areas.LightDark
	end

	if v9 then
		v9.Parent = game.Workspace.World.Build
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
	local v10 = nil
	local v11 = {
		[0] = {
			setProperty(
				"Workspace.CurrentCamera.CFrame",
				CFrame.new(
					4982.5005,
					142.036,
					-415.143,
					-0.0078,
					0.4663,
					-0.8846,
					-0.0122,
					0.8845,
					0.4664,
					0.9999,
					0.0144,
					-0.0012
				)
			),
			tweenProperty(
				"Workspace.CurrentCamera.CFrame",
				TweenInfo.new(5, Enum.EasingStyle.Linear),
				CFrame.new(
					5495.7603,
					71.3227,
					-358.1957,
					-0.4007,
					-0.0489,
					-0.9149,
					-0.155,
					0.9878,
					0.0151,
					0.903,
					0.1478,
					-0.4034
				)
			),
			setProperty("Workspace.CurrentCamera.FieldOfView", 45),
			setProperty(
				"Workspace.LightVSDarkCutsceneEnd.VFX.DarkWin.Aura.Floor.CFrame",
				CFrame.new(5508.5933, 68.4898, 508.6608, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			),
			setProperty(
				"Workspace.LightVSDarkCutsceneEnd.VFX.DarkWin.Aura.Halo.CFrame",
				CFrame.new(5524.729, 119.1384, 509.4725, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			),
			setProperty("Lighting.CutsceneBlur.Enabled", true),
			setProperty("Lighting.CutsceneBlur.Size", 25),
			tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(1.0333333333333334, Enum.EasingStyle.Linear), 2),
			setProperty("PlayerGui.CutsceneUI.Black.BackgroundTransparency", 0),
			tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.55, Enum.EasingStyle.Linear),
				1
			),
			setProperty("Lighting.White.Enabled", false),
			setProperty("Lighting.Black.Enabled", false),
			setProperty("Lighting.REDWhite.Enabled", false),
			setProperty("Lighting.REDBlack.Enabled", false),
			setProperty("PlayerGui.CutsceneUI.Vignette.ImageColor3", Color3.new(0, 0, 0)),
			tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageColor3",
				TweenInfo.new(5.25, Enum.EasingStyle.Linear),
				Color3.new(0.0586241, 0, 0)
			),
			setProperty("PlayerGui.CutsceneUI.Vignette.ImageTransparency", 1),
			setProperty("PlayerGui.CutsceneUI.Vignette.Visible", true)
		},
		[8] = { function()
				local floorSammy = v10.VFX.DarkWin.FloorSammy

				for _, effect in pairs(floorSammy:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = false
				end
			end },
		[20] = { function()
				local hearts = v10.VFX.DarkWin.Hearts

				for _, effect in pairs(hearts:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = false
				end
			end },
		[101] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.1, Enum.EasingStyle.Linear), 15) },
		[106] = { function()
				local hit = v10.VFX.DarkWin.Hit

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in pairs(hit:GetDescendants()) do
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
					local v14 = emitter
					task.delay(emitDuration, function()
						v14.Enabled = false
					end)
				end
			end },
		[107] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.3, Enum.EasingStyle.Linear), 2) },
		[220] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.18333333333333332, Enum.EasingStyle.Linear),
				15
			) },
		[227] = { function()
				local smoke = v10.VFX.DarkWin.Smoke

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in pairs(smoke:GetDescendants()) do
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
					local v14 = emitter
					task.delay(emitDuration, function()
						v14.Enabled = false
					end)
				end
			end },
		[231] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.75, Enum.EasingStyle.Linear), 2) },
		[300] = {
			tweenProperty(
				"Workspace.CurrentCamera.CFrame",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				CFrame.new(
					5442.0625,
					110.1231,
					508.3064,
					0.0085,
					-0.0872,
					-0.9962,
					-0,
					0.9962,
					-0.0872,
					1,
					0.0007,
					0.0085
				)
			),
			tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Sine),
				75
			),
			tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				15
			)
		},
		[301] = {
			tweenProperty(
				"Workspace.CurrentCamera.CFrame",
				TweenInfo.new(8.666666666666666, Enum.EasingStyle.Linear),
				CFrame.new(
					5626.7803,
					75.4134,
					505.1515,
					-0.226,
					-0.3605,
					-0.905,
					-0.2128,
					0.9248,
					-0.3152,
					0.9506,
					0.1214,
					-0.2857
				)
			),
			tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.26666666666666666, Enum.EasingStyle.Sine),
				50
			),
			tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.4166666666666667, Enum.EasingStyle.Linear), 2)
		},
		[314] = { tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.26666666666666666, Enum.EasingStyle.Linear),
				0
			) },
		[315] = {
			setProperty("Lighting.REDWhite.Enabled", true),
			tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageColor3",
				TweenInfo.new(19.333333333333332, Enum.EasingStyle.Linear),
				Color3.new(0.27451, 0, 0)
			)
		},
		[317] = { setProperty("Lighting.REDWhite.Enabled", false), setProperty("Lighting.REDBlack.Enabled", true) },
		[319] = { setProperty("Lighting.White.Enabled", true), setProperty("Lighting.REDBlack.Enabled", false) },
		[321] = { setProperty("Lighting.White.Enabled", false), setProperty("Lighting.Black.Enabled", true) },
		[323] = { setProperty("Lighting.Black.Enabled", false), setProperty("Lighting.REDWhite.Enabled", true) },
		[325] = { setProperty("Lighting.REDWhite.Enabled", false), setProperty("Lighting.REDBlack.Enabled", true) },
		[327] = { setProperty("Lighting.REDBlack.Enabled", false) },
		[340] = {
			setProperty("Lighting.REDWhite.Enabled", false),
			setProperty("Lighting.REDBlack.Enabled", false),
			setProperty("Lighting.White.Enabled", false),
			setProperty("Lighting.Black.Enabled", false),
			setProperty("Lighting.REDWhite.Enabled", false),
			setProperty("Lighting.REDBlack.Enabled", false)
		},
		[350] = {
			setProperty("Lighting.REDWhite.Enabled", false),
			setProperty("Lighting.REDBlack.Enabled", false),
			setProperty("Lighting.White.Enabled", false),
			setProperty("Lighting.Black.Enabled", false),
			setProperty("Lighting.REDWhite.Enabled", false),
			setProperty("Lighting.REDBlack.Enabled", false)
		},
		[600] = {
			tweenProperty(
				"Workspace.LightVSDarkCutsceneEnd.VFX.DarkWin.Aura.Floor.CFrame",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				CFrame.new(5508.5933, -165.5602, 508.6608, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			),
			tweenProperty(
				"Workspace.LightVSDarkCutsceneEnd.VFX.DarkWin.Aura.Halo.CFrame",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				CFrame.new(5524.729, -147.5948, 509.4725, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			),
			tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				1
			)
		},
		[821] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.25, Enum.EasingStyle.Sine),
				35
			) },
		[872] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.35, Enum.EasingStyle.Sine),
				45
			) },
		[890] = { function()
				local sammyHit = v10.VFX.DarkWin.SammyHit

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in pairs(sammyHit:GetDescendants()) do
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
					local v14 = emitter
					task.delay(emitDuration, function()
						v14.Enabled = false
					end)
				end
			end },
		[956] = { function()
				local smoke3 = v10.VFX.DarkWin.Smoke3

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in pairs(smoke3:GetDescendants()) do
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
					local v14 = emitter
					task.delay(emitDuration, function()
						v14.Enabled = false
					end)
				end
			end },
		[976] = { function()
				local smoke4 = v10.VFX.DarkWin.Smoke4

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in pairs(smoke4:GetDescendants()) do
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
					local v14 = emitter
					task.delay(emitDuration, function()
						v14.Enabled = false
					end)
				end
			end },
		[1219] = { function()
				local hearts = v10.VFX.DarkWin.Hearts

				for _, effect in pairs(hearts:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = true
				end
			end },
		[1305] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				15
			) },
		[1306] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.7333333333333333, Enum.EasingStyle.Linear),
				2
			) },
		[1376] = { function()
				local hearts = v10.VFX.DarkWin.Hearts

				for _, effect in pairs(hearts:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = false
				end
			end },
		[1393] = { function()
				local floorSammy = v10.VFX.DarkWin.FloorSammy

				for _, effect in pairs(floorSammy:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = true
				end
			end },
		[1471] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Sine),
				70
			) },
		[1472] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.25, Enum.EasingStyle.Sine),
				40
			) },
		[1475] = { tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.25, Enum.EasingStyle.Linear),
				0
			) },
		[1570] = {
			tweenProperty("PlayerGui.CutsceneUI.Black.BackgroundTransparency", TweenInfo.new(0.3), 0),
			tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.3, Enum.EasingStyle.Linear),
				1
			)
		}
	}
	return {
		Run = function()
			local v12 = false
			xpcall(hideCutsceneUi, warn)
			maid:Add(function()
				if not v12 then
					restoreCutsceneUi() -- equivalent call inferred; original call site unknown
					v12 = true
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
			hideZone12(maid)
			local clones = {}

			for _, child in script.LightingAssets:GetChildren() do
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
			local clone = ReplicatedStorage.CutsceneAssets.LightVSDarkCutsceneEnd:Clone()
			clone.Parent = Workspace
			v10 = clone
			maid:Add(clone)
			TweenService:Create(black, TweenInfo.new(0.1), {
				BackgroundTransparency = 0
			}):Play()
			maid:Add(function()
				black.BackgroundTransparency = 1
				black.Visible = false
			end)
			local clone2 = lightVsDarkCutsceneEndRigs:Clone()

			for _, model in clone2:GetChildren() do
				if model:IsA("Model") and model.PrimaryPart then
					model.PrimaryPart.Anchored = true
				end
			end

			clone2.Parent = workspace
			maid:Add(clone2)
			local darkWinAnimations = {}

			for _, child in clone2:GetChildren() do
				local darkWinAnimation = child:FindFirstChild("DarkWinAnimation")

				if darkWinAnimation then
					table.insert(darkWinAnimations, darkWinAnimation)
				end
			end

			ContentProvider:PreloadAsync(darkWinAnimations)
			local v13 = {}

			for _, child in clone2:GetChildren() do
				local darkWinAnimation = child:FindFirstChild("DarkWinAnimation")

				if darkWinAnimation then
					v13[child] = loadAnimationIntoRig(child, darkWinAnimation.AnimationId)
				end
			end

			local v14 = true
			maid:Add(function()
				v14 = false
			end)
			maid:Add(function()
				if not v14 then
					return
				end

				restoreCamera()
			end)

			for _, v15 in v13 do
				v15:Play(0)
			end

			local v15 = v13[clone2["Camera Rig"]]
			assert(v15, "Camera Rig needs an Animation")
			local v16 = os.clock() + 2

			while v14 and v15.TimePosition <= 0 and os.clock() < v16 do
				RunService.RenderStepped:Wait()
			end

			cutsceneMusic:Play()
			local cam = clone2["Camera Rig"].Cam
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if not v14 then
					renderSteppedConnection:Disconnect()
					return
				end

				currentCamera.CameraType = Enum.CameraType.Scriptable
				localPlayer.ReplicationFocus = cam
				currentCamera.Focus = cam.CFrame
				currentCamera.CFrame = cam.CFrame
			end)
			local v17 = {}
			local total = 0
			local v18 = 0.1
			local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				total += dt
				v18 -= 0.1

				if v18 <= 0 then
					v18 = 0.1

					for _, v19 in v13 do
						if not (v19.IsPlaying and math.abs(total - v19.TimePosition) >= 0.1) then
							continue
						end

						local v20 = v19
						xpcall(function()
							v20.TimePosition = total
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
					local v19 = math.floor(total * 60 - i)

					if not v11[v19] or v17[v19] then
						continue
					end

					v17[v19] = true

					for _, callback in v11[v19] do
						task.spawn(callback)
					end
				end
			end)
			maid:Add(heartbeatConnection)
			TweenService:Create(black, TweenInfo.new(0.5), {
				BackgroundTransparency = 1
			}):Play()
			task.wait(26.983333333333334)
			heartbeatConnection:Disconnect()
			xpcall(function()
				clone:Destroy()
			end, warn)
			v14 = false
			vignette.Visible = false
			xpcall(function()
				for _, v19 in clones do
					v19:Destroy()
				end
			end, warn)
			xpcall(function()
				clone2:Destroy()
			end, warn)
			xpcall(restoreCamera, warn)
			local v19 = BulkFade.new(cutsceneUI.SammyIsComing, TweenInfo.new(1))
			v19:FadeOutInstant()
			task.wait()
			v19:FadeIn()
			cutsceneUI.SammyIsComing.Visible = true
			task.spawn(function()
				local function toDHMS(p: number)
					return string.format("%02i:%02i:%02i:%02i", p / 86400, p / 3600 % 24, p / 60 % 60, p % 60)
				end

				local v20 = 604799

				while cutsceneUI.SammyIsComing.Visible do
					cutsceneUI.SammyIsComing.TimeRemaining.Text = string.format(
						"%02i:%02i:%02i:%02i",
						v20 / 86400,
						v20 / 3600 % 24,
						v20 / 60 % 60,
						v20 % 60
					)
					script.ClockTick:Play()
					task.wait(1)
					v20 -= 1
				end
			end)
			task.wait(5)
			TweenService:Create(black, TweenInfo.new(0.5), {
				BackgroundTransparency = 1
			}):Play()
			v19:FadeOut()
			task.wait(0.5)
			task.delay(1, function()
				cutsceneUI.SammyIsComing.Visible = false
				v19:FadeIn()
			end)
			black.Visible = false
			vignette.Visible = false
			pcall(function()
				areaEggSlotsClient.Parent = Workspace
			end)
			xpcall(function()
				restoreCutsceneUi() -- equivalent call inferred; original call site unknown
				v12 = true
			end, warn)
			restoreAllGuardsAndNests()
			restoreZone12() -- equivalent call inferred; original call site unknown
		end
	}
end