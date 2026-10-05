local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
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
	Name = "CheapShotController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Haruta.SwordThrow, humanoidRootPart, game.SoundService.Effect)
		end,
		ArmWave = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Haruta.Wave, humanoidRootPart, game.SoundService.Effect)
		end,
		Throw = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Haruta.SwordThrow:Clone()
			clone.Parent = humanoidRootPart

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local clone2 = utils.Gojo.HardHit:Clone()
			clone2.CFrame = humanoidRootPart.CFrame + humanoidRootPart.CFrame.LookVector * 3.5
			clone2.Parent = workspace.Effects
			clone2.Ring:Emit(5)
			Debris:AddItem(clone2, 0.5)

			if instance == localPlayer.Character then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Hit = function(instance, instance2, value)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Haruta.CheapShotHit, humanoidRootPart2, game.SoundService.Effect)
			local clone = utils.Yuta.SlashHit:Clone()
			clone.CFrame = CFrame.lookAlong(
				(humanoidRootPart2.CFrame * CFrame.new(value or 0, 0, 0)).Position,
				humanoidRootPart.CFrame.LookVector
			) * CFrame.Angles(0, 0, -1.5707963267948966)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.5)
			clone.Slash:Emit(5)
		end,
		Interp = function(instance)
			v2:PlaySound(sounds.Haruta.SwordSpin, instance, game.SoundService.Effect, true)
			local cFrame = instance.CFrame
			local lastTime = tick()
			local positionChangedConnection = instance:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = instance.CFrame
				lastTime = tick()
			end)
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if instance.Parent then
					workspace:BulkMoveTo(
						{ instance },
						{ cFrame + cFrame.LookVector * (150 * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
			end)
		end,
		Finisher = function(instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			v2:Bleed(instance)
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
	v = Knit.GetService("CheapShotService")
	v3 = Knit.GetController("HitboxController")
	v2 = Knit.GetController("FXController")
end

return controller