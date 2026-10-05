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

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[enemy][sound]:Clone()
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = CFrame.new(position, mouse_Position)
				clone.Parent = skills
				Debris:AddItem(clone, duration + 0.5)
				local clone2 = skillFolder[enemy][`{sound}_Part`]:Clone()
				clone2.Name = `{releaser_Id}_{enemy}_{sound}_Part`
				clone2.Parent = skills
				Debris:AddItem(clone2, duration + 1)
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
							Weapon_Effect = true
						}
					)
				end

				PlaySound.PlaySound_Character(clone, {
					Folder = "Weapon_Sound",
					Enemy = enemy,
					Sound = sound
				})

				if moving_Speed then
					local now = os.clock()
					local heartbeatConnection = nil
					local movingObject = clone:FindFirstChild("MovingObject")
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						local now2 = os.clock()

						if now + duration + 0.5 <= now2 or not Generate.CheckExist(clone) then
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
								movingObject.CFrame *= CFrame.fromEulerAnglesXYZ(0.1, 0, 0)
							end
						end
					end)
				end

				for _, effect in ipairs(clone:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) or effect.Enabled then
						continue
					end

					effect.Enabled = true
				end

				task.wait(1.25)

				if Generate.CheckExist(clone) then
					local movingObject = clone:FindFirstChild("MovingObject")

					if movingObject then
						for _, part in ipairs(movingObject:GetChildren()) do
							if part:IsA("UnionOperation") then
								TweenService:Create(part, TweenInfo.new(0.75, Enum.EasingStyle.Sine), {
									Transparency = 1
								}):Play()
							end
						end

						TweenService:Create(movingObject, TweenInfo.new(0.75, Enum.EasingStyle.Sine), {
							Transparency = 1
						}):Play()
					end
				end

				task.wait(0.75)

				for _, effect in ipairs(clone:GetDescendants()) do
					if not ((effect:IsA("ParticleEmitter") or effect:IsA("Trail")) and effect.Enabled) then
						continue
					end

					effect.Enabled = false
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
						Folder = "Weapon_Sound",
						Enemy = enemy,
						Sound = `{p2}_Hit`
					})
				end
			end
		end
	},
	X = {
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

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local v = {
					25,
					55,
					6,
					2
				}
				local v2 = {
					Amount = 15,
					Size = createVector(2.5, 2.5, 2.5),
					Velocity = {
						X = {
							Min = -75,
							Max = 75
						},
						Y = {
							Min = 75,
							Max = 75
						},
						Z = {
							Min = -75,
							Max = 75
						}
					}
				}
				local clone = skillFolder[enemy][sound]:Clone()
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = cFrame * CFrame.new(0, 1, 0)
				clone.Parent = skills
				Debris:AddItem(clone, duration + 0.5)
				local clone2 = skillFolder[enemy][`{sound}_Part`]:Clone()
				clone2.Name = `{releaser_Id}_{enemy}_{sound}_Part`
				clone2.Parent = skills
				Debris:AddItem(clone2, duration + 1)
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Weapon_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local attachment = clone:FindFirstChild("Attachment")
				local wave = clone:FindFirstChild("Wave")

				if attachment and wave then
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = Folders
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					local raycastResult = workspace:Raycast(clone.Position, clone.CFrame.UpVector * -10, raycastParams)
					Color3.fromRGB(163, 162, 165)
					local _ = Enum.Material.Concrete

					if raycastResult and raycastResult.Instance then
						Generate.Generate_FlyingRock(clone.Position, v2.Amount, v2.Size, v2.Velocity)
						Generate.Generate_Ground(clone, v[1], v[2], v[3], v[4])

						for _, emitter in ipairs(attachment:GetChildren()) do
							if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
								continue
							end

							Generate.SetParticle(emitter)
							emitter.Enabled = true
						end
					else
						local pink = attachment:FindFirstChild("Pink")

						if pink and not pink.Enabled then
							Generate.SetParticle(pink)
							pink.Enabled = true
						end

						task.spawn(function()
							local lastTime = tick()

							while clone and clone.Parent and tick() - lastTime <= 2 do
								local clone3 = wave:Clone()
								clone3.Transparency = 0.1
								clone3.CFrame = clone.CFrame * CFrame.new(0, -1.35, 0)
								clone3.Anchored = true
								clone3.Parent = clone
								Debris:AddItem(clone3, 1)
								TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Cubic), {
									Size = createVector(175, 10, 175),
									Transparency = 1
								}):Play()
								task.wait(0.25)
							end
						end)
					end

					task.wait(1.5)

					for _, emitter in ipairs(attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
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
						Folder = "Weapon_Sound",
						Enemy = enemy,
						Sound = `{p2}_Hit`
					})
				end
			end
		end
	}
}