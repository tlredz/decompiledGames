local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local BloodyZee = require(replicatedStorage.Modules.BloodyZee)
local LightningBeams = require(replicatedStorage.Modules.LightningBeams)
Random.new()
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "CleaveRushController"
})

function controller.KnitStart(_)
	local v3 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Heian.CleaveStart, humanoidRootPart, game.SoundService.Voice)
		end,
		Warn = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Mahito.Transfig.Eyes, humanoidRootPart, game.SoundService.Effect)

			if p then
				v2:PlaySound(sounds.Heian.CleaveFlashVoice, humanoidRootPart, game.SoundService.Voice)
			else
				v2:PlaySound(sounds.Heian.CleaveVoice, humanoidRootPart, game.SoundService.Voice)
			end

			local clone = replicatedStorage.Utils.Itadori.EyeTrails:Clone()
			clone.Weld.Part0 = instance.Head
			clone.Parent = workspace.Effects
			clone.Glow:Emit(1)
			Debris:AddItem(clone, 2)
			task.wait(1)
			clone.Trail1.Trail.Enabled = false
			clone.Trail2.Trail.Enabled = false
			clone.Eye1.Glow.Enabled = false
			clone.Eye2.Glow.Enabled = false
		end,
		Dash = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Itadori.Rush.Rush, humanoidRootPart, game.SoundService.Effect)
			local clone = replicatedStorage.Utils.Itadori.RushWind:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			clone.Dust:Emit(7)
			clone.Ring:Emit(7)
			clone.Dash1.Dash:Emit(1)
			clone.Dash2.Dash:Emit(1)
			Debris:AddItem(clone, 2)

			for i = 1, 5 do
				task.delay(i * 0.075, function()
					local clone2 = utils.Itadori.Shock:Clone()
					clone2.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
					clone2.Parent = workspace.Effects
					TweenService:Create(clone2, TweenInfo.new(0.2), {
						Size = createVector(8, 0, 8),
						Transparency = 1
					}):Play()
					Debris:AddItem(clone2, 0.2)
				end)
			end

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		CleaveGrab = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart2, game.SoundService.Effect)
			v2:PlaySound(sounds.Heian.CleaveVoice2, humanoidRootPart, game.SoundService.Voice)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart2.Position).Magnitude < 200 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Cleave = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Heian.Cleave:Clone()
			clone.Weld.Part1 = humanoidRootPart
			clone.Parent = workspace.Effects
			task.delay(0.35, function()
				clone.Slashes.Enabled = false
				clone.PointLight:Destroy()
				Debris:AddItem(clone, 0.08)
			end)
			TweenService:Create(
				clone.PointLight,
				TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
				{
					Brightness = 40
				}
			):Play()
			TweenService:Create(
				clone.Slashes,
				TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
				{
					TimeScale = 1
				}
			):Play()

			for _ = 1, 20 do
				v2:PlaySound(sounds.Itadori.Dismantle.Slash, humanoidRootPart, game.SoundService.Effect)

				if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 200 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				end

				task.wait()
			end
		end,
		CleaveHit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.Dismantle.Explode, humanoidRootPart, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 200 then
				task.delay(0.1, function()
					if _G.Settings.Flash ~= true then
						return
					end

					local clone = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
					clone.Parent = game.Lighting
					task.wait(0.05)
					clone.TintColor = Color3.new(1, 1, 1)
					clone.Brightness = 200
					clone.Contrast = -1000
					task.wait(0.05)
					clone:Destroy()
				end)
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end

			local clone = utils.Itadori.Dismantle.Cleave:Clone()
			clone.Weld.Part1 = humanoidRootPart
			clone.Parent = workspace.Effects
			task.delay(0.1, function()
				clone.Slashes.Enabled = false
				clone.Slash2.Enabled = false
				clone.PointLight:Destroy()
				Debris:AddItem(clone, 0.08)
			end)
			v2:PlaySound(sounds.Itadori.Dismantle.FinishSlash, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 10 do
				clone.Slashes:Emit(1)
				v2:PlaySound(sounds.Itadori.Dismantle.Slash, humanoidRootPart, game.SoundService.Effect)
				task.wait()
			end
		end,
		Finisher = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Bleed(instance)

			for _ = 1, 40 do
				BloodyZee:Blood(instance.Torso.CFrame, 50, 360, 360)
			end

			if _G.Settings.Gore then
				local clone = utils.Heian.BloodSpread:Clone()
				clone.Parent = humanoidRootPart
				clone:Emit(80)
				Debris:AddItem(clone, 2)
			end
		end,
		BlackFlashFinisherHard = function(instance, instance2)
			local WAIT_INTERVAL = 0.04
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local clone = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(2, 1, -5)
			clone.Parent = workspace.Effects
			clone.Wind:Emit(20)
			clone.Sparks:Emit(20)
			clone.Flare:Emit(20)
			clone.Lightning:Emit(25)
			clone.Back1.Back:Emit(1)
			clone.Back2.Back:Emit(1)
			TweenService:Create(clone.Back1, TweenInfo.new(2), {
				CFrame = clone.Back1.CFrame - clone.Back1.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.Back2, TweenInfo.new(2), {
				CFrame = clone.Back2.CFrame - clone.Back2.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()
			Debris:AddItem(clone, 3)
			v2:PlaySound(sounds.Itadori.DivergentFist.BlackFlashHit, humanoidRootPart2, game.SoundService.Effect)
			local model = Instance.new("Model", workspace.Effects.Bolt)
			local highlight = Instance.new("Highlight", model)
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.OutlineColor = Color3.new(1, 0, 0)
			highlight.FillColor = Color3.new(0, 0, 0)
			highlight.FillTransparency = 0
			Debris:AddItem(model, 1.2)
			local v4 = LightningBeams.new(clone.Core, humanoidRootPart2.RootAttachment, nil, model)
			v4.Color = Color3.new(1, 0, 0)
			v4.PulseSpeed = 1000
			v4.FadeLength = 0.35
			v4.MaxRadius = 20
			v4.MinRadius = 0
			v4.AnimationSpeed = 300
			v4.MinThicknessMultiplier = 0.5
			v4.MaxThicknessMultiplier = 10
			task.delay(0.1, function()
				local WAIT_INTERVAL2 = 0.1
				v4.MaxThicknessMultiplier = 5
				task.wait(WAIT_INTERVAL2)
				v4.MaxThicknessMultiplier = 3
				task.wait(WAIT_INTERVAL2)
				v4.MaxThicknessMultiplier = 2
				task.wait(WAIT_INTERVAL2)
				v4.MaxThicknessMultiplier = 1
				task.wait(0.4)
				v4:Destroy()
			end)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(1.5)

				if _G.Settings.Flash == true then
					local clone2 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
					clone2.Parent = game.Lighting
					task.wait(WAIT_INTERVAL)
					clone2.TintColor = Color3.new(1, 1, 1)
					task.wait(WAIT_INTERVAL)
					clone2.Brightness = 200
					clone2.Contrast = -1000
					task.wait(WAIT_INTERVAL)
					clone2:Destroy()
				end

				game.Lighting.ExposureCompensation = 3
				TweenService:Create(game.Lighting, TweenInfo.new(1), {
					ExposureCompensation = 0
				}):Play()
			end
		end
	}
	v.Effects:Connect(function(p, ...)
		local v4 = v3[p]

		if not v4 then
			return
		end

		v4(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("CleaveRushService")
	v2 = Knit.GetController("FXController")
end

return controller