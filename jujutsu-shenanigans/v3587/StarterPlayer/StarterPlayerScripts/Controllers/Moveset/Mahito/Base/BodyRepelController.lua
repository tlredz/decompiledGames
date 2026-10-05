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
	Name = "BodyRepelController"
})

function controller.KnitStart(_)
	local v3 = {
		Start = function(instance, parent)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Mahito.BodyRepel.Start, humanoidRootPart, game.SoundService.Effect)

			for _, child in replicatedStorage.Utils.Mahito.BodyRepel.BodyRepelStart:GetChildren() do
				local clone = child:Clone()
				clone[child.Name].Part0 = humanoidRootPart
				clone.Parent = parent
				task.wait(0.03)
			end
		end,
		Clap = function(instance, parent)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.BodyRepel.BodyCreate:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -3)
			clone.Weld.C0 = CFrame.new(0, 0, -3)
			clone.Color = utils.Mahito.BodyRepel.BodyRepel.Body1.Color
			clone.Weld.Part0 = humanoidRootPart
			clone.Parent = parent

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end

			clone.Attachment.Glow:Emit(1)
			clone.Attachment.Wind:Emit(8)
			clone.Attachment.Wind2:Emit(8)
			v2:PlaySound(sounds.Mahito.BodyRepel.Clap, humanoidRootPart, game.SoundService.Effect)
			TweenService:Create(clone.Weld, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				C0 = CFrame.new(0, 0, -10)
			}):Play()
			TweenService:Create(clone.Weld, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {
				C1 = CFrame.Angles(3.141592653589793, 3.141592653589793, 0)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = createVector(3, 3, 3)
			}):Play()
			task.wait(0.2)
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Size = createVector(10, 10, 25)
			}):Play()
			parent.Destroying:Connect(function()
				clone.Size = createVector(15, 15, 25)
				clone.Parent = workspace.Effects
				TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Size = createVector(0, 0, 0)
				}):Play()
				Debris:AddItem(clone, 0.1)

				for _ = 1, 20 do
					local clone2 = utils.Mahito.Morph:Clone()
					clone2.Color = clone.Color
					clone2.CFrame = clone.CFrame * CFrame.new(
						math.random(-clone.Size.X, clone.Size.X) / 2,
						math.random(-clone.Size.Y, clone.Size.Y) / 2,
						math.random(-clone.Size.Z, clone.Size.Z) / 2
					)
					clone2.Parent = workspace.Effects
					local v4 = math.random(20, 40) / 10
					clone2.Size = createVector(1, 1, 1) * v4
					clone2.Velocity = Vector3.new(math.random(-60, 60), math.random(-20, 60), math.random(-60, 60))
					TweenService:Create(
						clone2,
						TweenInfo.new(math.random(40, 60) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.In),
						{
							Size = createVector(0, 0, 0)
						}
					):Play()
					Debris:AddItem(clone2, 0.6)
				end
			end)
		end,
		Fire = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = replicatedStorage.Utils.Itadori.RushWind:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			clone.Dust:Emit(7)
			clone.Ring:Emit(7)
			clone.Dash1.Dash:Emit(1)
			clone.Dash2.Dash:Emit(1)
			Debris:AddItem(clone, 2)
			local clone2 = utils.Mahito.BodyRepel.BodyRepel:Clone()
			clone2:PivotTo(humanoidRootPart.CFrame)
			clone2.Parent = workspace.Effects
			v2:PlaySound(sounds.Mahito.BodyRepel.Fire, clone2.Head, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			local v4 = {
				clone2.Body1,
				clone2.Body2,
				clone2.Body3,
				clone2.Body4,
				clone2.Body5
			}

			for k, v5 in v4 do
				v5.CFrame = clone2.Head.CFrame - clone2.Head.CFrame.LookVector * k
			end

			task.spawn(function()
				if not p then
					return
				end

				repeat
					humanoidRootPart.CFrame = humanoidRootPart.CFrame - humanoidRootPart.Position + clone2.Head.Position
					task.wait()
				until not (humanoidRootPart.Parent and instance2.Parent)
			end)
			local v5 = false
			local now = tick()
			local position = instance2.Position
			local lastTime = tick()
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function(_, dt)
				if not clone2.Parent then
					steppedConnection:Disconnect()
					return
				end

				if instance2.Parent then
					if position == instance2.Position then
						clone2.Head.CFrame = instance2.CFrame + instance2.CFrame.LookVector * (120 * (tick() - lastTime))
					else
						position = instance2.Position
						lastTime = tick()
						clone2.Head.CFrame = instance2.CFrame
					end
				else
					clone2.Head.CFrame += clone2.Head.CFrame.LookVector * (60 * dt)
				end

				for k, v6 in v4 do
					local head = k == 1 and clone2.Head or v4[k - 1]
					local cframe = CFrame.new(head.Position, v6.Position)
					v6.CFrame = (cframe + cframe.LookVector * 7) * CFrame.Angles(0, 3.141592653589793, 0)
				end

				local now2 = tick()

				if now < now2 and v5 == false then
					local v6 = v4[math.random(1, #v4)]
					now = tick() + math.random(2, 6) / 100
					local clone3 = utils.Mahito.BodyRepel["Wind" .. math.random(1, 5)]:Clone()
					clone3.CFrame = v6.CFrame * CFrame.Angles(1.5707963267948966, math.rad((math.random(0, 360))), 0)
					TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
						CFrame = clone3.CFrame + v6.CFrame.LookVector * 10,
						Size = createVector(12, 0, 12)
					}):Play()
					Debris:AddItem(clone3, 0.3)
					clone3.Parent = workspace.Effects
					TweenService:Create(clone3, TweenInfo.new(0.15), {
						Transparency = 0
					}):Play()
					task.delay(0.15, function()
						TweenService:Create(clone3, TweenInfo.new(0.15), {
							Transparency = 1
						}):Play()
					end)
				end

				if not instance2.Parent and v5 == false then
					v5 = true
					local v6 = {
						clone2.Head,
						clone2.Body1,
						clone2.Body2,
						clone2.Body3,
						clone2.Body4,
						clone2.Body5
					}
					Debris:AddItem(clone2, 1.4)

					for _, folder in v6 do
						if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 300 then
							for _ = 1, 7 do
								local clone3 = utils.Mahito.Morph:Clone()
								clone3.Weld.Part0 = folder
								clone3.Color = folder.Color
								clone3.Weld.C1 = CFrame.new(
									math.random(-folder.Size.X, folder.Size.X) / 2,
									math.random(-folder.Size.Y, folder.Size.Y) / 2,
									math.random(-folder.Size.Z, folder.Size.Z) / 2
								)
								clone3.Parent = workspace.Effects
								local v7 = math.random(40, 80) / 10
								clone3.Size = createVector(1, 1, 1) * v7
								TweenService:Create(
									clone3,
									TweenInfo.new(
										math.random(20, 40) / 100,
										Enum.EasingStyle.Back,
										Enum.EasingDirection.In
									),
									{
										Size = createVector(0, 0, 0)
									}
								):Play()
								Debris:AddItem(clone3, 0.4)
								task.delay(0.2, function()
									clone3.Weld:Destroy()
									clone3.Velocity = Vector3.new(
										math.random(-40, 40),
										math.random(-20, 40),
										math.random(-40, 40)
									)
								end)
							end
						end

						folder.Transparency = 1

						for _, descendant in folder:GetDescendants() do
							if descendant:IsA("BasePart") or descendant:IsA("Decal") then
								descendant.Transparency = 1
							end
						end

						task.wait(0.1)
					end
				end
			end)
		end,
		Hit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Megumi.DivineAttack:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			clone.Bite:Emit(1)
			Debris:AddItem(clone, 0.2)
			v2:Flash(instance, Color3.fromRGB(255, 255, 255))
			v2:PlaySound(sounds.Hakari.EnergySurge.Hit2, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
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
	v = Knit.GetService("BodyRepelService")
	v2 = Knit.GetController("FXController")
end

return controller