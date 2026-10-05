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
	Name = "EnergySurgeController"
})

function controller.KnitStart(_)
	local v4 = {
		Dash = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Hakari.EnergySurge.Dash, humanoidRootPart, game.SoundService.Effect)
		end,
		HeavySwing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.CrushingBlow:Clone()
			clone.Air.Position = createVector(0, 40, 0)
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(1.5, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.PointLight.Color = Color3.fromRGB(85, 255, 127)
			TweenService:Create(clone.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()
			clone.Beam.Color = ColorSequence.new(Color3.fromRGB(85, 255, 127))
			clone.Floor.Sparks.Color = ColorSequence.new(Color3.fromRGB(85, 255, 127))
			clone.Floor.Ring:Emit(20)
			clone.Floor.Sparks:Emit(20)
			TweenService:Create(clone.Air, TweenInfo.new(0.15), {
				Position = createVector(0, 0, 0)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.4), {
				CFrame = clone.CFrame + humanoidRootPart.CFrame.LookVector * 30
			}):Play()
			v3:PlaySound(sounds.Hakari.EnergySurge.Swing, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Flash = function(self)
			local humanoidRootPart = self:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Hakari.EnergySurge.Swag, humanoidRootPart, game.SoundService.Effect)
		end,
		Flash2 = function(instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Teleport = function(instance, cFrame, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.Teleport:Clone()
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1.1)
			v3:PlaySound(sounds.Hakari.EnergySurge.Teleport, humanoidRootPart, game.SoundService.Effect)
			clone.Floor.Dust:Emit(30)
			clone.CFrame = humanoidRootPart.CFrame
			clone.Lines:Emit(30)
			clone.Floor.Dust:Emit(30)
		end,
		Jump = function(p, p2)
			local humanoidRootPart = p2.Parent.Parent:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = humanoidRootPart.CFrame.LookVector * 5

			if localPlayer.Character == humanoidRootPart.Parent then
				TweenService:Create(p2, TweenInfo.new(0.5), {
					P = 100000
				}):Play()

				repeat
					p2.Position = p.Position - v5
					task.wait()
				until not (p2.Parent and p)
			else
				repeat
					local v6 = humanoidRootPart.CFrame - humanoidRootPart.Position + p.Position - v5
					humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(v6, 0.15)
					task.wait()
				until not (p2.Parent and p)
			end

			TweenService:Create(p2, TweenInfo.new(0.5), {
				P = 100000
			}):Play()

			repeat
				p2.Position = p.Position - v5
				task.wait()
			until not (p2.Parent and p)
		end,
		Hit = function(p, instance, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hakari.OverLuck.Hit1, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Hakari.RoughHit:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			TweenService:Create(clone.PointLight, TweenInfo.new(0.6), {
				Brightness = 0
			}):Play()
			clone.Glow:Emit(1)
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)

			if p2 then
				v3:PlaySound(sounds.Hakari.EnergySurge.Hit2, humanoidRootPart, game.SoundService.Effect)
			else
				v3:PlaySound(sounds.Hakari.EnergySurge.Hit1, humanoidRootPart, game.SoundService.Effect)
			end

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
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
	v = Knit.GetService("EnergySurgeService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller