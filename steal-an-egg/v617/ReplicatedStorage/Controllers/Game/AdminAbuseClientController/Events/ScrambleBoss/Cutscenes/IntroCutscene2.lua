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
local introCutscene2 = ReplicatedStorage.CutsceneAssets.ScrambleBossCutsceneAssets.IntroCutscene2
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

return function(maid)
	local helperFunctions = CutsceneHelperFunctions.GetHelperFunctions(maid)
	local setProperty = helperFunctions.SetProperty
	local tweenProperty = helperFunctions.TweenProperty
	local loadAnimationIntoRig = helperFunctions.LoadAnimationIntoRig
	local cutsceneUI = localPlayer.PlayerGui.CutsceneUI
	local black = cutsceneUI.Black
	local vignette = cutsceneUI.Vignette
	local v7 = {
		[0] = {
			setProperty(
				"Workspace.CurrentCamera.CFrame",
				CFrame.new(
					106.2726,
					5.5588,
					56.7516,
					0.2516,
					-0.278,
					0.927,
					-0,
					0.9579,
					0.2872,
					-0.9678,
					-0.0723,
					0.241
				)
			),
			setProperty("Workspace.CurrentCamera.FieldOfView", 61.55506),
			setProperty("PlayerGui.CutsceneUI.Black.BackgroundTransparency", 0),
			tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.2, Enum.EasingStyle.Linear),
				1
			),
			setProperty("PlayerGui.CutsceneUI.Black.BackgroundColor3", Color3.new(0, 0, 0)),
			setProperty("PlayerGui.CutsceneUI.Vignette.ImageTransparency", 1),
			setProperty("PlayerGui.CutsceneUI.Vignette.Visible", true),
			setProperty("Lighting.CutsceneBlur.Enabled", true),
			setProperty("Lighting.CutsceneBlur.Size", 2),
			setProperty("Lighting.DepthOfField.Enabled", true),
			setProperty("Lighting.DepthOfField.FarIntensity", 1),
			setProperty("Lighting.DepthOfField.FocusDistance", 0.05),
			setProperty("Lighting.DepthOfField.InFocusRadius", 8),
			setProperty("Lighting.DepthOfField.NearIntensity", 0)
		},
		[61] = { tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundColor3",
				TweenInfo.new(0.11666666666666667, Enum.EasingStyle.Linear),
				Color3.new(1, 1, 1)
			) },
		[67] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.18333333333333332, Enum.EasingStyle.Linear),
				15
			) },
		[69] = { tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.06666666666666667, Enum.EasingStyle.Linear),
				0
			) },
		[77] = { tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.35, Enum.EasingStyle.Linear),
				0
			) },
		[86] = { tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.5, Enum.EasingStyle.Linear),
				1
			) },
		[98] = { tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.36666666666666664, Enum.EasingStyle.Linear),
				1
			) },
		[109] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.65, Enum.EasingStyle.Linear), 7) },
		[138] = { tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundColor3",
				TweenInfo.new(6.016666666666667, Enum.EasingStyle.Linear),
				Color3.new(0, 0, 0)
			) },
		[178] = { tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(1.4833333333333334, Enum.EasingStyle.Linear),
				0
			) },
		[193] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.5833333333333334, Enum.EasingStyle.Linear),
				12
			) },
		[268] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.9833333333333333, Enum.EasingStyle.Linear),
				4
			) },
		[425] = { tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.5, Enum.EasingStyle.Linear),
				1
			) },
		[453] = {
			tweenProperty(
				"Lighting.DepthOfField.FocusDistance",
				TweenInfo.new(0.43333333333333335, Enum.EasingStyle.Linear),
				28
			),
			tweenProperty(
				"Lighting.DepthOfField.InFocusRadius",
				TweenInfo.new(0.43333333333333335, Enum.EasingStyle.Linear),
				9.5
			),
			tweenProperty(
				"Lighting.DepthOfField.NearIntensity",
				TweenInfo.new(0.43333333333333335, Enum.EasingStyle.Linear),
				0.05
			)
		},
		[503] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.2, Enum.EasingStyle.Linear), 20) },
		[508] = { tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.13333333333333333, Enum.EasingStyle.Linear),
				0
			) }
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
			hideAllGuardsAndNests(maid)
			local clones = {}

			for _, child in introCutscene2.LightingAssets:GetChildren() do
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
			local clone = introCutscene2.ScrambleBossIntro2VFX:Clone()
			clone.Parent = Workspace
			maid:Add(clone)
			local clone2 = introCutscene2.ScrambleBossIntro2WorkspaceAssets:Clone()
			clone2.Parent = Workspace
			maid:Add(clone2)
			local clone3 = introCutscene2.CutsceneMusic:Clone()
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
			local clone4 = introCutscene2.ScrambleBossIntro2Rigs:Clone()

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
			local v9 = {}

			for _, child in clone4:GetChildren() do
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

			local v11 = v9[clone4.HumanoidCameraRig]
			assert(v11, "HumanoidCameraRig needs an Animation")
			local v12 = os.clock() + 2

			while v10 and v11.TimePosition <= 0 and os.clock() < v12 do
				RunService.RenderStepped:Wait()
			end

			clone3:Play()
			local torso = clone4.HumanoidCameraRig.Torso
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if not v10 then
					renderSteppedConnection:Disconnect()
					return
				end

				currentCamera.CameraType = Enum.CameraType.Scriptable
				localPlayer.ReplicationFocus = torso
				currentCamera.Focus = torso.CFrame
				currentCamera.CFrame = torso.CFrame
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
						if not (v15.IsPlaying and math.abs(total - v15.TimePosition) >= 0.4) then
							continue
						end

						local v16 = v15
						xpcall(function()
							v16.TimePosition = total
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
			task.wait(9.366666666666667)
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
			v10 = false
			vignette.Visible = false
			xpcall(function()
				for _, v15 in clones do
					v15:Destroy()
				end
			end, warn)
			xpcall(function()
				clone4:Destroy()
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
				v8 = true
			end, warn)
			restoreAllGuardsAndNests()
		end
	}
end