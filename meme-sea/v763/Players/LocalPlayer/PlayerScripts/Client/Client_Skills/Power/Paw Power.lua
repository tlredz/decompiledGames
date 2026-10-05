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
			local leftHand = p3.Skill_Releaser:FindFirstChild("LeftHand")

			if leftHand and (leftHand.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[p][`{p2}_Hold`]:Clone()
				clone.Name = `{releaser_Id}_{p}_{p2}_Hold`
				clone.CanCollide = false
				clone.Anchored = false
				clone.Parent = skills
				Debris:AddItem(clone, 60)
				local size = clone.Size
				clone.Size = createVector(0, 0, 0)
				clone.Transparency = 1
				local weld = clone:FindFirstChild("Weld")
				weld.Part1 = leftHand
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
					Size = size,
					Transparency = 0
				}):Play()
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
				child.Name = `{enemy}_{sound}`
				Debris:AddItem(child, 1)
				TweenService:Create(child, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
			end

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[enemy][sound]:Clone()
				clone.Name = `{releaser_Id}_{enemy}_{sound}`
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = CFrame.new(position, mouse_Position)
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
							Mouse_Position = mouse_Position
						}
					)
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
					local heartbeatConnection = nil
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						local now2 = os.clock()

						if not (now + duration <= now2) and Generate.CheckExist(clone) then
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

				task.wait(2.5)

				if Generate.CheckExist(clone) then
					TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Bounce), {
						Size = Vector3.new(clone.Size.X * 1.25, clone.Size.Y * 1.25, clone.Size.Z * 1.25),
						Transparency = 1
					}):Play()

					for _, trail in ipairs(clone:GetChildren()) do
						if trail:IsA("Trail") and trail.Enabled then
							trail.Enabled = false
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
					cFrame2 = cframe * CFrame.new(2, 0, 0)
				else
					cFrame2 = cframe * CFrame.new(-2, 0, 0)
				end

				clone.CFrame = cFrame2
				clone.Parent = skills
				Debris:AddItem(clone, duration)
				Generate.Generate_Ring(
					clone.CFrame * CFrame.new(0, 0, -7.5),
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

				if Generate.CheckExist(clone) then
					for _, trail in ipairs(clone:GetChildren()) do
						if trail:IsA("Trail") and trail.Enabled then
							trail.Enabled = false
						end
					end

					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = Vector3.new(clone.Size.X * 1.25, clone.Size.Y * 1.25, clone.Size.Z * 1.25),
						Transparency = 1
					}):Play()
				end
			end
		end
	},
	C = {
		Release = function(enemy: string, sound: string, _: string, data)
			local _ = data.Player_Releaser
			local skill_Releaser = data.Skill_Releaser
			local releaser_RootPart = data.Releaser_RootPart
			local _ = data.Mouse_Position
			local skill_Info = data.Skill_Info
			local _ = data.Releaser_Id
			local _ = skill_Info.Moving_Speed
			local duration = skill_Info.Duration
			local position = releaser_RootPart.Position
			local cFrame = releaser_RootPart.CFrame

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local _ = {
					20,
					37,
					6,
					1.5
				}
				local _, v, _ = CFrame.new(position, position + cFrame.LookVector):ToOrientation()
				local clone = skillFolder[enemy][sound]:Clone()
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = CFrame.new(position) * CFrame.new(0, 20, 0) * CFrame.fromOrientation(0, v, 0)
				clone.Parent = skills
				Debris:AddItem(clone, duration)
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local wave = clone:FindFirstChild("Wave")

				if wave then
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = Folders
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					workspace:Raycast(clone.Position, clone.CFrame.UpVector * -10, raycastParams)
					Color3.fromRGB(163, 162, 165)
					local _ = Enum.Material.Concrete
					local movingObject = clone:FindFirstChild("MovingObject")

					if movingObject then
						TweenService:Create(
							movingObject,
							TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
							{
								Size = createVector(112.5, 112.5, 75),
								Transparency = 0
							}
						):Play()
						TweenService:Create(
							clone,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								CFrame = clone.CFrame * CFrame.Angles(0, -3.141592653589793, 0)
							}
						):Play()
					end

					task.spawn(function()
						local lastTime = tick()

						while clone and clone.Parent and tick() - lastTime <= 1.75 do
							local clone2 = wave:Clone()
							clone2.Transparency = 0.1
							clone2.CFrame = clone.CFrame * CFrame.new(0, -20, 0)
							clone2.Anchored = true
							clone2.Parent = clone
							Debris:AddItem(clone2, 1)
							TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Cubic), {
								Size = createVector(175, 10, 175),
								Transparency = 1
							}):Play()
							task.wait(0.25)
						end
					end)
				end

				task.wait(1.5)
				local movingObject = clone:FindFirstChild("MovingObject")

				if movingObject then
					TweenService:Create(
						movingObject,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(
								movingObject.Size.X * 1.25,
								movingObject.Size.Y * 1.25,
								movingObject.Size.Z * 1.25
							),
							Transparency = 1
						}
					):Play()
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
					}):Play()
				end

				local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					PlaySound.FadingSound_Out(humanoidRootPart, 1, sound)
				end
			end
		end
	},
	V = {
		Hold = function(p: string, p2: string, _: string, p3)
			local releaser_Id = p3.Releaser_Id
			local skill_Releaser = p3.Skill_Releaser
			local clone = skillFolder[p][p2]:Clone()
			clone.Name = `{releaser_Id}_{p}_{p2}_Hold`
			clone.CanCollide = false
			clone.Anchored = false
			clone.Parent = skills
			Debris:AddItem(clone, 60)
			local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				clone.Anchored = true
				return
			end

			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 20, 0)
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
				Size = createVector(30, 30, 20),
				Transparency = 0.1
			}):Play()
			local weld = Instance.new("Weld")
			weld.Parent = clone
			weld.Part0 = clone
			weld.Part1 = humanoidRootPart
			weld.C1 *= CFrame.new(0, 20, 0)
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
			local v = CFrame.new(position, mouse_Position) * CFrame.new(0, 20, 0)
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}_Hold`))

			if child then
				child:Destroy()
				local clone = skillFolder[enemy][sound]:Clone()
				clone.Name = `{enemy}_{sound}_{releaser_Id}`
				clone.CanCollide = false
				clone.Anchored = true
				clone.Size = createVector(30, 30, 20)
				clone.Transparency = 0.1
				clone.CFrame = CFrame.new(v.Position, mouse_Position)
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
							Single_Target = skill_Info.Single_Target,
							RootPart_Position = position,
							Mouse_Position = mouse_Position,
							Hit_Sound = true,
							Prison_Sound = true
						}
					)
				end

				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
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

				if moving_Speed then
					local now = os.clock()
					local heartbeatConnection = nil
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						local now2 = os.clock()

						if not (now + duration <= now2) and Generate.CheckExist(clone) and not clone:GetAttribute("Hitted") then
							clone.CFrame += CFrame.new(v.Position, mouse_Position).LookVector * moving_Speed * dt
						elseif heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end
					end)
				end

				task.wait(1.5)

				if Generate.CheckExist(clone) and not clone:GetAttribute("Hitted") then
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
						Size = createVector(0, 0, 0),
						Transparency = 1
					}):Play()
					local attachment2 = clone:FindFirstChild("Attachment")

					if attachment2 then
						for _, emitter in ipairs(attachment2:GetChildren()) do
							if emitter:IsA("ParticleEmitter") and emitter.Enabled then
								emitter.Enabled = false
							end
						end
					end
				end
			end
		end,
		Prison = function(p: string, p2: string, _: string, data)
			local releaser_Id = data.Releaser_Id
			local _ = data.Releaser_Character
			local hit_Position = data.Hit_Position
			local child = skills:FindFirstChild((`{p}_{p2}_{releaser_Id}`))

			if child and not child:GetAttribute("Hitted") and (child.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local attachment = child:FindFirstChild("Attachment")

				if attachment then
					for _, emitter in ipairs(attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end
				end

				local lookVector = child.CFrame.LookVector
				child:SetAttribute("Hitted", true)
				TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
					CFrame = CFrame.new(hit_Position, hit_Position + lookVector) * CFrame.new(0, 3, 0)
				}):Play()

				if child and child.Transparency ~= 0.1 then
					TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
						Transparency = 0.1
					}):Play()
				end

				local lastTime = tick()

				while tick() - lastTime < 1.5 and child and child.Parent do
					local tween = TweenService:Create(
						child,
						TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(child.Size.X * 1.5, child.Size.Y * 1.5, child.Size.Z * 1.5)
						}
					)
					tween:Play()
					tween.Completed:Wait()

					if not (child and child.Parent) then
						break
					end

					local tween2 = TweenService:Create(
						child,
						TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(child.Size.X / 1.5, child.Size.Y / 1.5, child.Size.Z / 1.5)
						}
					)
					tween2:Play()
					tween2.Completed:Wait()

					if child and child.Parent then
						task.wait()
					else
						break
					end
				end

				if child and child.Parent then
					TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = Vector3.new(child.Size.X * 2, child.Size.Y * 2, child.Size.Z * 2),
						Transparency = 1
					}):Play()
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
				local clone = skillFolder[enemy][sound]:Clone()
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 5, 5)
				clone.Transparency = 1
				clone.Parent = skills
				Debris:AddItem(clone, 1)
				local circle = clone:FindFirstChild("Circle")

				if circle then
					circle.Transparency = 1
				end

				TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
					CFrame = CFrame.new(hit_Position) * CFrame.new(0, 5, 0) * CFrame.fromOrientation(0, v, 0)
				}):Play()
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local clone2 = skillFolder[enemy][sound]:Clone()
				clone2.CanCollide = false
				clone2.Anchored = true
				clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 2.5, 0)
				clone2.Parent = skills
				Debris:AddItem(clone2, 2)
				local circle2 = clone2:FindFirstChild("Circle")

				if circle2 then
					TweenService:Create(circle2, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(35, 35, 35),
						Transparency = 1
					}):Play()
				end

				TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(0, 0, 0),
					Transparency = 1
				}):Play()
				humanoidRootPart.CFrame = CFrame.new(hit_Position) * CFrame.new(0, 1, 0) * CFrame.fromOrientation(
					0,
					v,
					0
				)
				local clone3 = skillFolder[enemy][sound]:Clone()
				clone3.CanCollide = false
				clone3.Anchored = true
				clone3.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 2.5, 0)
				clone3.Parent = skills
				Debris:AddItem(clone3, 2)
				local circle3 = clone3:FindFirstChild("Circle")

				if circle3 then
					TweenService:Create(circle3, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(35, 35, 35),
						Transparency = 1
					}):Play()
				end

				TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(0, 0, 0),
					Transparency = 1
				}):Play()
			end
		end
	}
}