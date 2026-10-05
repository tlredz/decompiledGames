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
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "SeveringPathController"
})
local v3 = {
	10,
	5,
	55,
	50
}

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v:PlaySound(sounds.Yuta.SeveringPath.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		Start2 = function(instance)
			local yutaSword = instance.SetAssets:FindFirstChild("YutaSword")

			if not (yutaSword and instance:FindFirstChild("HumanoidRootPart")) then
				return
			end

			local blade = yutaSword.Sword.Blade
			local clone = utils.Yuta.ResoluteSlash.SwordBurst.Attachment0:Clone()
			local clone2 = utils.Yuta.ResoluteSlash.SwordBurst.Center:Clone()
			clone.Parent = blade
			clone2.Parent = blade
			Debris:AddItem(clone, 0.5)
			Debris:AddItem(clone2, 4)
			clone.Burst1:Emit(1)
			clone2.Burst2:Emit(1)
			task.wait(0.3)
			clone2:Destroy()
			local clone3 = utils.Yuta.ResoluteSlash.SwordBurst.Sparks:Clone()
			clone3.Parent = blade
			Debris:AddItem(clone3, 0.7)
			clone3:Emit(30)
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v:PlaySound(
				sounds.Yuta.SeveringPath["Swing" .. math.random(1, 3)],
				humanoidRootPart,
				game.SoundService.Effect
			)
		end,
		PunchSwing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local playSound = v:PlaySound(sounds.Hiromi.Throw2, humanoidRootPart, game.SoundService.Effect)
			playSound.PlaybackSpeed = math.random(9, 11) / 10
		end,
		Hit = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v:Flash(instance2, Color3.fromRGB(255, 170, 255))
			v:PlaySound(
				sounds.Yuta.SeveringPath:FindFirstChild("Hit" .. p),
				humanoidRootPart2,
				game.SoundService.Effect
			)
			local clone = utils.Yuta.SlashHit:Clone()
			clone.Slash.Color = ColorSequence.new(Color3.fromRGB(255, 85, 255))
			clone.CFrame = CFrame.lookAlong(humanoidRootPart2.Position, humanoidRootPart.CFrame.LookVector) * CFrame.Angles(
				0,
				0,
				(math.rad(v3[p] or 0))
			)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.5)
			clone.Slash:Emit(5)
		end,
		AirHit = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v:Flash(instance, Color3.new(1, 1, 1))
			v:PlaySound(sounds.Yuta.M1.Hit4, humanoidRootPart, game.SoundService.Effect)
		end
	}
	v2.Effects:Connect(function(p, ...)
		local v5 = v4[p]

		if not v5 then
			return
		end

		v5(...)
	end)
end

function controller.KnitInit(_)
	v2 = Knit.GetService("SeveringPathService")
	v = Knit.GetController("FXController")
end

return controller