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
local CutsceneHelperFunctions = require(script.Parent.Parent.Parent.CutsceneHelperFunctions)
require(ReplicatedStorage.Packages.Trove)
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local currentCamera = Workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
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

	local v6 = {}
	v3 = Tabs.Active()

	for _, screenGui in localPlayer:WaitForChild("PlayerGui"):GetChildren() do
		if not (screenGui:IsA("ScreenGui") and screenGui.Name ~= "DragonCinematic" and screenGui.Enabled) then
			continue
		end

		v6[screenGui] = true
		screenGui.Enabled = false
	end

	v2 = v6
	pcall(function()
		localPlayer.PlayerGui.BottomUI.BottomFrame.Holder.List.Visible = false
	end)
	local coreGuiEnableds = {}

	for _, v7 in v5 do
		coreGuiEnableds[v7] = StarterGui:GetCoreGuiEnabled(v7)
		StarterGui:SetCoreGuiEnabled(v7, false)
	end

	v4 = coreGuiEnableds
end

local function restoreAllUi()
	local v6 = v2
	local v7 = v3
	v2 = nil
	v3 = nil

	if v6 ~= nil then
		for k in v6 do
			if k.Parent ~= nil and k.Name ~= v7 then
				k.Enabled = true
			end
		end
	end

	pcall(function()
		localPlayer.PlayerGui.BottomUI.BottomFrame.Holder.List.Visible = true
	end)
	local v8 = v4
	v4 = nil

	if v8 ~= nil then
		for k, v9 in v8 do
			StarterGui:SetCoreGuiEnabled(k, v9)
		end
	end

	return v7
end

local function hideCutsceneUi()
	if v == nil then
		v = HiddenUIHandler.Acquire()
	end

	hideAllUi()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreCutsceneUi()
	local v6 = restoreAllUi()
	local v7 = v
	v = nil

	if v7 ~= nil then
		v7()
	end

	if v6 ~= nil then
		Tabs.Activate(v6, {
			instant = true
		})
	end
end

local function setTransparency(descendants, p: number?)
	for _, part in descendants do
		if not part:IsA("BasePart") then
			continue
		end

		if not part:GetAttribute("OriginalTransparency") then
			part:SetAttribute("OriginalTransparency", part.Transparency)
		end

		part.Transparency = p or part:GetAttribute("OriginalTransparency")
	end
end

