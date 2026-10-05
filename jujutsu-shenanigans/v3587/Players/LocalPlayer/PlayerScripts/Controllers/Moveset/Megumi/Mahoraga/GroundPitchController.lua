local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local _ = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "GroundPitchController"
})
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Spawns, workspace.Domains }

function controller.KnitStart(_)
	local v3 = {
		Crunch = function(instance, part, list)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local tweenInfo = TweenInfo.new(0.5)
			local count = #list
			local magnitude = (workspace.CurrentCamera.CFrame.Position - part.Position).Magnitude

			if magnitude < 40 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			task.delay(0.3, function()
				if part.Parent and humanoidRootPart.Parent then
					v2:PlaySound(sounds.Megumi.Mahoraga.Throw.Wind, humanoidRootPart, game.SoundService.Effect)
				end
			end)

			if magnitude > 75 then
				return
			end

			for _, v4 in list do
				local part2 = Instance.new("Part")
				part2.CanCollide = false
				part2.Massless = true
				part2.Position = v4[1]
				part2.Orientation = v4[2]
				part2.Color = v4[3]
				part2.Material = v4[4]
				part2.Size = v4[5]
				part2.Transparency = v4[6]
				part2.Parent = part.Rocks
				local weld = Instance.new("Weld")
				weld.C1 = part.CFrame:ToObjectSpace(part2.CFrame)
				weld.Part1 = part2
				weld.Part0 = part
				weld.Parent = part2
				TweenService:Create(weld, tweenInfo, {
					C1 = CFrame.new(
						math.random(-count, count) / 20,
						math.random(-count, count) / 20,
						math.random(-count, count) / 20
					) * CFrame.Angles(
						math.rad((math.random(0, 360))),
						math.rad((math.random(0, 360))),
						(math.rad((math.random(0, 360))))
					)
				}):Play()
			end

			part.Destroying:Connect(function()
				local ring = part.Ring
				local clone = utils.Megumi.Mahoraga.Rock:Clone()
				clone.Transparency = 1
				clone.Anchored = true
				clone.CFrame = part.CFrame
				clone.Parent = workspace.Effects
				ring.Parent = clone
				clone.Attachment.Dust:Emit(20)
				clone.Attachment.Hit:Emit(20)
				clone.Attachment.Sparks:Emit(20)
				Debris:AddItem(clone, 1.5)
				v2:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, clone, game.SoundService.Effect)
				local magnitude2 = (workspace.CurrentCamera.CFrame.Position - part.Position).Magnitude

				if magnitude2 < 40 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				end

				if magnitude2 < 100 then
					local tweenInfo2 = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

					for i, child in part.Rocks:GetChildren() do
						if i > 25 then
							continue
						end

						child.CanCollide = true
						child.CollisionGroup = "Effects"
						child.Parent = workspace.Effects
						Debris:AddItem(child, 3)
						TweenService:Create(child, tweenInfo2, {
							Size = createVector(0, 0, 0)
						}):Play()
					end
				end
			end)
		end,
		Throw = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Megumi.Mahoraga.Throw.Throw, humanoidRootPart, game.SoundService.Effect)
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
						{ cFrame + cFrame.LookVector * (150 * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
			end)
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.M1:FindFirstChild("Hit1"), humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Itadori.Rush.RushHit, humanoidRootPart, game.SoundService.Effect)
		end,
		Finisher = function(p)
			if not p.HumanoidRootPart then
				return
			end

			v2:Bleed(p)
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
	v = Knit.GetService("GroundPitchService")
	v2 = Knit.GetController("FXController")
end

return controller