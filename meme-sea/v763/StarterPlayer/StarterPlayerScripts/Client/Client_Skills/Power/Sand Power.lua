local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local currentCamera = workspace.CurrentCamera
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
ReplicatedStorage:WaitForChild("OtherEvent")
local skillFolder = ReplicatedStorage:WaitForChild("SkillFolder")
local skills = workspace:WaitForChild("Skills")
local character = workspace:WaitForChild("Character")
local monster = workspace:WaitForChild("Monster")
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
return {
	Z = {
		Hold = function(enemy: string, sound: string, _: string, data)
			local player_Releaser = data.Player_Releaser
			local skill_Releaser = data.Skill_Releaser
			local releaser_RootPart = data.Releaser_RootPart
			local mouse_Position = data.Mouse_Position
			local skill_Info = data.Skill_Info
			local releaser_Id = data.Releaser_Id
			local moving_Speed = skill_Info.Moving_Speed
			local duration = skill_Info.Duration
			local loop = data.Loop
			local position = releaser_RootPart.Position
			local cFrame = releaser_RootPart.CFrame

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[enemy][sound]:Clone()
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = CFrame.new(position, position + cFrame.LookVector)
				clone.Parent = skills
				Debris:AddItem(clone, duration + 0.5)
				local overlapParams = OverlapParams.new()
				overlapParams.FilterDescendantsInstances = { character, monster }
				overlapParams.FilterType = Enum.RaycastFilterType.Include
				local hitbox = clone:FindFirstChild("Hitbox")

				if hitbox then
					hitbox.Transparency = setting.Hitbox_Transparency
					Generate.Client_Hitbox(
						player_Releaser,
						skill_Releaser,
						hitbox,
						overlapParams,
						enemy,
						sound,
						duration,
						{
							Moving_Speed = moving_Speed,
							Skill_Type = skill_Info.Skill_Type,
							RootPart_Position = position,
							Mouse_Position = mouse_Position,
							Loop = loop,
							Hit_Sound = true
						}
					)
				end

				for _, trail in ipairs(clone:GetChildren()) do
					if not trail:IsA("Trail") or trail.Enabled then
						continue
					end

					trail.Enabled = true
				end

				local movingObject = clone:FindFirstChild("MovingObject")

				if movingObject then
					for _, emitter in ipairs(movingObject:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
							continue
						end

						Generate.SetParticle(emitter)
						emitter.Enabled = true
					end
				end

				if loop == 2 and not skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}_Hold`)) then
					local clone2 = skillFolder[enemy][`{sound}_Hold`]:Clone()
					clone2.Name = `{releaser_Id}_{enemy}_{sound}_Hold`
					clone2.CanCollide = false
					clone2.Anchored = false
					Debris:AddItem(clone2, 60)
					local launcher = clone2:FindFirstChild("Launcher")

					if launcher then
						launcher.Transparency = 1
					end

					clone2.Parent = skills
					TweenService:Create(launcher, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
						Transparency = 0
					}):Play()
					local rightHand = skill_Releaser:FindFirstChild("RightHand")

					if rightHand then
						local weld = clone2:FindFirstChild("Weld")
						weld.Part1 = rightHand
					end
				end

				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				Generate.Generate_Ring(
					clone.CFrame * CFrame.new(0, 0, -7.5),
					createVector(2.5, 0.1, 2.5),
					createVector(10, 1, 10),
					0.25,
					0.5
				)

				if moving_Speed then
					local now = os.clock()
					tick()
					local heartbeatConnection = nil
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						local now2 = os.clock()

						if not (now + duration <= now2) and Generate.CheckExist(clone) then
							clone.CFrame += clone.CFrame.LookVector * moving_Speed * dt
							return
						end

						if clone then
							clone:Destroy()
						end

						if heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end
					end)
				end

				task.wait(1.5)

				if Generate.CheckExist(clone) then
					for _, trail in ipairs(clone:GetChildren()) do
						if trail:IsA("Trail") and trail.Enabled then
							trail.Enabled = false
						end
					end

					local movingObject2 = clone:FindFirstChild("MovingObject")

					if movingObject2 then
						for _, emitter in ipairs(movingObject2:GetChildren()) do
							if emitter:IsA("ParticleEmitter") and emitter.Enabled then
								emitter.Enabled = false
							end
						end

						TweenService:Create(movingObject2, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							Transparency = 1
						}):Play()
					end
				end
			end
		end,
		Release = function(p: string, p2: string, _: string, p3)
			local child = skills:FindFirstChild((`{p3.Releaser_Id}_{p}_{p2}_Hold`))

			if child then
				child.Name = `{p}_{p2}`
				local launcher = child:FindFirstChild("Launcher")

				if launcher then
					TweenService:Create(launcher, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
				end

				Debris:AddItem(child, 1)
			end
		end
	},
	X = {
		Hold = function(p: string, p2: string, _: string, p3)
			local releaser_Id = p3.Releaser_Id
			local leftHand = p3.Skill_Releaser:FindFirstChild("LeftHand")

			if leftHand and (leftHand.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[p][`{p2}_Hold`]:Clone()
				clone.Name = `{releaser_Id}_{p}_{p2}_Hold`
				clone.CanCollide = false
				clone.Anchored = false
				clone.Parent = skills
				Debris:AddItem(clone, 60)
				local weld = clone:FindFirstChild("Weld")
				weld.Part1 = leftHand
				local attachment = clone:FindFirstChild("Attachment")

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
			local hit_Position = data.Hit_Position
			local position = releaser_RootPart.Position
			local cFrame = releaser_RootPart.CFrame
			local _, _, _ = CFrame.new(position, position + -cFrame.LookVector):ToOrientation()
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}_Hold`))

			if child then
				child.Name = `{enemy}_{sound}`
				Debris:AddItem(child, 1)
				local attachment = child:FindFirstChild("Attachment")

				if attachment then
					for _, emitter in ipairs(attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end
				end
			end

			if (hit_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local v = {
					25,
					40,
					6,
					2.5
				}
				Generate.Generate_Ground(CFrame.new(hit_Position), v[1], v[2], v[3], v[4])
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local clone = skillFolder[enemy][`{sound}_Part`]:Clone()
				clone.Name = `{releaser_Id}_{enemy}_{sound}_Part`
				clone.Parent = skills
				Debris:AddItem(clone, duration + 1)
				task.delay(0.25, function()
					local clone2 = skillFolder[enemy][`{sound}_Hitbox`]:Clone()
					clone2.CanCollide = false
					clone2.Anchored = true
					clone2.Transparency = setting.Hitbox_Transparency
					clone2.CFrame = CFrame.new(hit_Position) * CFrame.new(0, 1, 0)
					clone2.Parent = skills
					Debris:AddItem(clone2, duration or 10)
					local overlapParams = OverlapParams.new()
					overlapParams.FilterDescendantsInstances = { character, monster }
					overlapParams.FilterType = Enum.RaycastFilterType.Include
					Generate.Client_Hitbox(
						player_Releaser,
						skill_Releaser,
						clone2,
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
				end)
				local lastTime = tick()

				while tick() - lastTime < duration do
					local clone2 = skillFolder[enemy][sound]:Clone()
					clone2.CanCollide = false
					clone2.Anchored = true
					clone2.CFrame = CFrame.new(hit_Position) * CFrame.new(0, 0.5, 0)
					clone2.Parent = skills
					Debris:AddItem(clone2, 1)
					local sand = clone2:FindFirstChild("Sand")

					if sand then
						TweenService:Create(sand, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Size = createVector(0.5, 75, 75)
						}):Play()
						TweenService:Create(sand, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Transparency = 1
						}):Play()
					end

					task.wait(0.25)
				end
			end
		end,
		Coffin = function(enemy: string, p2: string, _: string, p3)
			local target_RootPart = p3.Target_RootPart
			local child = skills:FindFirstChild((`{p3.Releaser_Id}_{enemy}_{p2}_Part`))

			if target_RootPart and child and Generate.CheckIfAlive(target_RootPart.Parent) then
				if not child:GetAttribute("Last_Time") then
					child:SetAttribute("Last_Time", tick() - 1)
				end

				if (target_RootPart.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
					local clone = skillFolder[enemy][`{p2}_Prison`]:Clone()
					clone.CFrame = target_RootPart.CFrame
					clone.Parent = skills
					Debris:AddItem(clone, 3)
					local weld_2 = clone:FindFirstChild("Weld")
					weld_2.Part1 = target_RootPart
					local position = target_RootPart.Position
					local lastTime = tick()
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = Folders
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude

					while tick() - lastTime < 1 do
						local weld = (target_RootPart and (Vector3.new(
							target_RootPart.Position.X,
							0,
							target_RootPart.Position.Z
						) - Vector3.new(position.X, 0, position.Z)).Magnitude >= 50 and clone and clone.Parent or not Generate.CheckIfAlive(target_RootPart.Parent) and clone and clone.Parent) and clone:FindFirstChild("Weld")

						if weld then
							if tick() - child:GetAttribute("Last_Time") >= 0.25 then
								child:SetAttribute("Last_Time", tick())
								PlaySound.PlaySound_Character(clone, {
									Folder = "Power_Sound",
									Enemy = enemy,
									Sound = `{p2}_Explosion`
								})
							end

							TweenService:Create(
								clone,
								TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Size = clone.Size * 1.35,
									Transparency = 1
								}
							):Play()
							weld:Destroy()
							clone.Anchored = true
						end

						local clone2 = skillFolder[enemy][`{p2}_Sand`]:Clone()
						clone2.CanCollide = false
						clone2.Anchored = true
						clone2.CFrame = CFrame.new(clone.Position) * CFrame.new(
							Random.new():NextNumber(-7.5, 7.5),
							0,
							Random.new():NextNumber(-7.5, 7.5)
						)
						clone2.Parent = skills
						Debris:AddItem(clone2, 2)
						local raycastResult = workspace:Raycast(
							clone2.Position,
							clone2.CFrame.UpVector * -100,
							raycastParams
						)

						if raycastResult and raycastResult.Instance then
							TweenService:Create(
								clone2,
								TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									CFrame = clone2.CFrame * CFrame.new(0, -raycastResult.Distance, 0)
								}
							):Play()
							local v = clone2
							task.delay(0.25, function()
								local sand = v:FindFirstChild("Sand")

								if sand then
									TweenService:Create(
										sand,
										TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Size = createVector(10, 10, 30) * Random.new():NextNumber(1, 2)
										}
									):Play()
									task.wait(1)
									TweenService:Create(
										sand,
										TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Transparency = 1
										}
									):Play()
								end
							end)
						else
							TweenService:Create(
								clone2,
								TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									CFrame = clone2.CFrame * CFrame.new(0, -100, 0)
								}
							):Play()
							local v = clone2
							task.delay(0.25, function()
								local sand = v:FindFirstChild("Sand")

								if sand then
									TweenService:Create(
										sand,
										TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Transparency = 1
										}
									):Play()
								end
							end)
						end

						task.wait(0.1)
					end

					if clone and clone.Parent and child then
						if tick() - child:GetAttribute("Last_Time") >= 0.25 then
							child:SetAttribute("Last_Time", tick())
							PlaySound.PlaySound_Character(clone, {
								Folder = "Power_Sound",
								Enemy = enemy,
								Sound = `{p2}_Explosion`
							})
						end

						TweenService:Create(
							clone,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = clone.Size * 1.35,
								Transparency = 1
							}
						):Play()
					end
				end
			end
		end
	},
	C = {
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
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}_Hold`))

			if child then
				child.Name = `{enemy}_{sound}`
				Debris:AddItem(child, 1)
				local attachment = child:FindFirstChild("Attachment")

				if attachment then
					for _, emitter in ipairs(attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end
				end
			end

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local _, v, _ = CFrame.new(position, position + cFrame.LookVector):ToOrientation()
				local clone = skillFolder[enemy][sound]:Clone()
				clone.Anchored = true
				clone.CFrame = CFrame.new(position) * CFrame.new(0, -3, 0) * CFrame.fromOrientation(0, v, 0)
				clone.Parent = skills
				Debris:AddItem(clone, duration)
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local movingObject = clone:FindFirstChild("MovingObject")

				if movingObject then
					TweenService:Create(
						movingObject,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = createVector(100, 2, 100),
							Transparency = 0
						}
					):Play()
				end

				task.wait(1.75)
				local movingObject2 = Generate.CheckExist(clone) and clone:FindFirstChild("MovingObject")

				if movingObject2 then
					TweenService:Create(
						movingObject2,
						TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 2, 0),
							Transparency = 1
						}
					):Play()
				end
			end
		end
	},
	V = {
		Hold = function(p: string, p2: string, _: string, p3)
			local releaser_Id = p3.Releaser_Id
			local skill_Releaser = p3.Skill_Releaser

			for i = 1, 2 do
				local rightHand

				if i == 1 then
					rightHand = skill_Releaser:FindFirstChild("RightHand")
				else
					rightHand = skill_Releaser:FindFirstChild("LeftHand")
				end

				if not (rightHand and (rightHand.Position - currentCamera.CFrame.Position).Magnitude <= 1500) then
					continue
				end

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
			local cFrame = releaser_RootPart.CFrame

			for _, part in ipairs(skills:GetChildren()) do
				if not (part:IsA("BasePart") and part.Name == `{releaser_Id}_{enemy}_{sound}_Hold`) then
					continue
				end

				part.Name = `{enemy}_{sound}`
				Debris:AddItem(part, 1)
				local attachment = part:FindFirstChild("Attachment")

				if not attachment then
					continue
				end

				for _, emitter in ipairs(attachment:GetChildren()) do
					if emitter:IsA("ParticleEmitter") and emitter.Enabled then
						emitter.Enabled = false
					end
				end
			end

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[enemy][sound]:Clone()
				clone.Name = `{enemy}_{sound}_{releaser_Id}`
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = cFrame * CFrame.new(0, -3, 0)
				clone.Parent = skills
				Debris:AddItem(clone, duration + 2)
				local overlapParams = OverlapParams.new()
				overlapParams.FilterDescendantsInstances = { character, monster }
				overlapParams.FilterType = Enum.RaycastFilterType.Include
				local hitbox = clone:FindFirstChild("Hitbox")

				if hitbox then
					hitbox.Transparency = setting.Hitbox_Transparency
					Generate.Client_Hitbox(
						player_Releaser,
						skill_Releaser,
						hitbox,
						overlapParams,
						enemy,
						sound,
						duration,
						{
							Moving_Speed = moving_Speed,
							Skill_Type = skill_Info.Skill_Type,
							RootPart_Position = position,
							Mouse_Position = mouse_Position,
							Drag_Sound = true,
							Drag_Effect = true
						}
					)
				end

				local clone2 = skillFolder[enemy][`{sound}_Part`]:Clone()
				clone2.Name = `{releaser_Id}_{enemy}_{sound}_Part`
				clone2.Parent = skills
				Debris:AddItem(clone2, duration + 1)
				PlaySound.PlaySound_Character(clone, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})

				if moving_Speed then
					local now = os.clock()
					local movingObject = clone:FindFirstChild("MovingObject")
					local heartbeatConnection = nil

					for _, emitter in ipairs(movingObject:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
							continue
						end

						Generate.SetParticle(emitter)
						emitter.Enabled = true
					end

					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						local now2 = os.clock()

						if now + duration + 1 <= now2 or not Generate.CheckExist(clone) then
							if clone then
								clone:Destroy()
							end

							if heartbeatConnection then
								heartbeatConnection:Disconnect()
								heartbeatConnection = nil
							end
						else
							clone.CFrame += CFrame.new(position, mouse_Position).LookVector * moving_Speed * dt

							if movingObject and movingObject.Parent then
								movingObject.CFrame *= CFrame.fromEulerAnglesXYZ(0, 0.1, 0)
							end
						end
					end)
				end

				clone:SetAttribute("Flying_Rock", true)
				Generate.Flying_Rock(clone, {
					DestroyTime = 2,
					Cooldown = 0.1,
					Loops = 3,
					Duration = 1.5,
					Raycast = createVector(0, -20, 0),
					Size_X = {
						Min = 1,
						Max = 3
					},
					Size_Y = {
						Min = 1,
						Max = 3
					},
					Size_Z = {
						Min = 1,
						Max = 3
					},
					Left_Right = {
						Min = -50,
						Max = 50
					},
					Up_Down = {
						Min = 50,
						Max = 75
					},
					Front_Back = {
						Min = -50,
						Max = 50
					}
				})
				task.wait(1)

				if clone and clone.Parent then
					local movingObject = clone:FindFirstChild("MovingObject")

					if movingObject then
						for _, emitter in ipairs(movingObject:GetChildren()) do
							if emitter:IsA("ParticleEmitter") and emitter.Enabled then
								emitter.Enabled = false
							end
						end

						TweenService:Create(
							movingObject,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end

					clone:SetAttribute("Flying_Rock", nil)
				end
			end
		end,
		Hitted = function(enemy: string, p2: string, _: string, data)
			local _ = data.Releaser_Character
			local releaser_Id = data.Releaser_Id
			local hit_Character = data.Hit_Character
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{p2}_Part`))

			if hit_Character and hit_Character.Parent and child then
				local humanoidRootPart = hit_Character:FindFirstChild("HumanoidRootPart")

				if not child:GetAttribute("Last_Time") then
					child:SetAttribute("Last_Time", tick() - 1)
				end

				if humanoidRootPart and tick() - child:GetAttribute("Last_Time") >= 0.1 then
					child:SetAttribute("Last_Time", tick())
					PlaySound.PlaySound_Character(humanoidRootPart, {
						Folder = "Power_Sound",
						Enemy = enemy,
						Sound = `{p2}_Hit`
					})
				end
			end
		end
	},
	F = {
		Hold = function(enemy: string, sound: string, _: string, data)
			local skill_Releaser = data.Skill_Releaser
			local releaser_Id = data.Releaser_Id
			local duration = data.Duration
			local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")
			PlaySound.PlaySound_Character(humanoidRootPart, {
				Folder = "Power_Sound",
				Enemy = enemy,
				Sound = sound
			})
			local clone = skillFolder[enemy][sound]:Clone()
			clone.Name = `{releaser_Id}_{enemy}_{sound}_Left`
			clone.CanCollide = false
			clone.Anchored = false
			clone.Parent = skills
			local clone2 = skillFolder[enemy][sound]:Clone()
			clone2.Name = `{releaser_Id}_{enemy}_{sound}_Right`
			clone2.CanCollide = false
			clone2.Anchored = false
			clone2.Parent = skills
			local now = os.clock()
			local total = 0
			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				total += dt

				if total >= 1 then
					total = 0
					local now2 = os.clock()

					if now + duration <= now2 or not (clone and clone.Parent and clone2 and clone2.Parent) then
						if clone and clone.Parent then
							clone:Destroy()
						end

						if clone2 and clone2.Parent then
							clone2:Destroy()
						end

						if heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end
					end
				end
			end)

			if humanoidRootPart then
				local weld = clone:FindFirstChild("Weld")

				if weld then
					weld.Part1 = skill_Releaser:FindFirstChild("LeftUpperArm")
				end

				local weld2 = clone2:FindFirstChild("Weld")

				if weld2 then
					weld2.Part1 = skill_Releaser:FindFirstChild("RightUpperArm")
				end
			end

			local attachment = clone:FindFirstChild("Attachment")

			if attachment then
				for _, emitter in ipairs(attachment:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
						continue
					end

					Generate.SetParticle(emitter)
					emitter.Enabled = true
				end
			end

			local attachment2 = clone2:FindFirstChild("Attachment")

			if attachment2 then
				for _, emitter in ipairs(attachment2:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
						continue
					end

					Generate.SetParticle(emitter)
					emitter.Enabled = true
				end
			end
		end,
		Release = function(p: string, p2: string, _: string, p3)
			local skill_Releaser = p3.Skill_Releaser
			local releaser_Id = p3.Releaser_Id
			local child = skills:FindFirstChild((`{releaser_Id}_{p}_{p2}_Left`))
			local child2 = skills:FindFirstChild((`{releaser_Id}_{p}_{p2}_Right`))

			if child and child.Parent and child2 and child2.Parent then
				child:Destroy()
				child2:Destroy()
			end

			local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				PlaySound.FadingSound_Out(humanoidRootPart, 0.5, p2)
			end
		end
	}
}