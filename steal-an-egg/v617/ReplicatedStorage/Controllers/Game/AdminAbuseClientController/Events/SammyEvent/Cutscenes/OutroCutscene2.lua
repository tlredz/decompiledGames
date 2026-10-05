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
local sammyEventOutro2Rigs = ReplicatedStorage.CutsceneAssets.SammyEventOutro2Rigs
local sammyEventOutro2VFX = ReplicatedStorage.CutsceneAssets.SammyEventOutro2VFX
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
	local torso = nil
	local v8 = {
		[0] = {
			setProperty(
				"Workspace.CurrentCamera.CFrame",
				CFrame.new(
					9.131,
					16.6001,
					-21.2199,
					-0.4348,
					0.101,
					-0.8948,
					-0,
					0.9937,
					0.1121,
					0.9005,
					0.0487,
					-0.4321
				)
			),
			setProperty("Workspace.CurrentCamera.FieldOfView", 25),
			setProperty("Lighting.CutsceneDepthOfField.Enabled", true),
			setProperty("Lighting.CutsceneDepthOfField.InFocusRadius", 10),
			setProperty("Lighting.CutsceneDepthOfField.FocusDistance", 0.05),
			setProperty("Workspace.SammyEventOutro2Rigs.Mind Control Hat Rig.BrokenHelm.Transparency", 0),
			setProperty("PlayerGui.CutsceneUI.Black.BackgroundTransparency", 0),
			tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.38333333333333336, Enum.EasingStyle.Linear),
				1
			),
			setProperty("PlayerGui.CutsceneUI.Vignette.ImageTransparency", 1),
			setProperty("Lighting.ClockTime", 2.3)
		},
		[528] = { tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.25, Enum.EasingStyle.Linear),
				0
			) },
		[543] = { tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.03333333333333333, Enum.EasingStyle.Linear),
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
			local clone2 = sammyEventOutro2VFX:Clone()
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
			clone = sammyEventOutro2Rigs:Clone()

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

			local v12 = v10[clone.HumanoidCameraRig]
			assert(v12, "HumanoidCameraRig needs an Animation")
			local v13 = os.clock() + 2

			while v11 and v12.TimePosition <= 0 and os.clock() < v13 do
				RunService.RenderStepped:Wait()
			end

			cutsceneMusic:Play()
			torso = clone.HumanoidCameraRig.Torso
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
			task.wait(9.616666666666667)
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
			local v16 = BulkFade.new(cutsceneUI.ToBeContinued, TweenInfo.new(1))
			v16:FadeOutInstant()
			task.wait()
			v16:FadeIn()
			cutsceneUI.ToBeContinued.Visible = true
			task.spawn(function()
				local function toDHMS(p: number)
					return string.format("%02i:%02i:%02i:%02i", p / 86400, p / 3600 % 24, p / 60 % 60, p % 60)
				end

				local v17 = 604799

				while cutsceneUI.ToBeContinued.Visible do
					cutsceneUI.ToBeContinued.TimeRemaining.Text = string.format(
						"%02i:%02i:%02i:%02i",
						v17 / 86400,
						v17 / 3600 % 24,
						v17 / 60 % 60,
						v17 % 60
					)
					script.ClockTick:Play()
					task.wait(1)
					v17 -= 1
				end
			end)
			task.wait(5)
			TweenService:Create(black, TweenInfo.new(0.5), {
				BackgroundTransparency = 1
			}):Play()
			v16:FadeOut()
			task.delay(1, function()
				cutsceneUI.ToBeContinued.Visible = false
				v16:FadeIn()
			end)
			Lighting.ClockTime = 11.6
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
			restoreAllGuardsAndNests()
		end
	}
end