local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
game:GetService("TweenService")
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
	Name = "RikaLaunchController"
})

function controller.KnitStart(_)
	local v3 = {
		Feint = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if p then
				v2:PlaySound(sounds.Yuta.EnergyRipple.Feint.Feint, humanoidRootPart, game.SoundService.Effect)
				task.delay(0.2, function()
					v2:PlaySound(sounds.Yuta.EnergyRipple.Feint.Swing, humanoidRootPart, game.SoundService.Effect)
				end)
			end

			local clone = utils.Itadori.CounterHit.Feint:Clone()

			for _, child in clone:GetChildren() do
				child.Color = ColorSequence.new(Color3.fromRGB(255, 170, 255))
			end

			clone.Parent = humanoidRootPart
			clone.Sparks:Emit(10)
			clone.Star:Emit(1)
			clone.Ring:Emit(1)
			Debris:AddItem(clone, 0.5)
		end,
		StartSound = function(p)
			v2:PlaySound(sounds.Yuta.Rika.Launch, p, game.SoundService.Effect)
		end
	}
	RikaLaunchService.Effects:Connect(function(p, ...)
		local v4 = v3[p]

		if not v4 then
			return
		end

		v4(...)
	end)
end

function controller.KnitInit(_)
	RikaLaunchService = Knit.GetService("RikaLaunchService")
	v = Knit.GetController("HitboxController")
	v2 = Knit.GetController("FXController")
end

return controller