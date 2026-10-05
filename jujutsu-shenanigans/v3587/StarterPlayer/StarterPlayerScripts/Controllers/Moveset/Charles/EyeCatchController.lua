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
local controller = Knit.CreateController({
	Name = "EyeCatchController"
})

function controller.KnitStart(_)
	local v3 = {
		Hit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Charles.EyeCatch.Hit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Fade = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Damage.HitGlow:Clone()

			if instance:GetScale() ~= 1 then
				clone:ScaleTo(instance:GetScale())
			end

			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.5)

			for _, child in clone:GetChildren() do
				local child2 = instance:FindFirstChild(child.Name)

				if child2 then
					child.CFrame = child2.CFrame
				end

				child.Color = Color3.new(0, 0, 0)
				child.Anchored = true
				child.Transparency = 0.1
				TweenService:Create(child, TweenInfo.new(0.5), {
					Transparency = 1
				}):Play()
			end

			v2:PlaySound(sounds.Itadori.ManjiKick.Dodge, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Charles.EyeCatch.Dodge, humanoidRootPart, game.SoundService.Effect)
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
	v = Knit.GetService("EyeCatchService")
	v2 = Knit.GetController("FXController")
end

return controller