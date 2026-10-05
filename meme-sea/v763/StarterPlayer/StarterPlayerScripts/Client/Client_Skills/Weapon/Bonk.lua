local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local currentCamera = workspace.CurrentCamera
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
ReplicatedStorage:WaitForChild("OtherEvent")
local skillFolder = ReplicatedStorage:WaitForChild("SkillFolder")
local skill_Animation = ReplicatedStorage:WaitForChild("Animation_Folder"):WaitForChild("Skill_Animation")
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
			local target_RootPart = data.Target_RootPart
			local humanoid = skill_Releaser:FindFirstChild("Humanoid")
			local position = releaser_RootPart.Position
			local cFrame = releaser_RootPart.CFrame

			if releaser_RootPart and humanoid and (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				if target_RootPart and target_RootPart.Parent and Generate.CheckIfAlive(target_RootPart.Parent) then
					local _, v, _ = CFrame.new(position, mouse_Position):ToOrientation()
					releaser_RootPart.CFrame = CFrame.new(target_RootPart.Position) * CFrame.fromOrientation(0, v, 0) * CFrame.new(
						0,
						0,
						3
					)
					local animator = humanoid:FindFirstChild("Animator")

					if animator then
						animator:LoadAnimation(skill_Animation.Weapon[enemy][sound].Release2):Play()
					end

					local bodyPosition = Instance.new("BodyPosition")
					bodyPosition.P = 100000
					bodyPosition.MaxForce = createVector(1000000, 1000000, 1000000)
					bodyPosition.Position = releaser_RootPart.Position
					bodyPosition.Parent = releaser_RootPart
					Debris:AddItem(bodyPosition, 0.5)
					local clone = skillFolder[enemy][sound]:Clone()
					clone.CanCollide = false
					clone.Anchored = true
					clone.CFrame = CFrame.new(target_RootPart.Position) * CFrame.fromOrientation(0, v, 0)
					clone.Parent = skills
					Debris:AddItem(clone, 1.5)
					PlaySound.PlaySound_Character(clone, {
						Folder = "Weapon_Sound",
						Enemy = enemy,
						Sound = `{sound}_Hit`
					})

					if clone then
						local now = os.clock()
						local heartbeatConnection = nil
						heartbeatConnection = RunService.Heartbeat:Connect(function()
							local now2 = os.clock()

							if now + 1.5 <= now2 or not Generate.CheckExist(clone) then
								if heartbeatConnection then
									heartbeatConnection:Disconnect()
									heartbeatConnection = nil
								end
							elseif clone and clone.Parent then
								clone.CFrame *= CFrame.fromEulerAnglesXYZ(0, 0.2, 0)
							end
						end)
						local movingObject = clone:FindFirstChild("MovingObject")

						if movingObject then
							TweenService:Create(
								movingObject,
								TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
							local mesh = movingObject:FindFirstChild("Mesh")

							if mesh then
								TweenService:Create(
									mesh,
									TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Scale = mesh.Scale * 1.5
									}
								):Play()
							end
						end
					end
				else
					local position2 = position + CFrame.new(position, mouse_Position).LookVector * moving_Speed
					local animator = humanoid:FindFirstChild("Animator")
					local lowerTorso = skill_Releaser:FindFirstChild("LowerTorso")

					if animator and lowerTorso then
						for _, v2 in ipairs(animator:GetPlayingAnimationTracks()) do
							if v2.Name == "Release" then
								v2:Stop()
							end
						end

						animator:LoadAnimation(skill_Animation.Weapon[enemy][sound].Spin):Play()
						local clone = skillFolder[enemy][sound]:Clone()
						clone.CanCollide = false
						clone.Anchored = false
						clone.CFrame = cFrame
						clone.Parent = skills
						Debris:AddItem(clone, duration + 0.5)
						local overlapParams = OverlapParams.new()
						overlapParams.FilterDescendantsInstances = { character, monster }
						overlapParams.FilterType = Enum.RaycastFilterType.Include
						local clone2 = skillFolder[enemy][`{sound}_DragHitbox`]:Clone()
						clone2.CanCollide = false
						clone2.Anchored = false
						clone2.Transparency = setting.Hitbox_Transparency
						clone2.CFrame = cFrame
						clone2.Parent = skills
						Debris:AddItem(clone2, skill_Info.Duration + 0.5 or 10)
						local weld = clone2:FindFirstChild("Weld")

						if weld then
							weld.Part1 = releaser_RootPart
							weld.C1 *= CFrame.new(0, 1, 0)
						end

						Generate.Client_Hitbox(
							player_Releaser,
							skill_Releaser,
							clone2,
							overlapParams,
							enemy,
							sound,
							duration + 0.5,
							{
								Moving_Speed = moving_Speed,
								Skill_Type = skill_Info.Skill_Type,
								RootPart_Position = position,
								Mouse_Position = mouse_Position,
								Hit_Sound = true,
								Weapon_Effect = true,
								Spinning_Loop = 5
							}
						)
						local weld2 = Instance.new("Weld")
						weld2.Parent = clone
						weld2.Part0 = clone
						weld2.Part1 = lowerTorso
						weld2.C1 *= CFrame.new(0, 2.5, 0)
						PlaySound.PlaySound_Character(releaser_RootPart, {
							Folder = "Weapon_Sound",
							Enemy = enemy,
							Sound = sound
						})
						local bodyPosition = Instance.new("BodyPosition")
						bodyPosition.Name = `{releaser_Id}_{enemy}_{sound}_Spinning`
						bodyPosition.P = 25000
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
									Transparency = 1
								}):Play()
								local mesh = movingObject:FindFirstChild("Mesh")

								if mesh then
									TweenService:Create(mesh, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
										Scale = mesh.Scale * 1.5
									}):Play()
								end
							end
						end

						if animator then
							for _, v2 in ipairs(animator:GetPlayingAnimationTracks()) do
								if v2.Name == "Spin" then
									v2:Stop()
								end
							end
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
			local position = releaser_RootPart.Position
			local cFrame = releaser_RootPart.CFrame

			if (position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local v = {
					Amount = 15,
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
				clone.CFrame = cFrame
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
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = Folders
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult = workspace:Raycast(clone.Position, clone.CFrame.UpVector * -10, raycastParams)
				Color3.fromRGB(163, 162, 165)
				local _ = Enum.Material.Concrete

				if raycastResult and raycastResult.Instance then
					Generate.Generate_FlyingRock(clone.Position, v.Amount, v.Size, v.Velocity)
				end

				local cheems = clone:FindFirstChild("Cheems")

				if cheems then
					TweenService:Create(cheems, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 0
					}):Play()
					local tween = TweenService:Create(
						clone,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CFrame = clone.CFrame * CFrame.new(0, 25, 0)
						}
					)
					tween:Play()
					tween.Completed:Wait()
					local now = os.clock()
					local heartbeatConnection = nil
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						local now2 = os.clock()

						if now + duration <= now2 or not Generate.CheckExist(clone) then
							if heartbeatConnection then
								heartbeatConnection:Disconnect()
								heartbeatConnection = nil
							end
						elseif cheems and cheems.Parent then
							cheems.CFrame *= CFrame.fromEulerAnglesXYZ(0, 0.1 * (1 + dt), 0)
						end
					end)
					local random = Random.new()
					task.spawn(function()
						for _ = 1, 15 do
							local integer = random:NextInteger(0, 360)
							local number = random:NextNumber(10, 125)
							local clone3 = skillFolder[enemy][`{sound}_Stuff`]:Clone()
							clone3.CanCollide = false
							clone3.Anchored = false
							clone3.Parent = skills
							clone3.CFrame = cFrame * CFrame.new(0, 25, 0)
							clone3.Velocity = (clone3.CFrame * CFrame.Angles(0, math.rad(integer), 0)).LookVector * number
							Debris:AddItem(clone3, 3)
							task.delay(0.5, function()
								local cheems2 = clone3:FindFirstChild("Cheems")
								local attachment = clone3:FindFirstChild("Attachment")

								if attachment then
									for i, emitter in ipairs(attachment:GetChildren()) do
										if emitter:IsA("ParticleEmitter") then
											emitter:Emit(5)
										end
									end
								end

								if cheems2 then
									TweenService:Create(
										cheems2,
										TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Transparency = 1
										}
									):Play()

									for i, decal in ipairs(cheems2:GetChildren()) do
										if decal:IsA("Decal") then
											TweenService:Create(
												decal,
												TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
												{
													Transparency = 1
												}
											):Play()
										end
									end
								end
							end)
							PlaySound.PlaySound_Character(clone3, {
								Folder = "Weapon_Sound",
								Enemy = enemy,
								Sound = `{sound}_Spawn`
							})
							task.wait(0.1)
						end
					end)
					task.wait(2)
					local cheems2 = clone:FindFirstChild("Cheems")

					if cheems2 then
						TweenService:Create(
							cheems2,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
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