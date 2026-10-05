local createVector = vector.create
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
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "MaxElephantController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Megumi.Rabbit.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		Hitbox = function(p)
			local clone = utils.Megumi.HitArea:Clone()
			clone.Size = createVector(40, 0, 40)
			clone.Parent = workspace.Effects

			while true do
				local mouseTarget = v3:GetMouseTarget(75)
				local raycastResult = workspace:Raycast(
					mouseTarget + createVector(0, 1, 0),
					createVector(0, -300, 0),
					_G.MapParams
				)

				if raycastResult then
					mouseTarget = raycastResult.Position
				end

				clone.Position = mouseTarget
				task.wait()

				if p and p.Parent then
					continue
				end

				clone:Destroy()
				break
			end
		end,
		Spawn = function(position, p)
			local clone = utils.Megumi.Smash:Clone()
			clone.Position = position
			clone.Size = createVector(9, 9, 9)
			clone.Parent = workspace.Effects
			clone.Shadow:Emit(20)
			clone.ShadowSpark:Emit(40)
			Debris:AddItem(clone, 2)

			if p then
				v2:PlaySound(sounds.Megumi.Elephant.Spawn, clone, game.SoundService.Effect)
			else
				v2:PlaySound(sounds.Megumi.Elephant.Despawn, clone, game.SoundService.Effect)
			end

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 50 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Smash = function(position)
			local clone = utils.Megumi.Smash:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			clone.Dust:Emit(10)
			clone.Ring:Emit(10)
			Debris:AddItem(clone, 2)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 80 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Megumi.Elephant.Hit, humanoidRootPart, game.SoundService.Effect)
		end,
		Finisher = function(p)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			v2:Bleed(p)
			v2:PlaySound(sounds.Megumi.Elephant.Explode, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 20 do
				local clone = utils.Damage.Chunk:Clone()
				clone.CFrame = humanoidRootPart.CFrame
				clone.Velocity = Vector3.new(math.random(-90, 90), math.random(20, 50), math.random(-90, 90))
				clone.RotVelocity = Vector3.new(math.random(-200, 200), math.random(-200, 200), math.random(-200, 200))
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 1)

				if _G.Settings.Gore ~= false then
					continue
				end

				clone.Color = Color3.fromRGB(255, 85, 255)
				clone.Trail.Color = ColorSequence.new(Color3.fromRGB(255, 85, 255))
				clone.Blood.Color = clone.Trail.Color
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

function controller.ToolDeactivate(_)
	return (v3:GetMouseTarget(75))
end

function controller.KnitInit(_)
	v = Knit.GetService("MaxElephantService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller