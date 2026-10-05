local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local _ = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "TripController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local playSound = v2:PlaySound(sounds.Naoya.Cursory.Kick, humanoidRootPart, game.SoundService.Effect)
			playSound.TimePosition = 0.3
			v2:ArmFlash(instance["Right Leg"], Color3.fromRGB(167, 125, 203), 0.4)
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

			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Haruta.Trip, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Haruta.Trip2, humanoidRootPart, game.SoundService.Effect)

			if p then
				v2:PlaySound(sounds.Haruta.Trip3, humanoidRootPart2, game.SoundService.Effect)
			end

			if instance2:GetAttribute("Ragdoll") > 0 then
				v2:PlaySound(sounds.Nanami.CleavingWhirlwind.Hit, humanoidRootPart, game.SoundService.Effect)
			end

			if instance == localPlayer.Character or instance2 == localPlayer.Character then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.MediumHit)
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
	v = Knit.GetService("TripService")
	v3 = Knit.GetController("HitboxController")
	v2 = Knit.GetController("FXController")
end

return controller