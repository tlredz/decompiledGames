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
			local moving_Angle = data.Moving_Angle
			local loop = data.Loop
			local position = releaser_RootPart.Position
			local cFrame = releaser_RootPart.CFrame

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[enemy][`{sound}_{loop}`]:Clone()
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = CFrame.new(cFrame.Position, mouse_Position)
				clone.Parent = skills
				Debris:AddItem(clone, duration)
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

				local clone2 = skillFolder[enemy][`{sound}_Part`]:Clone()
				clone2.Name = `{releaser_Id}_{enemy}_{sound}_Part`
				clone2.Parent = skills
				Debris:AddItem(clone2, duration + 1)

				if loop == 0 then
					PlaySound.PlaySound_Character(skill_Releaser, {
						Folder = "Weapon_Sound",
						Enemy = enemy,
						Sound = sound
					})
				end

				for _, effect in ipairs(clone:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) or effect.Enabled then
						continue
					end

					Generate.SetParticle(effect)
					effect.Enabled = true
				end

				if moving_Speed then
					local now = os.clock()
					local heartbeatConnection = nil
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						local now2 = os.clock()

						if now + duration <= now2 or not Generate.CheckExist(clone) then
							if clone then
								clone:Destroy()
							end

							if heartbeatConnection then
								heartbeatConnection:Disconnect()
								heartbeatConnection = nil
							end
						elseif moving_Angle then
							clone.CFrame += (clone.CFrame * moving_Angle).LookVector * moving_Speed * dt
						else
							clone.CFrame += CFrame.new(position, mouse_Position).LookVector * moving_Speed * dt
						end
					end)
				end

				task.wait(1.5)
				local movingObject = Generate.CheckExist(clone) and clone:FindFirstChild("MovingObject")

				if movingObject then
					TweenService:Create(movingObject, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
				end

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
			local hit_Position = data.Hit_Position
			local _ = releaser_RootPart.Position
			local _ = releaser_RootPart.CFrame

			if (hit_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local v = {
					25,
					55,
					6,
					2.25
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

				if releaser_RootPart and releaser_RootPart.Parent then
					local _, v3, _ = CFrame.new(
						releaser_RootPart.Position,
						releaser_RootPart.Position + releaser_RootPart.CFrame.LookVector
					):ToOrientation()
					releaser_RootPart.CFrame = CFrame.new(hit_Position) * CFrame.new(0, 1, 0) * CFrame.fromOrientation(
						0,
						v3,
						0
					)
				end

				local clone = skillFolder[enemy][sound]:Clone()
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = CFrame.new(hit_Position) * CFrame.new(0, 33, 0)
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
				local sword = clone:FindFirstChild("Sword")
				local attachment = clone:FindFirstChild("Attachment")
				local wave = clone:FindFirstChild("Wave")

				if sword and attachment and wave then
					for _, part in ipairs(sword:GetChildren()) do
						if not (part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation")) then
							continue
						end

						TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
							Transparency = 0
						}):Play()
					end

					for _, effect in ipairs(sword:GetDescendants()) do
						if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) or effect.Enabled then
							continue
						end

						Generate.SetParticle(effect)
						effect.Enabled = true
					end

					local tween = TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
						CFrame = clone.CFrame * CFrame.new(0, 30, 0):Inverse()
					})
					tween:Play()
					tween.Completed:Wait()
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
						task.spawn(function()
							local lastTime = tick()

							while clone and clone.Parent and tick() - lastTime <= 2.5 do
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

					if attachment and attachment.Parent then
						for _, emitter in ipairs(attachment:GetChildren()) do
							if emitter:IsA("ParticleEmitter") and emitter.Enabled then
								emitter.Enabled = false
							end
						end
					end

					if sword and sword.Parent then
						for _, effect in ipairs(sword:GetDescendants()) do
							if not ((effect:IsA("ParticleEmitter") or effect:IsA("Beam")) and effect.Enabled) then
								continue
							end

							effect.Enabled = false
						end
					end

					task.wait(1)

					if sword and sword.Parent then
						for _, part in ipairs(sword:GetChildren()) do
							if not (part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation")) then
								continue
							end

							TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
								Transparency = 1
							}):Play()
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