return function(maid)
	local helperFunctions = CutsceneHelperFunctions.GetHelperFunctions(maid)
	local setProperty = helperFunctions.SetProperty
	local tweenProperty = helperFunctions.TweenProperty
	local _ = helperFunctions.PlaySequenceAsync
	local loadAnimationIntoRig = helperFunctions.LoadAnimationIntoRig
	local monsterEventCutscene = ReplicatedStorage.CutsceneAssets.MonsterEventCutscene
	local cutsceneUI = localPlayer.PlayerGui.CutsceneUI
	local cutsceneMusic = script.CutsceneMusic
	local black = cutsceneUI.Black
	local vignette = cutsceneUI.Vignette
	local v6 = nil
	local v7 = {
		[0] = {
			setProperty("Workspace.CurrentCamera.FieldOfView", 45),
			function()
				local ZZZ = v6:WaitForChild("ZZZ")

				for _, emitter in ipairs(ZZZ:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end,
			setProperty("Player.PlayerGui.CutsceneUI.Vignette.ImageColor3", Color3.new(0, 0, 0)),
			tweenProperty(
				"Player.PlayerGui.CutsceneUI.Vignette.ImageColor3",
				TweenInfo.new(0.9666666666666667, Enum.EasingStyle.Linear),
				Color3.new(0.419608, 0.733246, 1)
			),
			setProperty("Player.PlayerGui.CutsceneUI.Vignette.ImageTransparency", 0),
			setProperty("Lighting.Blizzard.Enabled", true),
			setProperty("Lighting.Blizzard.Saturation", 0.1),
			setProperty("Lighting.Blizzard.Contrast", -0.1),
			setProperty("Lighting.Blizzard.TintColor", Color3.new(0.811765, 0.94902, 0.988235)),
			setProperty("Lighting.Blizzard.Brightness", 0.05),
			setProperty("Lighting.CutsceneBlur.Enabled", true),
			setProperty("Lighting.CutsceneBlur.Size", 25),
			setProperty("Player.PlayerGui.CutsceneUI.Black.BackgroundTransparency", 0),
			tweenProperty(
				"Player.PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.9666666666666667, Enum.EasingStyle.Linear),
				1
			),
			setProperty("Lighting.EndDepth.Enabled", false),
			setProperty("Lighting.General.Enabled", true),
			setProperty("Lighting.Orange.Enabled", false),
			setProperty("Lighting.BlackOrange.Enabled", false),
			setProperty("Lighting.Purple.Enabled", false),
			setProperty("Lighting.BlackPurple.Enabled", false),
			setProperty("Lighting.Black+White.Enabled", false),
			setProperty("Lighting.White+Black.Enabled", false)
		},
		[23] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.7666666666666667, Enum.EasingStyle.Linear),
				2
			) },
		[297] = { function()
				local ZZZ = v6:WaitForChild("ZZZ")

				for _, emitter in ipairs(ZZZ:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end },
		[300] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.31666666666666665, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				12
			) },
		[311] = { function()
				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in v6.Exclaim:GetDescendants() do
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
					local v10 = emitter
					task.delay(emitDuration, function()
						v10.Enabled = false
					end)
				end
			end },
		[319] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				2
			) },
		[455] = { tweenProperty(
				"Player.PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				1
			) },
		[596] = {
			tweenProperty(
				"Player.PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				0
			),
			tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				20
			)
		},
		[597] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				2
			) },
		[627] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.08333333333333333, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				15
			) },
		[631] = { function()
				local land = v6.Land

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in pairs(land:GetDescendants()) do
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
					local v10 = emitter
					task.delay(emitDuration, function()
						v10.Enabled = false
					end)
				end
			end },
		[645] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(1.0666666666666667, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				5
			) },
		[781] = { function()
				local roar = v6:WaitForChild("Roar")

				for _, emitter in ipairs(roar:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end },
		[783] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.23333333333333334, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				10
			) },
		[815] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.06666666666666667, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				4
			) },
		[819] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.23333333333333334, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				5
			) },
		[825] = { function()
				local roar = v6:WaitForChild("Roar")

				for _, emitter in ipairs(roar:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end },
		[827] = { function()
				local scream = v6:WaitForChild("Scream")

				for _, emitter in ipairs(scream:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end },
		[915] = { function()
				local scream = v6:WaitForChild("Scream")

				for _, emitter in ipairs(scream:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end, tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				15
			) },
		[916] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				5
			) },
		[1362] = { function()
				local roar2 = v6:WaitForChild("Roar2")

				for _, emitter in ipairs(roar2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end },
		[1411] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.11666666666666667, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				9
			) },
		[1413] = { function()
				local roar2 = v6:WaitForChild("Roar2")

				for _, emitter in ipairs(roar2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end },
		[1414] = { function()
				local TweenService2 = game:GetService("TweenService")
				local folder = v6

				if not folder then
					warn("cutsceneVFX folder not found!")
					return
				end

				local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

				local function halfTimeScale(p)
					TweenService2:Create(p, tweenInfo, {
						TimeScale = p.TimeScale / 3
					}):Play()
				end

				for _, emitter in ipairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						TweenService2:Create(emitter, tweenInfo, {
							TimeScale = emitter.TimeScale / 3
						}):Play()
					end
				end
			end },
		[1415] = { function()
				local firstPunch = v6.Punches.FirstPunch

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in pairs(firstPunch:GetDescendants()) do
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
					local v10 = emitter
					task.delay(emitDuration, function()
						v10.Enabled = false
					end)
				end
			end },
		[1418] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.9666666666666667, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				5
			) },
		[1478] = { setProperty("Lighting.General.Enabled", false) },
		[1479] = { function()
				local TweenService2 = game:GetService("TweenService")
				local folder = v6

				if not folder then
					warn("cutsceneVFX folder not found!")
					return
				end

				local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

				local function doubleTimeScale(p)
					TweenService2:Create(p, tweenInfo, {
						TimeScale = p.TimeScale * 3
					}):Play()
				end

				for _, emitter in ipairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						TweenService2:Create(emitter, tweenInfo, {
							TimeScale = emitter.TimeScale * 3
						}):Play()
					end
				end
			end },
		[1483] = { setProperty("Lighting.EndDepth.Enabled", true) },
		[1488] = { function()
				local smash = v6.Smash

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in pairs(smash:GetDescendants()) do
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
					local v10 = emitter
					task.delay(emitDuration, function()
						v10.Enabled = false
					end)
				end
			end },
		[1489] = { function()
				local dust = v6.Dust

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in pairs(dust:GetDescendants()) do
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
					local v10 = emitter
					task.delay(emitDuration, function()
						v10.Enabled = false
					end)
				end
			end },
		[1505] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.4666666666666667, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				11
			) },
		[1533] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				5
			) },
		[1683] = {
			tweenProperty("Lighting.Blizzard.Saturation", TweenInfo.new(1.65, Enum.EasingStyle.Linear), 0),
			tweenProperty("Lighting.Blizzard.Contrast", TweenInfo.new(1.65, Enum.EasingStyle.Linear), 0),
			tweenProperty(
				"Lighting.Blizzard.TintColor",
				TweenInfo.new(1.65, Enum.EasingStyle.Linear),
				Color3.new(0.988235, 0.988235, 0.988235)
			),
			tweenProperty("Lighting.Blizzard.Brightness", TweenInfo.new(1.65, Enum.EasingStyle.Linear), 0)
		},
		[1693] = { tweenProperty(
				"Player.PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(1.5666666666666667, Enum.EasingStyle.Linear),
				1
			) },
		[1738] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.8833333333333333, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				2
			) },
		[1782] = { setProperty("Lighting.Blizzard.Enabled", false) },
		[1814] = { setProperty("Lighting.White+Black.Enabled", true) },
		[1816] = { function()
				local punch1 = v6.Punches.Punch1

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in pairs(punch1:GetDescendants()) do
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
					local v10 = emitter
					task.delay(emitDuration, function()
						v10.Enabled = false
					end)
				end
			end, setProperty("Lighting.BlackOrange.Enabled", true), setProperty("Lighting.White+Black.Enabled", false) },
		[1818] = { function()
				local smoke = v6.Smoke

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
					local v10 = emitter
					task.delay(emitDuration, function()
						v10.Enabled = false
					end)
				end
			end, setProperty("Lighting.Orange.Enabled", true), setProperty("Lighting.BlackOrange.Enabled", false) },
		[1820] = { setProperty("Lighting.Orange.Enabled", false) },
		[1854] = { function()
				local smoke2 = v6.Smoke2

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in pairs(smoke2:GetDescendants()) do
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
					local v10 = emitter
					task.delay(emitDuration, function()
						v10.Enabled = false
					end)
				end
			end },
		[2033] = { setProperty("Lighting.White+Black.Enabled", true) },
		[2034] = { function()
				local punch2 = v6.Punches.Punch2

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in pairs(punch2:GetDescendants()) do
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
					local v10 = emitter
					task.delay(emitDuration, function()
						v10.Enabled = false
					end)
				end
			end },
		[2035] = {
			setProperty("Lighting.BlackPurple.Enabled", true),
			setProperty("Lighting.White+Black.Enabled", false)
		},
		[2037] = { setProperty("Lighting.Purple.Enabled", true), setProperty("Lighting.BlackPurple.Enabled", false) },
		[2039] = { setProperty("Lighting.Purple.Enabled", false) },
		[2041] = { setProperty("Lighting.Black+White.Enabled", true) },
		[2043] = { setProperty("Lighting.Black+White.Enabled", false) },
		[2052] = { function()
				local smoke3 = v6.Smoke3

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
					local v10 = emitter
					task.delay(emitDuration, function()
						v10.Enabled = false
					end)
				end
			end },
		[2160] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.08333333333333333, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				10
			) },
		[2161] = { setProperty("Lighting.White+Black.Enabled", true) },
		[2163] = {
			setProperty("Lighting.Black+White.Enabled", true),
			setProperty("Lighting.White+Black.Enabled", false)
		},
		[2165] = { setProperty("Lighting.Black+White.Enabled", false) },
		[2166] = { function()
				local punch3 = v6.Punches.Punch3

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in pairs(punch3:GetDescendants()) do
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
					local v10 = emitter
					task.delay(emitDuration, function()
						v10.Enabled = false
					end)
				end
			end },
		[2167] = { function()
				local stomp = v6.Punches.Stomp

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in pairs(stomp:GetDescendants()) do
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
					local v10 = emitter
					task.delay(emitDuration, function()
						v10.Enabled = false
					end)
				end
			end, setProperty("Lighting.Orange.Enabled", true) },
		[2169] = { setProperty("Lighting.Orange.Enabled", false), setProperty("Lighting.BlackOrange.Enabled", true) },
		[2171] = {
			setProperty("Lighting.BlackOrange.Enabled", false),
			setProperty("Lighting.White+Black.Enabled", true)
		},
		[2173] = { setProperty("Lighting.White+Black.Enabled", false) },
		[2175] = { setProperty("Lighting.BlackOrange.Enabled", true) },
		[2177] = { setProperty("Lighting.BlackOrange.Enabled", false) },
		[2180] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.48333333333333334, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				2
			) },
		[2183] = { function()
				local smoke4 = v6.Smoke4

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
					local v10 = emitter
					task.delay(emitDuration, function()
						v10.Enabled = false
					end)
				end
			end, tweenProperty(
				"Player.PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.8333333333333334, Enum.EasingStyle.Linear),
				0
			) }
	}
	return {
		Run = function()
			local v8 = false
			xpcall(hideCutsceneUi, warn)
			local monsterEventMap = Workspace:FindFirstChild("MonsterEventMap")

			if monsterEventMap then
				monsterEventMap.WallStartVisual2.Transparency = 1
			end

			maid:Add(function()
				if not v8 then
					restoreCutsceneUi() -- equivalent call inferred; original call site unknown
					v8 = true
				end
			end)
			local areaEggSlotsClient = Workspace:FindFirstChild("AreaEggSlotsClient")
			pcall(function()
				areaEggSlotsClient.Parent = ReplicatedStorage
				maid:Add(function()
					areaEggSlotsClient.Parent = Workspace
				end)
			end)
			local descendants = game.Workspace.World.Areas.GuardAreas.Snow.Nests:GetDescendants()
			setTransparency(descendants, 1)
			maid:Add(function()
				setTransparency(descendants)
			end)
			pcall(function()
				task.spawn(function()
					local dragonEggEventMusic = Workspace:FindFirstChild("DragonEggEventMusic")

					if not dragonEggEventMusic then
						return
					end

					TweenService:Create(dragonEggEventMusic, TweenInfo.new(1), {
						Volume = 0
					}):Play()
				end)
			end)
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
			vignette.Visible = true
			maid:Add(function()
				vignette.Visible = false
				vignette.ImageTransparency = 1
			end)
			local clone = script.CutsceneVFX:Clone()
			clone.Parent = Workspace
			v6 = clone
			maid:Add(clone)
			TweenService:Create(black, TweenInfo.new(0.1), {
				BackgroundTransparency = 0
			}):Play()
			maid:Add(function()
				black.BackgroundTransparency = 1
				black.Visible = false
			end)
			local clone2 = monsterEventCutscene:Clone()

			for _, model in clone2:GetChildren() do
				if model:IsA("Model") and model.PrimaryPart then
					model.PrimaryPart.Anchored = true
				end
			end

			clone2.Parent = workspace
			maid:Add(clone2)
			local animations = {}

			for _, child in clone2:GetChildren() do
				local animation = child:FindFirstChildOfClass("Animation")

				if animation then
					table.insert(animations, animation)
				end
			end

			ContentProvider:PreloadAsync(animations)
			local v9 = {}

			for _, child in clone2:GetChildren() do
				local animation = child:FindFirstChildOfClass("Animation")

				if animation then
					v9[child] = loadAnimationIntoRig(child, animation.AnimationId)
				end
			end

			local v10 = true
			maid:Add(function()
				v10 = false
			end)
			maid:Add(function()
				if not v10 then
					return
				end

				restoreCamera()
			end)

			for _, v11 in v9 do
				v11:Play(0)
			end

			local v11 = v9[clone2["Camera Rig"]]
			assert(v11, "Camera Rig needs an Animation")
			local v12 = os.clock() + 2

			while v10 and v11.TimePosition <= 0 and os.clock() < v12 do
				RunService.RenderStepped:Wait()
			end

			cutsceneMusic:Play()
			local cam = clone2["Camera Rig"].Cam
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if not v10 then
					renderSteppedConnection:Disconnect()
					return
				end

				currentCamera.CameraType = Enum.CameraType.Scriptable
				localPlayer.ReplicationFocus = cam
				currentCamera.Focus = cam.CFrame
				currentCamera.CFrame = cam.CFrame
			end)
			local v13 = {}
			local total = 0
			local v14 = 0.1
			local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				total += dt
				v14 -= 0.1

				if v14 <= 0 then
					v14 = 0.1

					for _, v15 in v9 do
						if not (v15.IsPlaying and math.abs(total - v15.TimePosition) >= 0.1) then
							continue
						end

						local v16 = v15
						xpcall(function()
							v16.TimePosition = total
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
					local v15 = math.floor(total * 60 - i)

					if not v7[v15] or v13[v15] then
						continue
					end

					v13[v15] = true

					for _, callback in v7[v15] do
						task.spawn(callback)
					end
				end
			end)
			maid:Add(heartbeatConnection)
			task.wait(37.516666666666666)
			heartbeatConnection:Disconnect()
			xpcall(function()
				clone:Destroy()
			end, warn)
			v10 = false
			vignette.Visible = false
			xpcall(function()
				for _, v15 in clones do
					v15:Destroy()
				end
			end, warn)
			xpcall(function()
				clone2:Destroy()
			end, warn)
			pcall(function()
				task.spawn(function()
					local dragonEggEventMusic = Workspace:FindFirstChild("DragonEggEventMusic")

					if not dragonEggEventMusic then
						return
					end

					TweenService:Create(dragonEggEventMusic, TweenInfo.new(1), {
						Volume = 0.5
					}):Play()
				end)
			end)
			xpcall(restoreCamera, warn)
			local v15 = false
			task.spawn(function()
				Remotes.MonsterEvent.RequestTeleport:InvokeServer()
				v15 = true
			end)
			local total2 = 0

			while not v15 and total2 < 5 do
				total2 += task.wait()
			end

			TweenService:Create(black, TweenInfo.new(0.5), {
				BackgroundTransparency = 1
			}):Play()
			local monsterEventMap2 = Workspace:FindFirstChild("MonsterEventMap")

			if monsterEventMap2 then
				monsterEventMap2.WallStartVisual2.Transparency = 0
			end

			task.wait(0.5)
			black.Visible = false
			vignette.Visible = false
			pcall(function()
				areaEggSlotsClient.Parent = Workspace
			end)
			xpcall(function()
				restoreCutsceneUi() -- equivalent call inferred; original call site unknown
				v8 = true
			end, warn)
			setTransparency(descendants)
		end
	}
end