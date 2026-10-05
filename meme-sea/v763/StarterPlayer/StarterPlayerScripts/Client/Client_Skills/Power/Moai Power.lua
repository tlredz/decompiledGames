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
local visualFX = ReplicatedStorage:WaitForChild("VisualFX")
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

function Moai_Disappear(instance)
	if instance and instance.Parent then
		for _, part in ipairs(instance:GetChildren()) do
			if part:IsA("BasePart") then
				TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					Transparency = 1
				}):Play()
			end
		end
	end
end

function Moai_Jumpscare(instance)
	for _, part in ipairs(instance:GetChildren()) do
		if part:IsA("BasePart") then
			TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
				Transparency = 0
			}):Play()
		end
	end
end

function Throwing_Rock(_, instance, data)
	local hitPart = data.HitPart
	local distance = data.Distance or 5
	local amount = data.Amount or 5
	local duration = data.Duration or 2
	local left_Right = data.Left_Right
	local up_Down = data.Up_Down
	local front_Back = data.Front_Back
	local size_X = data.Size_X
	local size_Y = data.Size_Y
	local size_Z = data.Size_Z

	if instance and instance.Parent then
		local color

		if hitPart then
			color = hitPart.Color
		else
			color = Color3.fromRGB(255, 255, 255)
		end

		local material

		if hitPart then
			material = hitPart.Material
		else
			material = Enum.Material.Concrete
		end

		for i = 1, amount do
			if i == 1 then
				CFrame.new(distance / 2, -1, distance)
			else
				CFrame.new(-distance / 2, -1, distance)
			end

			local v2 = math.random(left_Right.Min, left_Right.Max)
			local v3 = math.random(up_Down.Min, up_Down.Max)
			local v4 = math.random(front_Back.Min, front_Back.Max)
			local number = Random.new():NextNumber(size_X.Min, size_X.Max)
			local number2 = Random.new():NextNumber(size_Y.Min, size_Y.Max)
			local number3 = Random.new():NextNumber(size_Z.Min, size_Z.Max)
			local clone = visualFX.Rocks[`Rock{math.random(1, 3)}`]:Clone()
			clone.Size = Vector3.new(clone.Size.X * number, clone.Size.Y * number2, clone.Size.Z * number3)
			clone.CFrame = CFrame.new(instance.Position)
			clone.Color = color
			clone.Material = material
			clone.Parent = skills
			clone.CollisionGroup = "Player"
			clone.CanCollide = true
			clone.Start.Trail.Color = ColorSequence.new(color)
			clone.AssemblyLinearVelocity = Vector3.new(v2, v3, v4)
			clone.AssemblyAngularVelocity = Vector3.new(v2, v3, v4)
			Debris:AddItem(clone, duration)
			task.delay(duration - 1, function()
				if clone and clone.Parent then
					clone.Start.Trail.Enabled = false
					TweenService:Create(clone, TweenInfo.new(0.5), {
						Size = createVector(0, 0, 0)
					}):Play()
				end
			end)
		end
	end
end

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
				local moai = child:FindFirstChild("Moai")

				if moai then
					TweenService:Create(moai, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
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

				local clone2 = skillFolder[enemy][`{sound}_Part`]:Clone()
				clone2.Name = `{releaser_Id}_{enemy}_{sound}_Part`
				clone2.Parent = skills
				Debris:AddItem(clone2, duration + 1)
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
				task.spawn(function()
					task.wait(0.25)

					while clone and clone.Parent and clone:FindFirstChild("MovingObject") and clone:FindFirstChild("MovingObject").Transparency < 1 do
						Generate.Generate_Ring(
							clone.CFrame,
							createVector(2.5, 0.1, 2.5),
							createVector(10, 1, 10),
							0.25,
							0.5
						)
						task.wait(0.25)
					end
				end)

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

				task.wait(1.5)
				local movingObject = Generate.CheckExist(clone) and clone:FindFirstChild("MovingObject")

				if movingObject then
					TweenService:Create(
						movingObject,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
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
				local attachment = clone:FindFirstChild("Attachment")
				local weld = clone:FindFirstChild("Weld")
				weld.Part1 = rightHand

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
			local duration = skill_Info.Duration
			local hit_Position = data.Hit_Position
			local position = releaser_RootPart.Position
			local _ = releaser_RootPart.CFrame
			local _, v2, _ = CFrame.new(position, mouse_Position):ToOrientation()
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}_Hold`))
			local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")

			if child then
				child.Name = `{enemy}_{sound}`
				Debris:AddItem(child, 1)
				local moai = child:FindFirstChild("Moai")
				local attachment = child:FindFirstChild("Attachment")

				if moai then
					TweenService:Create(moai, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end

				if attachment then
					for _, emitter in ipairs(attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end
				end
			end

			if (hit_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[enemy][sound]:Clone()
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = CFrame.new(hit_Position) * CFrame.new(0, 100, 0) * CFrame.fromOrientation(0, v2, 0)
				clone.Parent = skills
				Debris:AddItem(clone, duration + 0.5)
				os.clock()
				local movingObject = clone:FindFirstChild("MovingObject")
				local wave = clone:FindFirstChild("Wave")
				local attachment = clone:FindFirstChild("Attachment")

				if movingObject and wave then
					local tween = TweenService:Create(
						clone,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CFrame = clone.CFrame * CFrame.new(0, 99, 0):Inverse()
						}
					)
					tween:Play()
					tween.Completed:Wait()
					PlaySound.PlaySound_Character(skill_Releaser, {
						Folder = "Power_Sound",
						Enemy = enemy,
						Sound = sound
					})
					PlaySound.PlaySound_Character(clone, {
						Folder = "Power_Sound",
						Enemy = enemy,
						Sound = `{sound}_Explosion`
					})
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = Folders
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					local raycastResult = workspace:Raycast(clone.Position, clone.CFrame.UpVector * -25, raycastParams)
					Color3.fromRGB(163, 162, 165)
					local _ = Enum.Material.Concrete

					if raycastResult and raycastResult.Instance then
						Throwing_Rock(enemy, clone, {
							HitPart = raycastResult.Instance,
							Distance = 0,
							Amount = 10,
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
								Min = -75,
								Max = 75
							},
							Up_Down = {
								Min = 75,
								Max = 75
							},
							Front_Back = {
								Min = -75,
								Max = 75
							}
						})

						if attachment then
							for _, emitter in ipairs(attachment:GetChildren()) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(10)
								end
							end
						end
					end
				end

				task.spawn(function()
					local lastTime = tick()

					while clone and clone.Parent and tick() - lastTime <= 2 do
						local clone2 = wave:Clone()
						clone2.Transparency = 0.1
						clone2.CFrame = clone.CFrame
						clone2.Anchored = true
						clone2.Parent = clone
						Debris:AddItem(clone2, 1)
						TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							Size = createVector(175, 10, 175),
							Transparency = 1
						}):Play()
						task.wait(0.25)
					end
				end)
				local character2 = localPlayer.Character

				if Generate.CheckIfAlive(character2) then
					local humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart2 and (humanoidRootPart2.Position - clone.Position).Magnitude <= 75 and not localPlayer:GetAttribute("No_CameraShake") then
						v:Shake(CameraShaker.Presets.MiniExplosion)
					end
				end

				task.wait(2)

				if clone and clone.Parent then
					TweenService:Create(
						movingObject,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end

				if humanoidRootPart then
					PlaySound.FadingSound_Out(humanoidRootPart, 1, sound)
				end
			end
		end
	},
	C = {
		Release = function(enemy: string, sound: string, _: string, data)
			local _ = data.Releaser_Id
			local skill_Releaser = data.Skill_Releaser
			local duration = data.Duration
			local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				PlaySound.PlaySound_Character(humanoidRootPart, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local clone = skillFolder[enemy][`{sound}_Left`]:Clone()
				clone.CanCollide = false
				clone.Anchored = false
				clone.CFrame = humanoidRootPart.CFrame
				clone.Parent = skills
				Debris:AddItem(clone, duration + 1)
				local clone2 = skillFolder[enemy][`{sound}_Right`]:Clone()
				clone2.CanCollide = false
				clone2.Anchored = false
				clone2.CFrame = humanoidRootPart.CFrame
				clone2.Parent = skills
				Debris:AddItem(clone2, duration + 1)
				local clone3 = skillFolder[enemy][`{sound}_Front`]:Clone()
				clone3.CanCollide = false
				clone3.Anchored = false
				clone3.CFrame = humanoidRootPart.CFrame
				clone3.Parent = skills
				Debris:AddItem(clone3, duration + 1)
				local clone4 = skillFolder[enemy][`{sound}_Back`]:Clone()
				clone4.CanCollide = false
				clone4.Anchored = false
				clone4.CFrame = humanoidRootPart.CFrame
				clone4.Parent = skills
				Debris:AddItem(clone4, duration + 1)
				local v2 = 0
				local lastTime = tick()
				Moai_Jumpscare(clone)
				Moai_Jumpscare(clone2)
				Moai_Jumpscare(clone3)
				Moai_Jumpscare(clone4)
				task.spawn(function()
					while humanoidRootPart and humanoidRootPart.Parent and tick() - lastTime <= duration + 0.5 do
						v2 = (v2 + 0.01) % 1
						local v3 = 6.283185307179586 * v2
						clone.CFrame = CFrame.Angles(0, v3, 0) * CFrame.new(0, 0, 10) + humanoidRootPart.Position
						clone2.CFrame = CFrame.Angles(0, v3, 0) * CFrame.new(0, 0, -10) + humanoidRootPart.Position
						clone3.CFrame = CFrame.Angles(0, v3, 0) * CFrame.new(10, 0, 0) + humanoidRootPart.Position
						clone4.CFrame = CFrame.Angles(0, v3, 0) * CFrame.new(-10, 0, 0) + humanoidRootPart.Position
						task.wait()
					end
				end)
				task.wait(duration)
				Moai_Disappear(clone)
				Moai_Disappear(clone2)
				Moai_Disappear(clone3)
				Moai_Disappear(clone4)

				if humanoidRootPart then
					PlaySound.FadingSound_Out(humanoidRootPart, 1, sound)
				end
			end
		end
	},
	F = {
		Release = function(enemy: string, sound: string, _: string, data)
			local skill_Releaser = data.Skill_Releaser
			local _ = data.Mouse_Position
			local hit_Position = data.Hit_Position
			local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and humanoidRootPart.Parent and (hit_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local _, v2, _ = CFrame.new(humanoidRootPart.Position, hit_Position):ToOrientation()
				local clone = skillFolder[enemy][sound]:Clone()
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = CFrame.new(hit_Position) * CFrame.new(0, 4, 0) * CFrame.fromOrientation(0, v2, 0)
				clone.Parent = skills
				Debris:AddItem(clone, 2.5)
				PlaySound.PlaySound_Character(clone, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				humanoidRootPart.CFrame = CFrame.new(hit_Position) * CFrame.new(0, 1, 0) * CFrame.fromOrientation(
					0,
					v2,
					0
				)
				local wave = clone:FindFirstChild("Wave")

				if wave then
					wave.Transparency = 0.1
					TweenService:Create(
						wave,
						TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(58.333332, 3.3333333, 58.333332),
							Transparency = 1
						}
					):Play()
				end

				task.wait(0.25)
				TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end
		end
	}
}