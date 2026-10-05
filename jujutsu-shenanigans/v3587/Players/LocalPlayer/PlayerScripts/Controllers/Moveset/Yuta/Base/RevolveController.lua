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
local BloodyZee = require(replicatedStorage.Modules.BloodyZee)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "RevolveController"
})

function controller.KnitStart(_)
	local v4 = {
		DiveSound = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and instance2.Parent) then
				return
			end

			v3:PlaySound(sounds.Yuta.RevolveDive, humanoidRootPart, game.SoundService.Effect)
			local v5 = v3:PlaySound(sounds.Yuta.VeilstepDive, humanoidRootPart, game.SoundService.Effect)
			instance2.AncestryChanged:Once(function()
				v5:Destroy()
			end)
		end,
		Land = function(position)
			local clone = utils.Itadori.CrushingBlow:Clone()
			clone.PointLight:Destroy()
			clone.Beam:Destroy()
			clone.Position = position
			clone.Parent = workspace.Effects
			clone.Floor.Wind2.Color = ColorSequence.new(Color3.new(1, 1, 1))
			clone.Floor.Wind2:Emit(8)
			Debris:AddItem(clone, 1.5)
			v3:PlaySound(sounds.Yuta.RevolveLand, clone, game.SoundService.Effect)
		end,
		Spin = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Yuta.Veilstep.Spin.SpinRing:Clone()
			clone.Parent = humanoidRootPart
			Debris:AddItem(clone, 0.5)
			clone.CFrame *= CFrame.Angles(0, 0, 0.4363323129985824)
			clone.Ring:Emit(10)
		end,
		Impale = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Yuta.M1.Hit1, humanoidRootPart, game.SoundService.Effect)
		end,
		ImpaleFinisher = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			while true do
				task.wait(0.1)

				if not humanoidRootPart.Parent then
					break
				end

				BloodyZee:Blood(humanoidRootPart.CFrame * CFrame.new(0, 0, -0.5), 50, 10, 10)

				if not humanoidRootPart.Parent then
					break
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
	v.Hitbox:Connect(function(instance, p, object)
		local humanoidRootPart = p.HumanoidRootPart

		if not humanoidRootPart then
			return
		end

		repeat
			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position,
				instance.Velocity.Unit * 7 + humanoidRootPart.CFrame.LookVector * 3,
				raycastParams
			)
			local sphereHitbox = v2:SphereHitbox(p, CFrame.new(0, -5, -5), 8)

			if #sphereHitbox > 0 or raycastResult then
				if not (#sphereHitbox > 0) then
					sphereHitbox = false
				end

				object:FireServer(sphereHitbox, raycastResult and raycastResult.Position)

				if raycastResult then
					instance:Destroy()
				end
			end

			task.wait(0.025)
		until not instance.Parent
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("RevolveService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller