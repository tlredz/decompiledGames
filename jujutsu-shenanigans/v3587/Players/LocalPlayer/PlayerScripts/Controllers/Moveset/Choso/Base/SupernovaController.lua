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
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "SupernovaController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Itadori.ManjiKick.Dodge, humanoidRootPart, game.SoundService.Effect)
		end,
		Throw = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Itadori.DivergentFist.Swing, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit = function(instance, instance2)
			instance:FindFirstChild("HumanoidRootPart")
			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")
			v3:Flash(instance2, Color3.new(1, 0, 0))
			v3:PlaySound(sounds.Itadori.CursedStrikes.Hit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Burst = function(p)
			v3:PlaySound(sounds.Choso.BloodBurst2, p, game.SoundService.Effect)
			local clone = utils.Choso.BloodExplode:Clone()
			clone.Position = p.Position
			clone.Parent = workspace.Effects
			clone.Blood:Emit(30)
			clone.Burst:Emit(1)
			clone.Wind:Emit(6)
			Debris:AddItem(clone, 2)
		end,
		CounterHit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Choso.Counter, humanoidRootPart, game.SoundService.Effect)
			v3:ArmFlash(instance["Right Arm"], Color3.fromRGB(170, 0, 0), 0.9)
			local clone = utils.Choso.CounterHit:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(1)
			Debris:AddItem(clone, 0.2)
			local clone2 = utils.Itadori.DivergentFist.BlackFlashHit.Wind2:Clone()
			clone2.Parent = humanoidRootPart.RootAttachment
			clone2:Emit(7)
			Debris:AddItem(clone2, 0.1)

			if localPlayer.Character == instance or localPlayer.Character == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Hit1 = function(instance, instance2)
			instance:FindFirstChild("HumanoidRootPart")
			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")
			v3:Flash(instance2, Color3.new(1, 0, 0))
			v3:PlaySound(sounds.Mahito.Chainwhip.Hit, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Itadori.Dismantle.Explode, humanoidRootPart, game.SoundService.Effect)
			task.wait(0.2)
			v3:PlaySound(sounds.Mahito.Stockpile.Swing, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit2 = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")
			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hakari.EnergySurge.Hit2, humanoidRootPart2, game.SoundService.Effect)
			v3:PlaySound(sounds.Choso.BloodBurst, humanoidRootPart2, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end

			for i = 1, 4 do
				task.delay(i * 0.1, function()
					local clone = utils.Itadori.Shock:Clone()
					clone.CFrame = CFrame.lookAlong(humanoidRootPart2.Position, humanoidRootPart2.Velocity) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
					clone.Parent = workspace.Effects
					TweenService:Create(clone, TweenInfo.new(0.15), {
						Size = createVector(10, 0, 10),
						Transparency = 1
					}):Play()
					Debris:AddItem(clone, 0.15)
				end)
			end

			local clone = utils.Choso.CounterSwing:Clone()
			clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(2, 1, -4))
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.3)
			TweenService:Create(clone.Shock, TweenInfo.new(0.15), {
				Size = createVector(0, 25, 0),
				Transparency = 1
			}):Play()
			TweenService:Create(clone.Shock2, TweenInfo.new(0.1), {
				Size = createVector(8, 0, 8),
				Transparency = 1,
				Position = clone.Shock2.Position + humanoidRootPart.CFrame.LookVector * 3
			}):Play()
			TweenService:Create(clone.Shockwave, TweenInfo.new(0.3), {
				Size = createVector(0, 30, 0),
				Transparency = 1,
				CFrame = clone.Shockwave.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
			}):Play()
		end,
		Finisher = function(instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			v3:Bleed(instance)
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
	v = Knit.GetService("SupernovaService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller