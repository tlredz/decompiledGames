local createVector = vector.create
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
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "HomerunController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Reggie.Homerun.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		Interp = function(instance, parent)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(0.85)
			Debris:AddItem(model, 0.1)
			clone.CFrame = parent.CFrame
			clone.Parent = workspace.Effects
			clone.Wind:Emit(2)
			clone.PointLight:Destroy()
			clone.Wind.Lifetime = NumberRange.new(0.25, 0.8)
			clone.Back1.Back.Size = NumberSequence.new(0)
			clone.Back2.Back.Size = NumberSequence.new(0)
			Debris:AddItem(clone, 3)
			v3:PlaySound(sounds.Reggie.Homerun.BallLaunch2, humanoidRootPart, game.SoundService.Effect)
			local cFrame = parent.CFrame
			local lastTime = tick()
			local positionChangedConnection = parent:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = parent.CFrame
				lastTime = tick()
			end)
			local boostedChangedConnection = parent:GetAttributeChangedSignal("Boosted"):Connect(function()
				local clone2 = utils.Reggie.Boost:Clone()
				clone2.Parent = parent
				clone2.Wind2.Parent = parent
				v3:PlaySound(sounds.Reggie.Homerun.BallFire, parent, game.SoundService.Effect)

				repeat
					clone2.CFrame = utils.Reggie.Boost.CFrame * CFrame.Angles(0, 0, math.random(0, 3.141592653589793))
					task.wait()
				until not clone2.Parent
			end)
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if parent.Parent ~= workspace.Bullets then
					return
				end

				if parent.Parent then
					workspace:BulkMoveTo(
						{ parent },
						{ cFrame + cFrame.LookVector * (parent:GetAttribute("Speed") * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
				boostedChangedConnection:Disconnect()
			end)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		HitBall = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Reggie.Homerun.BallLaunch1, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
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

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart2.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 1))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(30)
			clone.Wind2:Emit(7)

			for _, emitter in clone:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				if p then
					emitter.Color = ColorSequence.new(Color3.fromRGB(255, 100, 100))
				end

				emitter.TimeScale = 0.05
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Reggie.Homerun.Hit, humanoidRootPart2, game.SoundService.Effect)

			if localPlayer.Character == instance2 or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
			end

			task.delay(0.15, function()
				v3:PlaySound(
					p and sounds.Reggie.Homerun.Hit2Homerun or sounds.Reggie.Homerun.Hit2,
					humanoidRootPart2,
					game.SoundService.Effect
				)
				v3:PlaySound(sounds.Reggie.Homerun.Followup, humanoidRootPart, game.SoundService.Effect)

				for _, emitter in clone:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.TimeScale = 1
					end
				end

				if localPlayer.Character == instance2 or localPlayer.Character == instance then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				end
			end)
		end,
		Hit2 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Reggie.Homerun.BallHit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
			end
		end,
		CollidedBall = function(instance, p)
			local clone = instance:Clone()

			if clone:FindFirstChild("Boost") then
				clone.Boost:Destroy()
				clone.Wind2:Destroy()
			end

			clone.Parent = workspace.Effects
			clone.CollisionGroup = "NoPlayerCollision"
			clone.CanCollide = true
			clone.Anchored = false
			clone.AssemblyLinearVelocity = p and -instance.CFrame.LookVector * 40 + createVector(0, 15, 0) or instance.CFrame.LookVector * 40
			Debris:AddItem(clone, 2)
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
	v = Knit.GetService("HomerunService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller