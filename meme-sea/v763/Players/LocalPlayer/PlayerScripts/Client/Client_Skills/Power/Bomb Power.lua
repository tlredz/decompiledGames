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
			local position = releaser_RootPart.Position
			local _ = releaser_RootPart.CFrame

			if (position - currentCamera.CFrame.Position).Magnitude <= 2000 then
				local cFrame = CFrame.new(position, mouse_Position) * CFrame.new(-1.25, 0.85, -2.75)
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
								local v3 = {
									24,
									53,
									7,
									1.25
								}
								local clone3 = skillFolder[enemy][`{sound}_Explosion`]:Clone()
								clone3:PivotTo(CFrame.new(clone.Position) * CFrame.new(0, 15, 0))
								clone3.Parent = skills
								Debris:AddItem(clone3, 3)
								PlaySound.PlaySound_Character(clone3, {
									Folder = "Power_Sound",
									Enemy = enemy,
									Sound = `{sound}_Explosion`
								})
								local ball = clone3:FindFirstChild("Ball")
								local stroke = clone3:FindFirstChild("Stroke")

								if ball and stroke then
									Generate.Generate_Ground(clone3.PrimaryPart, v3[1], v3[2], v3[3], v3[4])
									TweenService:Create(
										ball,
										TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Size = createVector(100, 100, 100),
											CFrame = ball.CFrame * CFrame.Angles(0, -3.141592653589793, 0),
											Transparency = 0
										}
									):Play()
									TweenService:Create(
										stroke,
										TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Size = createVector(110, 110, 110),
											CFrame = stroke.CFrame * CFrame.Angles(0, -3.141592653589793, 0),
											Transparency = 0
										}
									):Play()
									task.wait(1)
									TweenService:Create(
										ball,
										TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Transparency = 1
										}
									):Play()
									TweenService:Create(
										stroke,
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

				task.spawn(function()
					while clone and clone.Parent and clone.Transparency < 1 do
						Generate.Generate_Ring(
							clone.CFrame,
							createVector(2.5, 0.1, 2.5),
							createVector(7.5, 0.5, 7.5),
							0.25,
							0.5
						)
						task.wait(0.25)
					end
				end)

				for _, trail in ipairs(clone:GetChildren()) do
					if not trail:IsA("Trail") or trail.Enabled then
						continue
					end

					trail.Enabled = true
				end

				task.wait(1)

				if Generate.CheckExist(clone) then
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
					task.wait(0.5)

					for _, trail in ipairs(clone:GetChildren()) do
						if trail:IsA("Trail") and trail.Enabled then
							trail.Enabled = false
						end
					end
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
				local weld = clone:FindFirstChild("Weld")
				weld.Part1 = rightHand
			end
		end,
		Release = function(enemy: string, p2: string, _: string, data)
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
			local cFrame = releaser_RootPart.CFrame
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{p2}_Hold`))

			if child then
				child:Destroy()
			end

			if (hit_Position - currentCamera.CFrame.Position).Magnitude <= 1500 and releaser_RootPart then
				local _, v2, _ = CFrame.new(position, position + -cFrame.LookVector):ToOrientation()
				local clone = skillFolder[enemy][p2]:Clone()
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = CFrame.new(hit_Position) * CFrame.new(0, 13, 0) * CFrame.fromOrientation(0, v2, 0)
				clone.Parent = skills
				Debris:AddItem(clone, duration + 1)
				task.delay(0.5, function()
					local clone2 = skillFolder[enemy][`{p2}_Hitbox`]:Clone()
					clone2.CanCollide = false
					clone2.Anchored = true
					clone2.Transparency = setting.Hitbox_Transparency
					clone2.CFrame = CFrame.new(hit_Position) * CFrame.new(0, 13, 0)
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
						p2,
						duration - 1,
						{
							Moving_Speed = moving_Speed,
							Skill_Type = skill_Info.Skill_Type,
							RootPart_Position = position,
							Mouse_Position = mouse_Position
						}
					)
				end)
				local bomb = clone:FindFirstChild("Bomb")
				local ears = clone:FindFirstChild("Ears")
				local floppa_Ball = clone:FindFirstChild("Floppa_Ball")

				if bomb and ears and floppa_Ball then
					local specialMesh = bomb:FindFirstChild("SpecialMesh")
					local specialMesh2 = ears:FindFirstChild("SpecialMesh")

					if specialMesh then
						TweenService:Create(
							specialMesh,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Scale = createVector(16.877, 16.877, 16.877)
							}
						):Play()
					end

					if specialMesh2 then
						TweenService:Create(
							specialMesh2,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Scale = createVector(23.527, 18.018, 4.285)
							}
						):Play()
					end

					TweenService:Create(bomb, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(16.877, 16.877, 16.877),
						CFrame = bomb.CFrame * CFrame.new(bomb.CFrame.X, 15.03, bomb.CFrame.Z)
					}):Play()
					TweenService:Create(ears, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(23.527, 18.015, 4.275),
						CFrame = ears.CFrame * CFrame.new(ears.CFrame.X, 30.958, ears.CFrame.Z)
					}):Play()
					TweenService:Create(
						floppa_Ball,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = createVector(35.441, 35.441, 35.441),
							CFrame = floppa_Ball.CFrame * CFrame.new(floppa_Ball.CFrame.X, 15.03, floppa_Ball.CFrame.Z)
						}
					):Play()
					task.wait(0.5)
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = Folders
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					local raycastResult = workspace:Raycast(clone.Position, clone.CFrame.UpVector * -25, raycastParams)
					Color3.fromRGB(163, 162, 165)
					local _ = Enum.Material.Concrete

					if raycastResult and raycastResult.Instance then
						local v3 = {
							25,
							55,
							6,
							1
						}
						local v4 = {
							Amount = 20,
							Size = createVector(2.5, 2.5, 2.5),
							Velocity = {
								X = {
									Min = -125,
									Max = 125
								},
								Y = {
									Min = 125,
									Max = 125
								},
								Z = {
									Min = -125,
									Max = 125
								}
							}
						}
						Generate.Generate_FlyingRock(
							clone.Position - createVector(0, 5, 0),
							v4.Amount,
							v4.Size,
							v4.Velocity,
							1.75,
							true
						)
						Generate.Generate_Ground(clone, v3[1], v3[2], v3[3], v3[4])
					end

					PlaySound.PlaySound_Character(clone, {
						Folder = "Power_Sound",
						Enemy = enemy,
						Sound = `{p2}_Explosion`
					})

					for _, emitter in ipairs(floppa_Ball:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(25)
						end
					end

					TweenService:Create(bomb, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
					TweenService:Create(ears, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
					TweenService:Create(
						floppa_Ball,
						TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()

					for _, decal in ipairs(floppa_Ball:GetChildren()) do
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

					local character2 = localPlayer.Character

					if Generate.CheckIfAlive(character2) then
						local humanoidRootPart = character2:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart and (humanoidRootPart.Position - clone.Position).Magnitude <= 100 and not localPlayer:GetAttribute("No_CameraShake") then
							v:Shake(CameraShaker.Presets.MiniExplosion)
						end
					end
				end
			end
		end
	}
}