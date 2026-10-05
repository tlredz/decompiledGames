local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local _ = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
ReplicatedStorage:WaitForChild("Modules")
ReplicatedStorage:WaitForChild("OtherEvent")
local skillFolder = ReplicatedStorage:WaitForChild("SkillFolder")
local animation_Folder = ReplicatedStorage:WaitForChild("Animation_Folder")
local visualFX = ReplicatedStorage:WaitForChild("VisualFX")
local sound_Effect = ReplicatedStorage:WaitForChild("Sound_Effect")
local dash = visualFX:WaitForChild("Dash")
local skill_Animation = animation_Folder:WaitForChild("Skill_Animation")
local skills = workspace:WaitForChild("Skills")
local visuals = workspace:WaitForChild("Visuals")
local character = workspace:WaitForChild("Character")
local monster = workspace:WaitForChild("Monster")
require(moduleScript:WaitForChild("PlaySound"))
local Generate = require(moduleScript:WaitForChild("Generate"))
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
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
local dash2 = sound_Effect:FindFirstChild("Dash")
local jump = sound_Effect:FindFirstChild("Jump")

function FlashStep_Effect(color, material, instance)
	for _ = 1, 5 do
		local part = Instance.new("Part")
		part.Size = createVector(1, 1, 1)
		part.CanCollide = false
		part.Anchored = false
		part.Color = color
		part.Material = material
		part.Position = instance.Position
		part.Parent = workspace.Visuals
		local v = math.random(-75, 75)
		local v2 = math.random(-75, 75)
		part.AssemblyLinearVelocity = Vector3.new(v, 75, v2)
		part.AssemblyAngularVelocity = Vector3.new(v, 75, v2)
		task.delay(1, function()
			local tween = TweenService:Create(
				part,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					Size = createVector(0, 0, 0),
					Transparency = 1
				}
			)
			tween:Play()
			tween.Completed:Connect(function()
				if part and part.Parent then
					part:Destroy()
				end
			end)
		end)
	end

	local v = instance.CFrame.UpVector * 25

	for _ = 1, 10 do
		for _ = 1, math.random(1, 3) do
			local clone = visualFX.Dash.Sphere:Clone()
			clone.Anchored = true
			clone.CanCollide = false
			clone.Transparency = 0
			clone.Material = Enum.Material.Neon
			clone.Size = Vector3.new(0.07, 0.07, math.random(5, 7))

			if math.random(1, 4) == 1 then
				clone.Color = Color3.fromRGB(0, 0, 0)
			else
				clone.Color = Color3.new(1, 1, 1)
			end

			clone.CFrame = CFrame.new(instance.Position, instance.Position + v) * CFrame.new(
				math.random(-25, 20) / 10,
				math.random(-4, 2),
				math.random(-2, 2)
			)
			clone.Parent = visuals
			Debris:AddItem(clone, 0.3)
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Transparency = 1,
				Size = createVector(0, 0, 0),
				CFrame = clone.CFrame * CFrame.new(0, 0, math.random(2, 4))
			}):Play()
		end
	end
end

function Disonnection(connection)
	if connection then
		connection:Disconnect()
	end
end

function Checked_Humanoid(instance, p, data)
	if p and data and p.Anchored == false and data.WalkSpeed ~= 0 and data.Health > 0 and data.Sit == false and instance:FindFirstChild("Stun") and instance:FindFirstChild("Stun").Value <= 0 then
		return true
	end

	return false
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

			if (position - currentCamera.CFrame.Position).Magnitude <= 2000 then
				local cFrame = CFrame.new(position, mouse_Position) * CFrame.new(0.6, 2.25, 2.8)
				local Folders2 = {
					skill_Releaser,
					workspace.Skills,
					workspace.Region,
					workspace.Visuals,
					workspace.Location,
					workspace.Sea,
					workspace.Leaderboard,
					workspace.CameraFolder,
					workspace.SpawningPower
				}
				local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}_Hold`))

				if child then
					child.Name = `{enemy}_{sound}`
					Debris:AddItem(child, 1)
					local movingObject = child:FindFirstChild("MovingObject")

					if movingObject then
						TweenService:Create(movingObject, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
							Transparency = 1
						}):Play()
					end
				end

				local clone = skillFolder[enemy][sound]:Clone()
				clone.Name = `{releaser_Id}_{enemy}_{sound}`
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = cFrame
				clone.Parent = skills
				Debris:AddItem(clone, duration)
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local overlapParams = OverlapParams.new()
				overlapParams.FilterDescendantsInstances = Folders2
				overlapParams.FilterType = Enum.RaycastFilterType.Exclude
				local hitbox = clone:FindFirstChild("Hitbox")

				if hitbox then
					hitbox:SetAttribute("Exploded", false)
					hitbox.Transparency = setting.Hitbox_Transparency
					Generate.Client_Explosion(
						player_Releaser,
						skill_Releaser,
						hitbox,
						overlapParams,
						enemy,
						sound,
						duration,
						{
							Moving_Speed = moving_Speed,
							RootPart_Position = position,
							Mouse_Position = mouse_Position
						}
					)
					local explodedChangedConnection = nil
					local thread = task.delay(skill_Info.Duration, function()
						if explodedChangedConnection then
							explodedChangedConnection:Disconnect()
							explodedChangedConnection = nil
						end
					end)
					explodedChangedConnection = hitbox:GetAttributeChangedSignal("Exploded"):Connect(function()
						if Generate.CheckExist(hitbox) and hitbox:GetAttribute("Exploded") then
							if thread then
								task.cancel(thread)
							end

							if explodedChangedConnection then
								explodedChangedConnection:Disconnect()
								explodedChangedConnection = nil
							end

							local overlapParams2 = OverlapParams.new()
							overlapParams2.FilterDescendantsInstances = { character, monster }
							overlapParams2.FilterType = Enum.RaycastFilterType.Include
							local clone2 = skillFolder[enemy][`{sound}_ExplosionHitbox`]:Clone()
							clone2.CanCollide = false
							clone2.Anchored = true
							clone2.Transparency = setting.Hitbox_Transparency
							clone2.CFrame = CFrame.new(hitbox.Position) * CFrame.new(0, 20, 0)
							clone2.Parent = skills
							Debris:AddItem(clone2, 1)

							if hitbox and hitbox.Parent then
								hitbox:Destroy()
							end

							Generate.Client_Hitbox(
								player_Releaser,
								skill_Releaser,
								clone2,
								nil,
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

							if clone and clone.Parent then
								clone:SetAttribute("Exploded", true)
								local v2 = {
									24,
									53,
									7,
									2.25
								}
								local clone3 = skillFolder[enemy][`{sound}_Explosion`]:Clone()
								clone3:PivotTo(CFrame.new(clone.Position))
								clone3.Parent = skills
								Debris:AddItem(clone3, 3)
								PlaySound.PlaySound_Character(clone3, {
									Folder = "Power_Sound",
									Enemy = enemy,
									Sound = `{sound}_Explosion`
								})
								local dog = clone3:FindFirstChild("Dog")

								if dog then
									Generate.Generate_Ground(clone3.PrimaryPart, v2[1], v2[2], v2[3], v2[4])
									TweenService:Create(
										dog,
										TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Size = createVector(83.037, 74.153, 98.234),
											CFrame = CFrame.new(
												dog.Position,
												dog.Position + clone.CFrame.LookVector * createVector(1, 0, 1)
											),
											Transparency = 0
										}
									):Play()
									task.wait(1.5)
									TweenService:Create(
										dog,
										TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Transparency = 1
										}
									):Play()
								end
							end
						end
					end)
				end

				Generate.Generate_Ring(
					clone.CFrame * CFrame.new(0, 0, -7.5),
					createVector(2.5, 0.1, 2.5),
					createVector(10, 1, 10),
					0.25,
					0.5
				)
				clone:FindFirstChild("MovingObject")

				if moving_Speed then
					local now = os.clock()
					local heartbeatConnection = nil
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						local now2 = os.clock()

						if not (now + duration <= now2) and Generate.CheckExist(clone) and not clone:GetAttribute("Exploded") then
							clone.CFrame += CFrame.new(cFrame.Position, mouse_Position).LookVector * moving_Speed * dt
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

				for _, trail in ipairs(clone:GetChildren()) do
					if not trail:IsA("Trail") or trail.Enabled then
						continue
					end

					trail.Enabled = true
				end

				local attachment = clone:FindFirstChild("Attachment")

				if attachment then
					for _, emitter in ipairs(attachment:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
							continue
						end

						Generate.SetParticle(emitter)
						emitter.Enabled = true
					end
				end

				task.wait(1)

				if Generate.CheckExist(clone) then
					local movingObject = clone:FindFirstChild("MovingObject")

					if movingObject then
						TweenService:Create(movingObject, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
							Transparency = 1
						}):Play()
					end

					task.wait(0.5)

					if clone and clone.Parent then
						for _, trail in ipairs(clone:GetChildren()) do
							if trail:IsA("Trail") and trail.Enabled then
								trail.Enabled = false
							end
						end

						for _, emitter in ipairs(attachment:GetChildren()) do
							if emitter:IsA("ParticleEmitter") and emitter.Enabled then
								emitter.Enabled = false
							end
						end
					end
				end
			end
		end
	},
	X = {
		Hold = function(enemy: string, sound: string, _: string, data)
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
				local clone = skillFolder[enemy][sound]:Clone()
				clone.Name = `{releaser_Id}_{enemy}_{sound}`
				clone.CanCollide = false
				clone.Anchored = false
				clone.CFrame = cFrame * CFrame.new(0, 0, -2)
				clone.Parent = skills
				Debris:AddItem(clone, duration + 1)
				local weld = clone:FindFirstChild("Weld")

				if weld then
					weld.Part1 = releaser_RootPart
					weld.C1 *= CFrame.new(0, 0, -2)
				end

				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local attachment = clone:FindFirstChild("Attachment")

				if attachment then
					for _, emitter in ipairs(attachment:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
							continue
						end

						Generate.SetParticle(emitter)
						emitter.Enabled = true
					end

					task.wait(1.6)

					if clone and clone.Parent then
						for _, emitter in ipairs(attachment:GetChildren()) do
							if emitter:IsA("ParticleEmitter") and emitter.Enabled then
								emitter.Enabled = false
							end
						end
					end
				end
			end
		end,
		Release = function(p: string, p2: string, _: string, p3)
			local skill_Releaser = p3.Skill_Releaser
			local child = skills:FindFirstChild((`{p3.Releaser_Id}_{p}_{p2}`))

			if child then
				Debris:AddItem(child, 1)
				local attachment = child:FindFirstChild("Attachment")

				if attachment then
					for _, emitter in ipairs(attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end
				end

				local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					PlaySound.FadingSound_Out(humanoidRootPart, 0.5, p2)
				end
			end
		end
	},
	C = {
		Hold = function(p: string, p2: string, _: string, p3)
			local releaser_Id = p3.Releaser_Id
			local rightHand = p3.Skill_Releaser:FindFirstChild("RightHand")

			if rightHand and (rightHand.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[p][`{p2}_Hold`]:Clone()
				clone.Name = `{releaser_Id}_{p}_{p2}_Hold`
				clone.Parent = skills
				Debris:AddItem(clone, 60)
				os.clock()
				local dog = clone:FindFirstChild("Dog")
				local animationController = clone:FindFirstChild("AnimationController")
				local weld = clone:FindFirstChild("Weld")
				weld.Part1 = rightHand

				if dog then
					local attachment = dog:FindFirstChild("Attachment")

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

				local animator = animationController and animationController:FindFirstChild("Animator")

				if animator then
					animator:LoadAnimation(skill_Animation.Power[p][p2].Spin):Play()
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
			local duration = skill_Info.Duration
			local hit_Position = data.Hit_Position
			local _ = releaser_RootPart.Position
			local _ = releaser_RootPart.CFrame
			local v = {
				25,
				45,
				6,
				2
			}
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

			if (hit_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[enemy][sound]:Clone()
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = CFrame.new(hit_Position) * CFrame.new(0, 11, 0)
				clone.Parent = skills
				Debris:AddItem(clone, duration + 0.5)
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				os.clock()
				local aura = clone:FindFirstChild("Aura")
				local dog = clone:FindFirstChild("Dog")
				local beam = clone:FindFirstChild("Beam")
				local stroke = clone:FindFirstChild("Stroke")
				local wave = clone:FindFirstChild("Wave")
				local attachment = aura:FindFirstChild("Attachment")

				if aura and dog and beam and stroke and attachment then
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = Folders
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					local raycastResult = workspace:Raycast(clone.Position, clone.CFrame.UpVector * -15, raycastParams)
					Color3.fromRGB(163, 162, 165)
					local _ = Enum.Material.Concrete

					if raycastResult and raycastResult.Instance then
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

							while clone and clone.Parent and tick() - lastTime <= 1.5 do
								local clone2 = wave:Clone()
								clone2.Transparency = 0.1
								clone2.CFrame = clone.CFrame * CFrame.new(0, -10, 0)
								clone2.Anchored = true
								clone2.Parent = clone
								Debris:AddItem(clone2, 1)
								TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Cubic), {
									Size = createVector(175, 10, 175),
									Transparency = 1
								}):Play()
								task.wait(0.25)
							end
						end)
					end

					TweenService:Create(dog, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(31.9, 28.481, 37.743),
						Transparency = 0
					}):Play()
					TweenService:Create(beam, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(101.5, 85, 85),
						Transparency = 0
					}):Play()
					TweenService:Create(stroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(104, 90, 90),
						Transparency = 0.5
					}):Play()
					task.wait(1.5)

					if clone and clone.Parent then
						for _, emitter in ipairs(attachment:GetChildren()) do
							if emitter:IsA("ParticleEmitter") and emitter.Enabled then
								emitter.Enabled = false
							end
						end

						TweenService:Create(dog, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Transparency = 1
						}):Play()
						TweenService:Create(
							beam,
							TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
							{
								Size = createVector(101.5, 0, 0),
								Transparency = 1
							}
						):Play()
						TweenService:Create(
							stroke,
							TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
							{
								Size = createVector(104, 0, 0),
								Transparency = 1
							}
						):Play()
					end
				end
			end
		end
	},
	V = {
		Release = function(_: string, _: string, _: string, p)
			local summoned_Dog = p.Summoned_Dog

			if summoned_Dog and summoned_Dog.Parent then
				local humanoidRootPart = summoned_Dog:FindFirstChild("HumanoidRootPart")
				local attachment = humanoidRootPart and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude <= 1500 and humanoidRootPart:FindFirstChild("Attachment")

				if attachment then
					for _, emitter in ipairs(attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(5)
						end
					end
				end
			end
		end,
		Dash = function(_: string, _: string, _: string, data)
			local pet = data.Pet
			local pet_Humanoid = data.Pet_Humanoid
			local pet_RootPart = data.Pet_RootPart
			local nearest_RootPart = data.Nearest_RootPart

			if not pet:GetAttribute("Last_Dash") then
				pet:SetAttribute("Last_Dash", tick())
			end

			if pet_RootPart and pet_RootPart.Parent and tick() - pet:GetAttribute("Last_Dash") >= 0.35 and Checked_Humanoid(
				pet,
				pet_RootPart,
				pet_Humanoid
			) then
				if pet:GetAttribute("Dash_Direction") == "Left" then
					pet:SetAttribute("Dash_Direction", "Right")
				else
					pet:SetAttribute("Dash_Direction", "Left")
				end

				pet:SetAttribute("Last_Dash", tick())
				local lookVector = CFrame.new(pet_RootPart.Position, nearest_RootPart.Position).LookVector
				local cframe = CFrame.new(
					pet_RootPart.Position,
					pet_RootPart.Position + lookVector * createVector(1, 0, 1)
				)
				local lastTime = tick()
				local floorMaterialChangedConnection = nil
				local heartbeatConnection = nil
				local bodyGyro = Instance.new("BodyGyro")
				bodyGyro.Name = "Dash_Gyro"
				bodyGyro.MaxTorque = createVector(100000, 100000, 100000)
				bodyGyro.P = 100000
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.P = 100000
				bodyVelocity.MaxForce = createVector(100000, 0, 100000)
				bodyVelocity.Velocity = cframe.LookVector * 400
				bodyGyro.CFrame = cframe

				if pet_Humanoid.FloorMaterial == Enum.Material.Air then
					bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
				else
					bodyVelocity.MaxForce = createVector(100000, 0, 100000)
				end

				bodyVelocity.Parent = pet_RootPart
				Debris:AddItem(bodyGyro, 0.25)
				Debris:AddItem(bodyVelocity, 0.25)

				if (pet_RootPart.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
					PlaySound.PlaySound_RootPart(pet_RootPart, dash2)

					if pet_Humanoid.FloorMaterial == Enum.Material.Air then
						local clone = visualFX.Jump:FindFirstChild("Ring"):Clone()
						clone.Size = createVector(3, 1, 3)
						clone.Transparency = 0.75
						clone.Color = Color3.fromRGB(255, 255, 255)
						clone.CFrame = CFrame.new(
							pet_RootPart.Position,
							pet_RootPart.Position + pet_RootPart.CFrame.LookVector
						) * CFrame.Angles(-1.5707963267948966, 0, 0)
						clone.Parent = visuals
						Debris:AddItem(clone, 2)
						TweenService:Create(
							clone,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = createVector(20, 1.5, 20),
								CFrame = clone.CFrame * CFrame.new(0, 10, 0),
								Transparency = 1
							}
						):Play()

						for _ = 1, 5 do
							local v = math.random(3, 6)
							local clone2 = visualFX.Jump.Smoke:Clone()
							clone2.Color = Color3.fromRGB(203, 203, 203)
							clone2.CFrame = clone.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(
								math.random(360),
								math.random(360),
								math.random(360)
							)
							clone2.Size = Vector3.new(v, v, v)
							clone2.Parent = visuals
							Debris:AddItem(clone2, 0.5)
							TweenService:Create(
								clone2,
								TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Transparency = 1,
									Size = createVector(0, 0, 0),
									CFrame = clone2.CFrame * CFrame.new(math.random(-5, 5), -5, math.random(-5, 5)) * CFrame.Angles(
										math.random(360),
										math.random(360),
										math.random(360)
									)
								}
							):Play()
						end
					else
						local position = pet_RootPart.Position
						local clone = dash.DashEffect:Clone()
						clone.Parent = visuals
						clone.Weld.Part0 = pet_RootPart
						clone.Weld.Part1 = clone
						local raycastParams = RaycastParams.new()
						raycastParams.FilterDescendantsInstances = Folders
						raycastParams.FilterType = Enum.RaycastFilterType.Exclude
						local raycastResult = workspace:Raycast(
							pet_RootPart.Position,
							pet_RootPart.CFrame.UpVector * -10,
							raycastParams
						)
						local colorSequence = ColorSequence.new(Color3.fromRGB(163, 162, 165))

						if raycastResult and raycastResult.Instance and raycastResult.Instance.Color then
							colorSequence = ColorSequence.new(raycastResult.Instance.Color)
						end

						clone.A0.Dust.Color = colorSequence
						clone.A1.Dust.Color = colorSequence
						floorMaterialChangedConnection = pet_Humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
							if pet_Humanoid.FloorMaterial ~= Enum.Material.Air then
								local raycastResult2 = workspace:Raycast(
									pet_RootPart.Position,
									pet_RootPart.CFrame.UpVector * -10,
									raycastParams
								)

								if raycastResult2 and raycastResult2.Instance and raycastResult2.Instance.Color then
									colorSequence = ColorSequence.new(raycastResult2.Instance.Color)
								end

								clone.A0.Dust.Color = colorSequence
								clone.A1.Dust.Color = colorSequence
							end
						end)
						heartbeatConnection = RunService.Heartbeat:Connect(function()
							if pet_Humanoid.FloorMaterial ~= Enum.Material.Air and (pet_RootPart.Position - position).Magnitude > 2 then
								clone.A0.Dust:Emit(5)
								clone.A1.Dust:Emit(5)
								position = pet_RootPart.Position
							end
						end)
						Debris:AddItem(clone, 2)
						task.delay(0.35, function()
							Disonnection(floorMaterialChangedConnection)
							Disonnection(heartbeatConnection)
						end)
					end

					while tick() - lastTime <= 0.25 and pet and pet.Parent do
						bodyVelocity.Velocity = cframe.LookVector * (400 * (0.5 - (tick() - lastTime)))
						RunService.RenderStepped:Wait()
					end
				end
			end
		end,
		Normal_Jump = function(_: string, _: string, _: string, data)
			local _ = data.Pet
			local pet_Humanoid = data.Pet_Humanoid
			local pet_RootPart = data.Pet_RootPart
			local nearest_RootPart = data.Nearest_RootPart

			if pet_RootPart and pet_RootPart.Parent then
				if nearest_RootPart then
					pet_Humanoid:MoveTo(nearest_RootPart.Position - CFrame.new(
						pet_RootPart.Position,
						nearest_RootPart.Position + nearest_RootPart.CFrame.LookVector
					).LookVector * 5)
				end

				pet_Humanoid.Jump = true
			end
		end,
		Jump = function(_: string, _: string, _: string, data)
			local pet = data.Pet
			local pet_Humanoid = data.Pet_Humanoid
			local pet_RootPart = data.Pet_RootPart
			local _ = data.Nearest_RootPart

			if not pet:GetAttribute("Last_Jump") then
				pet:SetAttribute("Last_Jump", tick())
			end

			if pet_RootPart and pet_RootPart.Parent and tick() - pet:GetAttribute("Last_Jump") >= 0.35 and Checked_Humanoid(
				pet,
				pet_RootPart,
				pet_Humanoid
			) then
				pet:SetAttribute("Last_Jump", tick())
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
				bodyVelocity.Velocity = createVector(0, 50, 0)
				bodyVelocity.Parent = pet_RootPart
				Debris:AddItem(bodyVelocity, 0.25)

				if (pet_RootPart.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
					local clone = visualFX.Jump:WaitForChild("Ring"):Clone()
					clone.Size = createVector(3, 1, 3)
					clone.Transparency = 0.75
					clone.Color = Color3.fromRGB(255, 255, 255)
					clone.CFrame = CFrame.new(
						pet_RootPart.Position,
						pet_RootPart.Position + pet_RootPart.CFrame.LookVector
					)
					clone.Parent = visuals
					Debris:AddItem(clone, 1)
					PlaySound.PlaySound_RootPart(pet_RootPart, jump)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(17.5, 1.5, 17.5),
						CFrame = clone.CFrame * CFrame.new(0, -5, 0),
						Transparency = 1
					}):Play()

					for _ = 1, 5 do
						local v = math.random(3, 6)
						local clone2 = visualFX.Jump.Smoke:Clone()
						clone2.Color = Color3.fromRGB(203, 203, 203)
						clone2.CFrame = clone.CFrame * CFrame.new(0, -2.5, 0) * CFrame.Angles(
							math.random(360),
							math.random(360),
							math.random(360)
						)
						clone2.Size = Vector3.new(v, v, v)
						clone2.Parent = visuals
						Debris:AddItem(clone2, 0.5)
						TweenService:Create(
							clone2,
							TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1,
								Size = createVector(0, 0, 0),
								CFrame = clone2.CFrame * CFrame.new(math.random(-5, 5), -5, math.random(-5, 5)) * CFrame.Angles(
									math.random(360),
									math.random(360),
									math.random(360)
								)
							}
						):Play()
					end
				end
			end
		end,
		Flash_Step = function(_: string, _: string, _: string, data)
			local pet = data.Pet
			local last_Step = data.Last_Step
			local _ = data.Pet_Humanoid
			local pet_RootPart = data.Pet_RootPart
			local _ = data.Nearest_RootPart

			if not pet:GetAttribute("Last_FlashStep") then
				pet:SetAttribute("Last_FlashStep", tick())
			end

			if pet_RootPart and pet_RootPart.Parent and tick() - pet:GetAttribute("Last_FlashStep") >= 1 then
				pet:SetAttribute("Last_FlashStep", tick())

				if (pet_RootPart.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
					local clone = visualFX.Soru.FlashStep:Clone()
					clone.Anchored = true
					clone.CFrame = last_Step * CFrame.new(0, -2, 0)
					clone.Parent = visuals
					local wave = clone:FindFirstChild("Wave")

					if wave then
						wave.Orientation = createVector(-90, 0, 0)
						TweenService:Create(wave, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
							Size = createVector(20, 20, 5),
							Transparency = 1,
							Orientation = createVector(-90, -180, 0)
						}):Play()
						Debris:AddItem(clone, 1)
					end

					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = Folders
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					local raycastResult = workspace:Raycast(
						pet_RootPart.Position,
						pet_RootPart.CFrame.UpVector * -10,
						raycastParams
					)
					local color = Color3.fromRGB(105, 104, 106)
					local concrete = Enum.Material.Concrete

					if raycastResult and raycastResult.Instance and raycastResult.Instance.Color and raycastResult.Instance.Material then
						color = raycastResult.Instance.Color
						concrete = raycastResult.Instance.Material
					end

					FlashStep_Effect(color, concrete, pet_RootPart)
					local clone2 = visualFX.Soru.FlashStep:Clone()
					clone2.Anchored = true
					clone2.CFrame = pet_RootPart.CFrame * CFrame.new(0, -4, 0)
					clone2.Parent = visuals
					local wave2 = clone2:FindFirstChild("Wave")

					if wave2 then
						wave2.Orientation = createVector(-90, 0, 0)
						local tween = TweenService:Create(
							wave2,
							TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Size = createVector(20, 20, 5),
								Transparency = 1,
								Orientation = createVector(-90, -180, 0)
							}
						)
						tween:Play()
						tween.Completed:Wait()

						if clone2 then
							clone2:Destroy()
						end
					end
				end
			end
		end,
		Swim = function(_: string, _: string, _: string, data)
			local _ = data.Pet
			local _ = data.Pet_Humanoid
			local pet_RootPart = data.Pet_RootPart

			if pet_RootPart and pet_RootPart.Parent and pet_RootPart:FindFirstChild("Swim_BP") == nil then
				local bodyPosition = Instance.new("BodyPosition")
				bodyPosition.Name = "Swim_BP"
				bodyPosition:SetAttribute("Invincible", true)
				bodyPosition.MaxForce = createVector(0, 1000000, 0)
				bodyPosition.D = 750
				bodyPosition.P = 50000
				bodyPosition.Position = createVector(0, -108, 0)
				bodyPosition.Parent = pet_RootPart
			end
		end,
		Unswim = function(_: string, _: string, _: string, data)
			local _ = data.Pet
			local _ = data.Pet_Humanoid
			local pet_RootPart = data.Pet_RootPart
			local swim_BP = pet_RootPart:FindFirstChild("Swim_BP")

			if pet_RootPart and pet_RootPart.Parent and swim_BP then
				swim_BP:Destroy()
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Name = "Swim_BV"
				bodyVelocity.MaxForce = createVector(0, 100000, 0)
				bodyVelocity.Velocity = createVector(0, 50, 0)
				bodyVelocity.Parent = pet_RootPart
				Debris:AddItem(bodyVelocity, 0.25)
			end
		end
	},
	F = {
		Hold = function(enemy: string, sound: string, _: string, data)
			local skill_Releaser = data.Skill_Releaser
			local releaser_Id = data.Releaser_Id
			local duration = data.Duration
			skill_Releaser:FindFirstChild("HumanoidRootPart")
			local lowerTorso = skill_Releaser:FindFirstChild("LowerTorso")
			local clone = skillFolder[enemy][sound]:Clone()
			clone.Name = `{releaser_Id}_{enemy}_{sound}`
			clone.CanCollide = false
			clone.Anchored = false
			clone.Parent = skills
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
			PlaySound.PlaySound_Character(skill_Releaser, {
				Folder = "Power_Sound",
				Enemy = enemy,
				Sound = sound
			})

			if lowerTorso then
				local weld = Instance.new("Weld")
				weld.Parent = clone
				weld.Part0 = clone
				weld.Part1 = lowerTorso
			end

			Generate.Invisible(skill_Releaser)

			for _, effect in ipairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") and not effect.Enabled then
					Generate.SetParticle(effect)
					effect.Enabled = true
				elseif effect:IsA("Trail") and not effect.Enabled then
					effect.Enabled = true
				end
			end
		end,
		Release = function(p: string, p2: string, _: string, p3)
			local skill_Releaser = p3.Skill_Releaser
			local releaser_Id = p3.Releaser_Id
			local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")
			local folder = skills:FindFirstChild((`{releaser_Id}_{p}_{p2}`))

			if folder and folder.Parent then
				Debris:AddItem(folder, 1)
				local weld = folder:FindFirstChild("Weld")

				if weld then
					weld:Destroy()
					folder.Anchored = true
				end

				for _, effect in ipairs(folder:GetDescendants()) do
					if effect:IsA("ParticleEmitter") and effect.Enabled then
						effect:Destroy()
					elseif effect:IsA("Trail") and effect.Enabled then
						effect.Enabled = false
					end
				end

				TweenService:Create(folder, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					Transparency = 1
				}):Play()
			end

			if skill_Releaser and skill_Releaser.Parent then
				Generate.Visible(skill_Releaser)
				PlaySound.FadingSound_Out(humanoidRootPart, 0.5, p2)
			end
		end
	}
}