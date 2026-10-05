local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local _ = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
ReplicatedStorage:WaitForChild("Modules")
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
				local weld = clone:FindFirstChild("Weld")
				weld.Part1 = rightHand
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
			local _ = data.Loop
			local position = releaser_RootPart.Position
			local _ = releaser_RootPart.CFrame
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}_Hold`))

			if child then
				child.Name = `{enemy}_{sound}`
				Debris:AddItem(child, 1)
				TweenService:Create(child, TweenInfo.new(0.25, Enum.EasingStyle.Bounce), {
					Size = createVector(0, 0, 0),
					Transparency = 1
				}):Play()
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
				local clone = skillFolder[enemy][sound]:Clone()
				clone.Name = `{releaser_Id}_{enemy}_{sound}`
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = CFrame.new(position, mouse_Position) * CFrame.new(0, 12, 0)
				clone.Parent = skills
				Debris:AddItem(clone, duration + 3)
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
							Hit_Sound = true
						}
					)
				end

				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})

				if moving_Speed then
					local now = os.clock()
					local heartbeatConnection = nil
					clone:FindFirstChild("MovingObject")
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						local now2 = os.clock()

						if not (now + duration <= now2) and Generate.CheckExist(clone) and not clone:GetAttribute("Hitted") then
							clone.CFrame += CFrame.new(position, mouse_Position).LookVector * moving_Speed * dt
						elseif heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end
					end)
				end

				local movingObject = clone:FindFirstChild("MovingObject")

				if movingObject then
					TweenService:Create(
						movingObject,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Transparency = 0.5
						}
					):Play()

					for _, emitter in ipairs(movingObject:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
							continue
						end

						Generate.SetParticle(emitter)
						emitter.Enabled = true
					end
				end

				task.wait(1.75)
				local movingObject2 = clone and clone.Parent and not clone:GetAttribute("Hitted") and Generate.CheckExist(clone) and clone:FindFirstChild("MovingObject")

				if movingObject2 then
					for _, trail in ipairs(clone:GetChildren()) do
						if trail:IsA("Trail") and trail.Enabled then
							trail.Enabled = false
						end
					end

					for _, emitter in ipairs(movingObject:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end

					TweenService:Create(
						movingObject2,
						TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 0, 0),
							Transparency = 1
						}
					):Play()
				end
			end
		end,
		Coffin = function(enemy: string, p2: string, _: string, p3)
			local target_RootPart = p3.Target_RootPart
			local child = skills:FindFirstChild((`{p3.Releaser_Id}_{enemy}_{p2}`))

			if child and not child:GetAttribute("Hitted") and Generate.CheckIfAlive(target_RootPart.Parent) then
				child.Name = `{enemy}_{p2}`
				child:SetAttribute("Hitted", true)
				local weld = child:FindFirstChild("Weld")
				child.Anchored = false
				weld.Part1 = target_RootPart
				local position = target_RootPart.Position
				local movingObject = child:FindFirstChild("MovingObject")

				if movingObject then
					for _, trail in ipairs(child:GetChildren()) do
						if trail:IsA("Trail") and trail.Enabled then
							trail.Enabled = false
						end
					end

					for _, emitter in ipairs(movingObject:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end

					if movingObject.Transparency ~= 0.5 or movingObject.Size ~= createVector(25, 25, 25) then
						TweenService:Create(movingObject, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
							Size = createVector(25, 25, 25),
							Transparency = 0.5
						}):Play()
					end
				end

				local lastTime = tick()

				while tick() - lastTime < 1 do
					local weld2 = target_RootPart and (Vector3.new(
						target_RootPart.Position.X,
						0,
						target_RootPart.Position.Z
					) - Vector3.new(position.X, 0, position.Z)).Magnitude >= 10 and child and child.Parent and child:FindFirstChild("Weld")

					if weld2 then
						weld2:Destroy()
						child.Anchored = true
					end

					local tween = TweenService:Create(
						movingObject,
						TweenInfo.new(0.25, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
						{
							Size = movingObject.Size * 1.25
						}
					)
					tween:Play()
					tween.Completed:Wait()

					if not child or not child.Parent or tick() - lastTime >= 1 then
						break
					end

					local tween2 = TweenService:Create(
						movingObject,
						TweenInfo.new(0.25, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
						{
							Size = movingObject.Size / 1.25
						}
					)
					tween2:Play()
					tween2.Completed:Wait()

					if not child or not child.Parent or tick() - lastTime >= 1 then
						break
					end

					task.wait(0.1)
				end

				if child and child.Parent then
					local weld2 = child:FindFirstChild("Weld")

					if weld2 then
						weld2:Destroy()
						child.Anchored = true
					end

					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = Folders
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					local raycastResult = workspace:Raycast(
						child.Position,
						CFrame.new(child.Position).UpVector * -100,
						raycastParams
					)

					if raycastResult and raycastResult.Instance then
						local movingObject2 = child:FindFirstChild("MovingObject")

						if movingObject2 then
							child.Orientation = createVector(0, 0, 0)
							TweenService:Create(
								movingObject2,
								TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Size = createVector(10, 10, 10)
								}
							):Play()
							local tween = TweenService:Create(
								child,
								TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									CFrame = child.CFrame * CFrame.new(0, -raycastResult.Distance + 1, 0)
								}
							)
							tween:Play()
							tween.Completed:Wait()
							PlaySound.PlaySound_Character(child, {
								Folder = "Power_Sound",
								Enemy = enemy,
								Sound = `{p2}_Explosion`
							})
							local tween2 = TweenService:Create(
								movingObject2,
								TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Size = createVector(50, 5, 50)
								}
							)
							tween2:Play()
							tween2.Completed:Wait()
							task.wait(0.5)
							TweenService:Create(
								movingObject2,
								TweenInfo.new(0.25, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
								{
									Size = createVector(0, 5, 0),
									Transparency = 1
								}
							):Play()
						end
					else
						PlaySound.PlaySound_Character(child, {
							Folder = "Power_Sound",
							Enemy = enemy,
							Sound = `{p2}_Explosion`
						})
						local movingObject2 = child:FindFirstChild("MovingObject")

						if movingObject2 then
							movingObject2.Material = Enum.Material.Plastic
							TweenService:Create(
								movingObject2,
								TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Size = createVector(35, 35, 35),
									Transparency = 1
								}
							):Play()
						end
					end
				end
			end
		end
	},
	X = {
		Release = function(enemy: string, sound: string, _: string, data)
			local player_Releaser = data.Player_Releaser
			local skill_Releaser = data.Skill_Releaser
			local releaser_RootPart = data.Releaser_RootPart
			local mouse_Position = data.Mouse_Position
			local skill_Info = data.Skill_Info
			local _ = data.Releaser_Id
			local moving_Speed = skill_Info.Moving_Speed
			local duration = skill_Info.Duration
			local loop = data.Loop
			local position = releaser_RootPart.Position
			local cFrame = releaser_RootPart.CFrame
			local cframe = CFrame.new(position, position + cFrame.LookVector)

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 and Generate.CheckExist(releaser_RootPart) then
				local clone = skillFolder[enemy][sound]:Clone()
				clone.CanCollide = false
				clone.Anchored = true
				local cFrame2

				if loop % 2 == 0 then
					cFrame2 = cframe * CFrame.new(2, 0, -3)
				else
					cFrame2 = cframe * CFrame.new(-2, 0, -3)
				end

				clone.CFrame = cFrame2
				clone.Parent = skills
				Debris:AddItem(clone, duration)
				Generate.Generate_Ring(
					clone.CFrame * CFrame.new(0, 0, -5),
					createVector(2.5, 0.1, 2.5),
					createVector(10, 1, 10),
					0.25,
					0.5
				)
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
							Loop = loop
						}
					)
				end

				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local movingObject = clone:FindFirstChild("MovingObject")

				if movingObject then
					for _, trail in ipairs(movingObject:GetChildren()) do
						if not trail:IsA("Trail") or trail.Enabled then
							continue
						end

						trail.Enabled = true
					end
				end

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

				task.wait(2.5)
				local movingObject2 = Generate.CheckExist(clone) and clone:FindFirstChild("MovingObject")

				if movingObject2 then
					for _, trail in ipairs(movingObject2:GetChildren()) do
						if trail:IsA("Trail") and trail.Enabled then
							trail.Enabled = false
						end
					end

					TweenService:Create(
						movingObject2,
						TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 0, 0),
							Transparency = 1
						}
					):Play()
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
				local weld = clone:FindFirstChild("Weld")
				weld.Part1 = rightHand
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
				clone.CFrame = CFrame.new(position) * CFrame.new(0, -2.5, 0) * CFrame.fromOrientation(0, v, 0)
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
							Size = createVector(5, 100, 100),
							Transparency = 0.5
						}
					):Play()
				end

				task.wait(1.75)
				local movingObject2 = Generate.CheckExist(clone) and clone:FindFirstChild("MovingObject")

				if movingObject2 then
					TweenService:Create(
						movingObject2,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(1, 0, 0),
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
			local _ = releaser_RootPart.CFrame

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

			if (position - currentCamera.CFrame.Position).Magnitude <= 2000 then
				local clone = skillFolder[enemy][sound]:Clone()
				clone.Name = `{enemy}_{sound}_{releaser_Id}`
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = CFrame.new(position, mouse_Position) * CFrame.new(0, 0, 0)
				clone.Parent = skills
				Debris:AddItem(clone, duration + 1)
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
						duration - 0.4,
						{
							Moving_Speed = moving_Speed,
							Skill_Type = skill_Info.Skill_Type,
							RootPart_Position = position,
							Mouse_Position = mouse_Position,
							Drag_Sound = true
						}
					)
				end

				PlaySound.PlaySound_Character(clone, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})

				if moving_Speed then
					local now = os.clock()
					local heartbeatConnection = nil
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						local now2 = os.clock()

						if not (now + duration + 1 <= now2) and Generate.CheckExist(clone) then
							clone.CFrame += CFrame.new(position, mouse_Position).LookVector * moving_Speed * dt
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

				local movingObject = clone:FindFirstChild("MovingObject")

				if movingObject then
					TweenService:Create(
						movingObject,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Transparency = 0.5
						}
					):Play()
				end

				task.wait(1.5)
				local movingObject2 = clone and clone.Parent and clone:FindFirstChild("MovingObject")

				if movingObject2 then
					movingObject2.Material = Enum.Material.Plastic
					TweenService:Create(
						movingObject2,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
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
			local clone = skillFolder[enemy][sound]:Clone()
			clone.Name = `{releaser_Id}_{enemy}_{sound}`
			clone.CanCollide = false
			clone.Anchored = false
			clone.Parent = skills
			clone:SetAttribute("Active", true)
			local now = os.clock()
			local total = 0
			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				total += dt

				if total >= 1 then
					total = 0
					local now2 = os.clock()

					if now + duration <= now2 or not (clone and clone.Parent) then
						if clone and clone.Parent then
							clone:Destroy()
						end

						if heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end
					end
				end
			end)

			if humanoidRootPart then
				PlaySound.PlaySound_Character(humanoidRootPart, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local weld = clone:FindFirstChild("Weld")

				if weld then
					weld.Part1 = humanoidRootPart
				end
			end

			for _, trail in ipairs(clone:GetChildren()) do
				if not trail:IsA("Trail") or trail.Enabled then
					continue
				end

				trail.Enabled = true
			end

			local puddle = clone:FindFirstChild("Puddle")

			if puddle then
				TweenService:Create(puddle, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
					Size = createVector(10.884, 1.344, 10.858),
					Transparency = 0.5
				}):Play()
				task.wait(1)

				while clone and clone.Parent and clone:GetAttribute("Active") do
					local tween = TweenService:Create(
						puddle,
						TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(puddle.Size.X * 1.25, puddle.Size.Y, puddle.Size.Z * 1.25)
						}
					)
					tween:Play()
					tween.Completed:Wait()

					if not (clone and clone.Parent and clone:GetAttribute("Active")) then
						break
					end

					local tween2 = TweenService:Create(
						puddle,
						TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(puddle.Size.X / 1.25, puddle.Size.Y, puddle.Size.Z / 1.25)
						}
					)
					tween2:Play()
					tween2.Completed:Wait()

					if clone and clone.Parent and clone:GetAttribute("Active") then
						task.wait()
					else
						break
					end
				end
			end
		end,
		Release = function(p: string, p2: string, _: string, p3)
			local skill_Releaser = p3.Skill_Releaser
			local child = skills:FindFirstChild((`{p3.Releaser_Id}_{p}_{p2}`))

			if child and child.Parent then
				child:SetAttribute("Active", nil)
				local weld = child:FindFirstChild("Weld")

				if weld then
					child.Anchored = true
					weld:Destroy()
				end

				for _, trail in ipairs(child:GetChildren()) do
					if trail:IsA("Trail") and trail.Enabled then
						trail.Enabled = false
					end
				end

				local puddle = child:FindFirstChild("Puddle")

				if puddle then
					TweenService:Create(puddle, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(0, 1.344, 0),
						Transparency = 1
					}):Play()
				end

				task.wait(1)

				if child and child.Parent then
					child:Destroy()
				end
			end

			local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				PlaySound.FadingSound_Out(humanoidRootPart, 0.5, p2)
			end
		end
	}
}