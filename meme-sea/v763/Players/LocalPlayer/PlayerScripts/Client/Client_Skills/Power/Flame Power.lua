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
				local gun = clone:FindFirstChild("Gun")

				if gun then
					for _, emitter in ipairs(gun:GetChildren()) do
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
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}_Hold`))

			if child then
				child.Name = `{enemy}_{sound}`
				Debris:AddItem(child, 1)
				local gun = child:FindFirstChild("Gun")

				if gun then
					TweenService:Create(gun, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()

					for _, emitter in ipairs(gun:GetChildren()) do
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

				for _, emitter in ipairs(clone:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
						continue
					end

					Generate.SetParticle(emitter)
					emitter.Enabled = true
				end

				task.wait(1)

				if Generate.CheckExist(clone) then
					task.wait(0.5)

					for _, emitter in ipairs(clone:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end
				end
			end
		end
	},
	X = {
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

				for _, emitter in ipairs(clone:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
						continue
					end

					Generate.SetParticle(emitter)
					emitter.Enabled = true
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

				for _, emitter in ipairs(child:GetChildren()) do
					if emitter:IsA("ParticleEmitter") and emitter.Enabled then
						emitter.Enabled = false
					end
				end
			end

			if (hit_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[enemy][sound]:Clone()
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = CFrame.new(hit_Position) * CFrame.new(0, 0.25, 0)
				clone.Parent = skills
				Debris:AddItem(clone, duration + 0.5)
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local now = os.clock()
				local heartbeatConnection = nil
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
					elseif clone and clone.Parent then
						clone.CFrame *= CFrame.fromEulerAnglesXYZ(0, 0.1 * (1 + dt), 0)
					end
				end)
				local pilar_Attachment = clone:FindFirstChild("Pilar_Attachment")
				local pilar_Attachment2 = clone:FindFirstChild("Pilar_Attachment2")
				local attachment = clone:FindFirstChild("Attachment")

				if attachment and pilar_Attachment and pilar_Attachment2 then
					for _, emitter in ipairs(attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							Generate.SetParticle(emitter)
						end

						for _, emitter2 in ipairs(pilar_Attachment:GetChildren()) do
							if emitter2:IsA("ParticleEmitter") then
								Generate.SetParticle(emitter2)
							end
						end

						for _, emitter2 in ipairs(pilar_Attachment2:GetChildren()) do
							if emitter2:IsA("ParticleEmitter") then
								Generate.SetParticle(emitter2)
							end
						end

						task.wait(2)

						for _, emitter2 in ipairs(attachment:GetChildren()) do
							if emitter2:IsA("ParticleEmitter") and emitter2.Enabled then
								emitter2.Enabled = false
							end
						end

						for _, emitter2 in ipairs(pilar_Attachment:GetChildren()) do
							if emitter2:IsA("ParticleEmitter") and emitter2.Enabled then
								emitter2.Enabled = false
							end
						end

						for _, emitter2 in ipairs(pilar_Attachment2:GetChildren()) do
							if emitter2:IsA("ParticleEmitter") and emitter2.Enabled then
								emitter2.Enabled = false
							end
						end
					end
				end
			end
		end
	},
	C = {
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

				for _, emitter in ipairs(clone:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
						continue
					end

					Generate.SetParticle(emitter)
					emitter.Enabled = true
				end
			end
		end,
		Release = function(enemy: string, sound: string, _: string, data)
			local _ = data.Player_Releaser
			local skill_Releaser = data.Skill_Releaser
			local releaser_RootPart = data.Releaser_RootPart
			local mouse_Position = data.Mouse_Position
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

				for _, emitter in ipairs(child:GetChildren()) do
					if emitter:IsA("ParticleEmitter") and emitter.Enabled then
						emitter.Enabled = false
					end
				end
			end

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[enemy][sound]:Clone()
				clone.Name = `{releaser_Id}_{enemy}_{sound}`
				clone:PivotTo(CFrame.new(position, mouse_Position) * CFrame.new(0, 0, -27))
				clone.Parent = skills
				Debris:AddItem(clone, duration + 1)
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local start = clone:FindFirstChild("Start")

				if start then
					local attachment1 = start:FindFirstChild("Attachment1")

					if attachment1 then
						task.spawn(function()
							for _ = 1, 8 do
								for _, emitter in pairs(attachment1:GetChildren()) do
									if emitter:IsA("ParticleEmitter") then
										emitter:Emit(3)
									end
								end

								task.wait(0.1)
							end
						end)
					end

					for _, beam in pairs(start:GetDescendants()) do
						if not beam:IsA("Beam") then
							continue
						end

						beam.Width0 = 0
						beam.Width1 = 5
						beam.Enabled = false
						local v = beam
						task.delay(0.2, function()
							v.Enabled = true
							TweenService:Create(
								v,
								TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Width0 = 30,
									Width1 = 30
								}
							):Play()
						end)
						local v2 = beam
						task.delay(1.25, function()
							TweenService:Create(
								v2,
								TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Width0 = 0,
									Width1 = 0
								}
							):Play()
						end)
					end
				end
			end
		end
	},
	V = {
		Hold = function(p: string, p2: string, _: string, p3)
			local releaser_Id = p3.Releaser_Id
			local skill_Releaser = p3.Skill_Releaser
			local clone = skillFolder[p][p2]:Clone()
			clone.Name = `{releaser_Id}_{p}_{p2}`
			clone.CanCollide = false
			clone.Anchored = true
			clone.Parent = skills
			Debris:AddItem(clone, 60)
			local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
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

							local clone = skillFolder[enemy][`{sound}_ExplosionHitbox`]:Clone()
							clone.CanCollide = false
							clone.Anchored = true
							clone.Transparency = setting.Hitbox_Transparency
							clone.CFrame = CFrame.new(hitbox.Position) * CFrame.new(0, 10, 0)
							clone.Parent = skills
							Debris:AddItem(clone, 1)

							if hitbox and hitbox.Parent then
								hitbox:Destroy()
							end

							Generate.Client_Hitbox(
								player_Releaser,
								skill_Releaser,
								clone,
								nil,
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
								Debris:AddItem(clone2, 3)
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
									task.wait(1)
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
		end
	},
	F = {
		Hold = function(p: string, p2: string, _: string, data)
			local skill_Releaser = data.Skill_Releaser
			local releaser_Id = data.Releaser_Id
			local duration = data.Duration
			local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")
			local lowerTorso = skill_Releaser:FindFirstChild("LowerTorso")
			local clone = skillFolder[p][p2]:Clone()
			clone.Name = `{releaser_Id}_{p}_{p2}`
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

			if lowerTorso then
				local weld = Instance.new("Weld")
				weld.Parent = clone
				weld.Part0 = clone
				weld.Part1 = lowerTorso
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

			while clone and clone.Parent and clone:GetAttribute("Active") and clone:FindFirstChildWhichIsA("Weld") do
				Generate.Generate_Ring(
					CFrame.new(
						humanoidRootPart.Position,
						humanoidRootPart.Position + humanoidRootPart.AssemblyLinearVelocity
					),
					createVector(2.5, 0.1, 2.5),
					createVector(25, 1, 25),
					0.25,
					0.5
				)
				task.wait(0.25)
			end
		end,
		Release = function(p: string, p2: string, _: string, p3)
			local _ = p3.Skill_Releaser
			local child = skills:FindFirstChild((`{p3.Releaser_Id}_{p}_{p2}`))

			if child and child.Parent then
				child:SetAttribute("Active", nil)
				local attachment = child:FindFirstChild("Attachment")

				if attachment then
					for _, emitter in ipairs(attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end
				end

				task.wait(1)

				if child and child.Parent then
					child:Destroy()
				end
			end
		end
	}
}