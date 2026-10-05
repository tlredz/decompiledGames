local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local currentCamera = workspace.CurrentCamera
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
ReplicatedStorage:WaitForChild("OtherEvent")
local skillFolder = ReplicatedStorage:WaitForChild("SkillFolder")
local animation_Folder = ReplicatedStorage:WaitForChild("Animation_Folder")
ReplicatedStorage:WaitForChild("Modules")
local skills = workspace:WaitForChild("Skills")
local character = workspace:WaitForChild("Character")
local monster = workspace:WaitForChild("Monster")
local skill_Animation = animation_Folder:WaitForChild("Skill_Animation")
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
local Generate = require(moduleScript:WaitForChild("Generate"))
local Setting = require(moduleScript:WaitForChild("Setting"))
local setting = Setting.Setting
local Folders = {
	workspace.Skills,
	workspace.Region,
	workspace.Visuals,
	workspace.Location,
	workspace.Sea,
	workspace.Leaderboard,
	workspace.CameraFolder,
	workspace.SpawningPower,
	workspace.Character,
	workspace.Monster
}

function Generate_Clone(instance)
	if instance and instance.Parent then
		for _, part in ipairs(instance:GetChildren()) do
			if not (part:IsA("BasePart") and part.Transparency < 1) then
				continue
			end

			local part2 = Instance.new("Part")
			part2.CFrame = part.CFrame
			part2.Size = part.Size
			part2.Anchored = true
			part2.CanCollide = false
			part2.Material = Enum.Material.Neon
			part2.Transparency = 0.4
			part2.Color = Color3.fromRGB(0, 0, 0)
			part2.Massless = true
			part2.Parent = skills
			Debris:AddItem(part2, 1)
			TweenService:Create(part2, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end
	end
end

function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function Rock_Function(p, instance, _, p2, p3, _, p4, _)
	if instance and instance.Parent then
		local color

		if p4 then
			color = p4.Color
		else
			color = Color3.fromRGB(255, 255, 255)
		end

		local material

		if p4 then
			material = p4.Material
		else
			material = Enum.Material.Concrete
		end

		for i = 1, 2 do
			local clone = skillFolder[p].SideRock:Clone()
			local vector2 = Vector3.new(
				clone.Size.X * Random.new():NextNumber(5, 5.25),
				clone.Size.Y * Random.new():NextNumber(2, 2.25),
				clone.Size.Z * Random.new():NextNumber(4, 4.25)
			)
			Debris:AddItem(clone, 3)

			if i % 2 == 0 then
				clone.CFrame = instance.CFrame * CFrame.new(-p3, -p2 - 1, 0)
				clone.CFrame *= CFrame.Angles(
					math.rad((math.random(-10, 10))),
					math.rad((math.random(-0, 0))),
					(math.rad((math.random(-35, -25))))
				)
			else
				clone.CFrame = instance.CFrame * CFrame.new(p3, -p2 - 1, 0)
				clone.CFrame *= CFrame.Angles(
					math.rad((math.random(-10, 10))),
					math.rad((math.random(-0, 0))),
					(math.rad((math.random(25, 35))))
				)
			end

			clone.Size = createVector(0, 0, 0)
			clone.Parent = skills
			clone.Color = color
			clone.Material = material
			TweenService:Create(clone, TweenInfo.new(0.25), {
				Size = vector2
			}):Play()
			task.delay(1.5, function()
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(0, 0, 0),
					Transparency = 1
				}):Play()
			end)
		end
	end
end

