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
local LightingController = require(ReplicatedStorage.Controllers.Game.LightingController)
local currentCamera = Workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local lightVSDarkCutscene1Rigs = ReplicatedStorage.CutsceneAssets.LightVSDarkCutscene1Rigs
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

		local parent2 = child
		maid:Add(function()
			restoreGuard(guard, parent2) -- equivalent call inferred; original call site unknown

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
local v10 = nil
local parent = nil

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

	local fakeLightDarkWall = game.Workspace:FindFirstChild("FakeLightDarkWall")

	if fakeLightDarkWall then
		v10 = fakeLightDarkWall
		parent = fakeLightDarkWall.Parent
		fakeLightDarkWall.Parent = nil
		maid:Add(function()
			fakeLightDarkWall.Parent = parent
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

	if v10 then
		v10.Parent = parent
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
	local v11 = nil
	local clone = nil
	local v12 = {
		[0] = {
			setProperty(
				"Workspace.CurrentCamera.CFrame",
				CFrame.new(
					5012.6948,
					73.4391,
					-369.3411,
					-0.9624,
					-0.1056,
					0.2503,
					-0,
					0.9214,
					0.3888,
					-0.2716,
					0.3742,
					-0.8868
				)
			),
			tweenProperty(
				"Workspace.CurrentCamera.CFrame",
				TweenInfo.new(22.516666666666666, Enum.EasingStyle.Linear),
				CFrame.new(
					4959.1108,
					69.6647,
					-357.4677,
					-0.9912,
					-0.0969,
					-0.0901,
					0.0391,
					0.4358,
					-0.8992,
					0.1264,
					-0.8948,
					-0.4282
				)
			),
			setProperty("Workspace.CurrentCamera.FieldOfView", 45),
			function()
				local asteroid = workspace.LightVSDarkCutscene1.ZoneExtras.Asteroid

				for _, effect in pairs(asteroid:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = true
				end

				local aura = workspace.LightVSDarkCutscene1.VFX.Aura

				for _, effect in pairs(aura:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = false
				end
			end,
			setProperty(
				"Workspace.LightVSDarkCutscene1.VFX.Plates.HeavenSide.CFrame",
				CFrame.new(5306.4995, 67.7776, -378.3783, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			),
			setProperty(
				"Workspace.LightVSDarkCutscene1.VFX.Plates.HellSide.CFrame",
				CFrame.new(5314.0996, 67.7776, -349.8495, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			),
			setProperty("Lighting.White.Enabled", false),
			setProperty("Lighting.Black.Enabled", false),
			setProperty("Lighting.RedBlack.Enabled", false),
			setProperty("Lighting.RedWhite.Enabled", false),
			setProperty("Lighting.GoldWhite.Enabled", false),
			setProperty("Lighting.GoldBlack.Enabled", false),
			setProperty("Lighting.CutsceneBlur.Enabled", true),
			setProperty("Lighting.CutsceneBlur.Size", 2),
			setProperty("Player.PlayerGui.CutsceneUI.Black.BackgroundTransparency", 1),
			setProperty("Player.PlayerGui.CutsceneUI.Black.BackgroundColor3", Color3.new(0, 0, 0)),
			tweenProperty(
				"Player.PlayerGui.CutsceneUI.Black.BackgroundColor3",
				TweenInfo.new(22.216666666666665, Enum.EasingStyle.Linear),
				Color3.new(1, 1, 1)
			),
			setProperty("Lighting.Cut.Enabled", true),
			setProperty("Lighting.Cut.FarIntensity", 0.37),
			setProperty("Player.PlayerGui.CutsceneUI.Vignette.ImageColor3", Color3.new(0, 0, 0)),
			setProperty("Player.PlayerGui.CutsceneUI.Vignette.ImageTransparency", 1),
			setProperty("Player.PlayerGui.CutsceneUI.Vignette.Visible", true),
			setProperty("Lighting.Contrast.Enabled", true),
			setProperty("Lighting.Contrast.Saturation", 0),
			setProperty("Lighting.Contrast.Contrast", 0)
		},
		[63] = { tweenProperty("Lighting.Cut.FarIntensity", TweenInfo.new(0.8, Enum.EasingStyle.Linear), 0) },
		[112] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.25, Enum.EasingStyle.Linear), 15) },
		[125] = { function()
				local meteorImpact = workspace.LightVSDarkCutscene1.VFX.MeteorImpact

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in pairs(meteorImpact:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local emitCount = emitter:GetAttribute("EmitCount")
					local emitDuration = emitter:GetAttribute("EmitDuration")
					local emitDelay = emitter:GetAttribute("EmitDelay") or 0
					local v14 = emitter

					local function triggerParticles()
						if check(emitCount) then
							v14:Emit(emitCount)
						end

						if check(emitDuration) then
							v14.Enabled = true
							task.delay(emitDuration, function()
								v14.Enabled = false
							end)
						end
					end

					if check(emitDelay) then
						task.delay(emitDelay, triggerParticles)
					else
						triggerParticles()
					end
				end
			end },
		[126] = { function()
				local asteroid = workspace.LightVSDarkCutscene1.ZoneExtras.Asteroid

				for _, effect in pairs(asteroid:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = false
				end

				local smoke = workspace.LightVSDarkCutscene1.VFX.Smoke

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
					local emitDelay = emitter:GetAttribute("EmitDelay") or 0
					local v14 = emitter

					local function triggerParticles()
						if check(emitCount) then
							v14:Emit(emitCount)
						end

						if check(emitDuration) then
							v14.Enabled = true
							task.delay(emitDuration, function()
								v14.Enabled = false
							end)
						end
					end

					if check(emitDelay) then
						task.delay(emitDelay, triggerParticles)
					else
						triggerParticles()
					end
				end
			end },
		[127] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.16666666666666666, Enum.EasingStyle.Linear),
				14.91385
			) },
		[137] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(1.7666666666666666, Enum.EasingStyle.Linear),
				2
			) },
		[307] = { tweenProperty(
				"Lighting.Cut.FarIntensity",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				0.37
			) },
		[486] = { tweenProperty(
				"Player.PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(1.0666666666666667, Enum.EasingStyle.Linear),
				0.5
			) },
		[540] = { function()
				clone.ChatBubble.Text.SurfaceGui.SPEECHBUBBLE.Text = "MINE!"
			end },
		[689] = { tweenProperty(
				"Player.PlayerGui.CutsceneUI.Vignette.ImageColor3",
				TweenInfo.new(0.35, Enum.EasingStyle.Linear),
				Color3.new(1, 0.0431373, 0.0431373)
			) },
		[720] = { function()
				clone.ChatBubble.Text.SurfaceGui.SPEECHBUBBLE.Text = "Uh oh..."
			end },
		[730] = { tweenProperty(
				"Player.PlayerGui.CutsceneUI.Vignette.ImageColor3",
				TweenInfo.new(0.3, Enum.EasingStyle.Linear),
				Color3.new(1, 0.823366, 0.176471)
			) },
		[755] = { tweenProperty(
				"Player.PlayerGui.CutsceneUI.Vignette.ImageColor3",
				TweenInfo.new(0.2833333333333333, Enum.EasingStyle.Linear),
				Color3.new(0, 0, 0)
			) },
		[786] = { function()
				local split = workspace.LightVSDarkCutscene1.VFX.Split

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in pairs(split:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local emitCount = emitter:GetAttribute("EmitCount")
					local emitDuration = emitter:GetAttribute("EmitDuration")
					local emitDelay = emitter:GetAttribute("EmitDelay") or 0
					local v14 = emitter

					local function triggerParticles()
						if check(emitCount) then
							v14:Emit(emitCount)
						end

						if check(emitDuration) then
							v14.Enabled = true
							task.delay(emitDuration, function()
								v14.Enabled = false
							end)
						end
					end

					if check(emitDelay) then
						task.delay(emitDelay, triggerParticles)
					else
						triggerParticles()
					end
				end
			end },
		[807] = { tweenProperty(
				"Player.PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.45, Enum.EasingStyle.Linear),
				1
			) },
		[808] = { setProperty("Lighting.GoldWhite.Enabled", true) },
		[810] = { setProperty("Lighting.RedBlack.Enabled", true), setProperty("Lighting.GoldWhite.Enabled", false) },
		[812] = { setProperty("Lighting.White.Enabled", true), setProperty("Lighting.RedBlack.Enabled", false) },
		[814] = { setProperty("Lighting.White.Enabled", false), setProperty("Lighting.GoldBlack.Enabled", true) },
		[816] = { setProperty("Lighting.RedWhite.Enabled", true), setProperty("Lighting.GoldBlack.Enabled", false) },
		[818] = { setProperty("Lighting.Black.Enabled", true), setProperty("Lighting.RedWhite.Enabled", false) },
		[820] = { setProperty("Lighting.Black.Enabled", false) },
		[822] = {
			setProperty("Lighting.GoldWhite.Enabled", false),
			setProperty("Lighting.RedBlack.Enabled", false),
			setProperty("Lighting.White.Enabled", false),
			setProperty("Lighting.GoldBlack.Enabled", false),
			setProperty("Lighting.RedWhite.Enabled", false),
			setProperty("Lighting.Black.Enabled", false)
		},
		[830] = {
			setProperty("Lighting.GoldWhite.Enabled", false),
			setProperty("Lighting.RedBlack.Enabled", false),
			setProperty("Lighting.White.Enabled", false),
			setProperty("Lighting.GoldBlack.Enabled", false),
			setProperty("Lighting.RedWhite.Enabled", false),
			setProperty("Lighting.Black.Enabled", false)
		},
		[840] = {
			setProperty("Lighting.GoldWhite.Enabled", false),
			setProperty("Lighting.RedBlack.Enabled", false),
			setProperty("Lighting.White.Enabled", false),
			setProperty("Lighting.GoldBlack.Enabled", false),
			setProperty("Lighting.RedWhite.Enabled", false),
			setProperty("Lighting.Black.Enabled", false)
		},
		[850] = {
			setProperty("Lighting.GoldWhite.Enabled", false),
			setProperty("Lighting.RedBlack.Enabled", false),
			setProperty("Lighting.White.Enabled", false),
			setProperty("Lighting.GoldBlack.Enabled", false),
			setProperty("Lighting.RedWhite.Enabled", false),
			setProperty("Lighting.Black.Enabled", false)
		},
		[1085] = { function()
				local radiate1 = workspace.LightVSDarkCutscene1Rigs.Ben:WaitForChild("DarkCrystal"):WaitForChild("DGem"):WaitForChild("Radiate1")

				for _, emitter in ipairs(radiate1:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end },
		[1120] = { function()
				local radiate2 = workspace.LightVSDarkCutscene1Rigs.Ben:WaitForChild("LightCrystal"):WaitForChild("LGem"):WaitForChild("Radiate2")

				for _, emitter in ipairs(radiate2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end },
		[1150] = { function()
				local aura = workspace.LightVSDarkCutscene1.VFX.Aura

				for _, effect in pairs(aura:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = true
				end
			end },
		[1265] = { function()
				local radiate1 = workspace.LightVSDarkCutscene1Rigs.Ben:WaitForChild("DarkCrystal"):WaitForChild("DGem"):WaitForChild("Radiate1")

				for _, emitter in ipairs(radiate1:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				local radiate2 = workspace.LightVSDarkCutscene1Rigs.Ben:WaitForChild("LightCrystal"):WaitForChild("LGem"):WaitForChild("Radiate2")

				for _, emitter in ipairs(radiate2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end },
		[1277] = {
			tweenProperty(
				"Lighting.Contrast.Saturation",
				TweenInfo.new(1.2333333333333334, Enum.EasingStyle.Linear),
				-0.1
			),
			tweenProperty("Lighting.Contrast.Contrast", TweenInfo.new(1.2333333333333334, Enum.EasingStyle.Linear), 2)
		},
		[1333] = { tweenProperty(
				"Player.PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.3, Enum.EasingStyle.Linear),
				0
			) },
		[1351] = {
			tweenProperty(
				"Workspace.CurrentCamera.CFrame",
				TweenInfo.new(4.733333333333333, Enum.EasingStyle.Linear),
				CFrame.new(
					5044.5688,
					77.7031,
					-364.1059,
					0.0085,
					0.0175,
					-0.9998,
					-0.0001,
					0.9998,
					0.0175,
					1,
					0,
					0.0085
				)
			),
			tweenProperty(
				"Player.PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.13333333333333333, Enum.EasingStyle.Linear),
				0.0202
			),
			tweenProperty("Lighting.Contrast.Saturation", TweenInfo.new(0.9166666666666666, Enum.EasingStyle.Linear), 0),
			tweenProperty("Lighting.Contrast.Contrast", TweenInfo.new(0.9166666666666666, Enum.EasingStyle.Linear), 0)
		},
		[1350] = { function()
				LightingController.SetLayer("LightVsDarknessCutscene", "LightDarkness", 999, 0.05)
				maid:Add(function()
					LightingController.ClearLayer("LightVsDarknessCutscene")
				end)
			end },
		[1359] = {
			tweenProperty(
				"Player.PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.2833333333333333, Enum.EasingStyle.Linear),
				1
			),
			setProperty("Lighting.Cut.Enabled", false)
		},
		[1367] = { tweenProperty(
				"Player.PlayerGui.CutsceneUI.Black.BackgroundColor3",
				TweenInfo.new(0.25, Enum.EasingStyle.Linear),
				Color3.new(0, 0, 0)
			) },
		[1382] = { tweenProperty(
				"Player.PlayerGui.CutsceneUI.Black.BackgroundColor3",
				TweenInfo.new(4.4, Enum.EasingStyle.Linear),
				Color3.new(1, 1, 1)
			) },
		[1428] = { function()
				local aura = workspace.LightVSDarkCutscene1.VFX.Aura

				for _, effect in pairs(aura:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = false
				end
			end },
		[1500] = { function()
				local plates = workspace.LightVSDarkCutscene1.VFX.Plates

				for _, effect in pairs(plates:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = true
				end
			end },
		[1531] = {
			tweenProperty(
				"Workspace.LightVSDarkCutscene1.VFX.Plates.HeavenSide.CFrame",
				TweenInfo.new(1.8666666666666667, Enum.EasingStyle.Linear),
				CFrame.new(5306.4995, 67.7776, -370.2783, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			),
			tweenProperty(
				"Workspace.LightVSDarkCutscene1.VFX.Plates.HellSide.CFrame",
				TweenInfo.new(1.8666666666666667, Enum.EasingStyle.Linear),
				CFrame.new(5314.0996, 67.7776, -361.8634, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			)
		},
		[1612] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.6166666666666667, Enum.EasingStyle.Linear),
				35
			) },
		[1635] = { tweenProperty(
				"Player.PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.18333333333333332, Enum.EasingStyle.Linear),
				0
			) },
		[1645] = { function()
				local plates = workspace.LightVSDarkCutscene1.VFX.Plates

				for _, effect in pairs(plates:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = false
				end
			end },
		[1646] = {
			tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				25
			),
			tweenProperty(
				"Player.PlayerGui.CutsceneUI.Black.BackgroundColor3",
				TweenInfo.new(0.03333333333333333, Enum.EasingStyle.Linear),
				Color3.new(0, 0, 0)
			)
		},
		[1649] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(2.35, Enum.EasingStyle.Linear), 4) },
		[1726] = { tweenProperty(
				"Player.PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(1.0666666666666667, Enum.EasingStyle.Linear),
				1
			) },
		[1770] = {
			tweenProperty(
				"Workspace.CurrentCamera.CFrame",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				CFrame.new(
					5126.2271,
					70.3521,
					-364.1059,
					0.0083,
					-0.1908,
					-0.9816,
					-0.0002,
					0.9816,
					-0.1908,
					1,
					0.0017,
					0.0081
				)
			),
			tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				35
			)
		},
		[1771] = { tweenProperty(
				"Workspace.CurrentCamera.CFrame",
				TweenInfo.new(4.483333333333333, Enum.EasingStyle.Linear),
				CFrame.new(
					5127.7866,
					70.5555,
					-364.106,
					0.0084,
					-0.1564,
					-0.9877,
					-0.0002,
					0.9877,
					-0.1564,
					1,
					0.0015,
					0.0082
				)
			) },
		[2000] = { tweenProperty(
				"Player.PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.6, Enum.EasingStyle.Linear),
				0
			) }
	}
	return {
		Run = function()
			local v13 = false
			xpcall(hideCutsceneUi, warn)
			maid:Add(function()
				if not v13 then
					restoreCutsceneUi() -- equivalent call inferred; original call site unknown
					v13 = true
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
			local clone2 = ReplicatedStorage.CutsceneAssets.LightVSDarkCutscene1:Clone()
			clone2.Parent = Workspace
			v11 = clone2
			maid:Add(clone2)
			TweenService:Create(black, TweenInfo.new(0.1), {
				BackgroundTransparency = 0
			}):Play()
			maid:Add(function()
				black.BackgroundTransparency = 1
				black.Visible = false
			end)
			clone = lightVSDarkCutscene1Rigs:Clone()

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
			local v14 = {}

			for _, child in clone:GetChildren() do
				local animation = child:FindFirstChildOfClass("Animation")

				if animation then
					v14[child] = loadAnimationIntoRig(child, animation.AnimationId)
				end
			end

			for _, child in v11:GetChildren() do
				local animation = child:FindFirstChildOfClass("Animation")

				if animation then
					v14[child] = loadAnimationIntoRig(child, animation.AnimationId)
				end
			end

			local v15 = true
			maid:Add(function()
				v15 = false
			end)
			maid:Add(function()
				if not v15 then
					return
				end

				restoreCamera()
			end)

			for _, v16 in v14 do
				v16:Play(0)
			end

			local v16 = v14[clone["Camera Rig"]]
			assert(v16, "Camera Rig needs an Animation")
			local v17 = os.clock() + 2

			while v15 and v16.TimePosition <= 0 and os.clock() < v17 do
				RunService.RenderStepped:Wait()
			end

			cutsceneMusic:Play()
			local cam = clone["Camera Rig"].Cam
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if not v15 then
					renderSteppedConnection:Disconnect()
					return
				end

				currentCamera.CameraType = Enum.CameraType.Scriptable
				localPlayer.ReplicationFocus = cam
				currentCamera.Focus = cam.CFrame
				currentCamera.CFrame = cam.CFrame
			end)
			local v18 = {}
			local total = 0
			local v19 = 0.1
			local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				total += dt
				v19 -= 0.1

				if v19 <= 0 then
					v19 = 0.1

					for _, v20 in v14 do
						if not (v20.IsPlaying and math.abs(total - v20.TimePosition) >= 0.1) then
							continue
						end

						local v21 = v20
						xpcall(function()
							v21.TimePosition = total
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
					local v20 = math.floor(total * 60 - i)

					if not v12[v20] or v18[v20] then
						continue
					end

					v18[v20] = true

					for _, callback in v12[v20] do
						task.spawn(callback)
					end
				end
			end)
			maid:Add(heartbeatConnection)
			TweenService:Create(black, TweenInfo.new(0.5), {
				BackgroundTransparency = 1
			}):Play()
			task.wait(34.5)
			heartbeatConnection:Disconnect()
			xpcall(function()
				clone2:Destroy()
			end, warn)
			v15 = false
			vignette.Visible = false
			xpcall(function()
				for _, v20 in clones do
					v20:Destroy()
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
				v13 = true
			end, warn)
			restoreZone12() -- equivalent call inferred; original call site unknown
		end
	}
end