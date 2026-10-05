local createVector = vector.create
local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local BulkFade = require(ReplicatedStorage.Client.Modules.BulkFade)
local CutsceneHelperFunctions = require(script.Parent.Parent.Parent.CutsceneHelperFunctions)
require(ReplicatedStorage.Packages.Trove)
local currentCamera = Workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

local function restoreCamera()
	TweenService:Create(currentCamera, TweenInfo.new(0), {
		FieldOfView = 70
	}):Play()
	currentCamera.FieldOfView = 70
	currentCamera.CameraType = Enum.CameraType.Custom
	currentCamera.CameraSubject = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") or nil
	localPlayer.ReplicationFocus = nil
end

return function(maid)
	local helperFunctions = CutsceneHelperFunctions.GetHelperFunctions(maid)
	local setProperty = helperFunctions.SetProperty
	local tweenProperty = helperFunctions.TweenProperty
	local _ = helperFunctions.PlaySequenceAsync
	local loadAnimationIntoRig = helperFunctions.LoadAnimationIntoRig
	local dragonEggEventCutscene2 = ReplicatedStorage.CutsceneAssets.DragonEggEventCutscene2
	local cutsceneUI = localPlayer.PlayerGui.CutsceneUI
	local cutsceneMusic = script.CutsceneMusic
	local black = cutsceneUI.Black
	local v = nil
	local v2 = {
		[0] = {
			setProperty("Workspace.CurrentCamera.FieldOfView", 25),
			setProperty(
				"Workspace.World.Build.1.BOTTOMS.Footprint.Meshes/untitled2 (1).CFrame",
				CFrame.new(3438.9807, 35.8888, -354.9071, -0.3907, 0, 0.9205, 0, 1, 0, -0.9205, 0, -0.3907)
			),
			setProperty(
				"Workspace.World.Build.1.BOTTOMS.Footprint.FogMesh.CFrame",
				CFrame.new(3438.9807, 35.6132, -354.9067, 0.5446, 0, -0.8387, 0, 1, 0, 0.8387, 0, 0.5446)
			),
			setProperty("PlayerGui.CutsceneUI.Black.BackgroundTransparency", 0),
			tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.8333333333333334, Enum.EasingStyle.Linear),
				1
			),
			setProperty("PlayerGui.CutsceneUI.Vignette.ImageTransparency", 1),
			setProperty("Lighting.CutsceneBlur.Enabled", true),
			setProperty("Lighting.CutsceneBlur.Size", 2)
		},
		[326] = { function()
				for _, emitter in v.Charge.Orb:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end },
		[457] = { function()
				for _, emitter in v.Charge.Ball:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end },
		[484] = { function()
				for _, emitter in v.Charge.Orb:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end },
		[622] = { function()
				for _, emitter in v.Charge.Ball:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end },
		[821] = {
			tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(1.3333333333333333, Enum.EasingStyle.Linear),
				0
			),
			tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				20
			)
		},
		[822] = {
			tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(1.9833333333333334, Enum.EasingStyle.Linear),
				30
			),
			tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(1.2, Enum.EasingStyle.Linear), 4)
		},
		[917] = { tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.26666666666666666, Enum.EasingStyle.Linear),
				0.5
			) },
		[930] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.15, Enum.EasingStyle.Linear), 15) },
		[933] = { tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.23333333333333334, Enum.EasingStyle.Linear),
				1
			) },
		[939] = { tweenProperty("Lighting.CutsceneBlur.Size", TweenInfo.new(0.4, Enum.EasingStyle.Linear), 2) },
		[941] = { tweenProperty(
				"Workspace.CurrentCamera.FieldOfView",
				TweenInfo.new(0.7833333333333333, Enum.EasingStyle.Linear),
				25
			) },
		[943] = {
			tweenProperty(
				"Workspace.World.Build.1.BOTTOMS.Footprint.Meshes/untitled2 (1).CFrame",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				CFrame.new(3438.9807, 69.4803, -354.9071, -0.3907, 0, 0.9205, 0, 1, 0, -0.9205, 0, -0.3907)
			),
			tweenProperty(
				"Workspace.World.Build.1.BOTTOMS.Footprint.FogMesh.CFrame",
				TweenInfo.new(0.016666666666666666, Enum.EasingStyle.Linear),
				CFrame.new(3438.9807, 69.2047, -354.9067, 0.5446, 0, -0.8387, 0, 1, 0, 0.8387, 0, 0.5446)
			),
			setProperty("Workspace.World.Build.1.BOTTOMS.Floor.Transparency", 1)
		},
		[946] = { function()
				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function check(p: number?)
					return p ~= nil and p ~= 0
				end

				for _, emitter in v.Stomp:GetDescendants() do
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
					local v5 = emitter
					task.delay(emitDuration, function()
						v5.Enabled = false
					end)
				end
			end, function()
				for _, emitter in v.Decay:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end },
		[957] = { tweenProperty(
				"PlayerGui.CutsceneUI.Vignette.ImageTransparency",
				TweenInfo.new(1.3833333333333333, Enum.EasingStyle.Linear),
				1
			) },
		[1200] = {},
		[1380] = { tweenProperty(
				"Lighting.CutsceneBlur.Size",
				TweenInfo.new(1.6833333333333333, Enum.EasingStyle.Linear),
				50
			) },
		[1410] = { tweenProperty(
				"PlayerGui.CutsceneUI.Black.BackgroundTransparency",
				TweenInfo.new(0.5, Enum.EasingStyle.Linear),
				1
			) }
	}
	return {
		Run = function()
			local WAIT_INTERVAL = 5
			Workspace.World.Build:WaitForChild("AAEventProps")
			task.wait()
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
			local clone = script.CutsceneVFX:Clone()
			clone.Parent = Workspace
			v = clone
			maid:Add(clone)
			TweenService:Create(black, TweenInfo.new(0.1), {
				BackgroundTransparency = 0
			}):Play()
			maid:Add(function()
				black.BackgroundTransparency = 1
				black.Visible = false
			end)
			local clone2 = dragonEggEventCutscene2:Clone()

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
			local v3 = {}

			for _, child in clone2:GetChildren() do
				local animation = child:FindFirstChildOfClass("Animation")

				if animation then
					v3[child] = loadAnimationIntoRig(child, animation.AnimationId)
				end
			end

			local v4 = true
			maid:Add(function()
				v4 = false
			end)
			maid:Add(function()
				if not v4 then
					return
				end

				restoreCamera()
			end)

			for _, v5 in v3 do
				v5:Play(0)
			end

			local v5 = v3[clone2["Camera Rig"]]
			assert(v5, "Camera Rig needs an Animation")
			local v6 = os.clock() + 2

			while v4 and v5.TimePosition <= 0 and os.clock() < v6 do
				RunService.RenderStepped:Wait()
			end

			local vignette = cutsceneUI.Vignette
			maid:Add(function()
				vignette.Visible = false
				vignette.ImageTransparency = 1
			end)
			cutsceneMusic:Play()
			local cam = clone2["Camera Rig"].Cam
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if not v4 then
					renderSteppedConnection:Disconnect()
					return
				end

				currentCamera.CameraType = Enum.CameraType.Scriptable
				localPlayer.ReplicationFocus = cam
				currentCamera.Focus = cam.CFrame
				currentCamera.CFrame = cam.CFrame
			end)
			local v7 = {}
			local total = 0
			local v8 = 0.1
			local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				total += dt
				v8 -= 0.1

				if v8 <= 0 then
					v8 = 0.1

					for _, v9 in v3 do
						if not (v9.IsPlaying and math.abs(total - v9.TimePosition) >= 0.1) then
							continue
						end

						local v10 = v9
						xpcall(function()
							v10.TimePosition = total
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
					local v9 = math.floor(total * 60 - i)

					if not v2[v9] or v7[v9] then
						continue
					end

					v7[v9] = true

					for _, callback in v2[v9] do
						task.spawn(callback)
					end
				end
			end)
			maid:Add(heartbeatConnection)
			task.wait(24.666666666666668)
			heartbeatConnection:Disconnect()
			xpcall(function()
				clone:Destroy()
			end, warn)
			v4 = false
			vignette.Visible = false
			xpcall(function()
				for _, v9 in clones do
					v9:Destroy()
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
			local v9 = BulkFade.new(cutsceneUI.MonstersAreComing, TweenInfo.new(1))
			v9:FadeOutInstant()
			task.wait()
			v9:FadeIn()
			cutsceneUI.MonstersAreComing.Visible = true
			task.spawn(function()
				local function toDHMS(p: number)
					return string.format("%02i:%02i:%02i:%02i", p / 86400, p / 3600 % 24, p / 60 % 60, p % 60)
				end

				script.Roar:Play()
				local v10 = 604799

				while cutsceneUI.MonstersAreComing.Visible do
					cutsceneUI.MonstersAreComing.TimeRemaining.Text = string.format(
						"%02i:%02i:%02i:%02i",
						v10 / 86400,
						v10 / 3600 % 24,
						v10 / 60 % 60,
						v10 % 60
					)
					script.ClockTick:Play()
					task.wait(1)
					v10 -= 1
				end
			end)
			task.wait(WAIT_INTERVAL)
			local clone3 = ReplicatedStorage.CutsceneAssets.DragonEggEventRareEgg:Clone()

			for _, part in clone3:GetDescendants() do
				if part:IsA("BasePart") then
					part.Anchored = true
				end
			end

			maid:Add(clone3)
			Debris:AddItem(clone3, 20)
			clone3.Parent = Workspace
			currentCamera.CameraType = Enum.CameraType.Scriptable
			currentCamera.CFrame = CFrame.lookAt(createVector(3307, 100, -341), clone3:GetPivot().Position)
			currentCamera.FieldOfView = 40
			TweenService:Create(black, TweenInfo.new(1), {
				BackgroundTransparency = 1
			}):Play()
			v9:FadeOut()
			pcall(function()
				Workspace.World.Build["1"].BOTTOMS.Floor.Transparency = 0
				Workspace.World.Build["1"].BOTTOMS.Footprint["Meshes/untitled2 (1)"].Position = createVector(0, 0, 0)
				Workspace.World.Build["1"].BOTTOMS.Footprint.FogMesh.Position = createVector(0, 0, 0)
			end)
			pcall(function()
				setProperty(
					"Workspace.World.Build.1.BOTTOMS.Footprint.Meshes/untitled2 (1).Position",
					createVector(0, 0, 0)
				)()
				setProperty("Workspace.World.Build.1.BOTTOMS.Footprint.FogMesh.Position", createVector(0, 0, 0))()
			end)
			TweenService:Create(currentCamera, TweenInfo.new(4.5), {
				FieldOfView = 35
			}):Play()
			task.wait(1)
			black.Visible = false
			cutsceneUI.MonstersAreComing.Visible = false
			task.wait(WAIT_INTERVAL)
			local character = localPlayer.Character

			if character then
				character:FindFirstChild("HumanoidRootPart")
			end

			TweenService:Create(currentCamera, TweenInfo.new(5), {
				CFrame = CFrame.lookAt(createVector(485, 100.5, -365), createVector(515, 80.5, -365)),
				FieldOfView = 70
			}):Play()
			task.wait(WAIT_INTERVAL)
			xpcall(restoreCamera, warn)
			xpcall(function()
				Workspace.World.Build["1"].BOTTOMS.Floor.Transparency = 0
			end, warn)
			pcall(function()
				clone3:Destroy()
			end)
		end
	}
end