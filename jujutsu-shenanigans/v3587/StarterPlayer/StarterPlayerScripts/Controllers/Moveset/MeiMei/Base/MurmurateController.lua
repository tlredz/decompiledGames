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
	Name = "MurmurateController"
})
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }

function controller.KnitStart(_)
	local v3 = 1
	local v4 = {
		Flight = function(instance, instance2, object)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			instance:FindFirstChild("Humanoid")

			if instance == localPlayer.Character then
				local lastTime = tick()
				local v5 = 0.55
				local v6 = 40
				local total = 80
				local lookVector = humanoidRootPart.CFrame.LookVector
				local _ = humanoidRootPart.CFrame.RightVector
				local unit = (lookVector + createVector(0, 1, 0)).Unit
				local unit2 = (lookVector - createVector(0, 1, 0)).Unit
				local unit3 = (lookVector - createVector(0, 20, 0)).Unit
				local v7 = 1
				local bodyGyro = Instance.new("BodyGyro")
				bodyGyro.P = 10000
				bodyGyro.MaxTorque = createVector(40000, 40000, 40000)
				bodyGyro.CFrame = CFrame.lookAt(createVector(0, 0, 0), unit)
				bodyGyro.Parent = humanoidRootPart
				local heartbeatConnection = nil
				heartbeatConnection = RunService.Heartbeat:Connect(function(_)
					if instance2 and instance2.Parent and humanoidRootPart.Parent then
						local v8 = math.clamp((tick() - lastTime) / v5, 0, 1)
						local unit4

						if v7 == 1 then
							unit4 = unit:Lerp(unit2, v8).Unit

							if v8 >= 1 then
								v7 = 2
								lastTime = tick()
								v6 = total
								total += 125
								v5 = 1.25
							end
						else
							unit4 = unit2:Lerp(unit3, v8).Unit
						end

						local v9 = v6 + (total - v6) * v8
						local cframe = CFrame.lookAt(createVector(0, 0, 0), unit4)
						workspace:Raycast(
							(humanoidRootPart.CFrame * CFrame.new(0, 0, -2)).Position,
							instance2.Velocity.Unit * 6,
							raycastParams
						)
						bodyGyro.CFrame = CFrame.lookAt(createVector(0, 0, 0), unit4 * createVector(1, 0, 1))
						instance2.Velocity = cframe.LookVector * v9

						if instance2.Velocity.Y > 0 then
							return
						end

						local raycastResult = workspace:Raycast(
							(humanoidRootPart.CFrame * CFrame.new(0, 0, -7)).Position,
							(instance2.Velocity * createVector(0, 1, 0)).Unit * 6,
							raycastParams
						)
						local v10

						if not raycastResult then
							v10 = workspace:Raycast(humanoidRootPart.Position, createVector(-0, -5, -0), raycastParams)
						end

						if raycastResult or v10 or humanoidRootPart.Position.Y < -100 then
							local position = raycastResult and raycastResult.Position or (humanoidRootPart.CFrame * CFrame.new(
								0,
								0,
								-7
							)).Position - createVector(0, 3.5, 0)
							local normal = raycastResult and raycastResult.Normal or createVector(0, 1, 0)
							object:FireServer(position, normal)
							instance2:Destroy()
							bodyGyro:Destroy()
						end
					else
						heartbeatConnection:Disconnect()
						instance2:Destroy()
						bodyGyro:Destroy()
					end
				end)
			end
		end,
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.MeiMei.Murmurate.AxeThrow, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(
				sounds.MeiMei.Gliding["SpinHit" .. math.random(1, 2)],
				humanoidRootPart,
				game.SoundService.Effect
			)
			v2:Flash(instance2, Color3.new(1, 1, 1))
			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.new(0.513725, 0.643137, 1))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(30)
			clone.Wind2:Emit(7)
		end,
		Hit2 = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v2:PlaySound(sounds.MeiMei.Gliding.FallHit, humanoidRootPart2, game.SoundService.Effect)
			v2:Flash(instance2, Color3.new(1, 1, 1))
			local clone = utils.MeiMei.SlashHit:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(1.7)
			Debris:AddItem(model, 0.1)
			clone.CFrame = CFrame.lookAlong(humanoidRootPart2.Position, humanoidRootPart.CFrame.LookVector) * CFrame.Angles(
				0,
				0,
				1.5707963267948966
			)

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") and emitter.Lifetime == 0.15 then
					emitter.Lifetime = 0.25
				end
			end

			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.5)
			v2:PlayParticles(clone)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
			end
		end,
		Slash2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.MeiMei.Gliding.FallSlash, humanoidRootPart, game.SoundService.Effect)
			local clone = replicatedStorage.Utils.MeiMei.MeiMeiSlash:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(1.7)
			Debris:AddItem(model, 0.1)
			clone.Weld.Part0 = humanoidRootPart
			clone.Weld.C0 = CFrame.Angles(0, 3.141592653589793, -1.5707963267948966)

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.RotSpeed = NumberRange.new((math.abs(emitter.RotSpeed.Max)))
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			local clone2 = replicatedStorage.Utils.MeiMei.Circling.SwingMesh:Clone()
			clone2.Transparency = 0.05
			clone2.Mesh.Scale = createVector(0.25, 1, 0.25)
			clone2.Mesh.VertexColor = createVector(1.5, 1.5, 2.25)
			clone2.Weld.Part0 = humanoidRootPart
			clone2.Weld.C0 = CFrame.Angles(0, 0, -1.5707963267948966)
			TweenService:Create(clone2.Weld, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
				C0 = clone2.Weld.C0 * CFrame.Angles(0, 3.1066860685499065, 0)
			}):Play()
			TweenService:Create(clone2.Mesh, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = createVector(1, 0.25, 1)
			}):Play()
			TweenService:Create(
				clone2.Mesh,
				TweenInfo.new(0.09999999999999999, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					VertexColor = createVector(0.5, 0.5, 0.75)
				}
			):Play()
			TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.15)
			task.wait(0.3)
			clone.Weld:Destroy()
			clone.Anchored = true
		end,
		Slash = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if instance2 and not instance2:GetAttribute("Start") then
				instance2:SetAttribute("Start", true)
				v2:PlaySound(sounds.MeiMei.Gliding.Start, humanoidRootPart, game.SoundService.Effect)
			else
				v2:PlaySound(sounds.MeiMei.Gliding["Slash" .. v3], humanoidRootPart, game.SoundService.Effect)
				v3 += 1

				if v3 > 3 then
					v3 = 1
				end
			end

			local clone = utils.MeiMei.Circling.MeiMeiWideSlash3:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Weld.C0 = CFrame.new(-0.5, 0, 0) * CFrame.Angles(0, 0, -1.5707963267948966)

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			clone.Parent = workspace.Effects
			task.delay(0.25, function()
				clone.Weld:Destroy()
				clone.Anchored = true
			end)
			Debris:AddItem(clone, 1.5)

			for i = 1, 2 do
				local v5 = i == 2 and 180 or 0
				local clone2 = utils.MeiMei.Circling.SwingMesh:Clone()
				clone2.Transparency = 0.05
				clone2.Mesh.Scale = createVector(0.15, 1, 0.15)
				clone2.Mesh.VertexColor = createVector(1.5, 1.5, 2.25)
				clone2.Weld.Part0 = humanoidRootPart
				clone2.Weld.C0 = CFrame.new(-0.5, -1, 0) * CFrame.Angles(
					3.141592653589793,
					1.5707963267948966,
					3.141592653589793
				) * CFrame.Angles(0, math.rad(v5), 0) * CFrame.Angles(1.5707963267948966, 0, 0)
				TweenService:Create(clone2.Weld, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
					C0 = clone2.Weld.C0 * CFrame.Angles(0, 3.1066860685499065, 0)
				}):Play()
				TweenService:Create(clone2.Mesh, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Scale = createVector(0.5, 0.25, 0.5)
				}):Play()
				TweenService:Create(clone2.Mesh, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					VertexColor = createVector(0.5, 0.5, 0.75)
				}):Play()
				TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
					Transparency = 1
				}):Play()
				clone2.Parent = workspace.Effects
				Debris:AddItem(clone2, 0.25)
			end

			local clone2 = utils.MeiMei.Circling.WindMesh2:Clone()
			clone2.Weld.Part0 = humanoidRootPart
			clone2.Weld.C0 = CFrame.new(-0.5, -2, 0) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
			clone2.Transparency = 0.95
			clone2.Size = createVector(10, 2.5, 10)
			TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = createVector(35, 15, 35),
				Transparency = 1
			}):Play()
			TweenService:Create(clone2.Weld, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				C0 = clone2.Weld.C0 * CFrame.new(0, -0.5, 0) * CFrame.Angles(0, -3.12413936106985, 0)
			}):Play()
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.25)
		end,
		Land = function(instance, position)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = replicatedStorage.Utils.MeiMei.Slam:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(1.5)
			Debris:AddItem(model, 0.1)
			clone.CFrame = CFrame.lookAt(position, position + humanoidRootPart.CFrame.lookVector) + humanoidRootPart.CFrame.LookVector * 3
			v2:PlayParticles(clone)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			v2:PlaySound(sounds.MeiMei.Gliding.Impact, clone, game.SoundService.Effect)
			local clone2 = replicatedStorage.Utils.MeiMei.ShockwaveMesh:Clone()
			clone2.Transparency = 0
			clone2.Size = createVector(1, 0.01, 10)
			clone2.CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(-2, 2.75, -2) * CFrame.Angles(
				-1.5707963267948966,
				0,
				1.2217304763960306
			)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.new(-15, 0, -0.5),
				Size = createVector(30, 0, 5),
				Transparency = 1
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			Debris:AddItem(clone2, 1)
			local clone3 = replicatedStorage.Utils.MeiMei.ShockwaveMesh:Clone()
			clone3.Transparency = 0
			clone3.Size = createVector(1, 1, 10)
			clone3.CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(2, 2.75, -2) * CFrame.Angles(
				-1.5707963267948966,
				0,
				1.9198621771937625
			)
			clone3.Parent = workspace.Effects
			TweenService:Create(clone3, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = clone3.CFrame * CFrame.new(-15, 0, -0.5),
				Size = createVector(30, 0, 5)
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			Debris:AddItem(clone3, 1)
			local clone4 = replicatedStorage.Utils.MeiMei.WindMesh2:Clone()
			clone4.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(
				0,
				math.rad((math.random(-180, 180))),
				0
			)
			clone4.Transparency = 0.95
			clone4.Size = createVector(10, 2.5, 10)
			TweenService:Create(clone4, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = clone4.CFrame * CFrame.new(0, -0.5, 0) * CFrame.Angles(0, -3.12413936106985, 0),
				Size = createVector(35, 15, 35),
				Transparency = 1
			}):Play()
			clone4.Parent = workspace.Effects
			Debris:AddItem(clone4, 0.2)
			local clone5 = replicatedStorage.Utils.MeiMei.SpikeMesh1:Clone()
			clone5.Size = createVector(1, 20, 1)
			clone5.Transparency = 0.75
			clone5.CFrame = CFrame.new(position) * CFrame.new(0, 10, 0) * CFrame.Angles(
				0,
				math.rad((math.random(-180, 180))),
				0
			)
			TweenService:Create(clone5, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = clone5.CFrame * CFrame.new(0, -10, 0) * CFrame.Angles(0, 1.5707963267948966, 0),
				Size = createVector(20, 2.5, 20),
				Transparency = 1
			}):Play()
			clone5.Parent = workspace.Effects
			Debris:AddItem(clone5, 0.2)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Throw = function(instance, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = v2:PlaySound(sounds.MeiMei.Murmurate.AxeSpin, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.MeiMei.Murmurate:Clone()
			clone.Parent = p.Stick
			Debris:AddItem(clone, 10)

			for _, emitter in clone:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
				emitter.Lifetime = NumberRange.new(emitter.Lifetime.Min * 0.5, emitter.Lifetime.Max * 0.5)
			end

			while true do
				task.wait(0.15)

				for _, emitter in clone:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				if p2.Parent ~= nil then
					continue
				end

				for _, emitter in clone:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.LockedToPart = false
					end
				end

				TweenService:Create(v5, TweenInfo.new(0.25), {
					Volume = 0
				}):Play()
				Debris:AddItem(v5, 0.25)
				break
			end
		end,
		Catch = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.MeiMei.Murmurate.AxeCatch, humanoidRootPart, game.SoundService.Effect)
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
	v = Knit.GetService("MurmurateService")
	v2 = Knit.GetController("FXController")
end

return controller