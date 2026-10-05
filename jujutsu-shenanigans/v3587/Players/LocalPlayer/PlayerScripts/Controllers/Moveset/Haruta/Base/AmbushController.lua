local createVector = vector.create
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
local BloodyZee = require(replicatedStorage.Modules.BloodyZee)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "StingerController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local harutaSword = instance.SetAssets:FindFirstChild("HarutaSword")

			if harutaSword then
				local clone = utils.Haruta.CombatTrail:Clone()
				clone.Weld.Part0 = harutaSword.Blade
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 0.7)
				task.delay(0.5, function()
					clone.Trail.Enabled = false
					TweenService:Create(clone, TweenInfo.new(0.1), {
						Transparency = 1
					}):Play()
				end)
			end

			v2:PlaySound(sounds.Haruta.AmbushSwing, humanoidRootPart, game.SoundService.Effect)
		end,
		Whoosh = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Haruta.Backstab, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Choso.CounterSwing:Clone()
			clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -6, -6) * CFrame.Angles(
				-0.7853981633974483,
				0.17453292519943295,
				0
			))
			clone.Parent = workspace.Effects
			clone.Shockwave:Destroy()
			Debris:AddItem(clone, 0.3)
			clone.Shock.Size = createVector(10, 2, 10)
			TweenService:Create(clone.Shock, TweenInfo.new(0.125), {
				Size = createVector(2, 15, 2),
				Transparency = 1,
				Position = clone.Shock2.Position + humanoidRootPart.CFrame.LookVector * 3
			}):Play()
			TweenService:Create(clone.Shock2, TweenInfo.new(0.1), {
				Size = createVector(8, 0, 8),
				Transparency = 1,
				Position = clone.Shock2.Position + humanoidRootPart.CFrame.LookVector * 3
			}):Play()
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

			if instance == localPlayer.Character or instance2 == localPlayer.Character then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.MediumHit)
			end

			local clone = utils.Yuta.SlashHit:Clone()
			clone.CFrame = CFrame.lookAlong(humanoidRootPart2.Position, humanoidRootPart.CFrame.LookVector)

			if p then
				clone.CFrame = CFrame.lookAlong(
					(instance2.Torso.CFrame * CFrame.new(0, 1, 0)).Position,
					humanoidRootPart.CFrame.LookVector
				)
				clone.CFrame *= CFrame.Angles(0, 0, -0.4363323129985824)
			else
				clone.CFrame *= CFrame.Angles(0, 0, -0.7853981633974483)
			end

			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.5)
			clone.Slash:Emit(5)
			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Haruta.AmbushHit, humanoidRootPart2, game.SoundService.Effect)
		end,
		Stab = function(instance, instance2, _)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance2, Color3.new(0.745098, 0, 0.0117647))

			if instance == localPlayer.Character or instance2 == localPlayer.Character then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.MediumHit)
			end

			local playSound = v2:PlaySound(sounds.Choso.BloodEdge.StabHit, humanoidRootPart, game.SoundService.Effect)
			playSound.PlaybackSpeed = math.random(90, 110) / 100

			for _ = 1, 8 do
				BloodyZee:Blood(
					CFrame.lookAt(instance2.Torso.Position, instance2.Torso.Position + createVector(0, 10, 0)),
					math.random(20, 40),
					math.random(20, 40),
					math.random(20, 40)
				)
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
	v = Knit.GetService("AmbushService")
	v3 = Knit.GetController("HitboxController")
	v2 = Knit.GetController("FXController")
end

return controller