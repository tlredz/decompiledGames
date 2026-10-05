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
local BloodyZee = require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "HanamiController"
})

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function quadraticBezier(p, p2, p3, p4)
	local v4 = p + (p2 - p) * p4
	return v4 + (p2 + (p3 - p2) * p4 - v4) * p4
end

local v4 = { Color3.fromRGB(86, 66, 54), Color3.fromRGB(76, 60, 51), Color3.fromRGB(86, 60, 51) }
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }

function controller.KnitStart(_)
	local v5 = {
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit" .. p), humanoidRootPart, game.SoundService.Effect)
		end,
		ChaseHit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit3"), humanoidRootPart2, game.SoundService.Effect)
			local clone = utils.ChaseHit:Clone()
			clone.CFrame = CFrame.new(
				humanoidRootPart2.Position,
				(Vector3.new(humanoidRootPart.Position.X, humanoidRootPart2.Position.Y, humanoidRootPart.Position.Z))
			) * CFrame.Angles(0, 3.141592653589793, 0)
			clone.Parent = workspace.Effects
			clone.Ring:Emit(7)
			clone.Sparks:Emit(12)
			Debris:AddItem(clone, 0.5)
		end,
		AerialHit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart2, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			local cframe = CFrame.new(humanoidRootPart.Position, humanoidRootPart2.Position - createVector(0, 4, 0))
			local clone = utils.Gojo.HardHit:Clone()
			clone.CFrame = cframe + cframe.LookVector * 4
			clone.Parent = workspace.Effects
			clone.Dust:Emit(5)
			clone.Ring:Emit(5)
			clone.Sparks:Emit(10)
			Debris:AddItem(clone, 0.5)
		end,
		Chase = function(p)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 1, -4)
			clone.Size = createVector(0, 0, 2)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(9, 9, 0),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 0.3)
			v3:PlaySound(sounds.Misc.Chase, humanoidRootPart, game.SoundService.Effect)
			v3:DustTrail(p, 0.4, CFrame.Angles(0, -1.5707963267948966, 0))
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
		end,
		Swing2 = function(instance, p, p2)
			if p2 == "Down" then
				v3:ArmFlash(instance["Right Leg"], Color3.fromRGB(172, 203, 163), 0.4)
			elseif p == 1 and instance:GetAttribute("InUlt") then
				v3:ArmFlash(instance["Left Arm"], Color3.fromRGB(172, 203, 163), 0.3)
			else
				v3:ArmFlash(instance["Right Arm"], Color3.fromRGB(172, 203, 163), 0.3)
			end
		end,
		Launch = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone.Size = createVector(0, 0, 5)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(8, 8, 0),
				Transparency = 1,
				Position = clone.Position + Vector3.new(0, p, 0)
			}):Play()
			Debris:AddItem(clone, 0.3)

			if p < 0 then
				v3:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, humanoidRootPart, game.SoundService.Effect)
				v3:DustBreak(humanoidRootPart.Position + createVector(0, 2, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)

				if localPlayer:DistanceFromCharacter(humanoidRootPart.Position) < 20 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				end
			end
		end,
		ApplyDaze = function(instance, instance2)
			local torso = instance:FindFirstChild("Torso")

			if not torso then
				return
			end

			local clone = utils.Hanami.Petals:Clone()
			clone.Parent = workspace.Effects
			clone.Weld.Part0 = torso
			instance2.Destroying:Once(function()
				for _, v6 in clone:QueryDescendants("ParticleEmitter") do
					v6.Enabled = false
				end

				Debris:AddItem(clone, 2)
			end)

			while instance2.Parent do
				v3:Flash(instance, Color3.fromRGB(255, 170, 255), 8)
				clone.Root.Ring:Emit(2)
				task.wait(8)
			end
		end,
		ApplyBud = function(instance, instance2)
			local torso = instance:FindFirstChild("Torso")

			if not torso then
				return
			end

			local clone = utils.Hanami.Buds:Clone()
			clone.Parent = workspace.Effects
			clone.Weld.Part0 = torso
			clone.Root.Sparks:Emit(10)
			task.spawn(function()
				local C1 = clone.Weld.C1

				repeat
					for _, child in clone.Buds:GetChildren() do
						if tonumber(child.Name) > instance2.Value then
							child:Destroy()
						end
					end

					for i = 1, instance2.Value do
						if clone.Buds:FindFirstChild(i) then
							continue
						end

						local clone2 = clone.Buds["1"]:Clone()
						clone2.Name = i
						clone2.Weld.C0 = CFrame.new(math.random(-5, 5) / 10, math.random(-5, 5) / 10, 0) * CFrame.Angles(
							math.rad((math.random(-45, 45))),
							math.rad((math.random(-45, 45))),
							(math.rad((math.random(0, 360))))
						)
						clone2.Parent = clone.Buds
					end

					clone.Weld.C1 = C1 * CFrame.Angles(
						math.rad((math.random(-7, 7))),
						math.rad((math.random(-7, 7))),
						(math.rad((math.random(-5, 5))))
					)
					task.wait(0.05)
				until not clone.Parent
			end)
			instance2.Destroying:Once(function()
				clone.Root.Charge.Enabled = false
				clone.Root.Sparks:Emit(10)
				Debris:AddItem(clone, 1)
				clone.Buds:Destroy()
			end)
		end,
		Field = function(instance, p)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local raycastResult = workspace:Raycast(
				p.Position + p.lookVector * 1,
				createVector(0, -12, 0),
				_G.MapParams
			)

			if raycastResult then
				local clone = utils.Hanami.FlowerField:Clone()
				clone.CFrame = p - p.Position + raycastResult.Position + createVector(0, 0.3, 0)
				clone.Parent = workspace.Effects
				v3:PlaySound(sounds.Hanami.FlowersField.Field, clone, game.SoundService.Effect)
				local cFrame = clone.CFrame
				local v6 = clone.CFrame + p.lookVector * 24
				local lastTime = tick()

				while true do
					local lerped = cFrame:Lerp(v6, (math.clamp((tick() - lastTime) / 0.3, 0, 1)))
					local raycastResult2 = workspace:Raycast(
						lerped.Position + createVector(0, 2, 0),
						createVector(0, -12, 0),
						_G.MapParams
					)

					if raycastResult2 then
						clone.CFrame = CFrame.lookAlong(
							raycastResult2.Position + createVector(0, 0.3, 0),
							lerped.LookVector
						)
					end

					task.wait()

					if not (tick() - lastTime > 0.3) then
						continue
					end

					for _, emitter in clone:GetDescendants() do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					task.wait(2)
					clone:Destroy()
					break
				end
			end
		end,
		FieldStart = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Hanami.FlowersField.Startup, humanoidRootPart, game.SoundService.Effect)
		end,
		FlowersFieldHit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Hanami.FlowersField.Hit, humanoidRootPart, game.SoundService.Effect)
		end,
		Lasso = function(p, data, data2)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			local lookVector = data2.lookVector
			local rightVector = data2.rightVector
			local raycastResult = workspace:Raycast(
				data2.Position + rightVector * 3 - lookVector * 4,
				createVector(0, -12, 0),
				_G.MapParams
			)

			if raycastResult then
				local random = Random.new()
				local position = raycastResult.Position
				local position2 = raycastResult.Position
				local position3 = raycastResult.Position
				local color = v4[random:NextInteger(1, #v4)]
				local v7 = data2 * CFrame.new(0, 1, -40)
				v3:DustBreak(raycastResult.Position + createVector(0, 2, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)
				v3:PlaySound(sounds.Hanami.AOESpikes.WoodBallsAppear, humanoidRootPart, game.SoundService.Effect)
				v3:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, humanoidRootPart, game.SoundService.Effect)
				local v8 = position
				local v9 = {}
				local preRenderConnection = nil
				local preRenderConnection2 = nil
				local preRenderConnection3 = nil
				local preRenderConnection4 = nil

				for i = 1, 8 do
					local v10 = i / 8
					local v11 = v10 * -0.9 + 1.3
					local v12 = position3
					local v13 = position2
					local v14 = position + (v12 - position) * v10
					local v15 = v14 + (v12 + (v13 - v12) * v10 - v14) * v10
					local part = Instance.new("Part")
					part.Name = i
					part.CanCollide = false
					part.Transparency = 0
					part.Anchored = true
					part.Color = v4[random:NextInteger(1, #v4)]
					part.Material = Enum.Material.Wood
					part.CFrame = CFrame.new(v15, v8) * CFrame.new(0, 0, -(v8 - v15).Magnitude / 2)
					part.Size = vector.create(v11, v11, (v15 - v8).Magnitude * 1.25)
					v9[i] = part
					part.Parent = data.Parts
					v8 = v15
				end

				local total = 0
				local total2 = 0
				local v10 = 0.4
				local v11 = raycastResult.Position + createVector(0, 2.5, 0) + -lookVector * 10 + rightVector * 10
				local v12 = raycastResult.Position + createVector(0, 10, 0) + rightVector * 10
				local v13 = raycastResult.Position + createVector(0, 10, 0) + lookVector * 10
				local v14 = raycastResult.Position + createVector(0, 2.5, 0) + -lookVector * 10
				local v15 = false
				preRenderConnection2 = RunService.PreRender:Connect(function()
					if data.Parent then
						if v15 == false and data.Grab.Value then
							v15 = true
						end
					else
						if preRenderConnection then
							preRenderConnection:Disconnect()
							preRenderConnection = nil
						end

						if preRenderConnection2 then
							preRenderConnection2:Disconnect()
							preRenderConnection2 = nil
						end

						if preRenderConnection3 then
							preRenderConnection3:Disconnect()
							preRenderConnection3 = nil
						end

						if preRenderConnection4 then
							preRenderConnection4:Disconnect()
							preRenderConnection4 = nil
						end
					end

					local v16 = position

					for i, v17 in ipairs(v9) do
						local v18 = i / #v9
						local position4 = position
						local v20 = position3
						local v21 = position2
						local v22 = position4 + (v20 - position4) * v18
						local v23 = v22 + (v20 + (v21 - v20) * v18 - v22) * v18
						local magnitude = (v23 - v16).Magnitude
						v17.CFrame = CFrame.new(v23, v16) * CFrame.new(0, 0, -magnitude / 2)
						v17.Size = vector.create(v17.Size.X, v17.Size.Y, magnitude * 1.25)
						v16 = v23
					end
				end)
				preRenderConnection3 = RunService.PreRender:Connect(function(dt)
					total += dt
					local v16 = math.min(total / 0.2, 1)
					local v17 = position3
					local v18 = v11
					local v20 = v17 + (v18 - v17) * v16
					position3 = v20 + (v18 + (v12 - v18) * v16 - v20) * v16

					if v16 >= 1 then
						preRenderConnection3:Disconnect()
						preRenderConnection3 = nil
					end
				end)
				preRenderConnection4 = RunService.PreRender:Connect(function(dt)
					total2 += dt
					local v16 = math.min(total2 / v10, 1)
					local v17 = position2
					local v18 = v13
					local v20 = v17 + (v18 - v17) * v16
					position2 = v20 + (v18 + (v14 - v18) * v16 - v20) * v16

					if v16 >= 1 then
						preRenderConnection4:Disconnect()
						preRenderConnection4 = nil
					end
				end)
				task.wait(0.2)
				v3:PlaySound(sounds.Hanami.DefenseResponse.Startup, humanoidRootPart, game.SoundService.Effect)

				if preRenderConnection3 then
					preRenderConnection3:Disconnect()
				end

				if preRenderConnection4 then
					preRenderConnection4:Disconnect()
				end

				total = 0
				local v17 = (v12 + v7.Position) / 2 - rightVector * 2.5
				preRenderConnection3 = RunService.PreRender:Connect(function(dt)
					total += dt
					local v18 = math.min(total / 0.2, 1)
					local v19 = position3
					local v20 = v17
					local position4 = v7.Position
					local v21 = v19 + (v20 - v19) * v18
					position3 = v21 + (v20 + (position4 - v20) * v18 - v21) * v18
				end)
				total2 = 0
				local v19 = (v12 + v7.Position) / 2 + createVector(0, 5, 0) + rightVector * 10
				preRenderConnection4 = RunService.PreRender:Connect(function(dt)
					total2 += dt
					local v20 = math.min(total2 / v10, 1)
					local v21 = position2
					local v22 = v19
					local position4 = v7.Position
					local v23 = v21 + (v22 - v21) * v20
					position2 = v23 + (v22 + (position4 - v22) * v20 - v23) * v20
				end)
				task.wait(0.1)

				if v15 and data.Grab.Value then
					v10 = 0.13333333333333333
					local value = data.Grab.Value
					local v20 = {}

					for i = 1, 2 do
						local part = Instance.new("Part")
						part.Name = "StrangleRoot" .. i
						part.CanCollide = false
						part.Anchored = false
						part.Massless = true
						part.Color = color
						part.Material = Enum.Material.Wood
						part.Size = createVector(1, 0.5, 1.5)
						part.CFrame = value.HumanoidRootPart.CFrame * CFrame.new(0, 1, 0)

						if i == 2 then
							part.CFrame *= CFrame.new(0, 0.25, 0) * CFrame.Angles(0, 0, 0.2617993877991494)
						end

						TweenService:Create(part, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
							Size = createVector(2.3, 0.6, 1.5)
						}):Play()
						part.Parent = data.Parts
						local weldConstraint = Instance.new("WeldConstraint")
						weldConstraint.Part0 = value.HumanoidRootPart
						weldConstraint.Part1 = part
						weldConstraint.Parent = part
						table.insert(v20, part)
					end

					local part = Instance.new("Part")
					part.Name = "WrappingRoot"
					part.CanCollide = false
					part.Anchored = true
					part.Color = color
					part.Material = Enum.Material.Wood
					part.Size = createVector(1, 7, 1)
					part.CFrame = CFrame.lookAt(
						value.HumanoidRootPart.CFrame * CFrame.new(0, 3, 3).Position,
						value.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0).Position
					)
					part.Parent = data.Parts
					TweenService:Create(part, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Size = createVector(0.5, 0, 0.5)
					}):Play()
					local v21 = nil
					local v22 = 0
					local total3 = 0
					preRenderConnection = RunService.PreRender:Connect(function(dt)
						v21 = part.Size.Y / 1.5
						local position4 = (value.HumanoidRootPart.CFrame * CFrame.new(
							0,
							value.HumanoidRootPart.Size.Y / 2,
							0
						)).Position
						v22 -= 40 * dt
						total3 += 20 * dt
						local v23 = position4 + vector.create(
							math.cos(v22) * v21,
							math.cos(total3) * 0.5,
							math.sin(v22) * v21
						)
						local position5 = (value.HumanoidRootPart.CFrame * CFrame.new(0, 1, 0)).Position
						part.CFrame = CFrame.lookAt(v23, position5) * CFrame.Angles(0, 0, 0.7853981633974483) * CFrame.Angles(
							1.5707963267948966,
							0,
							0
						)
						v7 = CFrame.new(value.HumanoidRootPart.CFrame.Position) * CFrame.new(
							0,
							value.HumanoidRootPart.Size.Y / 2,
							0
						)
					end)
				end
			end
		end,
		LassoFail = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Hanami.RootDisappear, humanoidRootPart, game.SoundService.Effect)
			local particleDissipationHolder = replicatedStorage.Utils.Hanami.ParticleDissipationHolder

			for _, child in p.Parts:GetChildren() do
				for _, child2 in particleDissipationHolder:GetChildren() do
					local clone = child2:Clone()
					clone.Shape = Enum.ParticleEmitterShape.Box
					clone.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, child.Size.X * 2, 0),
						NumberSequenceKeypoint.new(1, child.Size.X * 2, 0)
					})
					clone.Parent = child
				end

				v3:PlayParticles(child)
				child.Transparency = 1
			end
		end,
		GrappleHit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart, game.SoundService.Effect)
		end,
		UppercutSpike = function(p, p2, instance)
			local raycastResult = workspace:Raycast(p.Position, createVector(0, -12, 0), _G.MapParams)

			if not raycastResult then
				return
			end

			local clone = utils.Hanami.UppercutRoot:Clone()
			clone.CFrame = p - p.Position + raycastResult.Position - createVector(0, 7, 0)
			clone.Parent = workspace.Effects

			for i = 1, 5 do
				local clone2 = utils.Hanami.ParticleDissipationHolder:Clone()
				clone2.BlackDust.Size = NumberSequence.new(4 - i / 2, 7 - i / 2)
				clone2.RedDust1.Size = clone2.BlackDust.Size
				clone2.RedDust2.Size = clone2.BlackDust.Size
				clone2.Position = Vector3.new(0, i * 2.5 + -6, 0)
				clone2.Parent = clone
			end

			v3:DustBreak(raycastResult.Position + createVector(0, 2, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)

			if p2 == nil then
				v3:PlaySound(sounds.Hanami.Uppercut, clone, game.SoundService.Effect)
			elseif p2 == true then
				v3:PlaySound(sounds.Hanami.AOESpikes.Spikes, clone, game.SoundService.Effect)
			elseif p2 == 2 then
				v3:PlaySound(sounds.Hanami.DefenseResponse.Root, clone, game.SoundService.Effect)
			end

			TweenService:Create(clone, TweenInfo.new(0.2), {
				Position = raycastResult.Position + createVector(0, 6, 0)
			}):Play()
			task.wait(0.5)

			if instance and instance:GetAttribute("Dead") then
				tick()

				repeat
					task.wait()
				until instance.Parent == nil
			end

			TweenService:Create(clone, TweenInfo.new(0.2), {
				Transparency = 1
			}):Play()
			v3:PlayParticles(clone)
			v3:PlaySound(sounds.Hanami.RootDisappear, clone, game.SoundService.Effect)
			Debris:AddItem(clone, 1)
		end,
		DownslamRoot = function(p)
			if workspace:Raycast(p.Position, createVector(0, -12, 0), _G.MapParams) then
			end
		end,
		Pierced = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Hiromi.Stab, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 40 do
				BloodyZee:Blood(instance.Torso.CFrame, math.random(-150, -5), 25, 25)
			end

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 70 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
			end
		end,
		EmpowerStart = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local leftArm

			if p then
				leftArm = instance["Left Arm"] or humanoidRootPart
			else
				leftArm = humanoidRootPart
			end

			local clone = replicatedStorage.Utils.Hanami.EmpowerCharge:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -3 * instance:GetScale(), 0) * CFrame.new(0, 0.1, 0)
			local raycastResult = workspace:Raycast(leftArm.Position, createVector(-0, -20, -0), raycastParams)

			if raycastResult then
				clone.Position = raycastResult.Position + createVector(0, 0.1, 0)
			end

			TweenService:Create(clone.PointLight, TweenInfo.new(0.7), {
				Brightness = 5
			}):Play()
			clone.Charge.Ring:Emit(1)
			Debris:AddItem(clone, 4)
			instance2:GetPropertyChangedSignal("Value"):Connect(function()
				TweenService:Create(clone.PointLight, TweenInfo.new(0.4), {
					Brightness = 0
				}):Play()
				clone.Charge.Light:Emit(1)
			end)
			instance2.Destroying:Connect(function()
				if instance2.Value == true then
					return
				end

				clone:Destroy()
			end)
			v3:PlaySound(sounds.Hanami.EmpowerStart, humanoidRootPart, game.SoundService.Effect)

			while true do
				task.wait()
				local raycastResult2 = workspace:Raycast(leftArm.Position, createVector(-0, -20, -0), raycastParams)

				if raycastResult2 then
					clone.Position = raycastResult2.Position + createVector(0, 0.1, 0)
				end

				if not (instance2.Parent == nil or instance2.Value == true) then
					continue
				end

				v3:PlaySound(sounds.Hanami.Empower, humanoidRootPart, game.SoundService.Effect)
				break
			end
		end,
		Chat = function(instance)
			local torso = instance:FindFirstChild("Torso")

			if not torso then
				return
			end

			v3:PlaySound(sounds.Hanami.Awaken, torso, game.SoundService.Effect)
			local clone = utils.Hanami.Dialogue:Clone()
			clone.Parent = torso
			local position = clone.Chat1.Position
			clone.Chat1.Position = position - UDim2.new(0, 0, 0.15, 0)
			TweenService:Create(clone.Chat1, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = position
			}):Play()
			TweenService:Create(clone.Chat1, TweenInfo.new(0.3), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(clone.Chat1.Sub, TweenInfo.new(0.3), {
				TextTransparency = 0
			}):Play()
			task.wait(1.1)
			local position2 = clone.Chat2.Position
			clone.Chat2.Position = position2 - UDim2.new(0, 0, 0.15, 0)
			TweenService:Create(clone.Chat2, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = position2
			}):Play()
			TweenService:Create(clone.Chat2, TweenInfo.new(0.3), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(clone.Chat2.Sub, TweenInfo.new(0.3), {
				TextTransparency = 0
			}):Play()
			task.wait(1.1)
			Debris:AddItem(clone, 0.6)

			for _, guiObject in clone:GetDescendants() do
				if guiObject:IsA("Frame") then
					TweenService:Create(guiObject, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Position = guiObject.Position - UDim2.new(0, 0, 0.2, 0),
						BackgroundTransparency = 1
					}):Play()
				elseif guiObject:IsA("TextLabel") then
					TweenService:Create(guiObject, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						TextTransparency = 1
					}):Play()

					if guiObject:FindFirstChild("UIStroke") then
						TweenService:Create(
							guiObject:FindFirstChild("UIStroke"),
							TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
							{
								Transparency = 1
							}
						):Play()
					end
				end
			end
		end,
		RipSound = function(instance)
			local torso = instance:FindFirstChild("Torso")

			if not torso then
				return
			end

			v3:PlaySound(sounds.Hanami.ArmWrapRip, torso, game.SoundService.Effect)

			for _, child in utils.Misc.M.Awk.mokultMeh["3"]:GetChildren() do
				child:PivotTo(instance.HumanoidRootPart.CFrame)
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
			end
		end,
		BeamOffCD = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 0.498039), 0.5)
			local clone = replicatedStorage.Utils.Hanami.EmpowerAura:Clone()
			clone.Parent = humanoidRootPart
			clone.HanamiAuraBurst:Emit(1)
			v3:PlaySound(sounds.Hanami.Empower, humanoidRootPart, game.SoundService.Effect)
			Debris:AddItem(clone, 1)
		end,
		PlantGuide = function(p)
			p.Ring:Emit(1)
			p.Shine.Enabled = true
		end
	}
	v.Effects:Connect(function(p, ...)
		local v6 = v5[p]

		if not v6 then
			return
		end

		v6(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("HanamiService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller