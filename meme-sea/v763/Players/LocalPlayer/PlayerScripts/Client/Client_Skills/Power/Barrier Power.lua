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
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = CFrame.new(position, mouse_Position) * CFrame.new(0, 18, 0)
				clone.Parent = skills
				Debris:AddItem(clone, duration + 1.75)
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
						duration + 1,
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

						if not (now + duration <= now2) and (Generate.CheckExist(clone) or not skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}`))) then
							clone.CFrame += CFrame.new(position, mouse_Position).LookVector * moving_Speed * dt
						elseif heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end
					end)
				end

				local movingObject = clone:FindFirstChild("MovingObject")

				if movingObject then
					TweenService:Create(
						movingObject,
						TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = createVector(40, 35, 0.5)
						}
					):Play()

					for _, trail in ipairs(movingObject:GetChildren()) do
						if not trail:IsA("Trail") or trail.Enabled then
							continue
						end

						trail.Enabled = true
					end

					task.wait(0.5)

					if Generate.CheckExist(clone) then
						movingObject.CanCollide = true
						task.wait(1)
						TweenService:Create(movingObject, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {
							Size = Vector3.new(0, 0, movingObject.Size.Z)
						}):Play()
						TweenService:Create(movingObject, TweenInfo.new(0.5), {
							Transparency = 1
						}):Play()

						for _, trail in ipairs(movingObject:GetChildren()) do
							if trail:IsA("Trail") and trail.Enabled then
								trail.Enabled = false
							end
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
			local _ = data.Loop
			local position = releaser_RootPart.Position
			local _ = releaser_RootPart.CFrame
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}_Hold`))

			if child then
				child:Destroy()
			end

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[enemy][sound]:Clone()
				clone.Name = `{enemy}_{sound}_{releaser_Id}`
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = CFrame.new(position, mouse_Position) * CFrame.new(0, 9, 0)
				clone.Parent = skills
				Debris:AddItem(clone, duration + 2)
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
							Hit_Sound = true,
							Prison_Sound = true
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
					clone:FindFirstChild("MovingObject")
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						local now2 = os.clock()

						if not (now + duration + 2 <= now2) and Generate.CheckExist(clone) and not clone:GetAttribute("Hitted") then
							clone.CFrame += CFrame.new(position, mouse_Position).LookVector * moving_Speed * dt
						elseif heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end
					end)
				end

				task.wait(1.5)
				local movingObject = not clone:GetAttribute("Hitted") and Generate.CheckExist(clone) and clone:FindFirstChild("MovingObject")

				if movingObject then
					TweenService:Create(
						movingObject,
						TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 0, 0),
							Transparency = 1
						}
					):Play()
				end
			end
		end,
		Prison = function(p: string, p2: string, _: string, data)
			local releaser_Id = data.Releaser_Id
			local _ = data.Releaser_Character
			local hit_Position = data.Hit_Position
			local child = skills:FindFirstChild((`{p}_{p2}_{releaser_Id}`))

			if child and not child:GetAttribute("Hitted") then
				child:SetAttribute("Hitted", true)
				TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
					CFrame = CFrame.new(hit_Position)
				}):Play()
				local movingObject = child:FindFirstChild("MovingObject")

				if movingObject and movingObject.Transparency ~= 0.5 then
					TweenService:Create(movingObject, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
						Transparency = 0.5
					}):Play()
				end

				task.wait(1.5)
				local movingObject2 = child:FindFirstChild("MovingObject")

				if movingObject2 then
					TweenService:Create(
						movingObject2,
						TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 0, 0),
							Transparency = 1
						}
					):Play()
				end
			end
		end
	},
	C = {
		Release = function(enemy: string, sound: string, _: string, data)
			local player_Releaser = data.Player_Releaser
			local skill_Releaser = data.Skill_Releaser
			local releaser_RootPart = data.Releaser_RootPart
			local mouse_Position = data.Mouse_Position
			local skill_Info = data.Skill_Info
			local _ = data.Releaser_Id
			local moving_Speed = skill_Info.Moving_Speed
			local duration = skill_Info.Duration
			local hit_Position = data.Hit_Position
			local position = releaser_RootPart.Position
			local cFrame = releaser_RootPart.CFrame

			if (hit_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local _, v2, _ = CFrame.new(position, position + -cFrame.LookVector):ToOrientation()
				local clone = skillFolder[enemy][sound]:Clone()
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = CFrame.new(hit_Position) * CFrame.new(0, 75, 0) * CFrame.fromOrientation(0, v2, 0)
				clone.Parent = skills
				Debris:AddItem(clone, duration)
				task.delay(0.5, function()
					local clone2 = skillFolder[enemy][`{sound}_Hitbox`]:Clone()
					clone2.CanCollide = false
					clone2.Anchored = true
					clone2.Transparency = setting.Hitbox_Transparency
					clone2.CFrame = CFrame.new(hit_Position) * CFrame.new(0, 7.5, 0) * CFrame.fromOrientation(0, v2, 0)
					clone2.Parent = skills
					Debris:AddItem(clone2, duration or 10)
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
						duration - 1,
						{
							Moving_Speed = moving_Speed,
							Skill_Type = skill_Info.Skill_Type,
							RootPart_Position = position,
							Mouse_Position = mouse_Position
						}
					)
				end)
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = `{sound}_Falling`
				})
				local movingObject = clone:FindFirstChild("MovingObject")

				if movingObject then
					local tween = TweenService:Create(
						clone,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CFrame = clone.CFrame * CFrame.new(0, 73, 0):Inverse()
						}
					)
					tween:Play()
					tween.Completed:Wait()
					PlaySound.PlaySound_Character(clone, {
						Folder = "Power_Sound",
						Enemy = enemy,
						Sound = sound
					})
					local character2 = localPlayer.Character

					if Generate.CheckIfAlive(character2) then
						if character2:GetAttribute("Safezone") then
							movingObject.CanCollide = false
						else
							movingObject.CanCollide = true
						end

						local humanoidRootPart = character2:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart and (humanoidRootPart.Position - clone.Position).Magnitude <= 30 and not localPlayer:GetAttribute("No_CameraShake") then
							v:Shake(CameraShaker.Presets.MiniExplosion)
						end
					else
						movingObject.CanCollide = false
					end

					local v3 = {
						30,
						23,
						3,
						2
					}
					local v4 = {
						Amount = 15,
						Size = createVector(2.5, 2.5, 2.5),
						Velocity = {
							X = {
								Min = -100,
								Max = 100
							},
							Y = {
								Min = 100,
								Max = 100
							},
							Z = {
								Min = -100,
								Max = 100
							}
						}
					}
					Generate.Generate_FlyingRock(clone.Position, v4.Amount, v4.Size, v4.Velocity, 1.75)
					Generate.Generate_Ground(clone, v3[1], v3[2], v3[3], v3[4])
					task.wait(2)

					if movingObject then
						movingObject.CanCollide = false
					end

					TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						CFrame = clone.CFrame * CFrame.new(0, 75, 0)
					}):Play()
					task.wait(0.25)
					TweenService:Create(
						movingObject,
						TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 0, 0)
						}
					):Play()
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

			if humanoidRootPart then
				local weld = Instance.new("Weld")
				weld.Parent = clone
				weld.Part0 = clone
				weld.Part1 = humanoidRootPart
				weld.C1 *= CFrame.new(0, -3, 0)
			end

			for _, trail in ipairs(clone:GetChildren()) do
				if not trail:IsA("Trail") or trail.Enabled then
					continue
				end

				trail.Enabled = true
			end

			while clone and clone.Parent and clone:GetAttribute("Active") do
				local tween = TweenService:Create(
					clone,
					TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
					{
						Size = Vector3.new(clone.Size.X * 1.5, clone.Size.Y, clone.Size.Z * 1.5)
					}
				)
				tween:Play()
				tween.Completed:Wait()

				if not (clone and clone.Parent and clone:GetAttribute("Active")) then
					break
				end

				local tween2 = TweenService:Create(
					clone,
					TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
					{
						Size = Vector3.new(clone.Size.X / 1.5, clone.Size.Y, clone.Size.Z / 1.5)
					}
				)
				tween2:Play()
				tween2.Completed:Wait()

				if clone and clone.Parent and clone:GetAttribute("Active") then
					task.wait()
				else
					break
				end
			end
		end,
		Release = function(p: string, p2: string, _: string, p3)
			local _ = p3.Skill_Releaser
			local child = skills:FindFirstChild((`{p3.Releaser_Id}_{p}_{p2}`))

			if child and child.Parent then
				child:SetAttribute("Active", nil)

				for _, trail in ipairs(child:GetChildren()) do
					if trail:IsA("Trail") and trail.Enabled then
						trail.Enabled = false
					end
				end

				TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
					Size = createVector(0, 0, 0)
				}):Play()
				task.wait(1)

				if child and child.Parent then
					child:Destroy()
				end
			end
		end
	}
}