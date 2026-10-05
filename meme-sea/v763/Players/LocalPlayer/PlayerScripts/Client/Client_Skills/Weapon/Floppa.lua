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
				clone.CFrame = CFrame.new(position, mouse_Position) * CFrame.new(0, 3, 0)
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
				PlaySound.PlaySound_Character(clone, {
					Folder = "Weapon_Sound",
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

				local movingObject = clone:FindFirstChild("MovingObject")

				if movingObject then
					for _, effect in ipairs(movingObject:GetChildren()) do
						if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) or effect.Enabled then
							continue
						end

						Generate.SetParticle(effect)
						effect.Enabled = true
					end
				end

				task.wait(1.5)
				local movingObject2 = Generate.CheckExist(clone) and clone:FindFirstChild("MovingObject")

				if movingObject2 then
					TweenService:Create(movingObject2, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
					local ears = movingObject2:FindFirstChild("Ears")

					if ears then
						TweenService:Create(ears, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							Transparency = 1
						}):Play()
					end

					for _, decal in ipairs(movingObject2:GetChildren()) do
						if decal:IsA("Decal") then
							TweenService:Create(decal, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
								Transparency = 1
							}):Play()
						end
					end

					for _, effect in ipairs(movingObject2:GetChildren()) do
						if not ((effect:IsA("ParticleEmitter") or effect:IsA("Trail")) and effect.Enabled) then
							continue
						end

						effect.Enabled = false
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
	},
	X = {
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

			if (hit_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[enemy][`{sound}_Part`]:Clone()
				clone.Name = `{releaser_Id}_{enemy}_{sound}_Part`
				clone.Parent = skills
				Debris:AddItem(clone, duration + 1)
				task.delay(0.15, function()
					PlaySound.PlaySound_Character(skill_Releaser, {
						Folder = "Weapon_Sound",
						Enemy = enemy,
						Sound = sound
					})
				end)
				local _, v, _ = CFrame.new(position, position + -cFrame.LookVector):ToOrientation()
				task.delay(0.5, function()
					local clone2 = skillFolder[enemy][`{sound}_Hitbox`]:Clone()
					clone2.CanCollide = false
					clone2.Anchored = true
					clone2.Transparency = setting.Hitbox_Transparency
					clone2.CFrame = CFrame.new(hit_Position) * CFrame.new(0, 5, 0) * CFrame.fromOrientation(0, v, 0)
					clone2.Parent = skills
					Debris:AddItem(clone2, duration + 1 or 10)
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
						duration,
						{
							Moving_Speed = moving_Speed,
							Skill_Type = skill_Info.Skill_Type,
							RootPart_Position = position,
							Mouse_Position = mouse_Position,
							Weapon_Effect = true
						}
					)
				end)

				for _ = 1, 20 do
					local v2 = math.random(-65, 65)
					local v3 = math.random(-65, 65)
					local clone2 = skillFolder[enemy][sound]:Clone()
					clone2.CanCollide = false
					clone2.Anchored = true
					clone2.CFrame = CFrame.new(hit_Position) * CFrame.new(v2, 75, v3) * CFrame.fromOrientation(0, v, 0)
					clone2.Parent = skills
					Debris:AddItem(clone2, 1.5)
					local movingObject = clone2:FindFirstChild("MovingObject")

					if movingObject then
						local ears = movingObject:FindFirstChild("Ears")

						if ears then
							TweenService:Create(
								ears,
								TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Transparency = 0
								}
							):Play()

							for _, decal in ipairs(movingObject:GetChildren()) do
								if decal:IsA("Decal") then
									TweenService:Create(
										decal,
										TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Transparency = 0
										}
									):Play()
								end
							end

							local movingObject2 = clone2:FindFirstChild("MovingObject")

							if movingObject2 then
								for _, emitter in ipairs(movingObject2:GetChildren()) do
									if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
										continue
									end

									Generate.SetParticle(emitter)
									emitter.Enabled = true
								end
							end

							local completedConnection = nil
							local tween = TweenService:Create(
								clone2,
								TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									CFrame = clone2.CFrame * CFrame.new(0, 73, 0):Inverse()
								}
							)
							tween:Play()
							local v4 = clone2
							local v5 = movingObject
							local v6 = ears
							completedConnection = tween.Completed:Connect(function()
								completedConnection:Disconnect()
								completedConnection = nil
								local movingObject3 = v4:FindFirstChild("MovingObject")

								if movingObject3 then
									for i, emitter in ipairs(movingObject3:GetChildren()) do
										if emitter:IsA("ParticleEmitter") and emitter.Enabled then
											emitter.Enabled = false
										end
									end
								end

								PlaySound.PlaySound_Character(v4, {
									Folder = "Weapon_Sound",
									Enemy = enemy,
									Sound = `{sound}_Explosion`
								})

								for i, decal in ipairs(v5:GetChildren()) do
									if decal:IsA("Decal") then
										TweenService:Create(
											decal,
											TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
											{
												Transparency = 1
											}
										):Play()
									end
								end

								TweenService:Create(
									v6,
									TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Transparency = 1
									}
								):Play()
							end)
						end
					end

					task.wait(0.1)
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