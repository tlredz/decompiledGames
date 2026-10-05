local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
ReplicatedStorage:WaitForChild("Modules")
ReplicatedStorage:WaitForChild("OtherEvent")
local skillFolder = ReplicatedStorage:WaitForChild("SkillFolder")
local skill_Animation = ReplicatedStorage:WaitForChild("Animation_Folder"):WaitForChild("Skill_Animation")
local skills = workspace:WaitForChild("Skills")
local character = workspace:WaitForChild("Character")
local monster = workspace:WaitForChild("Monster")
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
local Generate = require(moduleScript:WaitForChild("Generate"))
local Setting = require(moduleScript:WaitForChild("Setting"))
local setting = Setting.Setting
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
				local movingObject = clone:FindFirstChild("MovingObject")
				local attachment = movingObject and movingObject:FindFirstChild("Attachment")

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
			local position = releaser_RootPart.Position
			local _ = releaser_RootPart.CFrame
			local cFrame = CFrame.new(position, mouse_Position) * CFrame.new(0.6, 2.25, 2.8)
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}_Hold`))

			if child then
				child.Name = `{enemy}_{sound}`
				Debris:AddItem(child, 1)
				local movingObject = child:FindFirstChild("MovingObject")

				if movingObject then
					TweenService:Create(movingObject, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
					local attachment = movingObject:FindFirstChild("Attachment")

					if attachment then
						for _, emitter in ipairs(attachment:GetChildren()) do
							if emitter:IsA("ParticleEmitter") and emitter.Enabled then
								emitter.Enabled = false
							end
						end
					end
				end
			end

			if (position - currentCamera.CFrame.Position).Magnitude <= 2000 then
				local clone = skillFolder[enemy][sound]:Clone()
				clone.Name = `{releaser_Id}_{enemy}_{sound}`
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = cFrame
				clone.Parent = skills
				Debris:AddItem(clone, duration)
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
				local Folders = {
					skill_Releaser,
					workspace.Skills,
					workspace.Region,
					workspace.Visuals,
					workspace.Location,
					workspace.Sea,
					workspace.Leaderboard,
					workspace.CameraFolder,
					workspace.SpawningPower
				}
				local overlapParams = OverlapParams.new()
				overlapParams.FilterDescendantsInstances = Folders
				overlapParams.FilterType = Enum.RaycastFilterType.Exclude
				local hitbox = clone:FindFirstChild("Hitbox")

				if hitbox then
					hitbox:SetAttribute("Exploded", false)
					hitbox.Transparency = setting.Hitbox_Transparency
					Generate.Client_Explosion(
						player_Releaser,
						skill_Releaser,
						hitbox,
						overlapParams,
						enemy,
						sound,
						duration,
						{
							Moving_Speed = moving_Speed,
							RootPart_Position = position,
							Mouse_Position = mouse_Position
						}
					)
					local explodedChangedConnection = nil
					local thread = task.delay(skill_Info.Duration, function()
						if explodedChangedConnection then
							explodedChangedConnection:Disconnect()
							explodedChangedConnection = nil
						end
					end)
					explodedChangedConnection = hitbox:GetAttributeChangedSignal("Exploded"):Connect(function()
						if Generate.CheckExist(hitbox) and hitbox:GetAttribute("Exploded") then
							if thread then
								task.cancel(thread)
							end

							if explodedChangedConnection then
								explodedChangedConnection:Disconnect()
								explodedChangedConnection = nil
							end

							local overlapParams2 = OverlapParams.new()
							overlapParams2.FilterDescendantsInstances = { character, monster }
							overlapParams2.FilterType = Enum.RaycastFilterType.Include
							local clone2 = skillFolder[enemy][`{sound}_ExplosionHitbox`]:Clone()
							clone2.CanCollide = false
							clone2.Anchored = true
							clone2.Transparency = setting.Hitbox_Transparency
							clone2.CFrame = CFrame.new(hitbox.Position) * CFrame.new(0, 10, 0)
							clone2.Parent = skills
							Debris:AddItem(clone2, duration)

							if hitbox and hitbox.Parent then
								hitbox:Destroy()
							end

							Generate.Client_Hitbox(
								player_Releaser,
								skill_Releaser,
								clone2,
								overlapParams2,
								enemy,
								sound,
								duration - 1,
								{
									Moving_Speed = moving_Speed,
									Skill_Type = skill_Info.Skill_Type,
									RootPart_Position = position,
									Mouse_Position = mouse_Position
								}
							)

							if clone and clone.Parent then
								clone:SetAttribute("Exploded", true)
								local v2 = {
									24,
									53,
									7,
									1.25
								}
								local clone3 = skillFolder[enemy][`{sound}_Explosion`]:Clone()
								clone3:PivotTo(CFrame.new(clone.Position))
								clone3.Parent = skills
								Debris:AddItem(clone3, 2)
								PlaySound.PlaySound_Character(clone3, {
									Folder = "Power_Sound",
									Enemy = enemy,
									Sound = `{sound}_Explosion`
								})
								local ball = clone3:FindFirstChild("Ball")

								if ball then
									Generate.Generate_Ground(clone3.PrimaryPart, v2[1], v2[2], v2[3], v2[4])
									TweenService:Create(
										ball,
										TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Size = createVector(110, 110, 110),
											CFrame = ball.CFrame * CFrame.Angles(0, -3.141592653589793, 0),
											Transparency = 0
										}
									):Play()
									task.wait(0.5)
									TweenService:Create(
										ball,
										TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Transparency = 1
										}
									):Play()
								end
							end
						end
					end)
				end

				if moving_Speed then
					local now = os.clock()
					local heartbeatConnection = nil
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						local now2 = os.clock()

						if not (now + duration <= now2) and Generate.CheckExist(clone) and not clone:GetAttribute("Exploded") then
							clone.CFrame += CFrame.new(cFrame.Position, mouse_Position).LookVector * moving_Speed * dt
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

				task.spawn(function()
					task.wait(0.25)

					while clone and clone.Parent and clone.Transparency < 1 do
						Generate.Generate_Ring(
							clone.CFrame,
							createVector(2.5, 0.1, 2.5),
							createVector(7.5, 0.5, 7.5),
							0.25,
							0.5
						)
						task.wait(0.25)
					end
				end)

				for _, trail in ipairs(clone:GetChildren()) do
					if not trail:IsA("Trail") or trail.Enabled then
						continue
					end

					trail.Enabled = true
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

				task.wait(1)

				if Generate.CheckExist(clone) then
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
					task.wait(0.5)

					if clone and clone.Parent then
						for _, trail in ipairs(clone:GetChildren()) do
							if trail:IsA("Trail") and trail.Enabled then
								trail.Enabled = false
							end
						end

						for _, emitter in ipairs(attachment:GetChildren()) do
							if emitter:IsA("ParticleEmitter") and emitter.Enabled then
								emitter.Enabled = false
							end
						end
					end
				end
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
				local clone = skillFolder[enemy][sound]:Clone()
				clone:PivotTo(CFrame.new(hit_Position) * CFrame.new(0, 0.25, 0))
				clone.Parent = skills
				Debris:AddItem(clone, duration + 0.5)
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local now = os.clock()
				local heartbeatConnection = nil
				local movingObject = clone:FindFirstChild("MovingObject")
				local snowFloor = clone:FindFirstChild("SnowFloor")

				if movingObject and snowFloor then
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						local now2 = os.clock()

						if now + duration <= now2 or not Generate.CheckExist(clone) then
							if heartbeatConnection then
								heartbeatConnection:Disconnect()
								heartbeatConnection = nil
							end

							if clone and clone.Parent then
								clone:Destroy()
							end
						elseif movingObject and movingObject.Parent then
							movingObject.CFrame *= CFrame.fromEulerAnglesXYZ(0, 0.1 * (1 + dt), 0)
						end
					end)
					local auraPart = clone:FindFirstChild("AuraPart")

					if auraPart then
						for _, emitter in ipairs(auraPart:GetChildren()) do
							if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
								continue
							end

							Generate.SetParticle(emitter)
							emitter.Enabled = true
						end

						TweenService:Create(
							snowFloor,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = createVector(1, 100, 100),
								Transparency = 0
							}
						):Play()
						TweenService:Create(
							movingObject,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = createVector(100, 100, 100),
								Transparency = 0
							}
						):Play()
						task.wait(1.5)

						if clone and clone.Parent then
							for _, emitter in ipairs(auraPart:GetChildren()) do
								if emitter:IsA("ParticleEmitter") and emitter.Enabled then
									emitter.Enabled = false
								end
							end

							TweenService:Create(
								snowFloor,
								TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Size = snowFloor.Size * 1.25,
									Transparency = 1
								}
							):Play()
							TweenService:Create(
								movingObject,
								TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Size = movingObject.Size * 1.25,
									Transparency = 1
								}
							):Play()
						end
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
			local _ = releaser_RootPart.CFrame
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}_Hold`))

			if child then
				child.Name = `{enemy}_{sound}`
				Debris:AddItem(child, 1)
				child:FindFirstChild("MovingObject")
				local attachment = child:FindFirstChild("Attachment")

				if attachment then
					for _, emitter in ipairs(attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end
				end
			end

			if (position - currentCamera.CFrame.Position).Magnitude <= 2500 then
				local clone = skillFolder[enemy][sound]:Clone()
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = CFrame.new(position)
				clone.Parent = skills
				Debris:AddItem(clone, duration)
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local movingObject = clone:FindFirstChild("MovingObject")
				local snow = clone:FindFirstChild("Snow")

				if movingObject and snow then
					local character2 = localPlayer.Character

					if Generate.CheckIfAlive(character2) then
						if character2:GetAttribute("Safezone") then
							movingObject.CanCollide = false
						else
							movingObject.CanCollide = true
						end
					else
						movingObject.CanCollide = false
					end

					TweenService:Create(
						movingObject,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = createVector(250, 125, 250),
							Transparency = 0.5
						}
					):Play()
					TweenService:Create(snow, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(235, 125, 235),
						Transparency = 0.95
					}):Play()

					for _, emitter in ipairs(movingObject:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
							continue
						end

						Generate.SetParticle(emitter)
						emitter.Enabled = true
					end

					task.wait(2)

					if Generate.CheckExist(movingObject) then
						if movingObject.CanCollide then
							movingObject.CanCollide = false
						end

						TweenService:Create(
							movingObject,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = movingObject.Size * 1.1,
								Transparency = 1
							}
						):Play()
						TweenService:Create(snow, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Size = snow.Size * 1.1,
							Transparency = 1
						}):Play()

						for _, emitter in ipairs(movingObject:GetChildren()) do
							if emitter:IsA("ParticleEmitter") and emitter.Enabled then
								emitter.Enabled = false
							end
						end
					end
				end
			end
		end
	},
	V = {
		Release = function(enemy: string, p2: string, _: string, data)
			local releaser_Id = data.Releaser_Id
			local skill_Info = data.Skill_Info
			local turret_CFrame = data.Turret_CFrame
			local duration = skill_Info.Duration
			local clone = skillFolder[enemy].Turret:Clone()
			clone.Name = `{releaser_Id}_Turret`
			clone:PivotTo(turret_CFrame)

			for _, part in ipairs(clone:GetChildren()) do
				if not (part:IsA("BasePart") and part.Transparency < 1) then
					continue
				end

				part:SetAttribute("Original_Transparency", part.Transparency)
				part.Transparency = 1
			end

			clone.Parent = skills
			Debris:AddItem(clone, duration + 1)

			for _, part in ipairs(clone:GetChildren()) do
				if not (part:IsA("BasePart") and part:GetAttribute("Original_Transparency")) then
					continue
				end

				if part:GetAttribute("Original_Transparency") == 0 then
					if (part.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
						TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Transparency = part:GetAttribute("Original_Transparency")
						}):Play()
					else
						part.Transparency = part:GetAttribute("Original_Transparency")
					end
				elseif (part.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
					TweenService:Create(part, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = part:GetAttribute("Original_Transparency")
					}):Play()
				else
					part.Transparency = part:GetAttribute("Original_Transparency")
				end
			end

			PlaySound.PlaySound_Character(clone, {
				Folder = "Power_Sound",
				Enemy = enemy,
				Sound = `{p2}_Spawn`
			})
			local mainPart = clone:FindFirstChild("MainPart")
			local rootAttachment = mainPart and mainPart:FindFirstChild("RootAttachment")

			if rootAttachment then
				local alignOrientation = Instance.new("AlignOrientation")
				alignOrientation.Parent = mainPart
				alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
				alignOrientation.Attachment0 = rootAttachment
				alignOrientation.Responsiveness = 100
				alignOrientation.CFrame = mainPart.CFrame
				local alignPosition = Instance.new("AlignPosition")
				alignPosition.MaxForce = 1000000
				alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
				alignPosition.Responsiveness = 200
				alignPosition.Attachment0 = rootAttachment
				alignPosition.Position = mainPart.Position
				alignPosition.Parent = mainPart
			end
		end,
		Fire = function(enemy: string, sound: string, _: string, data)
			local releaser_Id = data.Releaser_Id
			local throw_CFrame = data.Throw_CFrame
			local target_CFrame = data.Target_CFrame
			local player_Releaser = data.Player_Releaser
			local skill_Releaser = data.Skill_Releaser
			local releaser_RootPart = data.Releaser_RootPart
			local skill_Info = data.Skill_Info
			local loop = data.Loop
			local moving_Speed = skill_Info.Moving_Speed
			local duration = skill_Info.Duration
			local _ = releaser_RootPart.Position
			local _ = releaser_RootPart.CFrame
			local child = skills:FindFirstChild((`{releaser_Id}_Turret`))

			if child and (child:GetPivot().Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local animationController = child:FindFirstChild("AnimationController")
				local mainPart = child:FindFirstChild("MainPart")

				if animationController and mainPart then
					local animator = animationController:FindFirstChild("Animator")

					if animator then
						animator:LoadAnimation(skill_Animation.Power[enemy][sound].Release):Play()
					end

					local alignOrientation = mainPart:FindFirstChild("AlignOrientation")

					if alignOrientation then
						alignOrientation.CFrame = CFrame.new(mainPart.Position, target_CFrame.Position)
					end

					local clone = skillFolder[enemy][sound]:Clone()
					clone.CanCollide = false
					clone.Anchored = true
					clone.CFrame = throw_CFrame
					clone.Parent = skills
					Debris:AddItem(clone, 3)
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
								RootPart_Position = throw_CFrame.Position,
								Mouse_Position = target_CFrame.Position,
								Loop = loop,
								Hit_Sound = true
							}
						)
					end

					PlaySound.PlaySound_Character(clone, {
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

							if not (now + 3 <= now2) and Generate.CheckExist(clone) then
								clone.CFrame += CFrame.new(throw_CFrame.Position, target_CFrame.Position).LookVector * moving_Speed * dt
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

					task.wait(2)

					if Generate.CheckExist(clone) then
						local movingObject = clone:FindFirstChild("MovingObject")

						if movingObject then
							TweenService:Create(
								movingObject,
								TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
						end

						if attachment then
							for _, emitter in ipairs(attachment:GetChildren()) do
								if emitter:IsA("ParticleEmitter") and emitter.Enabled then
									emitter.Enabled = false
								end
							end
						end
					end
				end
			end
		end,
		Complete = function(_: string, _: string, _: string, p)
			local child = skills:FindFirstChild((`{p.Releaser_Id}_Turret`))

			if child then
				for _, part in ipairs(child:GetChildren()) do
					if not (part:IsA("BasePart") and part.Transparency < 1) then
						continue
					end

					if (part.Position - currentCamera.CFrame.Position).Magnitude <= 1000 then
						TweenService:Create(
							part,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					else
						part.Transparency = 1
					end
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

			local snow = clone:FindFirstChild("Snow")

			if snow then
				TweenService:Create(snow, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
					Size = createVector(5, 5, 5),
					Transparency = 0
				}):Play()
			end
		end,
		Release = function(p: string, p2: string, _: string, p3)
			local skill_Releaser = p3.Skill_Releaser
			local child = skills:FindFirstChild((`{p3.Releaser_Id}_{p}_{p2}`))

			if child and child.Parent then
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

				local snow = child:FindFirstChild("Snow")

				if snow then
					TweenService:Create(snow, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(0, 0, 0),
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