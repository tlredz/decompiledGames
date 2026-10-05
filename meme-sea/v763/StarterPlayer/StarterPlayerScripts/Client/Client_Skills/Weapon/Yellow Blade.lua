local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
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
				clone.Name = `{enemy}_{sound}_{releaser_Id}`
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = CFrame.new(position, (Vector3.new(mouse_Position.X, position.Y, mouse_Position.Z)))
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
						duration - 0.5,
						{
							Moving_Speed = moving_Speed,
							Skill_Type = skill_Info.Skill_Type,
							RootPart_Position = position,
							Mouse_Position = mouse_Position,
							Drag_Sound = true,
							Drag_Effect = true
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

						if not (now + duration + 1 <= now2) and Generate.CheckExist(clone) then
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

				clone:SetAttribute("Flying_Rock", true)
				Generate.Flying_Rock(clone, {
					DestroyTime = 2,
					Cooldown = 0.1,
					Loops = 3,
					Duration = 1.5,
					Raycast = createVector(0, -20, 0),
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
						Min = -75,
						Max = 75
					},
					Up_Down = {
						Min = 75,
						Max = 100
					},
					Front_Back = {
						Min = -75,
						Max = 75
					}
				})

				for _, effect in ipairs(clone:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) or effect.Enabled then
						continue
					end

					Generate.SetParticle(effect)
					effect.Enabled = true
				end

				task.wait(2)

				if Generate.CheckExist(clone) then
					clone:SetAttribute("Flying_Rock", nil)

					for _, effect in ipairs(clone:GetDescendants()) do
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
		Hold = function(enemy: string, sound: string, _: string, data)
			local _ = data.Player_Releaser
			local skill_Releaser = data.Skill_Releaser
			local releaser_RootPart = data.Releaser_RootPart
			local skill_Info = data.Skill_Info
			local _ = data.Mouse_Position
			local releaser_Id = data.Releaser_Id
			local _ = skill_Info.Moving_Speed
			local duration = skill_Info.Duration
			local position = releaser_RootPart.Position
			local cFrame = releaser_RootPart.CFrame

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[enemy][sound]:Clone()
				clone.Name = `{releaser_Id}_{enemy}_{sound}`
				clone.CanCollide = false
				clone.Anchored = false
				clone.CFrame = cFrame
				clone.Parent = skills
				Debris:AddItem(clone, duration + 1)
				local weld = clone:FindFirstChild("Weld")

				if weld then
					weld.Part1 = releaser_RootPart
				end

				local clone2 = skillFolder[enemy][`{sound}_Part`]:Clone()
				clone2.Name = `{releaser_Id}_{enemy}_{sound}_Part`
				clone2.Parent = skills
				Debris:AddItem(clone2, duration + 1)
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Weapon_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local middle = clone:FindFirstChild("Middle")

				if middle then
					for _, emitter in ipairs(middle:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
							continue
						end

						Generate.SetParticle(emitter)
						emitter.Enabled = true
					end

					task.wait(1.6)

					for _, emitter in ipairs(middle:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end
				end
			end
		end,
		Release = function(p: string, p2: string, _: string, p3)
			local child = skills:FindFirstChild((`{p3.Releaser_Id}_{p}_{p2}`))

			if child then
				Debris:AddItem(child, 1)
				local middle = child:FindFirstChild("Middle")

				if middle then
					for _, emitter in ipairs(middle:GetChildren()) do
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