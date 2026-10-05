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

				for _, part in ipairs(child:GetChildren()) do
					if part:IsA("BasePart") or part:IsA("MeshPart") then
						TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
							Transparency = 1
						}):Play()
					end
				end
			end

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[enemy][sound]:Clone()
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

				task.spawn(function()
					while clone and clone.Parent and clone:FindFirstChild("Bullet") and clone:FindFirstChild("Bullet").Transparency < 1 do
						Generate.Generate_Ring(
							clone.CFrame,
							createVector(2.5, 0.1, 2.5),
							createVector(10, 0.5, 10),
							0.25,
							0.5
						)
						task.wait(0.25)
					end
				end)
				task.wait(2.5)

				if Generate.CheckExist(clone) then
					local bullet = clone:FindFirstChild("Bullet")

					if bullet then
						TweenService:Create(bullet, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
							Transparency = 1
						}):Play()
					end

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
				local floppa = child:FindFirstChild("Floppa")

				if floppa then
					floppa.Transparency = 1

					for _, child2 in ipairs(floppa:GetChildren()) do
						if child2:IsA("Decal") or child2:IsA("BasePart") then
							TweenService:Create(child2, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
								Transparency = 1
							}):Play()
						end
					end
				end
			end

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[enemy][sound]:Clone()
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

				local character2 = localPlayer.Character
				task.spawn(function()
					while clone and clone.Parent and clone:FindFirstChild("Floppa") and clone:FindFirstChild("Floppa").Transparency < 1 do
						local floorPart = clone:FindFirstChild("FloorPart")

						if floorPart then
							local raycastParams = RaycastParams.new()
							raycastParams.FilterDescendantsInstances = Folders
							raycastParams.FilterType = Enum.RaycastFilterType.Exclude
							local raycastResult = workspace:Raycast(
								floorPart.Position + createVector(0, 3, 0),
								floorPart.CFrame.UpVector * -10,
								raycastParams
							)

							if raycastResult and raycastResult.Instance then
								local clone2 = skillFolder[enemy][`{sound}_IceFloor`]:Clone()
								clone2.Position = raycastResult.Position + createVector(0, 1, 0)
								clone2.Parent = skills
								clone2.Anchored = true

								if Generate.CheckIfAlive(character2) then
									if character2:GetAttribute("Safezone") then
										clone2.CanCollide = false
									else
										clone2.CanCollide = true
									end
								end

								Debris:AddItem(clone2, 2)
								TweenService:Create(
									clone2,
									TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Transparency = 0
									}
								):Play()
								task.delay(1, function()
									if clone2 and clone2.Parent then
										TweenService:Create(
											clone2,
											TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
											{
												Size = createVector(0, 0, 0),
												Transparency = 1
											}
										):Play()
									end
								end)
							else
								local clone2 = skillFolder[enemy][`{sound}_IceFloor`]:Clone()
								clone2.Position = floorPart.Position + createVector(0, 1, 0)
								clone2.Orientation = Vector3.new(1, math.random(-360, 360), 0)
								clone2.Parent = skills
								clone2.Anchored = true

								if Generate.CheckIfAlive(character2) then
									if character2:GetAttribute("Safezone") then
										clone2.CanCollide = false
									else
										clone2.CanCollide = true
									end
								end

								Debris:AddItem(clone2, 2)
								TweenService:Create(
									clone2,
									TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Transparency = 0
									}
								):Play()
								task.delay(1, function()
									if clone2 and clone2.Parent then
										TweenService:Create(
											clone2,
											TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
											{
												Size = createVector(0, 0, 0),
												Transparency = 1
											}
										):Play()
									end
								end)
							end
						end

						task.wait(0.05)
					end
				end)
				local floppa = clone:FindFirstChild("Floppa")

				if floppa then
					for _, emitter in ipairs(floppa:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							Generate.SetParticle(emitter)
						end
					end
				end

				task.wait(2.5)
				local floppa2 = Generate.CheckExist(clone) and clone:FindFirstChild("Floppa")

				if floppa2 then
					for _, child2 in ipairs(floppa2:GetChildren()) do
						if child2:IsA("ParticleEmitter") and child2.Enabled then
							child2.Enabled = false
						elseif child2:IsA("BasePart") then
							TweenService:Create(child2, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
								Transparency = 1
							}):Play()
						elseif child2:IsA("Decal") then
							TweenService:Create(child2, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
								Transparency = 1
							}):Play()
						end
					end

					TweenService:Create(floppa2, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
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
				clone.CFrame = CFrame.new(position) * CFrame.new(0, -2, 0) * CFrame.fromOrientation(0, v, 0)

				if clone.Position.Y <= -95 and localPlayer.Name ~= skill_Releaser.Name then
					clone.CanCollide = true
				else
					clone.CanCollide = false
				end

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
				local movingObject = clone:FindFirstChild("MovingObject")

				if movingObject then
					TweenService:Create(
						movingObject,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = createVector(225, 1, 225),
							Transparency = 0
						}
					):Play()
				end

				task.wait(2)
				local movingObject2 = Generate.CheckExist(clone) and clone:FindFirstChild("MovingObject")

				if movingObject2 then
					TweenService:Create(
						movingObject2,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 1, 0),
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
			local humanoidRootPart = p3.Skill_Releaser:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				local clone = skillFolder[p][p2]:Clone()
				clone.Name = `{releaser_Id}_{p}_{p2}`
				clone.CanCollide = false
				clone.Anchored = true
				clone.Parent = skills
				Debris:AddItem(clone, 60)
				clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 30, 0)
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(50, 50, 50),
					Transparency = 0
				}):Play()
				local stroke = clone:FindFirstChild("Stroke")
				local attachment = clone:FindFirstChild("Attachment")

				if stroke then
					TweenService:Create(stroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(55, 55, 55),
						Transparency = 0
					}):Play()
				end

				task.wait(0.25)

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
			local v = CFrame.new(position, mouse_Position) * CFrame.new(0, 30, 0)
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}`))

			if child then
				Debris:AddItem(child, duration + 1)
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local Folders2 = {
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
				overlapParams.FilterDescendantsInstances = Folders2
				overlapParams.FilterType = Enum.RaycastFilterType.Exclude
				local hitbox = child:FindFirstChild("Hitbox")

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
							local clone = skillFolder[enemy][`{sound}_ExplosionHitbox`]:Clone()
							clone.CanCollide = false
							clone.Anchored = true
							clone.Transparency = setting.Hitbox_Transparency
							clone.CFrame = CFrame.new(hitbox.Position) * CFrame.new(0, 10, 0)
							clone.Parent = skills
							Debris:AddItem(clone, duration)

							if hitbox and hitbox.Parent then
								hitbox:Destroy()
							end

							Generate.Client_Hitbox(
								player_Releaser,
								skill_Releaser,
								clone,
								overlapParams2,
								enemy,
								sound,
								duration - 3,
								{
									Moving_Speed = moving_Speed,
									Skill_Type = skill_Info.Skill_Type,
									RootPart_Position = position,
									Mouse_Position = mouse_Position
								}
							)

							if child and child.Parent then
								child:SetAttribute("Exploded", true)
								local v2 = {
									24,
									53,
									7,
									1.25
								}
								local clone2 = skillFolder[enemy][`{sound}_Explosion`]:Clone()
								clone2:PivotTo(CFrame.new(child.Position) * CFrame.new(0, 5, 0))
								clone2.Parent = skills
								Debris:AddItem(clone2, 2)
								PlaySound.PlaySound_Character(clone2, {
									Folder = "Power_Sound",
									Enemy = enemy,
									Sound = `{sound}_Explosion`
								})
								local ball = clone2:FindFirstChild("Ball")
								local stroke = clone2:FindFirstChild("Stroke")

								if ball and stroke then
									Generate.Generate_Ground(clone2.PrimaryPart, v2[1], v2[2], v2[3], v2[4])
									TweenService:Create(
										ball,
										TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Size = createVector(100, 100, 100),
											CFrame = ball.CFrame * CFrame.Angles(0, -3.141592653589793, 0),
											Transparency = 0
										}
									):Play()
									TweenService:Create(
										stroke,
										TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Size = createVector(110, 110, 110),
											CFrame = stroke.CFrame * CFrame.Angles(0, -3.141592653589793, 0),
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
									TweenService:Create(
										stroke,
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

						if not (now + duration <= now2) and Generate.CheckExist(child) and not child:GetAttribute("Exploded") then
							child.CFrame += CFrame.new(v.Position, mouse_Position).LookVector * moving_Speed * dt
							return
						end

						if child then
							child:Destroy()
						end

						if heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end
					end)
				end

				task.wait(3)

				if Generate.CheckExist(child) then
					TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						Size = createVector(0, 0, 0),
						Transparency = 1
					}):Play()
					local stroke = child:FindFirstChild("Stroke")
					local attachment = child:FindFirstChild("Attachment")

					if stroke then
						TweenService:Create(
							stroke,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = createVector(0, 0, 0),
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
		end,
		Explosion = function(enemy: string, p2: string, _: string, p3)
			local releaser_Id = p3.Releaser_Id
			local explosion_CFrame = p3.Explosion_CFrame
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{p2}`))

			if child then
				child:SetAttribute("Exploded", true)
				local v = {
					24,
					53,
					7,
					1
				}
				local clone = skillFolder[enemy][`{p2}_Explosion`]:Clone()
				clone:PivotTo(explosion_CFrame)
				clone.Parent = skills
				Debris:AddItem(clone, 2)
				PlaySound.PlaySound_Character(clone, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = `{p2}_Explosion`
				})
				local ball = clone:FindFirstChild("Ball")
				local stroke = clone:FindFirstChild("Stroke")

				if ball and stroke then
					Generate.Generate_Ground(clone.PrimaryPart, v[1], v[2], v[3], v[4])
					TweenService:Create(ball, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(100, 100, 100),
						CFrame = ball.CFrame * CFrame.Angles(0, -3.141592653589793, 0),
						Transparency = 0
					}):Play()
					TweenService:Create(stroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(110, 110, 110),
						CFrame = stroke.CFrame * CFrame.Angles(0, -3.141592653589793, 0),
						Transparency = 0
					}):Play()
					task.wait(0.5)
					TweenService:Create(ball, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
					TweenService:Create(stroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
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
			local lowerTorso = skill_Releaser:FindFirstChild("LowerTorso")
			PlaySound.PlaySound_Character(humanoidRootPart, {
				Folder = "Power_Sound",
				Enemy = enemy,
				Sound = sound
			})
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
			local weld = lowerTorso and clone:FindFirstChild("Weld")

			if weld then
				weld.Part1 = lowerTorso
			end

			local iceFloppa = clone:FindFirstChild("IceFloppa")

			if iceFloppa then
				for _, trail in ipairs(clone:GetChildren()) do
					if not trail:IsA("Trail") or trail.Enabled then
						continue
					end

					trail.Enabled = true
				end

				for _, emitter in ipairs(iceFloppa:GetChildren()) do
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
			local child = skills:FindFirstChild((`{p3.Releaser_Id}_{p}_{p2}`))

			if child and child.Parent then
				local weld = child:FindFirstChild("Weld")

				if weld then
					child.Anchored = true
					weld:Destroy()
				end

				local iceFloppa = child:FindFirstChild("IceFloppa")

				if iceFloppa then
					for _, trail in ipairs(child:GetChildren()) do
						if trail:IsA("Trail") and trail.Enabled then
							trail.Enabled = false
						end
					end

					for _, emitter in ipairs(iceFloppa:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end

					TweenService:Create(iceFloppa, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
					local ears_Ice = iceFloppa:FindFirstChild("Ears_Ice")
					local ice = iceFloppa:FindFirstChild("Ice")

					if ears_Ice then
						TweenService:Create(ears_Ice, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							Transparency = 1
						}):Play()
					end

					if ice then
						TweenService:Create(ice, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							Transparency = 1
						}):Play()
					end

					for _, decal in ipairs(iceFloppa:GetChildren()) do
						if decal:IsA("Decal") then
							TweenService:Create(decal, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
								Transparency = 1
							}):Play()
						end
					end
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