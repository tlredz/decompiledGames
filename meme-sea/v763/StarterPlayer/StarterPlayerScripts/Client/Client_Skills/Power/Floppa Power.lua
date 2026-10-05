local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local modules = ReplicatedStorage:WaitForChild("Modules")
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
local currentCamera2 = workspace.CurrentCamera
local CameraShaker = require(modules.CameraShaker)
local v = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(p)
	currentCamera2.CFrame *= p
end)
v:Start()
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
				local weld = clone:FindFirstChild("Weld")
				weld.Part1 = leftHand
				local floppa = clone:FindFirstChild("Floppa")

				if floppa then
					for _, emitter in ipairs(floppa:GetChildren()) do
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
				local floppa = child:FindFirstChild("Floppa")

				if floppa then
					TweenService:Create(floppa, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
					local ears = floppa:FindFirstChild("Ears")

					if ears then
						TweenService:Create(ears, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							Transparency = 1
						}):Play()
					end

					for _, child2 in ipairs(floppa:GetChildren()) do
						if child2:IsA("Decal") then
							TweenService:Create(child2, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
								Transparency = 1
							}):Play()
						elseif child2:IsA("ParticleEmitter") and child2.Enabled then
							child2.Enabled = false
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
						duration - 0.5,
						{
							Moving_Speed = moving_Speed,
							Skill_Type = skill_Info.Skill_Type,
							RootPart_Position = position,
							Mouse_Position = mouse_Position
						}
					)
				end

				PlaySound.PlaySound_Character(clone, {
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

				for _, emitter in ipairs(clone:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
						continue
					end

					Generate.SetParticle(emitter)
					emitter.Enabled = true
				end

				task.wait(1.5)

				if Generate.CheckExist(clone) then
					TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
					local ears = clone:FindFirstChild("Ears")

					if ears then
						TweenService:Create(ears, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
							Transparency = 1
						}):Play()
					end

					for _, decal in ipairs(clone:GetChildren()) do
						if decal:IsA("Decal") then
							TweenService:Create(decal, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
								Transparency = 1
							}):Play()
						end
					end

					for _, emitter in ipairs(clone:GetDescendants()) do
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
				local floppa = clone:FindFirstChild("Floppa")
				local attachment = floppa and floppa:FindFirstChild("Attachment")

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
			local mouse_Position = data.Mouse_Position
			local skill_Info = data.Skill_Info
			local releaser_Id = data.Releaser_Id
			local _ = skill_Info.Moving_Speed
			local _ = skill_Info.Duration
			local position = releaser_RootPart.Position
			local _ = releaser_RootPart.CFrame
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}_Hold`))

			if child then
				child.Name = `{enemy}_{sound}`
				Debris:AddItem(child, 1)
				local floppa = child:FindFirstChild("Floppa")

				if floppa then
					TweenService:Create(floppa, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
					local ears = floppa:FindFirstChild("Ears")

					if ears then
						TweenService:Create(ears, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							Transparency = 1
						}):Play()
					end

					for _, decal in ipairs(floppa:GetChildren()) do
						if decal:IsA("Decal") then
							TweenService:Create(decal, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
								Transparency = 1
							}):Play()
						end
					end

					local attachment = floppa:FindFirstChild("Attachment")

					if attachment then
						for _, emitter in ipairs(attachment:GetChildren()) do
							if emitter:IsA("ParticleEmitter") and emitter.Enabled then
								emitter.Enabled = false
							end
						end
					end
				end
			end

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})

				for _ = 1, 30 do
					if not Generate.CheckExist(releaser_RootPart) then
						break
					end

					local clone = skillFolder[enemy][sound]:Clone()
					clone.CanCollide = false
					clone.Anchored = true
					local number = Random.new():NextNumber(-50, 50)
					local number2 = Random.new():NextNumber(0, 10)
					local number3 = Random.new():NextNumber(0, -2.5)
					clone.CFrame = CFrame.new(position, mouse_Position) * CFrame.new(number, number2, number3)
					clone.Parent = skills
					Debris:AddItem(clone, 2)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						CFrame = clone.CFrame * CFrame.new(0, 0, Random.new():NextNumber(-85, -95))
					}):Play()

					for _, emitter in ipairs(clone:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
							continue
						end

						Generate.SetParticle(emitter)
						emitter.Enabled = true
					end

					local folder = clone
					task.delay(0.5, function()
						if Generate.CheckExist(folder) then
							TweenService:Create(folder, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
								Transparency = 1
							}):Play()
							local ears = folder:FindFirstChild("Ears")

							if ears then
								TweenService:Create(ears, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
									Transparency = 1
								}):Play()
							end

							for i, decal in ipairs(folder:GetChildren()) do
								if decal:IsA("Decal") then
									TweenService:Create(decal, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
										Transparency = 1
									}):Play()
								end
							end

							for i, emitter in ipairs(folder:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") and emitter.Enabled then
									emitter.Enabled = false
								end
							end
						end
					end)
					task.wait(0.05)
				end

				if releaser_RootPart and releaser_RootPart.Parent then
					PlaySound.FadingSound_Out(releaser_RootPart, 1, sound)
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
			local releaser_Id = data.Releaser_Id
			local selected_CFrame = data.Selected_CFrame
			local _ = skill_Info.Moving_Speed
			local duration = skill_Info.Duration
			local position = releaser_RootPart.Position
			local _ = releaser_RootPart.CFrame

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 and Generate.CheckExist(releaser_RootPart) then
				local clone = skillFolder[enemy][`{sound}_Shrine`]:Clone()
				clone:PivotTo(selected_CFrame * CFrame.new(0, -30, 25))
				clone.Parent = skills
				Debris:AddItem(clone, duration)
				local clone2 = skillFolder[enemy][`{sound}_Part`]:Clone()
				clone2.Name = `{releaser_Id}_{enemy}_{sound}_Part`
				clone2.Parent = skills
				Debris:AddItem(clone2, duration + 1)
				local primaryPart = clone.PrimaryPart

				if primaryPart then
					TweenService:Create(
						primaryPart,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CFrame = primaryPart.CFrame * CFrame.new(0, 30, 0)
						}
					):Play()
				end

				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				task.wait(0.5)
				local clone3 = skillFolder[enemy][sound]:Clone()
				clone3.CanCollide = false
				clone3.Anchored = true
				clone3.CFrame = selected_CFrame * CFrame.new(0, 20, -75)
				clone3.Parent = skills
				Debris:AddItem(clone3, duration)

				for _, emitter in ipairs(clone3:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
						continue
					end

					Generate.SetParticle(emitter)
					emitter.Enabled = true
				end

				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = `{sound}_Domain`
				})
				task.wait(1.75)

				if Generate.CheckExist(clone3) then
					for _, emitter in ipairs(clone3:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end
				end

				if clone and clone.Parent then
					local primaryPart2 = clone.PrimaryPart
					local middle = clone:FindFirstChild("Middle")

					if primaryPart2 then
						TweenService:Create(
							primaryPart2,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								CFrame = primaryPart2.CFrame * CFrame.new(0, -40, 0)
							}
						):Play()
					end

					if middle then
						for _, decal in ipairs(middle:GetChildren()) do
							if decal:IsA("Decal") and decal.Transparency < 1 then
								TweenService:Create(
									decal,
									TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Transparency = 1
									}
								):Play()
							end
						end
					end

					for _, part in ipairs(clone:GetChildren()) do
						if part:IsA("BasePart") and part.Transparency < 1 then
							TweenService:Create(
								part,
								TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
						end
					end
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
	V = {
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
			local _ = data.Player_Releaser
			local skill_Releaser = data.Skill_Releaser
			local releaser_RootPart = data.Releaser_RootPart
			local mouse_Position = data.Mouse_Position
			local skill_Info = data.Skill_Info
			local releaser_Id = data.Releaser_Id
			local _ = skill_Info.Moving_Speed
			local duration = skill_Info.Duration
			local hit_Position = data.Hit_Position
			local position = releaser_RootPart.Position
			local _ = releaser_RootPart.CFrame
			local v2 = {
				40,
				75,
				7,
				1.75
			}
			local _, v3, _ = CFrame.new(position, mouse_Position):ToOrientation()
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}_Hold`))

			if child then
				child.Name = `{enemy}_{sound}`
				Debris:AddItem(child, 1)
				local floppa = child:FindFirstChild("Floppa")

				if floppa then
					TweenService:Create(floppa, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
					local ears = floppa:FindFirstChild("Ears")

					if ears then
						TweenService:Create(ears, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							Transparency = 1
						}):Play()
					end

					for _, decal in ipairs(floppa:GetChildren()) do
						if decal:IsA("Decal") then
							TweenService:Create(decal, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
								Transparency = 1
							}):Play()
						end
					end

					local attachment = floppa:FindFirstChild("Attachment")

					if attachment then
						for _, emitter in ipairs(attachment:GetChildren()) do
							if emitter:IsA("ParticleEmitter") and emitter.Enabled then
								emitter.Enabled = false
							end
						end
					end
				end
			end

			if (hit_Position - currentCamera.CFrame.Position).Magnitude <= 2000 then
				local clone = skillFolder[enemy][sound]:Clone()
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = CFrame.new(hit_Position) * CFrame.new(0, 100, 0) * CFrame.fromOrientation(0, v3, 0)
				clone.Parent = skills
				Debris:AddItem(clone, duration + 1)
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				os.clock()
				local floppa = clone:FindFirstChild("Floppa")
				floppa:FindFirstChild("Attachment")
				local wave = clone:FindFirstChild("Wave")

				if floppa and wave then
					local attachment = floppa:FindFirstChild("Attachment")
					local ears = floppa:FindFirstChild("Ears")

					if attachment and ears then
						for _, trail in ipairs(floppa:GetChildren()) do
							if not trail:IsA("Trail") or trail.Enabled then
								continue
							end

							trail.Enabled = true
						end

						local tween = TweenService:Create(
							clone,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								CFrame = clone.CFrame * CFrame.new(0, 90, 0):Inverse()
							}
						)
						tween:Play()
						tween.Completed:Wait()
						PlaySound.PlaySound_Character(clone, {
							Folder = "Power_Sound",
							Enemy = enemy,
							Sound = `{sound}_Explosion`
						})
						local raycastParams = RaycastParams.new()
						raycastParams.FilterDescendantsInstances = Folders
						raycastParams.FilterType = Enum.RaycastFilterType.Exclude
						local raycastResult = workspace:Raycast(
							clone.Position,
							clone.CFrame.UpVector * -25,
							raycastParams
						)
						Color3.fromRGB(163, 162, 165)
						local _ = Enum.Material.Concrete
						TweenService:Create(
							floppa,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = floppa.Size * 2
							}
						):Play()
						TweenService:Create(ears, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Size = ears.Size * 2
						}):Play()
						local weld = ears:FindFirstChild("Weld")

						if weld then
							TweenService:Create(
								weld,
								TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									C1 = weld.C1 * CFrame.new(0, 15, 0)
								}
							):Play()
						end

						if raycastResult and raycastResult.Instance then
							Generate.Throwing_Rock(enemy, clone, {
								HitPart = raycastResult.Instance,
								Distance = 0,
								Amount = 20,
								Duration = 3,
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
									Min = -100,
									Max = 100
								},
								Up_Down = {
									Min = 75,
									Max = 75
								},
								Front_Back = {
									Min = -100,
									Max = 100
								}
							})
							Generate.Generate_Ground(clone, v2[1], v2[2], v2[3], v2[4])

							for _, emitter in ipairs(attachment:GetChildren()) do
								if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
									continue
								end

								Generate.SetParticle(emitter)
								emitter.Enabled = true
							end
						else
							task.spawn(function()
								local lastTime = tick()

								while clone and clone.Parent and tick() - lastTime <= 2 do
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
					end

					local character2 = localPlayer.Character

					if Generate.CheckIfAlive(character2) then
						local humanoidRootPart = character2:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart and (humanoidRootPart.Position - clone.Position).Magnitude <= 75 and not localPlayer:GetAttribute("No_CameraShake") then
							v:Shake(CameraShaker.Presets.MiniExplosion)
						end
					end

					task.wait(1)

					for _, emitter in ipairs(attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end

					for _, trail in ipairs(floppa:GetChildren()) do
						if trail:IsA("Trail") and trail.Enabled then
							trail.Enabled = false
						end
					end

					task.wait(1)
					TweenService:Create(floppa, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
					local ears2 = floppa:FindFirstChild("Ears")

					if ears2 then
						TweenService:Create(ears2, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							Transparency = 1
						}):Play()
					end

					for _, decal in ipairs(floppa:GetChildren()) do
						if decal:IsA("Decal") then
							TweenService:Create(decal, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
								Transparency = 1
							}):Play()
						end
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
			local lowerTorso = skill_Releaser:FindFirstChild("LowerTorso")
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

			if lowerTorso then
				local weld = Instance.new("Weld")
				weld.Parent = clone
				weld.Part0 = clone
				weld.Part1 = lowerTorso
			end

			if humanoidRootPart then
				PlaySound.PlaySound_Character(humanoidRootPart, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
			end

			Generate.Invisible(skill_Releaser)

			for _, effect in ipairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") and not effect.Enabled then
					Generate.SetParticle(effect)
					effect.Enabled = true
				elseif effect:IsA("Trail") and not effect.Enabled then
					effect.Enabled = true
				end
			end
		end,
		Release = function(p: string, p2: string, _: string, p3)
			local skill_Releaser = p3.Skill_Releaser
			local folder = skills:FindFirstChild((`{p3.Releaser_Id}_{p}_{p2}`))

			if folder and folder.Parent then
				Debris:AddItem(folder, 1)
				local weld = folder:FindFirstChild("Weld")

				if weld then
					weld:Destroy()
					folder.Anchored = true
				end

				for _, effect in ipairs(folder:GetDescendants()) do
					if effect:IsA("ParticleEmitter") and effect.Enabled then
						effect:Destroy()
					elseif effect:IsA("Trail") and effect.Enabled then
						effect.Enabled = false
					end
				end

				TweenService:Create(folder, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					Transparency = 1
				}):Play()
				local ears = folder:FindFirstChild("Ears")

				if ears then
					TweenService:Create(ears, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
				end

				for _, decal in ipairs(folder:GetChildren()) do
					if decal:IsA("Decal") then
						TweenService:Create(decal, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							Transparency = 1
						}):Play()
					end
				end
			end

			if skill_Releaser and skill_Releaser.Parent then
				Generate.Visible(skill_Releaser)
				local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					PlaySound.FadingSound_Out(humanoidRootPart, 0.5, p2)
				end
			end
		end
	}
}