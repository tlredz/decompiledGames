local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local _ = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "ReversalRedController"
})

function controller.KnitStart(_)
	local v3 = {
		Red = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Gojo.ReversalRed.Wind, humanoidRootPart, game.SoundService.Effect)
			TweenService:Create(p, TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
				Size = createVector(0.9, 0.9, 0.9)
			}):Play()
			TweenService:Create(p.Center.Light, TweenInfo.new(0.5), {
				Brightness = 40,
				Range = 8
			}):Play()
			TweenService:Create(p.Center.Charge, TweenInfo.new(0.3), {
				Rate = 40,
				TimeScale = 1
			}):Play()
			task.wait(0.3)
			p.Center.Charge.Enabled = false
			TweenService:Create(
				p.Center.Light,
				TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
				{
					Range = 16
				}
			):Play()
			task.wait(0.2)
			v2:PlaySound(sounds.Gojo.ReversalRed.Throw, humanoidRootPart, game.SoundService.Effect)
		end,
		Explode = function(position)
			local clone = utils.Gojo.ReversalRed.RedExplode:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 2)
			clone.Burst:Emit(1)
			clone.Sparks:Emit(15)
			clone.Wind:Emit(6)
			clone.Dust:Emit(6)
			TweenService:Create(clone.Light, TweenInfo.new(0.5), {
				Brightness = 0
			}):Play()
			v2:PlaySound(sounds.Gojo.ReversalRed.Explode, clone, game.SoundService.Effect)
		end,
		Finisher = function(p)
			if not p.HumanoidRootPart then
				return
			end

			if _G.Settings.Gore then
				local clone = utils.Heian.BloodSpread:Clone()
				clone.Parent = p.Head
				clone:Emit(20)
				Debris:AddItem(clone, 2)
			end

			v2:Bleed(p)
		end,
		Flip = function(p, p2)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			p2.Flip.Sparks1.Enabled = true
			p2.Flip.Sparks2.Enabled = true
			p2.Flip.Charging.Enabled = true
			p2.Flip.Wind.Enabled = true
			p2.Flip.Wind2:Emit(7)
			TweenService:Create(p2.Flip.Wind2, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				TimeScale = 0.05
			}):Play()
			v2:PlaySound(sounds.Gojo.RedFlip, humanoidRootPart, game.SoundService.Voice)
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
	v = Knit.GetService("ReversalRedService")
	v2 = Knit.GetController("FXController")
end

return controller