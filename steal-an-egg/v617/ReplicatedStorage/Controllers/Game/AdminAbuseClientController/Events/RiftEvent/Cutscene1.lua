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
require(ReplicatedStorage.Shared.Remotes)
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
	local riftCutscene = ReplicatedStorage.CutsceneAssets.RiftCutscene
	local cutsceneUI = localPlayer.PlayerGui.CutsceneUI
	local cutsceneMusic = script.CutsceneMusic
	local black = cutsceneUI.Black
	local vignette = cutsceneUI.Vignette
	local v6 = nil
	local v7 = {
		[0] = {
			setProperty(
				"Workspace.CurrentCamera.CFrame",
				CFrame.new(
					4778.5664,
					77.7973,
					-307.0335,
					-0.3841,
					0.438,
					-0.8128,
					0,
					0.8803,
					0.4744,
					0.9233,
					0.1822,
					-0.3381
				)
			),
			tweenProperty(
				"Workspace.CurrentCamera.CFrame",
				TweenInfo.new(9.45, Enum.EasingStyle.Linear),
				CFrame.new(
					4802.2295,
					73.7093,
					-297.8694,
					-0.8171,
					0,
					0.5766,
					-0.0083,
					0.9999,
					-0.0119,
					-0.5765,
					-0.0145,
					-0.817
				)
			),
			setProperty("Workspace.CurrentCamera.FieldOfView", 45)
		},
		[407] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				35
			) },
		[566] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				45
			) },
		[567] = { tweenProperty(
				"Workspace.CurrentCamera.CFrame",
				TweenInfo.new(2.216666666666667, Enum.EasingStyle.Linear),
				CFrame.new(
					4796.2349,
					71.199,
					-303.4302,
					0.8192,
					0.06,
					0.5704,
					-0.05,
					0.9982,
					-0.0331,
					-0.5714,
					-0.0014,
					0.8207
				)
			) },
		[700] = { tweenProperty(
				"Workspace.CurrentCamera.CFrame",
				TweenInfo.new(4, Enum.EasingStyle.Linear),
				CFrame.new(
					4797.2402,
					71.2416,
					-292.843,
					-0.9137,
					-0.2377,
					-0.3295,
					-0.1682,
					0.9595,
					-0.2258,
					0.3699,
					-0.1509,
					-0.9167
				)
			) },
		[940] = { tweenProperty(
				"Workspace.CurrentCamera.CFrame",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				CFrame.new(4795.6162, 72.4162, -297.8404, -0.9994, 0, -0.0349, -0, 1, -0, 0.0349, 0, -0.9994)
			) },
		[941] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.8666666666666667, Enum.EasingStyle.Sine),
				90
			) },
		[1066] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.16666666666666666, Enum.EasingStyle.Sine),
				75.51428
			) },
		[1076] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.06666666666666667, Enum.EasingStyle.Sine),
				56.2
			) },
		[1080] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.18333333333333332, Enum.EasingStyle.Sine),
				25
			) },
		[1168] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Sine),
				45
			) },
		[1400] = { function()
				TweenService:Create(black, TweenInfo.new(0.5), {
					BackgroundTransparency = 0
				}):Play()
			end }
	}
	return {
		Run = function()
			local v8 = false
			xpcall(hideCutsceneUi, warn)
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
			local childrenByGuard = {}

			for _, child in game.Workspace.World.Areas.GuardAreas:GetChildren(), nil, nil do
				local guard = child.Guard
				childrenByGuard[guard] = child
				guard.Parent = nil
				local parent = child
				maid:Add(function()
					guard.Parent = parent
				end)
			end

			local descendants = game.Workspace.World.Areas.GuardAreas["Titan Temple"].Nests:GetDescendants()
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
			vignette.Visible = false
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
			local clone2 = riftCutscene:Clone()

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
			TweenService:Create(black, TweenInfo.new(0.5), {
				BackgroundTransparency = 1
			}):Play()
			task.wait(24.5)
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
				v8 = true
			end, warn)
			setTransparency(descendants)

			for k, parent in childrenByGuard do
				k.Parent = parent
			end
		end
	}
end