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
local controller = Knit.CreateController({
	Name = "GarudaStabController"
})

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Yuki.Startup2, humanoidRootPart, game.SoundService.Effect)
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Yuki.Stab, humanoidRootPart, game.SoundService.Effect)
		end,
		Stab = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Hiromi.Stab, humanoidRootPart, game.SoundService.Effect)
			task.delay(0.04, function()
				for _ = 1, 40 do
					BloodyZee:Blood(instance.Torso.CFrame, math.random(-150, -5), 25, 25)
				end
			end)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 70 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Trail = function(instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local clone = replicatedStorage.Utils.Yuki.MassChargeLeg:Clone()
			clone.Parent = workspace.Effects
			TweenService:Create(clone.PointLight, TweenInfo.new(0.3), {
				Brightness = 5
			}):Play()
			clone.Weld.C1 = CFrame.new(0, 2, 0)
			clone.Weld.Part0 = instance["Right Leg"]
			task.wait(0.3)

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
		Hit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Yuki.MassHit:Clone()
			clone.CFrame = CFrame.lookAlong(instance.Torso.Position, createVector(0, 1, 0))
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
		GarudaTrail = function(instance)
			local WAIT_INTERVAL = 0.4

			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local garuda = instance.SetAssets:FindFirstChild("Garuda")

			if not garuda then
				return
			end

			local tailHolder = garuda.Garuda["segment finale"].TailHolder
			local clone = replicatedStorage.Utils.Yuki.MassCharge:Clone()
			Debris:AddItem(clone, 2)
			clone.Parent = workspace.Effects
			clone.Weld.Part0 = tailHolder

			local function Enable()
				for _, emitter in clone:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				TweenService:Create(clone.PointLight, TweenInfo.new(0.2), {
					Brightness = 5
				}):Play()
				clone.Trail.Enabled = true
			end

			local function Disable()
				for _, emitter in clone:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				TweenService:Create(clone.PointLight, TweenInfo.new(0.2), {
					Brightness = 0
				}):Play()
				clone.Trail.Enabled = false
			end

			Enable()
			task.wait(WAIT_INTERVAL)
			Disable()
			task.wait(WAIT_INTERVAL)
			Enable()
			task.wait(WAIT_INTERVAL)
			Disable()
		end,
		Whip = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Yuta.Veilstep.Spin.SpinRing:Clone()
			clone.Parent = humanoidRootPart
			Debris:AddItem(clone, 0.5)
			clone.Ring.Size = NumberSequence.new(17.5)
			clone.Ring.LockedToPart = false
			clone.Ring:Emit(5)
		end,
		Whip1 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Yuki.FirstWhip, humanoidRootPart, game.SoundService.Effect)
		end,
		Whip2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Yuki.SecondWhip, humanoidRootPart, game.SoundService.Effect)
		end,
		FlyBack = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Yuki.WhipFlyBack, humanoidRootPart, game.SoundService.Effect)
		end,
		WhipHit = function(_, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Yuki.RisingRage.Hit, humanoidRootPart, game.SoundService.Effect)
		end,
		WhipHitHard = function(p, instance)
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
	v = Knit.GetService("GarudaStabService")
	v2 = Knit.GetController("FXController")
end

return controller