function Side_Rocks(p, instance, _, _, _, p2, p3, p4)
	if instance and instance.Parent then
		local color

		if p3 then
			color = p3.Color
		else
			color = Color3.fromRGB(255, 255, 255)
		end

		local material

		if p3 then
			material = p3.Material
		else
			material = Enum.Material.Concrete
		end

		if p2 and p4 % 8 == 0 then
			local clone = skillFolder[p].Rocks[`Rock{math.random(1, 3)}`]:Clone()
			clone.Size *= Random.new():NextNumber(1.01, 2)
			clone.CFrame = instance.CFrame * CFrame.new(math.random(-5, 5), math.random(0, 5), math.random(-5, 5)) * CFrame.Angles(
				math.rad((math.random(-60, 60))),
				0,
				(math.rad((math.random(-60, 60))))
			)
			clone.Color = color
			clone.Material = material
			clone.Parent = skills
			clone.Start.Trail.Color = ColorSequence.new(color)
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
			bodyVelocity.P = 1000
			bodyVelocity.Velocity = clone.CFrame.UpVector * math.random(25, 75)
			bodyVelocity.Parent = clone
			Debris:AddItem(bodyVelocity, 0.2)
			task.delay(2, function()
				if clone and clone.Parent then
					clone.Start.Trail.Enabled = false
					TweenService:Create(clone, TweenInfo.new(0.5), {
						Size = createVector(0, 0, 0)
					}):Play()
					Debris:AddItem(clone, 0.5)
				end
			end)
		end
	end
end

function BlackHole_Rock(p, instance, p2, p3, p4)
	if instance and instance.Parent then
		local clone = skillFolder[p].Rock:Clone()

		if p2 == "Auto" then
			clone.CFrame = instance.CFrame * CFrame.new(
				-p3 * Random.new():NextNumber(-7.5, 7.5),
				-25,
				p3 * Random.new():NextNumber(-1.5, 1.5)
			)
		else
			clone.CFrame = instance.CFrame * CFrame.new(
				-p3 * Random.new():NextNumber(-7.5, 7.5),
				0,
				p3 * Random.new():NextNumber(-1.5, 1.5)
			)
		end

		clone.Parent = skills
		local v = math.random(-25, 25)
		local v2 = math.random(-25, 25)
		local v3 = math.random(-50, 25)
		coroutine.wrap(function()
			local position = clone.Position

			for i = 1, p4 do
				local v4 = i / p4
				local position2 = instance.Position
				local v5 = (position + position2) / 2 + Vector3.new(v, v2, v3)
				local lerped = lerp(position, v5, v4)
				local lerped2 = lerp(v5, position2, v4)
				clone.Position = lerp(lerped, lerped2, v4)
				task.wait()
			end

			if clone and clone.Parent then
				TweenService:Create(clone, TweenInfo.new(0.1), {
					Size = createVector(0, 0, 0)
				}):Play()
			end

			Debris:AddItem(clone, 0.35)
		end)()
	end
end

