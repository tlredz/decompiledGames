local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local currentCamera = workspace.CurrentCamera
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
ReplicatedStorage:WaitForChild("OtherEvent")
local skillFolder = ReplicatedStorage:WaitForChild("SkillFolder")
local animation_Folder = ReplicatedStorage:WaitForChild("Animation_Folder")
ReplicatedStorage:WaitForChild("Modules")
local visualFX = ReplicatedStorage:WaitForChild("VisualFX")
local skills = workspace:WaitForChild("Skills")
local character = workspace:WaitForChild("Character")
local monster = workspace:WaitForChild("Monster")
local skill_Animation = animation_Folder:WaitForChild("Skill_Animation")
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
local Generate = require(moduleScript:WaitForChild("Generate"))
local ItemSettings = require(moduleScript:WaitForChild("ItemSettings"))
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
local v = { "RightLowerArm", "RightHand" }
local v2 = {
	"LeftLowerArm",
	"LeftHand",
	"RightLowerArm",
	"RightHand"
}

function Generate_DoughParts(instance, p, p2, p3, list)
	for _, childName in ipairs(list) do
		local child = instance:FindFirstChild(childName)

		if not (child and child.Transparency < 1) then
			continue
		end

		local part = Instance.new("Part")
		part.Name = `{p}_{p2}_{p3}_{child.Name}`
		part:SetAttribute("Dough_Part", true)
		part.CanCollide = false
		part.Transparency = 0
		part.Massless = true
		part.Size = child.Size + createVector(0.065, 0.065, 0.065)
		part.Color = Color3.fromRGB(255, 255, 255)
		part.Material = Enum.Material.Glass
		part.Parent = skills
		Debris:AddItem(part, 60)
		local weld = Instance.new("Weld")
		weld.Parent = part
		weld.Part0 = child
		weld.Part1 = part
	end
end

function Side_Rocks(_, instance, _, _, p, p2, p3)
	if instance and instance.Parent then
		local color

		if p3 then
			color = p3.Color
		else
			color = Color3.fromRGB(255, 255, 255)
		end

		local material

		if p3 then
			material = p3.Material
		else
			material = Enum.Material.Concrete
		end

		if p2 then
			for i = 1, 2 do
				local cframe

				if i == 1 then
					cframe = CFrame.new(p / 2, -2, p)
				else
					cframe = CFrame.new(-p / 2, -2, p)
				end

				local clone = visualFX.Rocks[`Rock{math.random(1, 3)}`]:Clone()
				clone.Size *= Random.new():NextNumber(1.01, 2)
				clone.CFrame = instance.CFrame * cframe * CFrame.Angles(
					math.rad((math.random(-60, 60))),
					0,
					(math.rad((math.random(-60, 60))))
				)
				clone.Color = color
				clone.Material = material
				clone.Parent = skills
				clone.CanCollide = true
				clone.CollisionGroup = "Player"
				clone.Start.Trail.Color = ColorSequence.new(color)
				Debris:AddItem(clone, 2)
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
				bodyVelocity.P = 2500
				bodyVelocity.Velocity = clone.CFrame.UpVector * math.random(25, 75)
				bodyVelocity.Parent = clone
				Debris:AddItem(bodyVelocity, 0.2)
				task.delay(1, function()
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
end

return {
	Z = {
		Hold = function(p: string, p2: string, _: string, p3)
			local releaser_Id = p3.Releaser_Id
			local skill_Releaser = p3.Skill_Releaser
			local rightHand = skill_Releaser:FindFirstChild("RightHand")

			if rightHand and (rightHand.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[p][`{p2}_Hold`]:Clone()
				clone.Name = `{releaser_Id}_{p}_{p2}_Hold`
				clone.CanCollide = false
				clone.Anchored = false
				clone.Parent = skills
				Debris:AddItem(clone, 60)
				local attachment = clone:FindFirstChild("Attachment")

				for _, emitter in ipairs(attachment:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
						continue
					end

					Generate.SetParticle(emitter)
					emitter.Enabled = true
				end

				local weld = clone:FindFirstChild("Weld")
				weld.Part1 = rightHand
				Generate_DoughParts(skill_Releaser, releaser_Id, p, p2, v)
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
				local attachment = child:FindFirstChild("Attachment")

				if attachment then
					for _, emitter in ipairs(attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end
				end
			end

			for _, part in ipairs(skills:GetChildren()) do
				if not (part:IsA("BasePart") and string.find(part.Name, releaser_Id) and part:GetAttribute("Dough_Part")) then
					continue
				end

				part.Name = `{enemy}_{sound}`
				Debris:AddItem(part, 1)
				TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[enemy][`{sound}_Donut`]:Clone()
				clone.Name = `{releaser_Id}_{enemy}_{sound}_Dough`
				clone:PivotTo(CFrame.new(position, mouse_Position) * CFrame.new(0, 0, -5))
				clone.Parent = skills
				Debris:AddItem(clone, duration + 1)
				local clone2 = skillFolder[enemy][sound]:Clone()
				clone2.Name = `{releaser_Id}_{enemy}_{sound}`
				clone2.CanCollide = false
				clone2.Anchored = true
				clone2.CFrame = CFrame.new(position, mouse_Position)
				clone2.Parent = skills
				Debris:AddItem(clone2, duration + 1)
				local overlapParams = OverlapParams.new()
				overlapParams.FilterDescendantsInstances = { character, monster }
				overlapParams.FilterType = Enum.RaycastFilterType.Include
				local hitbox = clone2:FindFirstChild("Hitbox")

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
							Hit_Sound = true
						}
					)
				end

				PlaySound.PlaySound_Character(clone2, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local animationController = clone:FindFirstChild("AnimationController")

				if animationController then
					local animator = animationController:FindFirstChild("Animator")

					if animator then
						animator:LoadAnimation(skill_Animation.Power[enemy][sound].Dough):Play()
						local donut = clone:FindFirstChild("Donut")

						if donut then
							TweenService:Create(
								donut,
								TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Size = createVector(8.525001, 8.24125, 3.34),
									Transparency = 0
								}
							):Play()
						end

						tick()

						if moving_Speed then
							local now = os.clock()
							local heartbeatConnection = nil
							heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
								local now2 = os.clock()

								if not (now + duration + 1 <= now2) and Generate.CheckExist(clone2) then
									clone2.CFrame += CFrame.new(position, mouse_Position).LookVector * moving_Speed * dt
								elseif heartbeatConnection then
									heartbeatConnection:Disconnect()
									heartbeatConnection = nil
								end
							end)
						end
					end

					task.wait(1)

					if clone2 and clone2.Parent then
						local movingObject = clone2:FindFirstChild("MovingObject")

						for _, trail in ipairs(clone2:GetChildren()) do
							if trail:IsA("Trail") and trail.Enabled then
								trail.Enabled = false
							end
						end

						if movingObject then
							TweenService:Create(
								movingObject,
								TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
							local sphere = movingObject:FindFirstChild("Sphere")

							if sphere then
								TweenService:Create(
									sphere,
									TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Transparency = 1
									}
								):Play()
							end
						end
					end

					task.wait(0.5)

					if clone and clone.Parent then
						local donut = clone:FindFirstChild("Donut")

						if donut then
							TweenService:Create(
								donut,
								TweenInfo.new(0.25, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
								{
									Size = createVector(0, 0, 0),
									Transparency = 1
								}
							):Play()
						end

						if animator then
							for _, v3 in ipairs(animator:GetPlayingAnimationTracks()) do
								if v3.Name == "Dough" then
									v3:Stop()
								end
							end
						end
					end
				end
			end
		end,
		Hitted = function(p: string, p2: string, _: string, data)
			local releaser_Id = data.Releaser_Id
			local releaser_Character = data.Releaser_Character
			local humanoidRootPart = data.Hit_Character:FindFirstChild("HumanoidRootPart")
			local humanoidRootPart2 = releaser_Character:FindFirstChild("HumanoidRootPart")
			local child = skills:FindFirstChild((`{releaser_Id}_{p}_{p2}`))
			local child2 = skills:FindFirstChild((`{releaser_Id}_{p}_{p2}_Dough`))

			if child and humanoidRootPart and humanoidRootPart2 then
				child:Destroy()

				if child2 and child2.PrimaryPart then
					humanoidRootPart2 = child2.PrimaryPart
				end

				local clone = skillFolder[p][`{p2}_Grab`]:Clone()
				clone.Parent = skills
				clone.CFrame = CFrame.new(
					humanoidRootPart.Position,
					humanoidRootPart.Position + -humanoidRootPart2.CFrame.LookVector
				) * CFrame.Angles(0, 3.141592653589793, 0)
				Debris:AddItem(clone, 2)
				local weldConstraint = clone:FindFirstChild("WeldConstraint")

				if weldConstraint then
					weldConstraint.Part1 = humanoidRootPart
				end

				task.wait(0.5)

				if clone and clone.Parent then
					weldConstraint:Destroy()
					clone.Anchored = true

					for _, trail in ipairs(clone:GetChildren()) do
						if trail:IsA("Trail") and trail.Enabled then
							trail.Enabled = false
						end
					end

					local movingObject = clone:FindFirstChild("MovingObject")
					TweenService:Create(
						movingObject,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
					local sphere = movingObject:FindFirstChild("Sphere")

					if sphere then
						TweenService:Create(
							sphere,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end
				end
			end
		end
	},
	X = {
		Hold = function(p: string, p2: string, _: string, p3)
			local releaser_Id = p3.Releaser_Id
			local skill_Releaser = p3.Skill_Releaser
			local rightHand = skill_Releaser:FindFirstChild("RightHand")

			if rightHand and (rightHand.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[p][`{p2}_Hold`]:Clone()
				clone.Name = `{releaser_Id}_{p}_{p2}_Hold`
				clone.CanCollide = false
				clone.Anchored = false
				clone.Parent = skills
				Debris:AddItem(clone, 60)
				local attachment = clone:FindFirstChild("Attachment")

				for _, emitter in ipairs(attachment:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
						continue
					end

					Generate.SetParticle(emitter)
					emitter.Enabled = true
				end

				local weld = clone:FindFirstChild("Weld")
				weld.Part1 = rightHand
				Generate_DoughParts(skill_Releaser, releaser_Id, p, p2, v)
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
			local hit_Position = data.Hit_Position
			local position = releaser_RootPart.Position
			local _ = releaser_RootPart.CFrame
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}_Hold`))

			if child then
				child.Name = `{enemy}_{sound}`
				Debris:AddItem(child, 1)

				for _, emitter in ipairs(child:GetChildren()) do
					if emitter:IsA("ParticleEmitter") and emitter.Enabled then
						emitter.Enabled = false
					end
				end
			end

			for _, part in ipairs(skills:GetChildren()) do
				if not (part:IsA("BasePart") and string.find(part.Name, releaser_Id) and part:GetAttribute("Dough_Part")) then
					continue
				end

				part.Name = `{enemy}_{sound}`
				Debris:AddItem(part, 1)
				TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end

			if (hit_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[enemy][sound]:Clone()
				clone:PivotTo(CFrame.new(hit_Position) * CFrame.new(0, 0, 0))
				clone.Parent = skills
				Debris:AddItem(clone, duration + 1)
				local overlapParams = OverlapParams.new()
				overlapParams.FilterDescendantsInstances = { character, monster }
				overlapParams.FilterType = Enum.RaycastFilterType.Include
				local clone2 = skillFolder[enemy][`{sound}_Hitbox`]:Clone()
				clone2.Name = `{enemy}_{sound}_{releaser_Id}`
				clone2.CanCollide = false
				clone2.Anchored = true
				clone2.Transparency = setting.Hitbox_Transparency
				clone2.CFrame = CFrame.new(hit_Position) * CFrame.new(0, 45, 0)
				clone2.Parent = skills
				Debris:AddItem(clone2, duration or 10)
				Generate.Client_Hitbox(player_Releaser, skill_Releaser, clone2, overlapParams, enemy, sound, duration, {
					Moving_Speed = moving_Speed,
					Skill_Type = skill_Info.Skill_Type,
					RootPart_Position = position,
					Mouse_Position = mouse_Position
				})
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local clone3 = skillFolder[enemy][`{sound}_Part`]:Clone()
				clone3.Name = `{releaser_Id}_{enemy}_{sound}_Part`
				clone3.CFrame = CFrame.new(hit_Position) * CFrame.new(0, 0, 0)
				clone3.Parent = skills
				Debris:AddItem(clone3, duration + 1)
				local now = os.clock()
				local heartbeatConnection = nil
				heartbeatConnection = RunService.Heartbeat:Connect(function(_)
					local now2 = os.clock()

					if not (now + duration <= now2) and Generate.CheckExist(clone) then
						return
					end

					if heartbeatConnection then
						heartbeatConnection:Disconnect()
						heartbeatConnection = nil
					end

					if clone and clone.Parent then
						clone:Destroy()
					end
				end)
				local dough = clone:FindFirstChild("Dough")
				local doughFloor = clone:FindFirstChild("DoughFloor")

				if dough and doughFloor then
					TweenService:Create(
						doughFloor,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = createVector(100, 15, 100)
						}
					):Play()
					TweenService:Create(dough, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(50, 100, 50),
						Transparency = 0,
						CFrame = dough.CFrame * CFrame.new(0, 45, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
					}):Play()
					task.wait(1)
					TweenService:Create(dough, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(50, 0, 50),
						CFrame = dough.CFrame * CFrame.new(0, -45, 0) * CFrame.Angles(0, 3.141592653589793, 0)
					}):Play()
					TweenService:Create(dough, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
					task.wait(0.5)
					TweenService:Create(
						doughFloor,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 5, 0),
							Transparency = 1
						}
					):Play()
				end
			end
		end,
		Hitted = function(enemy: string, p2: string, _: string, data)
			local target_RootPart = data.Target_RootPart
			local releaser_Id = data.Releaser_Id
			local _ = data.Releaser_Character
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{p2}_Part`))

			if target_RootPart and child and Generate.CheckIfAlive(target_RootPart.Parent) then
				if not child:GetAttribute("Last_Time") then
					child:SetAttribute("Last_Time", tick() - 1)
				end

				task.wait(ItemSettings[enemy][p2].Delayed_Duration)

				if child and child.Parent and target_RootPart and target_RootPart.Parent and tick() - child:GetAttribute("Last_Time") >= 0.25 then
					child:SetAttribute("Last_Time", tick())
					PlaySound.PlaySound_Character(child, {
						Folder = "Power_Sound",
						Enemy = enemy,
						Sound = `{p2}_Down`
					})
				end
			end
		end
	},
	C = {
		Hold = function(p: string, p2: string, _: string, p3)
			local releaser_Id = p3.Releaser_Id
			local skill_Releaser = p3.Skill_Releaser
			local rightHand = skill_Releaser:FindFirstChild("RightHand")

			if rightHand and (rightHand.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[p][`{p2}_Hold`]:Clone()
				clone.Name = `{releaser_Id}_{p}_{p2}_Hold`
				clone.CanCollide = false
				clone.Anchored = false
				clone.Parent = skills
				Debris:AddItem(clone, 60)
				local attachment = clone:FindFirstChild("Attachment")

				for _, emitter in ipairs(attachment:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
						continue
					end

					Generate.SetParticle(emitter)
					emitter.Enabled = true
				end

				local weld = clone:FindFirstChild("Weld")
				weld.Part1 = rightHand
				Generate_DoughParts(skill_Releaser, releaser_Id, p, p2, v)
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
			local cFrame = releaser_RootPart.CFrame
			local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}_Hold`))

			if child then
				child.Name = `{enemy}_{sound}`
				Debris:AddItem(child, 1)
				local attachment = child:FindFirstChild("Attachment")

				if attachment then
					for _, emitter in ipairs(attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end
				end
			end

			for _, part in ipairs(skills:GetChildren()) do
				if not (part:IsA("BasePart") and string.find(part.Name, releaser_Id) and part:GetAttribute("Dough_Part")) then
					continue
				end

				part.Name = `{enemy}_{sound}`
				Debris:AddItem(part, 1)
				TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local _, v3, _ = CFrame.new(position, position + cFrame.LookVector):ToOrientation()
				local clone = skillFolder[enemy][sound]:Clone()
				clone.Anchored = true
				clone.CFrame = cFrame * CFrame.new(0, -3, 0) * CFrame.fromOrientation(0, v3, 0)
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
						duration,
						{
							Moving_Speed = moving_Speed,
							Skill_Type = skill_Info.Skill_Type,
							RootPart_Position = position,
							Mouse_Position = mouse_Position
						}
					)
				end

				if humanoidRootPart then
					PlaySound.PlaySound_Character(humanoidRootPart, {
						Folder = "Power_Sound",
						Enemy = enemy,
						Sound = sound
					})
				end

				local movingObject = clone:FindFirstChild("MovingObject")

				if movingObject then
					TweenService:Create(
						movingObject,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = createVector(175, 7.5, 175),
							Transparency = 0
						}
					):Play()
				end

				task.wait(2)
				local movingObject2 = Generate.CheckExist(clone) and clone:FindFirstChild("MovingObject")

				if movingObject2 then
					TweenService:Create(
						movingObject2,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 2.5, 0)
						}
					):Play()
				end
			end
		end
	},
	V = {
		Hold = function(p: string, p2: string, _: string, p3)
			local releaser_Id = p3.Releaser_Id
			local skill_Releaser = p3.Skill_Releaser

			for i = 1, 2 do
				local rightHand

				if i == 1 then
					rightHand = skill_Releaser:FindFirstChild("RightHand")
				else
					rightHand = skill_Releaser:FindFirstChild("LeftHand")
				end

				if not (rightHand and (rightHand.Position - currentCamera.CFrame.Position).Magnitude <= 1500) then
					continue
				end

				local clone = skillFolder[p][`{p2}_Hold`]:Clone()
				clone.Name = `{releaser_Id}_{p}_{p2}_Hold`
				clone.CanCollide = false
				clone.Anchored = false
				clone.Parent = skills
				Debris:AddItem(clone, 60)
				local attachment = clone:FindFirstChild("Attachment")

				for _, emitter in ipairs(attachment:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
						continue
					end

					Generate.SetParticle(emitter)
					emitter.Enabled = true
				end

				local weld = clone:FindFirstChild("Weld")
				weld.Part1 = rightHand

				if i == 1 then
					Generate_DoughParts(skill_Releaser, releaser_Id, p, p2, v2)
				end
			end
		end,
		Release = function(enemy: string, sound: string, _: string, data)
			local _ = data.Player_Releaser
			local skill_Releaser = data.Skill_Releaser
			local releaser_RootPart = data.Releaser_RootPart
			local _ = data.Mouse_Position
			local skill_Info = data.Skill_Info
			local releaser_Id = data.Releaser_Id
			local _ = skill_Info.Moving_Speed
			local _ = skill_Info.Duration
			local hit_Position = data.Hit_Position
			local position = releaser_RootPart.Position
			local cFrame = releaser_RootPart.CFrame
			task.delay(0.15, function()
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Weapon_Sound",
					Enemy = enemy,
					Sound = sound
				})
			end)

			for _, part in ipairs(skills:GetChildren()) do
				if part:IsA("BasePart") and part.Name == `{releaser_Id}_{enemy}_{sound}_Hold` then
					part.Name = `{enemy}_{sound}`
					Debris:AddItem(part, 1)
					local attachment = part:FindFirstChild("Attachment")

					if attachment then
						for _, emitter in ipairs(attachment:GetChildren()) do
							if emitter:IsA("ParticleEmitter") and emitter.Enabled then
								emitter.Enabled = false
							end
						end
					end
				elseif part:IsA("BasePart") and string.find(part.Name, releaser_Id) and part:GetAttribute("Dough_Part") then
					part.Name = `{enemy}_{sound}`
					Debris:AddItem(part, 1)
					TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end
			end

			if (hit_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local _, v3, _ = CFrame.new(position, position + -cFrame.LookVector):ToOrientation()

				for _ = 1, 20 do
					local v4 = math.random(-35, 35)
					local v5 = math.random(-35, 35)
					local clone = skillFolder[enemy][`{sound}_Donut`]:Clone()
					clone:PivotTo(CFrame.new(hit_Position) * CFrame.new(v4, 42.5, v5) * CFrame.fromOrientation(0, v3, 0))
					clone.Parent = skills
					Debris:AddItem(clone, 2)
					local donut = clone:FindFirstChild("Donut")

					if donut then
						TweenService:Create(
							donut,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = createVector(13.64, 13.186, 5.344),
								CFrame = donut.CFrame * CFrame.Angles(3.141592653589793, -3.141592653589793, 0),
								Transparency = 0
							}
						):Play()
					end

					local clone2 = skillFolder[enemy][sound]:Clone()
					clone2.CanCollide = false
					clone2.Anchored = true
					clone2.CFrame = CFrame.new(hit_Position) * CFrame.new(v4, 40, v5) * CFrame.fromOrientation(0, v3, 0)
					clone2.Parent = skills
					Debris:AddItem(clone2, 2)
					local movingObject = clone2:FindFirstChild("MovingObject")

					if movingObject then
						local completedConnection = nil
						local tween = TweenService:Create(
							clone2,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								CFrame = clone2.CFrame * CFrame.new(0, Random.new():NextNumber(38.5, 39.5), 0):Inverse()
							}
						)
						tween:Play()
						TweenService:Create(
							movingObject,
							TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 0
							}
						):Play()
						local v6 = movingObject
						local v7 = clone2
						local v8 = donut
						completedConnection = tween.Completed:Connect(function()
							completedConnection:Disconnect()
							completedConnection = nil
							TweenService:Create(
								v6,
								TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Size = createVector(50, 50, 150)
								}
							):Play()
							PlaySound.PlaySound_Character(v7, {
								Folder = "Power_Sound",
								Enemy = enemy,
								Sound = `{sound}_Explosion`
							})
							task.delay(0.5, function()
								if v8 and v8.Parent then
									TweenService:Create(
										v8,
										TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											CFrame = v8.CFrame * CFrame.Angles(3.141592653589793, 3.141592653589793, 0),
											Size = createVector(0, 0, 0),
											Transparency = 1
										}
									):Play()
								end

								task.wait(0.5)

								if v7 and v7.Parent then
									TweenService:Create(
										v6,
										TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
										{
											Transparency = 1
										}
									):Play()
								end
							end)
						end)
					end

					task.wait(0.075)
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
			clone.Parent = skills
			clone:SetAttribute("Active", true)
			Debris:AddItem(clone, duration * 5)
			local clone2 = visualFX.Dough_Trail:Clone()
			clone2.Name = `{releaser_Id}_{enemy}_{sound}_Dough`
			clone2.Anchored = false
			clone2.CanCollide = false
			clone2.CFrame = CFrame.new(
				humanoidRootPart.Position,
				humanoidRootPart.Position + humanoidRootPart.AssemblyLinearVelocity
			)
			clone2.Parent = skills
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

						if clone2 and clone2.Parent then
							clone2:Destroy()
						end

						if heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end
					end
				end
			end)

			for _, emitter in ipairs(clone2:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
					continue
				end

				Generate.SetParticle(emitter)
				emitter.Enabled = true
			end

			local weld = Instance.new("Weld")
			weld.Part0 = clone2
			weld.Part1 = humanoidRootPart
			weld.Parent = clone2
			weld.C1 *= CFrame.new(0, 0, 10)

			if humanoidRootPart then
				PlaySound.PlaySound_Character(humanoidRootPart, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
			end

			Generate.Invisible(skill_Releaser)

			if lowerTorso then
				local weld_2 = clone.PrimaryPart:FindFirstChild("Weld")
				weld_2.Part1 = lowerTorso
			end

			local donut = clone:FindFirstChild("Donut")

			if donut then
				TweenService:Create(donut, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(3.5, 9, 9)
				}):Play()

				for _, part in ipairs(donut:GetChildren()) do
					if part:IsA("BasePart") and part.Name == "Spike" then
						TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Size = createVector(2, 2, 2),
							Transparency = 0
						}):Play()
					end
				end
			end

			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = Folders
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			task.spawn(function()
				while clone and clone.Parent and humanoidRootPart and humanoidRootPart.Parent and clone:GetAttribute("Active") do
					local raycastResult = workspace:Raycast(
						humanoidRootPart.Position,
						humanoidRootPart.CFrame.UpVector * -10,
						raycastParams
					)

					if raycastResult and raycastResult.Instance then
						Side_Rocks(
							enemy,
							humanoidRootPart,
							humanoidRootPart.Position,
							raycastResult.Distance,
							5,
							true,
							raycastResult.Instance
						)
					end

					task.wait(0.2)
				end
			end)
		end,
		Release = function(p: string, p2: string, _: string, p3)
			local skill_Releaser = p3.Skill_Releaser
			local releaser_Id = p3.Releaser_Id
			local child = skills:FindFirstChild((`{releaser_Id}_{p}_{p2}`))
			local child2 = skills:FindFirstChild((`{releaser_Id}_{p}_{p2}_Dough`))

			if child2 and child2.Parent then
				child2:Destroy()
			end

			if child and child.Parent then
				Debris:AddItem(child, 1)
				local weld = child.PrimaryPart:FindFirstChild("Weld")

				if weld then
					weld:Destroy()
					child.PrimaryPart.Anchored = true
				end

				child:SetAttribute("Active", nil)
				local donut = child:FindFirstChild("Donut")

				if donut then
					TweenService:Create(donut, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(0, 0, 0),
						Transparency = 1
					}):Play()

					for _, part in ipairs(donut:GetChildren()) do
						if part:IsA("BasePart") and part.Name == "Spike" then
							TweenService:Create(
								part,
								TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Size = createVector(0, 0, 0),
									Transparency = 1
								}
							):Play()
						end
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