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
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "ReserveBallController"
})

function controller.KnitStart(_)
	local v3 = {
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Itadori.DivergentFist.Swing, humanoidRootPart, game.SoundService.Effect)
		end,
		Fire = function(instance, p, folder, color)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Hakari.Indicators.BallFire:Clone()
			clone.CFrame = p * CFrame.new(0, 0, -3)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.7)
			clone.Sparks:Emit(10)
			clone.Wind:Emit(10)
			clone.Ring:Emit(1)

			if color then
				folder.Color = color

				for _, effect in folder:GetDescendants() do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Color = ColorSequence.new(color)
					end
				end

				for _, emitter in clone:GetChildren() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Color = ColorSequence.new(color)
					end
				end
			end

			v2:PlaySound(sounds.Hakari.ReserveBalls.Fire, humanoidRootPart, game.SoundService.Effect)
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
		Hit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Hakari.ReserveBalls.Impact, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Another = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v2:PlaySound(sounds.Gojo.Teleport, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Gojo.Teleport, humanoidRootPart2, game.SoundService.Effect)
			local clone = utils.Gojo.Teleport:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1.1)
			local clone2 = utils.Gojo.Teleport:Clone()
			clone2.CFrame = humanoidRootPart2.CFrame
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 1.1)
			clone.Center.Flash:Emit(1)
			clone2.Center.Flash:Emit(1)
			task.delay(0.1, function()
				clone.Floor.Dust:Emit(30)
				clone2.Floor.Dust:Emit(30)
				task.wait(0.05)
				clone.CFrame = humanoidRootPart.CFrame
				clone.Lines:Emit(30)
				clone.Floor.Dust:Emit(30)
				clone2.CFrame = humanoidRootPart.CFrame
				clone2.Lines:Emit(30)
				clone2.Floor.Dust:Emit(30)
			end)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				local clone3 = utils.Gojo.TeleportBreak:Clone()
				clone3.Parent = workspace.Effects
				Debris:AddItem(clone3, 0.8)
				local highlight = Instance.new("Highlight")
				highlight.OutlineTransparency = 1
				highlight.FillColor = Color3.new(1, 1, 1)
				highlight.FillTransparency = 0.8
				highlight.Parent = clone3
				task.spawn(function()
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)

					for _ = 1, 30 do
						local clone4 = utils.Gojo.Shard:Clone()
						clone4.CFrame = clone3.Part.CFrame * CFrame.new(
							math.random(-40, 40) / 10,
							math.random(-20, 20) / 10,
							0
						)
						clone4.CFrame *= CFrame.Angles(math.random(0, 360), math.random(0, 360), math.random(0, 360))
						clone4.Parent = clone3.Shards
						TweenService:Create(clone4, TweenInfo.new(math.random(4, 7) / 10), {
							Size = createVector(0, 0, 0)
						}):Play()
						local v4 = clone3.Part.CFrame * CFrame.Angles(math.random(0, 30), math.random(-30, 30), 0)
						clone4.RotVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.Archivable = false
						bodyVelocity.Parent = clone4
						bodyVelocity.Velocity = v4.LookVector * math.random(1, 80) / 10
					end

					repeat
						clone3:SetPrimaryPartCFrame(workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -2))

						for _, child in clone3.Shards:GetChildren() do
							child.BodyVelocity.Velocity -= createVector(0, 0.25, 0)
						end

						RunService.RenderStepped:Wait()
					until not clone3.Parent
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
	v = Knit.GetService("ReserveBallService")
	v2 = Knit.GetController("FXController")
end

return controller