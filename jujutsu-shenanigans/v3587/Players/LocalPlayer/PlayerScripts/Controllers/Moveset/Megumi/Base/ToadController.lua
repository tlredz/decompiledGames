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
	Name = "ToadController"
})
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Spawns, workspace.Domains }

function controller.KnitStart(_)
	local v3 = {
		Grab = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.CounterHit.Feint:Clone()

			for _, child in clone:GetChildren() do
				child.Color = ColorSequence.new(Color3.fromRGB(125, 45, 152))
				child.TimeScale = 0.5
			end

			clone.Parent = humanoidRootPart
			clone.Sparks:Emit(30)
			clone.Ring:Emit(6)
			Debris:AddItem(clone, 1)
		end,
		Toad = function(p, instance, position, parent)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			local clone = utils.Megumi.Spawn:Clone()
			clone.Parent = workspace.Effects
			clone.Position = position
			Debris:AddItem(clone, 3)
			clone.Shadow:Emit(12)
			clone.Dive:Emit(6)
			clone.Dive.Size = NumberSequence.new(8)
			clone.Shadow.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, 8),
				NumberSequenceKeypoint.new(0.75, 9),
				NumberSequenceKeypoint.new(1, 10)
			})
			local clone2 = utils.Megumi.Toad:Clone()
			clone2.RootPart.CFrame = CFrame.new(position)
			clone2.Parent = parent
			local track = clone2.AnimationController:LoadAnimation(clone2.AnimationController.Summon)
			track:Play(0, nil, 1.3333333333333333)
			v2:PlaySound(sounds.Megumi.Toad.Spawn, clone2.RootPart, game.SoundService.Effect)
			task.delay(0.55, function()
				if not humanoidRootPart.Parent then
					return
				end

				if (position - humanoidRootPart.Position).Magnitude > 100 then
					local _ = clone2.Position + CFrame.new(clone2.Position, humanoidRootPart.Position).LookVector * 100
				else
					local _ = humanoidRootPart.Position
				end

				TweenService:Create(
					clone2.Torso.Attachment,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{
						WorldPosition = humanoidRootPart.Position
					}
				):Play()
				v2:PlaySound(sounds.Megumi.Toad.Fly, clone2.RootPart, game.SoundService.Effect)
				task.wait(0.2)
				track:AdjustSpeed(0.9)
				TweenService:Create(
					clone2.Torso.Attachment,
					TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Position = createVector(0, 0.05, -3.9)
					}
				):Play()
				v2:PlaySound(sounds.Megumi.Toad.Flyback, clone2.RootPart, game.SoundService.Effect)
			end)
			local now = tick()
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function(_, _)
				if humanoidRootPart.Parent then
					local now2 = tick()

					if not (now + 1.2 < now2) then
						local vector2 = Vector3.new(
							humanoidRootPart.Position.X,
							clone2.RootPart.Position.Y,
							humanoidRootPart.Position.Z
						)
						clone2.RootPart.CFrame = CFrame.new(clone2.RootPart.Position, vector2)
						return
					end
				end

				steppedConnection:Disconnect()

				for _, part in clone2:GetDescendants() do
					if part:IsA("BasePart") then
						TweenService:Create(part, TweenInfo.new(0.2), {
							Color = Color3.new(0, 0, 0)
						}):Play()
					end
				end

				Debris:AddItem(clone2, 0.2)
				clone.Shadow:Emit(12)
				clone.Dive:Emit(6)
				v2:PlaySound(sounds.Megumi.Toad.Despawn, clone, game.SoundService.Effect)
			end)
		end,
		ToadAir = function(_, instance, p, parent)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			for i = 1, 10 do
				local v4 = i
				task.spawn(function()
					local v5 = 0.5 - (v4 - 1) * 0.05
					local clone = utils.Megumi.Shadow:Clone()
					clone.Parent = workspace.Effects
					clone.Dive.Enabled = false
					clone.Shadow.Enabled = false
					Debris:AddItem(clone, 5)
					local position = p + Vector3.new(math.random(-70, 70) / 10, 0, math.random(-70, 70) / 10)
					local raycastResult = workspace:Raycast(
						position + createVector(0, 4, 0),
						createVector(0, -8, 0),
						raycastParams
					)

					if raycastResult then
						position = raycastResult.Position
						clone.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal)
						clone.Shadow:Emit(4)
						clone.Dive:Emit(1)
					else
						clone.Position = position
						clone.ShadowAir:Emit(4)
					end

					local clone2 = utils.Megumi.ToadNue:Clone()
					clone2.CFrame = humanoidRootPart.CFrame - humanoidRootPart.Position + position
					clone2.Pos.Value = clone2.Position
					clone2.Parent = parent
					TweenService:Create(clone2.Pos, TweenInfo.new(v5, Enum.EasingStyle.Back), {
						Value = clone2.Position + Vector3.new(0, math.random(30, 60) / 10, 0)
					}):Play()
					Debris:AddItem(clone2, 3)
					local v6 = math.random(0, 3.141592653589793)
					v2:PlaySound(sounds.Megumi.Toad.Spawn, clone2, game.SoundService.Effect)
					local heartbeatConnection = nil
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						if not (humanoidRootPart.Parent and clone2.Parent) then
							heartbeatConnection:Disconnect()
							return
						end

						v6 += 0.2

						if v6 > 3.141592653589793 then
							v6 = 0
						end

						local v7 = math.sin(v6)
						clone2.CFrame = CFrame.new(clone2.Pos.Value, humanoidRootPart.Position)
						clone2.CFrame += Vector3.new(0, v7, 0)

						if v7 < 0 then
							v7 = -v7
						end

						clone2.Wings.Size = Vector3.new(v7 * 7, 2.8, 0.233)
					end)
					task.wait(v5)

					if (p - humanoidRootPart.Position).Magnitude > 100 then
						local v7 = clone2.Position + CFrame.new(clone2.Position, humanoidRootPart.Position).LookVector * 100
					else
						local position2 = humanoidRootPart.Position
					end

					TweenService:Create(
						clone2.Attachment,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{
							WorldPosition = humanoidRootPart.Position
						}
					):Play()
					task.wait(0.2)
					TweenService:Create(
						clone2.Attachment,
						TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							Position = createVector(0, 0.45, -0.4)
						}
					):Play()
					TweenService:Create(
						clone2.Pos,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							Value = clone2.Pos.Value + createVector(0, 2.5, 0)
						}
					):Play()
					task.wait(0.4)
					TweenService:Create(clone2.Pos, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Value = clone2.Pos.Value + Vector3.new(0, math.random(100, 200) / 10, 0)
					}):Play()
					task.wait(math.random(120, 160) / 100)
					v2:PlaySound(sounds.Megumi.Toad.Despawn, clone, game.SoundService.Effect)
					clone.Position = clone2.Position
					clone.ShadowAir:Emit(4)
					clone2:Destroy()
				end)
				task.wait(0.05)
			end
		end,
		Hit = function(_, instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local toad = instance2:FindFirstChild("Toad")

			if not toad then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Megumi.Toad.Hit, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Megumi.TongueGrab:Clone()
			clone.Weld.Part0 = humanoidRootPart
			toad.Torso.Tongue.Beam.Attachment1 = clone.Attachment
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.6)
		end,
		HitAir = function(_, instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Megumi.Toad.Hit, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Megumi.TongueGrab:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1.2)

			for _, child in instance2:GetChildren() do
				child.Tongue.Beam.Attachment1 = clone.Attachment
				local v4 = child
				task.delay(0.2, function()
					TweenService:Create(
						v4.Tongue.Beam,
						TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In),
						{
							CurveSize0 = -20
						}
					):Play()
					task.wait(0.5)
					TweenService:Create(v4.Tongue.Beam, TweenInfo.new(0.3), {
						CurveSize0 = 10
					}):Play()
					task.wait(0.5)
					v4.Attachment.WorldPosition = clone.Position
					v4.Tongue.Beam.Attachment1 = v4.Attachment
					TweenService:Create(v4.Tongue.Beam, TweenInfo.new(0.4), {
						CurveSize0 = 0
					}):Play()
					TweenService:Create(v4.Attachment, TweenInfo.new(0.4), {
						Position = v4.Tongue.Position
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
	v = Knit.GetService("ToadService")
	v2 = Knit.GetController("FXController")
end

return controller