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
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "BloodEdgeController"
})
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Spawns, workspace.Domains }

function controller.KnitStart(_)
	local v4 = {
		Draw = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Mahito.DrillSplit.Unmorph, humanoidRootPart, game.SoundService.Effect)
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Choso.BloodEdge.Dash, humanoidRootPart, game.SoundService.Effect)
		end,
		Dash = function(instance, _, object)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Mahito.CrushingRushdown.Leap, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				task.wait(0.5)

				repeat
					task.wait()
				until not object.Parent or workspace:Raycast(
					humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 1.5,
					createVector(0, -6, 0),
					raycastParams
				)

				if not object.Parent then
					return
				end

				object:FireServer(humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 1.5)
			end
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Choso.BloodEdge.StabHit, humanoidRootPart, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 150 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)

				for _ = 1, 2 do
					BloodyZee:Blood(instance.Torso.CFrame, math.random(40, 90), 45, 45)
				end
			end
		end,
		FinalHit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Itadori.CursedStrikes.Hit, humanoidRootPart, game.SoundService.Effect)
		end,
		Crush = function(p, position)
			local clone = utils.Itadori.CrushingBlow:Clone()
			clone.Position = position
			clone.PointLight:Destroy()
			clone.Air:Destroy()
			clone.Parent = workspace.Effects
			clone.Floor.Wind2.Color = ColorSequence.new(Color3.new(1, 0, 0))
			clone.Floor.Sparks.Color = ColorSequence.new(Color3.new(1, 0, 0))
			clone.Floor.Ring:Emit(10)
			clone.Floor.Sparks:Emit(10)
			clone.Floor.Wind2:Emit(8)
			Debris:AddItem(clone, 1.5)
			v3:PlaySound(sounds.Itadori.CrushingBlow.GroundImpact, clone, game.SoundService.Effect)

			if localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			local cframe = CFrame.lookAt(position + createVector(0, 5, 0), position)
			local clone2 = utils.Choso.CounterSwing:Clone()
			clone2:PivotTo(cframe * CFrame.new(2, 1, -4))

			for _, child in clone2:GetChildren() do
				child.Color = Color3.new(1, 0.5, 0.5)
			end

			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.3)
			TweenService:Create(clone2.Shock, TweenInfo.new(0.2), {
				Size = createVector(0, 25, 0),
				Transparency = 1
			}):Play()
			TweenService:Create(clone2.Shock2, TweenInfo.new(0.3), {
				Size = createVector(8, 0, 8),
				Transparency = 1,
				Position = clone2.Shock2.Position + cframe.LookVector * 3
			}):Play()
			TweenService:Create(clone2.Shockwave, TweenInfo.new(0.3), {
				Size = createVector(0, 30, 0),
				Transparency = 1,
				CFrame = clone2.Shockwave.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
			}):Play()
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
	v = Knit.GetService("BloodEdgeService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller