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
	local riftCutscene2 = ReplicatedStorage.CutsceneAssets.RiftCutscene2
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
					4804.1978,
					73.1938,
					-341.0876,
					-0.8189,
					-0.0967,
					0.5657,
					0,
					0.9857,
					0.1684,
					-0.5739,
					0.1379,
					-0.8073
				)
			),
			tweenProperty(
				"Workspace.CurrentCamera.CFrame",
				TweenInfo.new(26.65, Enum.EasingStyle.Linear),
				CFrame.new(
					4795.2813,
					70.9149,
					-313.1396,
					-0.9998,
					-0.0092,
					-0.0186,
					-0.0054,
					0.9809,
					-0.1945,
					0.0201,
					-0.1944,
					-0.9807
				)
			),
			setProperty("Workspace.CurrentCamera.FieldOfView", 70),
			tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.5166666666666667, Enum.EasingStyle.Linear),
				45
			),
			setProperty("Lighting.CutsceneBlur.Enabled", true),
			setProperty("Lighting.CutsceneBlur.Size", 25),
			tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.7833333333333333, Enum.EasingStyle.Linear), 2)
		},
		[31] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.4, Enum.EasingStyle.Linear),
				35
			) },
		[55] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.9, Enum.EasingStyle.Linear),
				45
			) },
		[57] = { function()
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
					local emitDelay = emitter:GetAttribute("EmitDelay") or 0
					local v9 = emitter

					local function triggerParticles()
						if check(emitCount) then
							v9:Emit(emitCount)
						end

						if check(emitDuration) then
							v9.Enabled = true
							task.delay(emitDuration, function()
								v9.Enabled = false
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
		[59] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.11666666666666667, Enum.EasingStyle.Linear),
				10
			) },
		[66] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.1, Enum.EasingStyle.Linear), 4) },
		[103] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.11666666666666667, Enum.EasingStyle.Linear),
				10
			) },
		[105] = { function()
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
					local emitDelay = emitter:GetAttribute("EmitDelay") or 0
					local v9 = emitter

					local function triggerParticles()
						if check(emitCount) then
							v9:Emit(emitCount)
						end

						if check(emitDuration) then
							v9.Enabled = true
							task.delay(emitDuration, function()
								v9.Enabled = false
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
		[110] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.1, Enum.EasingStyle.Linear), 4) },
		[137] = { function()
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
					local emitDelay = emitter:GetAttribute("EmitDelay") or 0
					local v9 = emitter

					local function triggerParticles()
						if check(emitCount) then
							v9:Emit(emitCount)
						end

						if check(emitDuration) then
							v9.Enabled = true
							task.delay(emitDuration, function()
								v9.Enabled = false
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
		[138] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.11666666666666667, Enum.EasingStyle.Linear),
				10
			) },
		[145] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.1, Enum.EasingStyle.Linear), 4) },
		[155] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.18333333333333332, Enum.EasingStyle.Linear),
				9
			) },
		[166] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.7333333333333333, Enum.EasingStyle.Linear),
				2
			) },
		[890] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.3333333333333333, Enum.EasingStyle.Linear),
				8
			) },
		[892] = { function()
				local roar = v6:WaitForChild("Roar")

				for _, emitter in ipairs(roar:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end },
		[910] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.8, Enum.EasingStyle.Linear), 2) },
		[927] = { function()
				local roar = v6:WaitForChild("Roar")

				for _, emitter in ipairs(roar:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end },
		[1324] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(2.566666666666667, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				75
			) },
		[1392] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.3, Enum.EasingStyle.Linear), 10) },
		[1420] = { function()
				local charge = workspace:WaitForChild("RiftCutscene2"):WaitForChild("Portal"):WaitForChild("Charge")

				for _, emitter in ipairs(charge:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end },
		[1430] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.45, Enum.EasingStyle.Linear), 2) },
		[1599] = {
			tweenProperty(
				"Workspace.CurrentCamera.CFrame",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				CFrame.new(
					4795.5762,
					69.3859,
					-353.8327,
					0.6834,
					0,
					-0.7301,
					0.0038,
					1,
					0.0036,
					0.7301,
					-0.0052,
					0.6834
				)
			),
			tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				35
			)
		},
		[1600] = { tweenProperty(
				"Workspace.CurrentCamera.CFrame",
				TweenInfo.new(9.333333333333334, Enum.EasingStyle.Linear),
				CFrame.new(
					4791.5317,
					69.3774,
					-356.0904,
					0.5039,
					0.0021,
					-0.8638,
					0.0106,
					0.9999,
					0.0086,
					0.8637,
					-0.0135,
					0.5038
				)
			) },
		[1713] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				55
			) },
		[1788] = { function()
				local eggSpawn = workspace.RiftCutscene2.Portal.EggSpawn

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in pairs(eggSpawn:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local emitCount = emitter:GetAttribute("EmitCount")
					local emitDuration = emitter:GetAttribute("EmitDuration")
					local emitDelay = emitter:GetAttribute("EmitDelay") or 0
					local v9 = emitter

					local function triggerParticles()
						if check(emitCount) then
							v9:Emit(emitCount)
						end

						if check(emitDuration) then
							v9.Enabled = true
							task.delay(emitDuration, function()
								v9.Enabled = false
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
		[1843] = { function()
				local charge = workspace:WaitForChild("RiftCutscene2"):WaitForChild("Portal"):WaitForChild("Charge")

				for _, emitter in ipairs(charge:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end },
		[1896] = { function()
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
					local emitDelay = emitter:GetAttribute("EmitDelay") or 0
					local v9 = emitter

					local function triggerParticles()
						if check(emitCount) then
							v9:Emit(emitCount)
						end

						if check(emitDuration) then
							v9.Enabled = true
							task.delay(emitDuration, function()
								v9.Enabled = false
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
		[1897] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				40
			) },
		[1923] = { function()
				local smoke5 = v6.Smoke5

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in pairs(smoke5:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local emitCount = emitter:GetAttribute("EmitCount")
					local emitDuration = emitter:GetAttribute("EmitDuration")
					local emitDelay = emitter:GetAttribute("EmitDelay") or 0
					local v9 = emitter

					local function triggerParticles()
						if check(emitCount) then
							v9:Emit(emitCount)
						end

						if check(emitDuration) then
							v9.Enabled = true
							task.delay(emitDuration, function()
								v9.Enabled = false
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
		[2115] = { function()
				TweenService:Create(black, TweenInfo.new(0.5), {
					BackgroundTransparency = 0
				}):Play()
			end }
	}
	return {
		Run = function()
			local v8 = false
			xpcall(hideCutsceneUi, warn)
			pcall(function()
				localPlayer.PlayerGui.BossFightUI.Enabled = false
			end)
			maid:Add(function()
				if not v8 then
					restoreCutsceneUi() -- equivalent call inferred; original call site unknown
					localPlayer.PlayerGui.BossFightUI.Enabled = false
					ReplicatedStorage.Controllers.Game.BossEventClientController.BossArenaMusic.Volume = 0
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
			local clone2 = riftCutscene2:Clone()

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
			task.wait(36.5)
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
				localPlayer.PlayerGui.BossFightUI.Enabled = false
				ReplicatedStorage.Controllers.Game.BossEventClientController.BossArenaMusic.Volume = 0
				v8 = true
			end, warn)
			setTransparency(descendants)

			for k, parent in childrenByGuard do
				k.Parent = parent
			end
		end
	}
end