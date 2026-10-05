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
				clone.Name = `{releaser_Id}_{enemy}_{sound}`
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = CFrame.new(position, mouse_Position) * CFrame.new(0, 2, 0)
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
							Single_Target = skill_Info.Single_Target,
							RootPart_Position = position,
							Mouse_Position = mouse_Position,
							Weapon_Effect = true
						}
					)
				end

				local clone2 = skillFolder[enemy][`{sound}_Part`]:Clone()
				clone2.Name = `{releaser_Id}_{enemy}_{sound}_Part`
				clone2.Parent = skills
				Debris:AddItem(clone2, duration)
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Weapon_Sound",
					Enemy = enemy,
					Sound = sound
				})
				clone:SetAttribute("Spinning", true)
				local movingObject = clone:FindFirstChild("MovingObject")

				if movingObject then
					if moving_Speed then
						local now = os.clock()
						local heartbeatConnection = nil
						heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
							local now2 = os.clock()

							if not (now + duration <= now2) and Generate.CheckExist(clone) and clone:GetAttribute("Spinning") then
								clone.CFrame += CFrame.new(position, mouse_Position).LookVector * moving_Speed * dt
							elseif heartbeatConnection then
								heartbeatConnection:Disconnect()
								heartbeatConnection = nil
							end
						end)
					end

					for _, effect in ipairs(movingObject:GetChildren()) do
						if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) or effect.Enabled then
							continue
						end

						Generate.SetParticle(effect)
						effect.Enabled = true
					end

					task.wait(1.5)

					if Generate.CheckExist(clone) then
						local movingObject2 = clone:FindFirstChild("MovingObject")

						if movingObject2 then
							TweenService:Create(
								movingObject2,
								TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()

							for _, decal in ipairs(movingObject:GetChildren()) do
								if decal:IsA("Decal") then
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
					end

					task.wait(0.5)

					for _, effect in ipairs(movingObject:GetChildren()) do
						if not ((effect:IsA("ParticleEmitter") or effect:IsA("Trail")) and effect.Enabled) then
							continue
						end

						effect.Enabled = false
					end
				end
			end
		end,
		Destroy = function(self: string, p2: string, _: string, p3)
			local releaser_Id = p3.Releaser_Id
			local _ = p3.Releaser_Character
			local child = skills:FindFirstChild((`{releaser_Id}_{self}_{p2}`))

			if child then
				child:SetAttribute("Spinning", nil)
				Debris:AddItem(child, 1)
				local movingObject = child:FindFirstChild("MovingObject")

				if movingObject then
					movingObject.Transparency = 1
					TweenService:Create(
						movingObject,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = movingObject.Size * 1.5
						}
					):Play()
					TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						CFrame = child.CFrame * CFrame.Angles(0, -3.141592653589793, 0)
					}):Play()

					for _, child2 in ipairs(movingObject:GetChildren()) do
						if child2:IsA("ParticleEmitter") or child2:IsA("Trail") then
							if child2.Enabled then
								child2.Enabled = false
							end
						elseif child2:IsA("Decal") then
							TweenService:Create(
								child2,
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
						Folder = "Weapon_Sound",
						Enemy = enemy,
						Sound = `{p2}_Hit`
					})
				end
			end
		end
	},
	X = {
		Hold = function(enemy: string, sound: string, _: string, data)
			local player_Releaser = data.Player_Releaser
			local skill_Releaser = data.Skill_Releaser
			local releaser_RootPart = data.Releaser_RootPart
			local _ = data.Mouse_Position
			local skill_Info = data.Skill_Info
			local releaser_Id = data.Releaser_Id
			local _ = skill_Info.Moving_Speed
			local duration = skill_Info.Duration
			local cooldown = player_Releaser:FindFirstChild("Cooldown")
			local position = releaser_RootPart.Position
			local _ = releaser_RootPart.CFrame

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[enemy][`{sound}_Part`]:Clone()
				clone.Name = `{releaser_Id}_{enemy}_{sound}_Part`
				clone.Parent = skills
				Debris:AddItem(clone, duration + 1)

				if cooldown then
					for _ = 1, 16 do
						if not (cooldown:FindFirstChild((`Weapon_{sound}_Holding`)) and Generate.CheckExist(releaser_RootPart)) then
							break
						end

						local clone2 = skillFolder[enemy][sound]:Clone()
						clone2.CanCollide = false
						clone2.Anchored = true
						local number = Random.new():NextNumber(-35, 35)
						local number2 = Random.new():NextNumber(0, 12)
						local number3 = Random.new():NextNumber(-5, -10)
						clone2.CFrame = releaser_RootPart.CFrame * CFrame.new(number, number2, number3)
						clone2.Parent = skills
						Debris:AddItem(clone2, 1)
						PlaySound.PlaySound_Character(skill_Releaser, {
							Folder = "Weapon_Sound",
							Enemy = enemy,
							Sound = sound
						})
						TweenService:Create(
							clone2,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								CFrame = clone2.CFrame * CFrame.new(0, 0, Random.new():NextNumber(-30, -40))
							}
						):Play()
						local movingObject = clone2:FindFirstChild("MovingObject")

						if movingObject then
							TweenService:Create(
								movingObject,
								TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
						end

						task.wait(0.1)
					end
				end
			end
		end,
		Release = function(p: string, p2: string, _: string, p3)
			local child = skills:FindFirstChild((`{p3.Releaser_Id}_{p}_{p2}_Part`))

			if Generate.CheckExist(child) then
				child:Destroy()
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