local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "BigMovesController"
})

function controller.KnitStart(_)
	local v4 = {
		Hit = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Reggie.TruckHit, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 1))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(50)
			clone.Wind2:Emit(7)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Shake = function(self)
			v3:PlaySound(sounds.Reggie.TruckHorn, self, game.SoundService.Effect)
			local clone = utils.Reggie.TruckWind:Clone()
			clone.Parent = self.Parent.Truck.Main
			clone.Wind1.Parent = self.Parent.Truck.Main
			clone.Wind2.Parent = self.Parent.Truck.Main

			while true do
				task.wait(0.1)

				if (self:GetAttribute("Speed") or 0) < 40 and self.Parent and self.Parent.Truck.Main.Wind1.Enabled then
					self.Parent.Truck.Main.Wind1.Enabled = false
					self.Parent.Truck.Main.Wind2.Enabled = false
				end

				if (workspace.CurrentCamera.CFrame.Position - self.Position).Magnitude < 60 and (self:GetAttribute("Speed") or 0) > 40 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				end

				if self.Parent then
					continue
				end

				if clone and clone.Parent then
					clone:Destroy()
				end

				break
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
	v = Knit.GetService("BigMovesService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller