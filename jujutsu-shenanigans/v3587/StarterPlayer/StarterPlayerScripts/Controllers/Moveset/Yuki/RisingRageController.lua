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
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "RisingRageController"
})

function controller.KnitStart(_)
	local v4 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Yuki.Startup, humanoidRootPart, game.SoundService.Effect)
		end,
		Trail = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Yuki.Swing, humanoidRootPart, game.SoundService.Effect)
			local clone = replicatedStorage.Utils.Yuki.MassChargeLeg:Clone()
			clone.Parent = workspace.Effects
			TweenService:Create(clone.PointLight, TweenInfo.new(0.3), {
				Brightness = 5
			}):Play()
			clone.Weld.C1 = CFrame.new(0, 2, 0)
			clone.Weld.Part0 = instance["Left Leg"]
			task.wait(0.2)

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			TweenService:Create(clone.PointLight, TweenInfo.new(0.5), {
				Brightness = 0
			}):Play()
			Debris:AddItem(clone, 0.6)
			clone.Trail.Enabled = false
		end,
		Hit = function(p, instance, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)

			if p2 == 1 then
				v2:PlaySound(sounds.Yuki.Mass.Hit, humanoidRootPart, game.SoundService.Effect)
			elseif p2 == 2 then
				v2:PlaySound(sounds.Yuki.RisingRage.Hit, humanoidRootPart, game.SoundService.Effect)
			elseif p2 == 3 then
				v2:PlaySound(sounds.Yuki.RisingRage.Hit2, humanoidRootPart, game.SoundService.Effect)
			end

			v2:Flash(instance, Color3.new(1, 1, 1))

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Hit2 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Yuki.MassHit:Clone()
			clone.CFrame = CFrame.lookAlong(humanoidRootPart.Position, createVector(0, 1, 0))
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local clone2 = utils.Gojo.LapseBlue.LapseBlue.Grab:Clone()
			clone2.Size = createVector(40, 40, 40)
			clone2.Weld.Part0 = humanoidRootPart
			clone2.Parent = workspace.Effects
			local highlight = Instance.new("Highlight", clone2)
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			clone2.Transparency = 50
			TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 0),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone2, 0.4)
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Yuki.Mass.Hit, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Yuki.Mass.Hit2, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		KneeBuild = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Yuki.RisingRage.Charge, humanoidRootPart, game.SoundService.Effect)
			local clone = replicatedStorage.Utils.Yuki.FullRisingRage:Clone()
			clone.Parent = workspace.Effects
			TweenService:Create(clone.PointLight, TweenInfo.new(0.6), {
				Brightness = 10
			}):Play()
			clone.Weld.Part0 = instance["Right Leg"]
			Debris:AddItem(clone, 2)

			for _, emitter in clone:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.TimeScale = 0
				TweenService:Create(emitter, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
					TimeScale = 1
				}):Play()
			end

			task.wait(0.6)

			for _, child in clone.Hit:GetChildren() do
				child.Enabled = false
			end

			clone.impactframeines3.Enabled = true
			clone.Start["Down_Smoke [11]"].Enabled = true
			clone.Start.Hit.Enabled = true
			clone.Smear:Emit(1)
			clone.Start.Flare:Emit(1)
			clone.Start.Wind2:Emit(8)
			task.wait(0.3)
			TweenService:Create(clone.PointLight, TweenInfo.new(0.4), {
				Brightness = 0
			}):Play()

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end,
		Dash = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			for i = 1, 4 do
				task.delay(i * 0.05, function()
					local clone = utils.Itadori.Shock:Clone()
					clone.CFrame = CFrame.lookAlong(humanoidRootPart.Position, humanoidRootPart.Velocity) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
					clone.Transparency = 0.3
					clone.Parent = workspace.Effects
					TweenService:Create(clone, TweenInfo.new(0.15), {
						Size = createVector(20, 0, 20),
						Transparency = 1
					}):Play()
					Debris:AddItem(clone, 0.15)
				end)
			end

			local clone = utils.Choso.CounterSwing.Shock:Clone()
			clone.Size = createVector(6, 30, 6)
			clone.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.2)
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Size = createVector(25, 0, 25),
				Transparency = 1,
				Position = clone.Position + humanoidRootPart.CFrame.LookVector * 10
			}):Play()
			local clone2 = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
			clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(2, 1, -5)
			clone2.Parent = workspace.Effects
			clone2.Wind:Emit(20)
			clone2.PointLight:Destroy()
			clone2.Back1.Back:Emit(1)
			clone2.Back2.Back:Emit(1)
			TweenService:Create(clone2.Back1, TweenInfo.new(2), {
				CFrame = clone2.Back1.CFrame - clone2.Back1.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone2.Back2, TweenInfo.new(2), {
				CFrame = clone2.Back2.CFrame - clone2.Back2.CFrame.LookVector * 20
			}):Play()
			Debris:AddItem(clone2, 3)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		KneeHit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Yuki.RisingRage.Hit3, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		HeadHit = function(p, instance, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:Flash(instance, Color3.new(1, 0, 0), 5)
			v2:PlaySound(sounds.Yuki.RisingRage.Hit3, humanoidRootPart, game.SoundService.Effect)
			local cframe = CFrame.lookAlong(instance.Head.Position, p2)

			for _ = 1, 40 do
				BloodyZee:Blood(cframe, math.random(-150, -5), 25, 25)
			end

			if localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			elseif localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
				CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.LightHit):StartFadeOut(5)
				v2:PlaySound(sounds.Yuki.RisingRage.Ring, workspace, game.SoundService.Effect)
				local blurEffect = Instance.new("BlurEffect", game.Lighting)
				Debris:AddItem(blurEffect, 5)
				blurEffect.Size = 64
				TweenService:Create(blurEffect, TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Size = 0
				}):Play()

				if _G.Settings.Flash == true then
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
					Debris:AddItem(colorCorrectionEffect, 5)
					colorCorrectionEffect.TintColor = Color3.new(1, 0, 0)
					colorCorrectionEffect.Contrast = 200
					task.wait(0.05)
					colorCorrectionEffect.Contrast = -200
					colorCorrectionEffect.TintColor = Color3.new(1, 1, 1)
					task.wait(0.05)
					colorCorrectionEffect.Contrast = 0
					colorCorrectionEffect.TintColor = Color3.new(1, 0.3, 0.3)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(2.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							TintColor = Color3.fromRGB(255, 201, 201)
						}
					):Play()
					task.wait(2.4)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							TintColor = Color3.fromRGB(255, 255, 255)
						}
					):Play()
				end
			end
		end
	}
	v.Effects:Connect(function(p, ...)
		local v5 = v4[p]

		if not v5 then
			return
		end

		v5(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("RisingRageService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller