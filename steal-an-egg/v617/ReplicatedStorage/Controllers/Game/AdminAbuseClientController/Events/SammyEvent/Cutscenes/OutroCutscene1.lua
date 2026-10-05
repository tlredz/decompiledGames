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
local sammyEventOutro1Rigs = ReplicatedStorage.CutsceneAssets.SammyEventOutro1Rigs
local sammyEventOutro1VFX = ReplicatedStorage.CutsceneAssets.SammyEventOutro1VFX
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
				"Workspace.SammyEventOutro1Rigs.Sammy Hat Rig.CFrame",
				CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			),
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
			setProperty("Workspace.CurrentCamera.FieldOfView", 30),
			setProperty(
				"Workspace.SammyEventOutro1Rigs.ChatBubbleRig.CFrame",
				CFrame.new(0, 0, 0, 0.9942, 0, 0.1073, 0, 1, 0, -0.1073, 0, 0.9942)
			),
			setProperty("Workspace.SammyEventOutro1Rigs.Mind Control Hat Rig.RegularHelm.Transparency", 0),
			setProperty("Workspace.SammyEventOutro1Rigs.Mind Control Hat Rig.BrokenHelm.Transparency", 1),
			setProperty("Workspace.SammyEventOutro1Rigs.Sammy.head.Handle.SammyFace.Transparency", 0),
			setProperty("Workspace.SammyEventOutro1Rigs.Sammy.head.Handle.SammyFace.Color3", Color3.new(1, 1, 1)),
			setProperty(
				"Workspace.SammyEventOutro1Rigs.Sammy.head.Handle.SammyFace.Texture",
				"rbxassetid://104450394167021"
			),
			setProperty("PlayerGui.CutsceneUI.Vignette.ImageColor3", Color3.new(0, 0, 0)),
			tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageColor3",
				TweenInfo.new(12.433333333333334, Enum.EasingStyle.Linear),
				Color3.new(0.345098, 0.67711, 1)
			),
			setProperty("PlayerGui.CutsceneUI.Vignette.BackgroundColor3", Color3.new(1, 1, 1)),
			setProperty("PlayerGui.CutsceneUI.Vignette.ImageTransparency", 1),
			setProperty("PlayerGui.CutsceneUI.Black.BackgroundTransparency", 0),
			tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.8833333333333333, Enum.EasingStyle.Linear),
				1
			),
			setProperty("Lighting.CutsceneBlur.Enabled", true),
			setProperty("Lighting.CutsceneBlur.Size", 20),
			tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(1.2333333333333334, Enum.EasingStyle.Linear), 2),
			setProperty("Lighting.CutBlue.Enabled", false),
			setProperty("Lighting.CutBlue.Saturation", -3),
			tweenProperty("Lighting.CutBlue.Saturation", TweenInfo.new(13.833333333333334, Enum.EasingStyle.Linear), 0),
			setProperty("Lighting.CutBlue.Contrast", -3),
			tweenProperty("Lighting.CutBlue.Contrast", TweenInfo.new(13.833333333333334, Enum.EasingStyle.Linear), 0),
			setProperty("Lighting.CutBlue.TintColor", Color3.new(0.835294, 0.937255, 1)),
			tweenProperty(
				"Lighting.CutBlue.TintColor",
				TweenInfo.new(13.833333333333334, Enum.EasingStyle.Linear),
				Color3.new(1, 1, 1)
			),
			setProperty("Lighting.CutBlue.Brightness", 0.3),
			tweenProperty("Lighting.CutBlue.Brightness", TweenInfo.new(13.833333333333334, Enum.EasingStyle.Linear), 0)
		},
		[498] = { function()
				local charge = v7.ChargingMachine1.Beams.Beams1.Charge

				for _, effect in pairs(charge:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = true
				end
			end },
		[503] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(1.0166666666666666, Enum.EasingStyle.Linear),
				15
			) },
		[564] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(1.4166666666666667, Enum.EasingStyle.Linear),
				4
			) },
		[765] = { tweenProperty(
				"Workspace.SammyEventOutro1Rigs.ChatBubbleRig.CFrame",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				CFrame.new(0, -506.1769, 0, 0.9942, 0, 0.1073, 0, 1, 0, -0.1073, 0, 0.9942)
			) },
		[782] = { tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.9833333333333333, Enum.EasingStyle.Linear),
				0
			) },
		[830] = {
			setProperty("Lighting.CutBlue.Enabled", true),
			tweenProperty(
				"Lighting.CutBlue.Saturation",
				TweenInfo.new(0.03333333333333333, Enum.EasingStyle.Linear),
				-3
			),
			tweenProperty("Lighting.CutBlue.Contrast", TweenInfo.new(0.03333333333333333, Enum.EasingStyle.Linear), -3),
			tweenProperty(
				"Lighting.CutBlue.TintColor",
				TweenInfo.new(0.03333333333333333, Enum.EasingStyle.Linear),
				Color3.new(0.835294, 0.937255, 1)
			),
			tweenProperty(
				"Lighting.CutBlue.Brightness",
				TweenInfo.new(0.03333333333333333, Enum.EasingStyle.Linear),
				0.3
			)
		},
		[832] = {
			tweenProperty("Lighting.CutBlue.Saturation", TweenInfo.new(0.06666666666666667, Enum.EasingStyle.Linear), 0),
			tweenProperty("Lighting.CutBlue.Contrast", TweenInfo.new(0.06666666666666667, Enum.EasingStyle.Linear), 0),
			tweenProperty(
				"Lighting.CutBlue.TintColor",
				TweenInfo.new(0.06666666666666667, Enum.EasingStyle.Linear),
				Color3.new(1, 1, 1)
			),
			tweenProperty("Lighting.CutBlue.Brightness", TweenInfo.new(0.06666666666666667, Enum.EasingStyle.Linear), 0)
		},
		[834] = { function()
				local beams = v7.ChargingMachine1.Beams

				for _, effect in pairs(beams:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = true
				end
			end },
		[836] = { setProperty("Lighting.CutBlue.Enabled", false) },
		[925] = { function()
				local beams1 = v7.ChargingMachine1.Beams.Beams1

				for _, effect in pairs(beams1:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = false
				end
			end },
		[937] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.21666666666666667, Enum.EasingStyle.Linear),
				15
			) },
		[942] = { tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(0.7833333333333333, Enum.EasingStyle.Linear),
				1
			) },
		[945] = { setProperty(
				"Workspace.SammyEventOutro1Rigs.Sammy.head.Handle.SammyFace.Texture",
				"rbxassetid://104450394167021 "
			) },
		[946] = {
			tweenProperty(
				"Workspace.SammyEventOutro1Rigs.Mind Control Hat Rig.RegularHelm.Transparency",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				1
			),
			tweenProperty(
				"Workspace.SammyEventOutro1Rigs.Mind Control Hat Rig.BrokenHelm.Transparency",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				0
			)
		},
		[950] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(1.1, Enum.EasingStyle.Linear), 4) },
		[954] = { setProperty(
				"Workspace.SammyEventOutro1Rigs.Sammy.head.Handle.SammyFace.Texture",
				"rbxassetid://1077395150"
			) },
		[972] = { tweenProperty(
				"Workspace.SammyEventOutro1Rigs.Sammy.head.Handle.SammyFace.Color3",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				Color3.new(0, 0, 0)
			) },
		[973] = { setProperty(
				"Workspace.SammyEventOutro1Rigs.Sammy.head.Handle.SammyFace.Texture",
				"rbxassetid://11389379146"
			) },
		[975] = { function()
				local beams = v7.ChargingMachine1.Beams

				for _, effect in pairs(beams:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = false
				end
			end },
		[986] = { function()
				local smoke = v7.Smoke

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
					local v11 = emitter
					task.delay(emitDuration, function()
						v11.Enabled = false
					end)
				end
			end },
		[1128] = { tweenProperty(
				"Workspace.SammyEventOutro1Rigs.Sammy.head.Handle.SammyFace.Color3",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				Color3.new(1, 1, 1)
			) },
		[1129] = { setProperty(
				"Workspace.SammyEventOutro1Rigs.Sammy.head.Handle.SammyFace.Texture",
				"rbxassetid://103446416975797 "
			) },
		[1366] = { setProperty(
				"Workspace.SammyEventOutro1Rigs.Sammy.head.Handle.SammyFace.Texture",
				"rbxassetid://12637990841 "
			) },
		[1452] = { tweenProperty(
				"Workspace.SammyEventOutro1Rigs.Sammy Hat Rig.CFrame",
				TweenInfo.new(0.05, Enum.EasingStyle.Linear),
				CFrame.new(0, 0, 0.1, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			) },
		[1590] = { tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.5, Enum.EasingStyle.Linear),
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
			local clone2 = sammyEventOutro1VFX:Clone()
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
			clone = sammyEventOutro1Rigs:Clone()

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
			task.wait(27.833333333333332)
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