return {
	Z = {
		Hold = function(p: string, p2: string, _: string, p3)
			local releaser_Id = p3.Releaser_Id
			local rightHand = p3.Skill_Releaser:FindFirstChild("RightHand")

			if rightHand and (rightHand.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[p][`{p2}_Hold`]:Clone()
				clone.Name = `{releaser_Id}_{p}_{p2}_Hold`
				clone.CanCollide = false
				clone.Anchored = false
				clone.Parent = skills
				Debris:AddItem(clone, 60)
				local attachment = clone:FindFirstChild("Attachment")

				for _, emitter in ipairs(attachment:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
						continue
					end

					Generate.SetParticle(emitter)
					emitter.Enabled = true
				end

				local weld = clone:FindFirstChild("Weld")
				weld.Part1 = rightHand
			end
		end,
		Release = function(enemy: string, sound: string, _: string, data)
			local player_Releaser = data.Player_Releaser
			local skill_Releaser = data.Skill_Releaser
			local releaser_RootPart = data.Releaser_RootPart
			local mouse_Position = data.Mouse_Position
			local skill_Info = data.Skill_Info
			local releaser_Id = data.Releaser_Id
			local moving_Speed = skill_Info.Moving_Speed
			local duration = skill_Info.Duration
			local position = releaser_RootPart.Position
			local _ = releaser_RootPart.CFrame
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}_Hold`))

			if child then
				child:Destroy()
			end

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[enemy].Emit:Clone()
				clone.CFrame = CFrame.new(position, mouse_Position) * CFrame.new(0, 0, -5) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
				clone.Parent = skills
				Debris:AddItem(clone, duration)
				local attachment = clone:FindFirstChild("Attachment")

				if attachment then
					for _, emitter in ipairs(attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount") or 5)
						end
					end
				end

				local clone2 = skillFolder[enemy][sound]:Clone()
				clone2.Name = `{enemy}_{sound}_{releaser_Id}`
				clone2.CanCollide = false
				clone2.Anchored = true
				clone2.CFrame = CFrame.new(position, mouse_Position)
				clone2.Parent = skills
				Debris:AddItem(clone2, duration + 1)
				Generate.Generate_Ring(
					clone2.CFrame * CFrame.new(0, 0, -5),
					createVector(2.5, 0.1, 2.5),
					createVector(10, 1, 10),
					0.25,
					0.5,
					Color3.fromRGB(0, 0, 0)
				)
				local overlapParams = OverlapParams.new()
				overlapParams.FilterDescendantsInstances = { character, monster }
				overlapParams.FilterType = Enum.RaycastFilterType.Include
				local hitbox = clone2:FindFirstChild("Hitbox")

				if hitbox then
					hitbox.Transparency = setting.Hitbox_Transparency
					Generate.Client_Hitbox(
						player_Releaser,
						skill_Releaser,
						hitbox,
						overlapParams,
						enemy,
						sound,
						duration - 0.5,
						{
							Moving_Speed = moving_Speed,
							Skill_Type = skill_Info.Skill_Type,
							RootPart_Position = position,
							Mouse_Position = mouse_Position
						}
					)
				end

				PlaySound.PlaySound_Character(clone2, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local attachment2 = clone2:FindFirstChild("Attachment")

				if attachment2 then
					for _, emitter in ipairs(attachment2:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
							continue
						end

						Generate.SetParticle(emitter)
					end
				end

				if moving_Speed then
					local now = os.clock()
					local lastTime = tick()
					local count = 0
					local heartbeatConnection = nil
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = Folders
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						local now2 = os.clock()

						if not (now + duration + 1 <= now2) and Generate.CheckExist(clone2) then
							clone2.CFrame += CFrame.new(position, mouse_Position).LookVector * moving_Speed * dt
							return
						end

						if clone2 then
							clone2:Destroy()
						end

						if heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end
					end)

					while tick() - lastTime < 1.5 and clone2 and clone2.Parent do
						local raycastResult = workspace:Raycast(
							clone2.Position,
							clone2.CFrame.UpVector * -100,
							raycastParams
						)

						if raycastResult and raycastResult.Instance then
							Side_Rocks(
								enemy,
								clone2,
								clone2.Position,
								raycastResult.Distance,
								10,
								true,
								raycastResult.Instance,
								count
							)

							if count % 4 == 0 then
								BlackHole_Rock(enemy, clone2, raycastResult.Distance, 5, 20)
							end
						elseif count % 4 == 0 then
							BlackHole_Rock(enemy, clone2, "Auto", 5, 20)
						end

						count += 1
						task.wait(0.025)
					end
				end

				local attachment3 = clone2 and clone2.Parent and clone2:FindFirstChild("Attachment")

				if attachment3 then
					for _, emitter in ipairs(attachment3:GetChildren()) do
						if not (emitter:IsA("ParticleEmitter") and emitter.Enabled) then
							continue
						end

						if emitter.Name == "Blackhole" then
							emitter.Lifetime = NumberRange.new(0.5, 1)
						end

						emitter.Enabled = false
					end
				end
			end
		end
	},
	X = {
		Hold = function(enemy: string, sound: string, _: string, data)
			local _ = data.Player_Releaser
			local skill_Releaser = data.Skill_Releaser
			local releaser_RootPart = data.Releaser_RootPart
			local _ = data.Mouse_Position
			local skill_Info = data.Skill_Info
			local releaser_Id = data.Releaser_Id
			local _ = skill_Info.Moving_Speed
			local duration = skill_Info.Duration
			local position = releaser_RootPart.Position
			local _ = releaser_RootPart.CFrame
			local rightHand = skill_Releaser:FindFirstChild("RightHand")

			if Generate.CheckExist(releaser_RootPart) and Generate.CheckExist(rightHand) and (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[enemy][sound]:Clone()
				clone.Name = `{releaser_Id}_{enemy}_{sound}_Hold`
				clone.CanCollide = false
				clone.Anchored = false
				clone.Parent = skills
				clone:SetAttribute("Active", true)
				Debris:AddItem(clone, duration + 1.5)
				local weld = clone:FindFirstChild("Weld")
				weld.Part1 = rightHand
				local attachment = clone:FindFirstChild("Attachment")
				local attachment2 = clone:FindFirstChild("Attachment2")
				local lastTime = tick()

				if attachment then
					for _, emitter in ipairs(attachment:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
							continue
						end

						Generate.SetParticle(emitter)
						emitter.Enabled = true
					end

					if attachment2 then
						for _, emitter in ipairs(attachment2:GetChildren()) do
							if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
								continue
							end

							Generate.SetParticle(emitter)
							emitter.Enabled = true
						end
					end
				end

				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = Folders
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude

				while tick() - lastTime < 2 and clone and clone.Parent and releaser_RootPart and releaser_RootPart.Parent and clone:GetAttribute("Active") do
					local clone2 = skillFolder[enemy].Rock:Clone()
					clone2.CFrame = releaser_RootPart.CFrame * CFrame.new(
						Random.new():NextNumber(-2, 2),
						Random.new():NextNumber(-2, 2),
						-84
					)
					clone2.Size = Vector3.new(
						clone2.Size.X * Random.new():NextNumber(1, 1.75),
						clone2.Size.Y * Random.new():NextNumber(1, 1.75),
						clone2.Size.Z * Random.new():NextNumber(1, 1.75)
					)
					clone2.Parent = skills
					local v5 = math.random(-25, 25)
					local v6 = math.random(-25, 25)
					local v7 = math.random(-50, 25)
					coroutine.wrap(function()
						local position2 = clone2.Position

						for i = 1, 20 do
							local v8 = i / 20
							local position3 = (releaser_RootPart.CFrame * CFrame.new(0, 0, -4.5)).Position
							local v9 = (position2 + position3) / 2 + Vector3.new(v5, v6, v7)
							local lerped = lerp(position2, v9, v8)
							local lerped2 = lerp(v9, position3, v8)
							clone2.Position = lerp(lerped, lerped2, v8)
							task.wait()
						end

						if clone2 and clone2.Parent then
							TweenService:Create(clone2, TweenInfo.new(0.1), {
								Size = createVector(0, 0, 0)
							}):Play()
						end

						Debris:AddItem(clone2, 0.35)
					end)()
					task.wait(0.025)
				end
			end
		end,
		Release = function(p: string, p2: string, _: string, p3)
			local releaser_Id = p3.Releaser_Id
			local skill_Releaser = p3.Skill_Releaser
			local child = skills:FindFirstChild((`{releaser_Id}_{p}_{p2}_Hold`))

			if child then
				child:SetAttribute("Active", nil)
				local weld = child:FindFirstChild("Weld")

				if weld then
					child.Anchored = true
					weld:Destroy()
				end

				task.wait(0.5)
				local attachment = child:FindFirstChild("Attachment")
				local attachment2 = child:FindFirstChild("Attachment2")
				local floppa = child:FindFirstChild("Floppa")

				if attachment then
					for _, emitter in ipairs(attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end
				end

				if attachment2 then
					for _, emitter in ipairs(attachment2:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end
				end

				if floppa then
					TweenService:Create(floppa, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
					local ears = floppa:FindFirstChild("Ears")
					local outline = floppa:FindFirstChild("Outline")

					if outline then
						TweenService:Create(
							outline,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end

					if ears then
						TweenService:Create(
							ears,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()

						for _, decal in ipairs(floppa:GetChildren()) do
							if decal:IsA("Decal") then
								TweenService:Create(
									decal,
									TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Transparency = 1
									}
								):Play()
							end
						end
					end
				end
			end

			local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				PlaySound.FadingSound_Out(humanoidRootPart, 0.5, p2)
			end
		end
	},
	C = {
		Hold = function(enemy: string, sound: string, _: string, data)
			local _ = data.Player_Releaser
			local skill_Releaser = data.Skill_Releaser
			local releaser_RootPart = data.Releaser_RootPart
			local _ = data.Mouse_Position
			local skill_Info = data.Skill_Info
			local releaser_Id = data.Releaser_Id
			local _ = skill_Info.Moving_Speed
			local duration = skill_Info.Duration
			local position = releaser_RootPart.Position
			local cFrame = releaser_RootPart.CFrame

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 and Generate.CheckExist(releaser_RootPart) then
				local _, v, _ = CFrame.new(position, position + cFrame.LookVector):ToOrientation()
				local clone = skillFolder[enemy][sound]:Clone()
				clone.Name = `{releaser_Id}_{enemy}_{sound}`
				clone.Anchored = false
				clone.CFrame = CFrame.new(position) * CFrame.new(0, -3, 0) * CFrame.fromOrientation(0, v, 0)
				clone:SetAttribute("Active", true)
				clone.Parent = skills
				Debris:AddItem(clone, duration + 1)
				local weld = Instance.new("Weld")
				weld.Parent = clone
				weld.Part0 = clone
				weld.Part1 = releaser_RootPart
				weld.C1 = weld.C1 * CFrame.new(0, -3, 0) * CFrame.fromOrientation(0, v, 0)
				Debris:AddItem(weld, duration)
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local movingObject = clone:FindFirstChild("MovingObject")
				local lastTime = tick()

				if movingObject then
					local attachment = movingObject:FindFirstChild("Attachment")

					if attachment then
						for _, emitter in ipairs(attachment:GetChildren()) do
							if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
								continue
							end

							Generate.SetParticle(emitter)
							emitter.Enabled = true
						end
					end

					for _, emitter in ipairs(movingObject:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
							continue
						end

						Generate.SetParticle(emitter)
						emitter.Enabled = true
					end

					local tween = TweenService:Create(
						movingObject,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = createVector(100, 2, 100)
						}
					)
					tween:Play()
					tween.Completed:Wait()

					while tick() - lastTime < 2 and clone and clone.Parent and clone:GetAttribute("Active") do
						local clone2 = skillFolder[enemy][`{sound}_Dark`]:Clone()
						clone2.CanCollide = false
						clone2.Anchored = false
						clone2.CFrame = CFrame.new(position) * CFrame.new(0, -3, 0)
						clone2.Parent = skills
						Debris:AddItem(clone2, 1)
						local weld2 = Instance.new("Weld")
						weld2.Parent = clone2
						weld2.Part0 = clone2
						weld2.Part1 = releaser_RootPart
						weld2.C1 *= CFrame.new(0, -3, 0)
						Debris:AddItem(weld2, 1)
						local movingObject2 = clone2:FindFirstChild("MovingObject")

						if movingObject2 then
							TweenService:Create(
								movingObject2,
								TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Size = Vector3.new(
										movingObject2.Size.X * 1.15,
										movingObject2.Size.Y,
										movingObject2.Size.Z * 1.15
									),
									Transparency = 1
								}
							):Play()
						end

						task.wait(0.15)
					end
				end

				if Generate.CheckExist(clone) and clone:GetAttribute("Active") then
					local weld2 = clone:FindFirstChild("Weld")

					if weld2 then
						weld2:Destroy()
						clone.Anchored = true
					end

					local movingObject2 = clone:FindFirstChild("MovingObject")

					if movingObject2 then
						local attachment = movingObject2:FindFirstChild("Attachment")

						if attachment then
							for _, emitter in ipairs(attachment:GetChildren()) do
								if emitter:IsA("ParticleEmitter") and emitter.Enabled then
									emitter:Destroy()
								end
							end
						end

						for _, emitter in ipairs(movingObject2:GetChildren()) do
							if emitter:IsA("ParticleEmitter") and emitter.Enabled then
								emitter.Enabled = false
							end
						end

						TweenService:Create(
							movingObject2,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = createVector(0, 2, 0),
								Transparency = 1
							}
						):Play()
					end
				end
			end
		end,
		Release = function(p: string, p2: string, _: string, p3)
			local releaser_Id = p3.Releaser_Id
			local skill_Releaser = p3.Skill_Releaser
			local child = skills:FindFirstChild((`{releaser_Id}_{p}_{p2}`))

			if child and child:GetAttribute("Active") then
				local weld = child:FindFirstChild("Weld")

				if weld then
					weld:Destroy()
					child.Anchored = true
				end

				child:SetAttribute("Active", nil)
				local movingObject = child:FindFirstChild("MovingObject")

				if movingObject then
					local attachment = movingObject:FindFirstChild("Attachment")

					if attachment then
						for _, emitter in ipairs(attachment:GetChildren()) do
							if emitter:IsA("ParticleEmitter") and emitter.Enabled then
								emitter:Destroy()
							end
						end
					end

					for _, emitter in ipairs(movingObject:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end

					TweenService:Create(
						movingObject,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 2, 0),
							Transparency = 1
						}
					):Play()
				end
			end

			local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				PlaySound.FadingSound_Out(humanoidRootPart, 0.5, p2)
			end
		end
	},
	V = {
		Hold = function(p: string, p2: string, _: string, p3)
			local releaser_Id = p3.Releaser_Id
			local rightHand = p3.Skill_Releaser:FindFirstChild("RightHand")

			if rightHand and (rightHand.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[p][`{p2}_Hold`]:Clone()
				clone.Name = `{releaser_Id}_{p}_{p2}_Hold`
				clone.Parent = skills
				Debris:AddItem(clone, 60)
				local lastTime = os.clock()
				local cube = clone:FindFirstChild("Cube")
				local animationController = clone:FindFirstChild("AnimationController")
				local stroke = clone:FindFirstChild("Stroke")
				local weld = clone:FindFirstChild("Weld")
				weld.Part1 = rightHand

				if cube then
					local attachment = cube:FindFirstChild("Attachment")

					if attachment then
						for _, emitter in ipairs(attachment:GetChildren()) do
							if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
								continue
							end

							Generate.SetParticle(emitter)
							emitter.Enabled = true
						end
					end
				end

				local animator = animationController and animationController:FindFirstChild("Animator")

				if animator then
					animator:LoadAnimation(skill_Animation.Power[p][p2].Spin):Play()
				end

				if stroke then
					while os.clock() - lastTime < 60 and clone and clone.Parent do
						local tween = TweenService:Create(
							stroke,
							TweenInfo.new(0.75, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
							{
								Size = stroke.Size * 1.25
							}
						)
						tween:Play()
						tween.Completed:Wait()

						if not clone or not clone.Parent or os.clock() - lastTime >= 60 then
							break
						end

						local tween2 = TweenService:Create(
							stroke,
							TweenInfo.new(0.75, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
							{
								Size = stroke.Size / 1.25
							}
						)
						tween2:Play()
						tween2.Completed:Wait()

						if not clone or not clone.Parent or os.clock() - lastTime >= 60 then
							break
						end

						task.wait()
					end
				end
			end
		end,
		Release = function(enemy: string, sound: string, _: string, data)
			local _ = data.Player_Releaser
			local skill_Releaser = data.Skill_Releaser
			local releaser_RootPart = data.Releaser_RootPart
			local _ = data.Mouse_Position
			local skill_Info = data.Skill_Info
			local releaser_Id = data.Releaser_Id
			local _ = skill_Info.Moving_Speed
			local duration = skill_Info.Duration
			local hit_Position = data.Hit_Position
			local _ = releaser_RootPart.Position
			local _ = releaser_RootPart.CFrame
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}_Hold`))

			if child then
				child.Name = `{enemy}_{sound}`
				Debris:AddItem(child, 1)
				local cube = child:FindFirstChild("Cube")
				local stroke = child:FindFirstChild("Stroke")

				if cube and stroke then
					TweenService:Create(cube, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
					TweenService:Create(stroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
					local attachment = cube:FindFirstChild("Attachment")

					if attachment then
						for _, emitter in ipairs(attachment:GetChildren()) do
							if emitter:IsA("ParticleEmitter") and emitter.Enabled then
								emitter.Enabled = false
							end
						end
					end
				end
			end

			if (hit_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[enemy][sound]:Clone()
				clone:PivotTo(CFrame.new(hit_Position))
				clone.Parent = skills
				Debris:AddItem(clone, duration + 0.5)
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				os.clock()
				local movingObject = clone:FindFirstChild("MovingObject")
				local mainPart = clone:FindFirstChild("MainPart")
				local stroke = movingObject:FindFirstChild("Stroke")
				local secret = movingObject:FindFirstChild("Secret")
				local attachment = movingObject:FindFirstChild("Attachment")
				local decal = secret:FindFirstChild("Decal")

				if movingObject and mainPart and stroke then
					TweenService:Create(
						movingObject,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = createVector(10, 10, 10),
							CFrame = movingObject.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(
								0,
								-3.141592653589793,
								0
							),
							Transparency = 0
						}
					):Play()
					TweenService:Create(stroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(11, 11, 11),
						CFrame = stroke.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(0, -3.141592653589793, 0),
						Transparency = 0.5
					}):Play()
					task.wait(0.5)

					if decal then
						TweenService:Create(
							decal,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 0.9
							}
						):Play()
					end

					if attachment then
						for _, emitter in ipairs(attachment:GetChildren()) do
							if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
								continue
							end

							Generate.SetParticle(emitter)
							emitter.Enabled = true
						end
					end

					local lastTime = tick()

					while tick() - lastTime < 2.25 and clone and clone.Parent do
						local tween = TweenService:Create(
							stroke,
							TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
							{
								Size = stroke.Size * 1.15
							}
						)
						tween:Play()
						tween.Completed:Wait()

						if not clone or not clone.Parent or tick() - lastTime >= 1.5 then
							break
						end

						local tween2 = TweenService:Create(
							stroke,
							TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
							{
								Size = stroke.Size / 1.15
							}
						)
						tween2:Play()
						tween2.Completed:Wait()

						if not clone or not clone.Parent or tick() - lastTime >= 1.5 then
							break
						end

						task.wait()
					end

					if clone and clone.Parent then
						PlaySound.PlaySound_Character(skill_Releaser, {
							Folder = "Power_Sound",
							Enemy = enemy,
							Sound = `{sound}_Explosion`
						})

						for _, emitter in ipairs(attachment:GetChildren()) do
							if emitter:IsA("ParticleEmitter") and emitter.Enabled then
								emitter.Enabled = false
							end
						end

						if decal then
							TweenService:Create(
								decal,
								TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
						end

						TweenService:Create(
							movingObject,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = movingObject.Size * 1.5,
								CFrame = movingObject.CFrame * CFrame.Angles(0, 3.141592653589793, 0),
								Transparency = 1
							}
						):Play()
						TweenService:Create(
							stroke,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = stroke.Size * 1.5,
								CFrame = stroke.CFrame * CFrame.Angles(0, 3.141592653589793, 0),
								Transparency = 1
							}
						):Play()
					end
				end
			end
		end
	},
	F = {
		Release = function(enemy: string, sound: string, _: string, data)
			local skill_Releaser = data.Skill_Releaser
			local _ = data.Mouse_Position
			local hit_Position = data.Hit_Position
			local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and humanoidRootPart.Parent and (hit_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local _, v, _ = CFrame.new(humanoidRootPart.Position, hit_Position):ToOrientation()
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local clone = skillFolder[enemy][sound]:Clone()
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = humanoidRootPart.CFrame
				clone.Parent = skills
				Debris:AddItem(clone, 2)
				local circle = clone:FindFirstChild("Circle")

				if circle then
					TweenService:Create(circle, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(25, 25, 25),
						Transparency = 1
					}):Play()
				end

				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(0, 0, 0),
					Transparency = 1
				}):Play()
				Generate_Clone(skill_Releaser)
				humanoidRootPart.CFrame = CFrame.new(hit_Position) * CFrame.new(0, 1, 0) * CFrame.fromOrientation(
					0,
					v,
					0
				)
				local clone2 = skillFolder[enemy][sound]:Clone()
				clone2.CanCollide = false
				clone2.Anchored = true
				clone2.CFrame = humanoidRootPart.CFrame
				clone2.Parent = skills
				Debris:AddItem(clone2, 2)
				local circle2 = clone2:FindFirstChild("Circle")

				if circle2 then
					TweenService:Create(circle2, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(25, 25, 25),
						Transparency = 1
					}):Play()
				end

				TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(0, 0, 0),
					Transparency = 1
				}):Play()
			end
		end
	}
}