local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
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
				clone.CFrame = CFrame.new(position, mouse_Position)
				clone.Parent = skills
				Debris:AddItem(clone, duration + 1)
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
							Single_Target = skill_Info.Single_Target,
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
				clone:SetAttribute("Active", true)

				if moving_Speed then
					local now = os.clock()
					local heartbeatConnection = nil
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						local now2 = os.clock()

						if not (now + duration + 1 <= now2) and Generate.CheckExist(clone) and clone:GetAttribute("Active") then
							clone.CFrame += CFrame.new(position, mouse_Position).LookVector * moving_Speed * dt
						elseif heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end
					end)
				end

				for _, effect in ipairs(clone:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) or effect.Enabled then
						continue
					end

					Generate.SetParticle(effect)
					effect.Enabled = true
				end

				task.wait(1.5)
				local movingObject = Generate.CheckExist(clone) and clone:FindFirstChild("MovingObject")

				if movingObject then
					TweenService:Create(movingObject, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
				end

				task.wait(0.5)

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
		end,
		Destroy = function(p: string, p2: string, _: string, p3)
			local releaser_Id = p3.Releaser_Id
			local _ = p3.Releaser_Character
			local child = skills:FindFirstChild((`{releaser_Id}_{p}_{p2}`))

			if child then
				child:SetAttribute("Active", nil)
				Debris:AddItem(child, 1)
				local movingObject = child:FindFirstChild("MovingObject")

				if movingObject then
					TweenService:Create(
						movingObject,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = movingObject.Size * 1.5,
							Transparency = 1
						}
					):Play()
					TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						CFrame = child.CFrame * CFrame.Angles(0, -3.141592653589793, 0)
					}):Play()

					for _, emitter in ipairs(movingObject:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end
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
				local v2 = {
					25,
					55,
					6,
					1.75
				}
				local v3 = {
					Amount = 20,
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
				clone.CFrame = CFrame.new(hit_Position) * CFrame.new(0, 50, 0)
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
				local now = os.clock()
				local heartbeatConnection = nil
				local pumpkin = clone:FindFirstChild("Pumpkin")
				local attachment = pumpkin:FindFirstChild("Attachment")
				local wave = clone:FindFirstChild("Wave")

				if pumpkin and attachment and wave then
					TweenService:Create(pumpkin, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 0
					}):Play()

					for _, emitter in ipairs(pumpkin:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
							continue
						end

						Generate.SetParticle(emitter)
						emitter.Enabled = true
					end

					local tween = TweenService:Create(
						clone,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CFrame = clone.CFrame * CFrame.new(0, 47, 0):Inverse()
						}
					)
					tween:Play()
					tween.Completed:Wait()
					PlaySound.PlaySound_Character(clone, {
						Folder = "Weapon_Sound",
						Enemy = enemy,
						Sound = `{sound}_Explosion`
					})
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						local now2 = os.clock()

						if now + duration <= now2 or not Generate.CheckExist(clone) then
							if heartbeatConnection then
								heartbeatConnection:Disconnect()
								heartbeatConnection = nil
							end
						elseif pumpkin and pumpkin.Parent then
							pumpkin.CFrame *= CFrame.fromEulerAnglesXYZ(0, 0.1 * (1 + dt), 0)
						end
					end)
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = Folders
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					local raycastResult = workspace:Raycast(clone.Position, clone.CFrame.UpVector * -10, raycastParams)
					Color3.fromRGB(163, 162, 165)
					local _ = Enum.Material.Concrete

					if raycastResult and raycastResult.Instance then
						Generate.Generate_FlyingRock(clone.Position, v3.Amount, v3.Size, v3.Velocity)
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

					local character2 = localPlayer.Character

					if Generate.CheckIfAlive(character2) then
						local humanoidRootPart = character2:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart and (humanoidRootPart.Position - clone.Position).Magnitude <= 60 and not localPlayer:GetAttribute("No_CameraShake") then
							v:Shake(CameraShaker.Presets.MiniExplosion)
						end
					end

					task.wait(1)

					for _, emitter in ipairs(attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end

					for _, emitter in ipairs(pumpkin:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end

					task.wait(0.5)
					TweenService:Create(pumpkin, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(0, 42.46, 0),
						Transparency = 1
					}):Play()
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