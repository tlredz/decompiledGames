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
		Hold = function(p: string, p2: string, _: string, data)
			local skill_Releaser = data.Skill_Releaser
			local releaser_Id = data.Releaser_Id
			local duration = data.Duration
			local start_Position = data.Start_Position

			if (start_Position.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[p][p2]:Clone()
				clone.Name = `{releaser_Id}_{p}_{p2}`
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = start_Position
				clone.Parent = skills
				Debris:AddItem(clone, duration)
				local now = os.clock()
				local heartbeatConnection = nil
				local movingObject = clone:FindFirstChild("MovingObject")
				clone:SetAttribute("Spinning", true)
				heartbeatConnection = RunService.Heartbeat:Connect(function(_)
					local now2 = os.clock()

					if now + duration <= now2 or not (Generate.CheckExist(clone) and clone:GetAttribute("Spinning") and Generate.CheckIfAlive(skill_Releaser)) then
						if heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end
					elseif movingObject and movingObject.Parent then
						movingObject.CFrame *= CFrame.fromEulerAnglesXYZ(0.15, 0, 0)
					end
				end)
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
			local custom_Start = data.Custom_Start
			local position = releaser_RootPart.Position
			local _ = releaser_RootPart.CFrame
			local folder = skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}`))

			if folder then
				folder.Name = `{enemy}_{sound}`
				local overlapParams = OverlapParams.new()
				overlapParams.FilterDescendantsInstances = { character, monster }
				overlapParams.FilterType = Enum.RaycastFilterType.Include
				local hitbox = folder:FindFirstChild("Hitbox")

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

				local clone = skillFolder[enemy][`{sound}_Part`]:Clone()
				clone.Name = `{releaser_Id}_{enemy}_{sound}_Part`
				clone.Parent = skills
				Debris:AddItem(clone, duration + 1)

				for _, effect in ipairs(folder:GetDescendants()) do
					if not ((effect:IsA("ParticleEmitter") or effect:IsA("Trail")) and effect.Enabled) then
						continue
					end

					effect.Enabled = true
				end

				folder:SetAttribute("Spinning", nil)
				PlaySound.PlaySound_Character(folder, {
					Folder = "Weapon_Sound",
					Enemy = enemy,
					Sound = sound
				})

				if moving_Speed then
					local now = os.clock()
					local heartbeatConnection = nil
					local movingObject = folder:FindFirstChild("MovingObject")
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						local now2 = os.clock()

						if now + duration <= now2 or not Generate.CheckExist(folder) then
							if folder and folder.Parent then
								folder:Destroy()
							end

							if heartbeatConnection then
								heartbeatConnection:Disconnect()
								heartbeatConnection = nil
							end
						else
							folder.CFrame += CFrame.new(custom_Start, mouse_Position).LookVector * moving_Speed * dt

							if movingObject and movingObject.Parent then
								movingObject.CFrame *= CFrame.fromEulerAnglesXYZ(0.15, 0, 0)
							end
						end
					end)
				end

				for _, effect in ipairs(folder:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) or effect.Enabled then
						continue
					end

					effect.Enabled = true
				end

				task.wait(1.25)
				local movingObject = Generate.CheckExist(folder) and folder:FindFirstChild("MovingObject")

				if movingObject then
					TweenService:Create(movingObject, TweenInfo.new(1, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
				end

				task.wait(0.75)

				for _, effect in ipairs(folder:GetDescendants()) do
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
	}
}