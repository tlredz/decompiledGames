local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "RabbitEscapeController"
})
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Spawns, workspace.Domains }

function controller.KnitStart(_)
	local v3 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Megumi.Rabbit.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		Rab = function(instance, position, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Megumi.Rabbit:Clone()
			clone.Parent = workspace.Effects
			clone.Size = createVector(11, 2, 11)
			clone.Color = Color3.new(0, 0, 0)
			TweenService:Create(clone, TweenInfo.new(0.1), {
				Size = utils.Megumi.Rabbit.Size,
				Color = Color3.new(1, 1, 1)
			}):Play()
			local clone2 = utils.Megumi.Shadow:Clone()
			clone2.Parent = workspace.Effects
			clone2.Dive.Enabled = false
			clone2.Shadow.Enabled = false
			Debris:AddItem(clone2, 1)
			local raycastResult = workspace:Raycast(
				position + createVector(0, 2, 0),
				createVector(0, -8, 0),
				raycastParams
			)

			if raycastResult then
				position = raycastResult.Position
				clone2.CFrame = CFrame.new(position, position + raycastResult.Normal)
				clone2.Shadow:Emit(4)
				clone2.Dive:Emit(1)
			else
				clone2.Position = position
				clone2.ShadowAir:Emit(4)
			end

			local lastTime = tick()
			local vector2 = Vector3.new(math.random(-40, 40) / 10, 0, math.random(-40, 40) / 10)
			local total = 1
			local v4 = math.random(5, 13) / 10
			clone.CFrame = CFrame.new(position, humanoidRootPart.Position - createVector(0, 3, 0))
			sounds.Megumi.Rabbit.Spawn.PlaybackSpeed = math.random(80, 120) / 100
			v2:PlaySound(sounds.Megumi.Rabbit.Spawn, clone, game.SoundService.Effect)
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function(_, dt)
				local v5 = tick() - lastTime

				if humanoidRootPart.Parent and not (p + 0.4 <= v5) then
					local v6 = humanoidRootPart.Position - createVector(0, 3, 0) + vector2
					local lookVector = CFrame.new(position, v6).LookVector
					local lerped = position:Lerp(v6, v5 / p)
					local raycastResult2 = workspace:Raycast(
						lerped + createVector(0, 2, 0),
						createVector(0, -8, 0),
						raycastParams
					)
					local cframe = CFrame.new(lerped, lerped + lookVector + Vector3.new(0, v4 / 2, 0))

					if raycastResult2 then
						cframe = cframe - cframe.Position + raycastResult2.Position
					end

					v4 -= 10 * dt
					total += v4

					if total <= 0 then
						total = 1
						v4 = math.random(5, 13) / 10
					end

					clone.CFrame = cframe

					if raycastResult2 then
						clone.CFrame += Vector3.new(0, total, 0)
					end
				else
					steppedConnection:Disconnect()
					TweenService:Create(clone, TweenInfo.new(0.1), {
						Color = Color3.new(0, 0, 0)
					}):Play()
					v2:PlaySound(sounds.Megumi.Rabbit.Despawn, clone, game.SoundService.Effect)
					task.wait(0.1)
					clone.Decal:Destroy()
					clone.Transparency = 1
					clone.Despawn:Emit(3)
					Debris:AddItem(clone, 0.6)
				end
			end)
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(
				sounds.Gojo.M1:FindFirstChild("Hit" .. math.random(1, 4)),
				humanoidRootPart,
				game.SoundService.Effect
			)

			if instance:GetAttribute("Dead") then
				local v4 = nil

				for _, child in instance:GetChildren() do
					if utils.Damage.Skeleton:FindFirstChild(child.Name) and child.Transparency == 0 then
						v4 = child
					end
				end

				if not v4 then
					return
				end

				v4.Transparency = 1
				local clone = utils.Damage.Skeleton:FindFirstChild(v4.Name):Clone()
				local weld = Instance.new("Weld", clone)
				weld.Part0 = v4
				weld.Part1 = clone
				clone.Parent = v4
				v2:PlaySound(sounds.Megumi.Rabbit.Eat, humanoidRootPart, game.SoundService.Effect)
			end
		end,
		Hit2 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Hakari.EnergySurge.Hit2, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Launch = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Megumi.Rabbit.Spawn, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Megumi.RabbitLaunch:Clone()
			clone.CFrame = humanoidRootPart.CFrame - createVector(0, 2, 0)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 3)
			TweenService:Create(clone, TweenInfo.new(0.2), {
				CFrame = humanoidRootPart.CFrame + createVector(0, 5, 0)
			}):Play()
			task.wait(0.2)

			for _, child in clone:GetChildren() do
				local manualWeld = child:FindFirstChildWhichIsA("ManualWeld")

				if manualWeld then
					manualWeld:Destroy()
				end

				child.CollisionGroup = "Effects"
				child.CanCollide = true
				child.Velocity = Vector3.new(0, math.random(60, 80), 0)
				local v4 = child
				task.delay(math.random(150, 200) / 100, function()
					v2:PlaySound(sounds.Megumi.Rabbit.Despawn, humanoidRootPart, game.SoundService.Effect)
					TweenService:Create(v4, TweenInfo.new(0.5), {
						Size = v4.Size * createVector(0, 1, 1),
						Color = Color3.new(0, 0, 0)
					}):Play()
					task.wait(0.5)
					TweenService:Create(v4, TweenInfo.new(0.5), {
						Transparency = 1
					}):Play()
				end)
			end
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
	v = Knit.GetService("RabbitEscapeService")
	v2 = Knit.GetController("FXController")
end

return controller