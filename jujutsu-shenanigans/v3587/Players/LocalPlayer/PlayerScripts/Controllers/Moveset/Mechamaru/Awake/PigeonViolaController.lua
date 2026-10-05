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
local SraikoVFX = require(replicatedStorage.Modules.SraikoVFX)
local _ = SraikoVFX.Enabled
local _ = SraikoVFX.Emit
local _ = SraikoVFX.EmitMesh
local pigeonViolaVFX = utils.Mechamaru.PigeonViolaVFX
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "PigeonViolaController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local function HandEffects(parent)
				if not parent then
					return
				end

				local clone = pigeonViolaVFX.Hands:Clone()
				clone.Parent = parent
				Debris:AddItem(clone, 2)
				task.delay(0.5, function()
					for _, v5 in clone:QueryDescendants("ParticleEmitter") do
						v5.Enabled = false
					end
				end)
			end

			HandEffects(instance:FindFirstChild("Right Arm"))
			HandEffects(instance:FindFirstChild("Left Arm"))
			v3:PlaySound(sounds.Mechamaru.PigeonViola.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		Spawn = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = pigeonViolaVFX.Spawn:Clone()
			clone.Parent = humanoidRootPart
			Debris:AddItem(clone, 2)

			for _, v5 in clone:QueryDescendants("ParticleEmitter") do
				v5:Emit(v5:GetAttribute("EmitCount"))
			end

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			task.wait(0.1)
			local clone2 = pigeonViolaVFX.Stars:Clone()
			clone2.Weld.Part0 = humanoidRootPart
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 2)
			task.wait(0.2)

			for _, v5 in clone2:QueryDescendants("ParticleEmitter") do
				v5.Enabled = false
			end
		end,
		Shoot = function(instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Interp = function(instance)
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
						{ cFrame + cFrame.LookVector * (instance:GetAttribute("Speed") * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
			end)
		end,
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, p)
			v3:PlaySound(
				sounds.Mechamaru.PigeonViola:FindFirstChild("Hit" .. math.random(1, 2)),
				humanoidRootPart,
				game.SoundService.Effect
			)
		end,
		Explode = function(p, p2)
			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = p2.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Brightness = 45
			clone.Sparks.LightEmission = 0
			clone.Sparks.Color = ColorSequence.new(p2.Color)
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)

			if localPlayer.Character == p or localPlayer:DistanceFromCharacter(p2.Position) < 30 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
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
	v = Knit.GetService("PigeonViolaService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller