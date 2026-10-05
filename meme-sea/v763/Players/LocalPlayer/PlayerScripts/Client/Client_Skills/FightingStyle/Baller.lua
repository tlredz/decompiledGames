local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local currentCamera = workspace.CurrentCamera
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
ReplicatedStorage:WaitForChild("OtherEvent")
local skillFolder = ReplicatedStorage:WaitForChild("SkillFolder")
local visualFX = ReplicatedStorage:WaitForChild("VisualFX")
local skill_Animation = ReplicatedStorage:WaitForChild("Animation_Folder"):WaitForChild("Skill_Animation")
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
			local _ = data.Releaser_Id
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
							RootPart_Position = position,
							Mouse_Position = mouse_Position
						}
					)
				end

				PlaySound.PlaySound_Character(clone, {
					Folder = "FightingStyle_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local v = CFrame.new(position, mouse_Position) * CFrame.new(0, 0, -10)
				task.spawn(function()
					for i = 1, 5 do
						local clone2 = visualFX.VFX.RingPart:Clone()
						clone2.CanCollide = false
						clone2.Anchored = true
						clone2.CFrame = v * CFrame.new(0, 0, i * -20)
						clone2.Parent = skills
						Debris:AddItem(clone2, 3)
						local ring = clone2:FindFirstChild("Ring")

						if ring then
							ring.Size = Vector3.new(i * 2.5, 0.1, i * 2.5)
							ring.Color = Color3.fromRGB(255, 255, 255)
							ring.Transparency = 0

							if ring:FindFirstChild("Fire") then
								ring.Fire.Enabled = true
							end

							local v2 = ring
							task.delay(0.25, function()
								if v2 and v2.Parent then
									v2.Fire.Enabled = false
								end
							end)
							TweenService:Create(ring, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
								Size = Vector3.new(i * 10, 1, i * 10),
								Transparency = 1
							}):Play()
						end

						task.wait(0.1)
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

				local movingObject = clone:FindFirstChild("MovingObject")

				if movingObject then
					for _, emitter in ipairs(movingObject:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
							continue
						end

						Generate.SetParticle(emitter)
						emitter.Enabled = true
					end
				end

				task.wait(1.5)
				local movingObject2 = Generate.CheckExist(clone) and clone:FindFirstChild("MovingObject")

				if movingObject2 then
					TweenService:Create(movingObject2, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()

					for _, effect in ipairs(movingObject2:GetChildren()) do
						if not ((effect:IsA("ParticleEmitter") or effect:IsA("Trail")) and effect.Enabled) then
							continue
						end

						effect.Enabled = false
					end
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
			local position = releaser_RootPart.Position
			local cFrame = releaser_RootPart.CFrame

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local lowerTorso = skill_Releaser:FindFirstChild("LowerTorso")
				local humanoid = skill_Releaser:FindFirstChild("Humanoid")
				local animator

				if humanoid then
					animator = humanoid:FindFirstChild("Animator")
				end

				local position2 = position + CFrame.new(position, mouse_Position).LookVector * moving_Speed
				local clone = skillFolder[enemy][sound]:Clone()
				clone.Name = `{releaser_Id}_{enemy}_{sound}`
				clone.CanCollide = false
				clone.Anchored = false
				clone.CFrame = cFrame
				clone.Parent = skills
				Debris:AddItem(clone, duration + 1)
				local clone2 = skillFolder[enemy][`{sound}_Hitbox`]:Clone()
				clone2.CanCollide = false
				clone2.Anchored = false
				clone2.Transparency = setting.Hitbox_Transparency
				clone2.CFrame = cFrame
				clone2.Parent = skills
				Debris:AddItem(clone2, duration + 1 or 10)
				local overlapParams = OverlapParams.new()
				overlapParams.FilterDescendantsInstances = { character, monster }
				overlapParams.FilterType = Enum.RaycastFilterType.Include
				local weld = clone2:FindFirstChild("Weld")

				if weld then
					weld.Part1 = releaser_RootPart
				end

				Generate.Client_Hitbox(player_Releaser, skill_Releaser, clone2, overlapParams, enemy, sound, duration, {
					Moving_Speed = moving_Speed,
					Skill_Type = skill_Info.Skill_Type,
					RootPart_Position = position,
					Mouse_Position = mouse_Position,
					Spinning_Loop = 5
				})

				if releaser_RootPart and lowerTorso then
					local weld2 = clone:FindFirstChild("Weld")

					if weld2 then
						weld2.Part1 = lowerTorso
					end

					PlaySound.PlaySound_Character(clone, {
						Folder = "FightingStyle_Sound",
						Enemy = enemy,
						Sound = sound
					})
					local bodyPosition = Instance.new("BodyPosition")
					bodyPosition.Name = `{releaser_Id}_{enemy}_{sound}_Spinning`
					bodyPosition.P = 12500
					bodyPosition.MaxForce = createVector(100000, 100000, 100000)
					bodyPosition.Position = position2
					bodyPosition.Parent = releaser_RootPart
					Debris:AddItem(bodyPosition, duration)
					task.wait(duration)

					if weld2 and weld2.Parent then
						weld2:Destroy()
					end

					if clone then
						clone.Anchored = true
						local movingObject = clone:FindFirstChild("MovingObject")

						if movingObject then
							TweenService:Create(movingObject, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
								Size = movingObject.Size * 1.5,
								Transparency = 1
							}):Play()
						end
					end

					if animator then
						for _, v2 in ipairs(animator:GetPlayingAnimationTracks()) do
							if v2.Name == "Release" then
								v2:Stop()
							end
						end
					end

					PlaySound.FadingSound_Out(clone, 0.5, sound)
				end
			end
		end
	},
	C = {
		Hold = function(enemy: string, sound: string, _: string, data)
			local player_Releaser = data.Player_Releaser
			local skill_Releaser = data.Skill_Releaser
			local releaser_RootPart = data.Releaser_RootPart
			local _ = data.Mouse_Position
			local skill_Info = data.Skill_Info
			local _ = data.Releaser_Id
			local _ = skill_Info.Moving_Speed
			local _ = skill_Info.Duration
			local cooldown = player_Releaser:FindFirstChild("Cooldown")
			local position = releaser_RootPart.Position
			local _ = releaser_RootPart.CFrame

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 and releaser_RootPart then
				local clone = skillFolder[enemy].Baller:Clone()
				clone:PivotTo(releaser_RootPart.CFrame * CFrame.new(-15, 0, 0))
				clone.Parent = skills
				Debris:AddItem(clone, 3)
				local clone2 = skillFolder[enemy].Baller:Clone()
				clone2:PivotTo(releaser_RootPart.CFrame * CFrame.new(15, 0, 0))
				clone2.Parent = skills
				Debris:AddItem(clone2, 3)

				if releaser_RootPart:FindFirstChild("RootAttachment") then
					local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")
					local humanoid = clone:FindFirstChild("Humanoid")
					local humanoidRootPart2 = clone2:FindFirstChild("HumanoidRootPart")
					local humanoid2 = clone2:FindFirstChild("Humanoid")

					if humanoidRootPart and humanoidRootPart2 and humanoid and humanoid2 then
						local animator = humanoid:FindFirstChild("Animator")
						local animator2 = humanoid2:FindFirstChild("Animator")

						if animator and animator2 then
							animator:LoadAnimation(skill_Animation.FightingStyle[enemy][sound].Release):Play()
							animator2:LoadAnimation(skill_Animation.FightingStyle[enemy][sound].Release):Play()
							local rootAttachment = humanoidRootPart:FindFirstChild("RootAttachment")
							local rootAttachment2 = humanoidRootPart2:FindFirstChild("RootAttachment")

							if rootAttachment and rootAttachment2 then
								local alignOrientation = Instance.new("AlignOrientation")
								alignOrientation.Parent = humanoidRootPart
								alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
								alignOrientation.Attachment0 = rootAttachment
								alignOrientation.Responsiveness = 200
								local alignOrientation2 = Instance.new("AlignOrientation")
								alignOrientation2.Parent = humanoidRootPart2
								alignOrientation2.Mode = Enum.OrientationAlignmentMode.OneAttachment
								alignOrientation2.Attachment0 = rootAttachment2
								alignOrientation2.Responsiveness = 200
								local bodyPosition = Instance.new("BodyPosition")
								bodyPosition.P = 100000
								bodyPosition.MaxForce = createVector(1000000, 1000000, 1000000)
								bodyPosition.Parent = humanoidRootPart
								local bodyPosition2 = Instance.new("BodyPosition")
								bodyPosition2.P = 100000
								bodyPosition2.MaxForce = createVector(1000000, 1000000, 1000000)
								bodyPosition2.Parent = humanoidRootPart2

								for _ = 1, 16 do
									if not (cooldown:FindFirstChild((`FightingStyle_{sound}_Holding`)) and Generate.CheckExist(releaser_RootPart)) then
										break
									end

									local clone3 = skillFolder[enemy][sound]:Clone()
									clone3.CanCollide = false
									clone3.Anchored = true
									local number = Random.new():NextNumber(-25, 25)
									local number2 = Random.new():NextNumber(0, 12)
									local number3 = Random.new():NextNumber(-5, -10)
									clone3.CFrame = releaser_RootPart.CFrame * CFrame.new(number, number2, number3)
									clone3.Parent = skills
									Debris:AddItem(clone3, 1)

									if alignOrientation then
										alignOrientation.CFrame = releaser_RootPart.CFrame
									end

									if alignOrientation2 then
										alignOrientation2.CFrame = releaser_RootPart.CFrame
									end

									if bodyPosition then
										bodyPosition.Position = (CFrame.new(
											releaser_RootPart.Position,
											releaser_RootPart.Position + releaser_RootPart.CFrame.LookVector
										) * CFrame.new(-15, -0.6, 0)).Position
									end

									if bodyPosition2 then
										bodyPosition2.Position = (CFrame.new(
											releaser_RootPart.Position,
											releaser_RootPart.Position + releaser_RootPart.CFrame.LookVector
										) * CFrame.new(15, -0.6, 0)).Position
									end

									Generate.Generate_Ring(
										clone3.CFrame,
										createVector(2.5, 0.1, 2.5),
										createVector(7.5, 0.5, 7.5),
										0.25,
										0.5
									)
									PlaySound.PlaySound_Character(skill_Releaser, {
										Folder = "FightingStyle_Sound",
										Enemy = enemy,
										Sound = sound
									})
									TweenService:Create(
										clone3,
										TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											CFrame = clone3.CFrame * CFrame.new(0, 0, Random.new():NextNumber(-40, -50))
										}
									):Play()
									local movingObject = clone3:FindFirstChild("MovingObject")

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

								if clone and clone.Parent then
									clone:Destroy()
								end

								if clone2 and clone2.Parent then
									clone2:Destroy()
								end
							end
						end
					end
				end
			end
		end
	},
	V = {
		Release = function(enemy: string, p2: string, _: string, data)
			local releaser_Id = data.Releaser_Id
			local skill_Info = data.Skill_Info
			local baller_CFrame = data.Baller_CFrame
			local duration = skill_Info.Duration
			local clone = skillFolder[enemy].Baller:Clone()
			clone.Name = `{releaser_Id}_Baller`
			clone:PivotTo(baller_CFrame)
			clone.Parent = skills
			Debris:AddItem(clone, duration + 1)
			PlaySound.PlaySound_Character(clone, {
				Folder = "FightingStyle_Sound",
				Enemy = enemy,
				Sound = `{p2}_Spawn`
			})
			local humanoid = clone:FindFirstChild("Humanoid")
			local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")

			if humanoid and humanoidRootPart then
				local animator = humanoid:FindFirstChild("Animator")

				if animator then
					animator:LoadAnimation(skill_Animation.FightingStyle[enemy][p2].Idle):Play()
				end

				local rootAttachment = humanoidRootPart:FindFirstChild("RootAttachment")

				if rootAttachment then
					local alignOrientation = Instance.new("AlignOrientation")
					alignOrientation.Parent = humanoidRootPart
					alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
					alignOrientation.Attachment0 = rootAttachment
					alignOrientation.Responsiveness = 50
					alignOrientation.CFrame = humanoidRootPart.CFrame
					local alignPosition = Instance.new("AlignPosition")
					alignPosition.MaxForce = 1000000
					alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
					alignPosition.Responsiveness = 200
					alignPosition.Attachment0 = rootAttachment
					alignPosition.Position = humanoidRootPart.Position
					alignPosition.Parent = humanoidRootPart
				end
			end
		end,
		Throw = function(enemy: string, sound: string, _: string, data)
			local releaser_Id = data.Releaser_Id
			local throw_CFrame = data.Throw_CFrame
			local target_CFrame = data.Target_CFrame
			local player_Releaser = data.Player_Releaser
			local skill_Releaser = data.Skill_Releaser
			local releaser_RootPart = data.Releaser_RootPart
			local skill_Info = data.Skill_Info
			local loop = data.Loop
			local moving_Speed = skill_Info.Moving_Speed
			local duration = skill_Info.Duration
			local position = releaser_RootPart.Position
			local _ = releaser_RootPart.CFrame
			local child = skills:FindFirstChild((`{releaser_Id}_Baller`))

			if child and (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local humanoid = child:FindFirstChild("Humanoid")
				local humanoidRootPart = child:FindFirstChild("HumanoidRootPart")

				if humanoid and humanoidRootPart then
					local animator = humanoid:FindFirstChild("Animator")

					if animator then
						animator:LoadAnimation(skill_Animation.FightingStyle[enemy][sound].Release):Play()
					end

					local alignOrientation = humanoidRootPart:FindFirstChild("AlignOrientation")

					if alignOrientation then
						alignOrientation.CFrame = CFrame.new(humanoidRootPart.Position, target_CFrame.Position)
					end

					local ball = child:FindFirstChild("Ball")
					local handle = ball and ball:FindFirstChild("Handle")

					if handle then
						handle.Transparency = 1
						TweenService:Create(
							handle,
							TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.35),
							{
								Transparency = 0
							}
						):Play()
					end

					local clone = skillFolder[enemy][sound]:Clone()
					clone.CanCollide = false
					clone.Anchored = true
					clone.CFrame = throw_CFrame
					clone.Parent = skills
					Debris:AddItem(clone, 3)
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
								RootPart_Position = throw_CFrame.Position,
								Mouse_Position = target_CFrame.Position,
								Loop = loop,
								Hit_Sound = true,
								Weapon_Effect = true
							}
						)
					end

					PlaySound.PlaySound_Character(clone, {
						Folder = "FightingStyle_Sound",
						Enemy = enemy,
						Sound = sound
					})

					if moving_Speed then
						local now = os.clock()
						local heartbeatConnection = nil
						heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
							local now2 = os.clock()

							if not (now + 3 <= now2) and Generate.CheckExist(clone) then
								clone.CFrame += CFrame.new(throw_CFrame.Position, target_CFrame.Position).LookVector * moving_Speed * dt
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

					task.wait(2)
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
			end
		end,
		Complete = function(_: string, _: string, _: string, p)
			local child = skills:FindFirstChild((`{p.Releaser_Id}_Baller`))

			if child then
				if (child.PrimaryPart.Position - currentCamera.CFrame.Position).Magnitude <= 1000 then
					local ball = child:FindFirstChild("Ball")
					local handle = ball and ball:FindFirstChild("Handle")

					if handle then
						TweenService:Create(
							handle,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end

					for _, part in ipairs(child:GetChildren()) do
						if not (part:IsA("BasePart") and part.Transparency < 1) then
							continue
						end

						TweenService:Create(
							part,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()

						if part.Name ~= "Head" then
							continue
						end

						local face = part:FindFirstChild("face")

						if not face then
							continue
						end

						face.Texture = "rbxassetid://13468798521"
						TweenService:Create(face, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Transparency = 1
						}):Play()
					end
				else
					local ball = child:FindFirstChild("Ball")
					local handle = ball and ball:FindFirstChild("Handle")

					if handle then
						handle.Transparency = 1
					end

					for _, part in ipairs(child:GetChildren()) do
						if part:IsA("BasePart") and part.Transparency < 1 then
							part.Transparency = 1
						end
					end
				end
			end
		end
	}
}