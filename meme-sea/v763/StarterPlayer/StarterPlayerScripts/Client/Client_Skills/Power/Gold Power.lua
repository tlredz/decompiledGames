local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local _ = Players.LocalPlayer
local heartbeat = RunService.Heartbeat
local currentCamera = workspace.CurrentCamera
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
ReplicatedStorage:WaitForChild("Modules")
ReplicatedStorage:WaitForChild("OtherEvent")
local skillFolder = ReplicatedStorage:WaitForChild("SkillFolder")
local skills = workspace:WaitForChild("Skills")
local character = workspace:WaitForChild("Character")
local monster = workspace:WaitForChild("Monster")
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
local Generate = require(moduleScript:WaitForChild("Generate"))
local Setting = require(moduleScript:WaitForChild("Setting"))
local setting = Setting.Setting

function lerp(p, p2, p3)
	return p * (1 - p3) + p2 * p3
end

function quad(p, p2, p3, p4)
	local lerped = lerp(p, p2, p4)
	local lerped2 = lerp(p2, p3, p4)
	return (lerp(lerped, lerped2, p4))
end

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
			local hit_Position = data.Hit_Position
			local position = releaser_RootPart.Position
			local cFrame = releaser_RootPart.CFrame

			if (hit_Position - currentCamera.CFrame.Position).Magnitude <= 1500 and releaser_RootPart then
				local _, v, _ = CFrame.new(position, hit_Position):ToOrientation()
				local clone = skillFolder[enemy][sound]:Clone()
				clone.CanCollide = false
				clone.Anchored = true
				clone.CFrame = CFrame.new((cFrame * CFrame.new(20, 0, 0)).Position, hit_Position) * CFrame.fromOrientation(
					0,
					v,
					0
				)
				clone.Parent = skills
				Debris:AddItem(clone, duration)
				local clone2 = skillFolder[enemy][sound]:Clone()
				clone2.CanCollide = false
				clone2.Anchored = true
				clone2.CFrame = CFrame.new((cFrame * CFrame.new(-20, 0, 0)).Position, hit_Position) * CFrame.fromOrientation(
					0,
					v,
					0
				)
				clone2.Parent = skills
				Debris:AddItem(clone2, duration)
				local clone3 = skillFolder[enemy][`{sound}_Part`]:Clone()
				clone3.Name = `{releaser_Id}_{enemy}_{sound}_Part`
				clone3.Parent = skills
				Debris:AddItem(clone3, duration + 1)
				task.delay(0.5, function()
					local clone4 = skillFolder[enemy][`{sound}_Hitbox`]:Clone()
					clone4.CanCollide = false
					clone4.Anchored = true
					clone4.Transparency = setting.Hitbox_Transparency
					clone4.CFrame = CFrame.new(hit_Position)
					clone4.Parent = skills
					Debris:AddItem(clone4, duration or 10)
					local overlapParams = OverlapParams.new()
					overlapParams.FilterDescendantsInstances = { character, monster }
					overlapParams.FilterType = Enum.RaycastFilterType.Include
					Generate.Client_Hitbox(
						player_Releaser,
						skill_Releaser,
						clone4,
						overlapParams,
						enemy,
						sound,
						duration - 1.5,
						{
							Moving_Speed = moving_Speed,
							Skill_Type = skill_Info.Skill_Type,
							RootPart_Position = position,
							Mouse_Position = mouse_Position,
							Hit_Sound = true
						}
					)
				end)
				PlaySound.PlaySound_Character(skill_Releaser, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local movingObject = clone:FindFirstChild("MovingObject")
				local movingObject2 = clone2:FindFirstChild("MovingObject")

				if movingObject and movingObject2 then
					TweenService:Create(
						movingObject,
						TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Transparency = 0.25
						}
					):Play()
					TweenService:Create(
						movingObject2,
						TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Transparency = 0.25
						}
					):Play()
					local position2 = releaser_RootPart.Position
					local position3 = clone.Position
					local position4 = clone2.Position
					local total = 1
					local total2 = 0

					while total <= 25 and clone and clone.Parent and clone2 and clone2.Parent do
						local v2 = quad(position2, position3, hit_Position, total / 25)
						local v3 = quad(position2, position4, hit_Position, total / 25)
						clone.CFrame = CFrame.new(v2, CFrame.new(clone.Position, v2).Position)
						clone2.CFrame = CFrame.new(v3, CFrame.new(clone2.Position, v3).Position)
						total2 += heartbeat:Wait()
						total += math.ceil(total2 / 12.5 * 25)
					end

					local clone4 = skillFolder[enemy][`{sound}_Circle`]:Clone()
					clone4.CanCollide = false
					clone4.Anchored = true
					clone4.CFrame = CFrame.new(hit_Position)
					clone4.Parent = skills
					Debris:AddItem(clone4, 1)
					TweenService:Create(clone4, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(75, 75, 75),
						Transparency = 0.75
					}):Play()

					if movingObject and movingObject2 then
						TweenService:Create(
							movingObject,
							TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
							{
								Size = createVector(0, 0, 0),
								Transparency = 1
							}
						):Play()
						TweenService:Create(
							movingObject2,
							TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
							{
								Size = createVector(0, 0, 0),
								Transparency = 1
							}
						):Play()
					end

					task.wait(0.25)
					TweenService:Create(clone4, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end
			end
		end,
		Hitted = function(enemy: string, p2: string, _: string, data)
			local releaser_Id = data.Releaser_Id
			local _ = data.Releaser_Character
			local humanoidRootPart = data.Hit_Character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{p2}_Part`))

				if child then
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

				if (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
					local clone = skillFolder[enemy][`{p2}_Fish`]:Clone()
					clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, 6.85)
					clone.Parent = skills
					Debris:AddItem(clone, 2)
					local weld = clone:FindFirstChild("Weld")

					if weld then
						weld.Part1 = humanoidRootPart
					end

					task.wait(1)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = clone.Size * 1.25,
						Transparency = 1
					}):Play()
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

				for _, emitter in ipairs(attachment:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
						continue
					end

					Generate.SetParticle(emitter)
					emitter.Enabled = true
				end

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
			local hit_Position = data.Hit_Position
			local position = releaser_RootPart.Position
			local _ = releaser_RootPart.CFrame
			local child = skills:FindFirstChild((`{releaser_Id}_{enemy}_{sound}_Hold`))

			if child then
				child.Name = `{enemy}_{sound}`
				Debris:AddItem(child, 1)

				for _, emitter in ipairs(child:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
						continue
					end

					emitter.Enabled = false
				end
			end

			if (hit_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				local clone = skillFolder[enemy][sound]:Clone()
				clone:PivotTo(CFrame.new(hit_Position))
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
						duration - 1.5,
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
				local gold = clone:FindFirstChild("Gold")
				local goldFloor = clone:FindFirstChild("GoldFloor")

				if gold and goldFloor then
					TweenService:Create(
						goldFloor,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = createVector(100, 10, 100)
						}
					):Play()
					TweenService:Create(gold, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(50, 100, 50),
						Transparency = 0,
						CFrame = gold.CFrame * CFrame.Angles(0, -1.5707963267948966, 0)
					}):Play()
					task.wait(1.5)
					TweenService:Create(
						goldFloor,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = goldFloor.Size * 1.25,
							Transparency = 1
						}
					):Play()
					TweenService:Create(gold, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(0, 100, 0),
						Transparency = 1,
						CFrame = gold.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
					}):Play()
				end
			end
		end
	},
	C = {
		Release = function(enemy: string, sound: string, _: string, p3)
			local DISTANCE_THRESHOLD = 1500
			local skill_Releaser = p3.Skill_Releaser
			local type = p3.Type

			if Generate.CheckIfAlive(skill_Releaser) then
				if type == "Transform" and skill_Releaser:GetAttribute("Transform") then
					PlaySound.PlaySound_Character(skill_Releaser, {
						Folder = "Power_Sound",
						Enemy = enemy,
						Sound = sound
					})
					local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart and not humanoidRootPart:FindFirstChild("Gold_Attachment") then
						local clone = skillFolder[enemy][sound].Gold_Attachment:Clone()
						clone.Parent = humanoidRootPart

						for _, emitter in ipairs(clone:GetChildren()) do
							if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
								continue
							end

							emitter.Enabled = true
						end
					end

					local folder = Instance.new("Folder")
					folder.Name = "Golden_Folder"
					folder.Parent = skill_Releaser

					for _, part in ipairs(skill_Releaser:GetChildren()) do
						if not (part:IsA("MeshPart") and part.Transparency < 1) then
							continue
						end

						local clone = part:Clone()
						clone.Name = `{part}_ClonedBody`
						clone:ClearAllChildren()
						clone.Transparency = 1
						clone.Massless = true
						clone.TextureID = ""
						clone.Size += createVector(0.015, 0.015, 0.015)
						clone.Color = Color3.fromRGB(255, 255, 255)
						clone.Material = Enum.Material.Glass
						clone.Parent = folder
						local weld = Instance.new("Weld")
						weld.Name = `{part}_ClonedBodyWeld`
						weld.Parent = clone
						weld.Part0 = part
						weld.Part1 = clone

						if (clone.Position - currentCamera.CFrame.Position).Magnitude <= DISTANCE_THRESHOLD then
							TweenService:Create(
								clone,
								TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Transparency = 0,
									Color = Color3.fromRGB(239, 184, 56)
								}
							):Play()
						else
							clone.Transparency = 0
							clone.Color = Color3.fromRGB(239, 184, 56)
						end
					end
				elseif type == "Untransform" and not skill_Releaser:GetAttribute("Transform") then
					local golden_Folder = skill_Releaser:FindFirstChild("Golden_Folder")

					if golden_Folder then
						for _, part in ipairs(golden_Folder:GetChildren()) do
							if not part:IsA("MeshPart") then
								continue
							end

							if (part.Position - currentCamera.CFrame.Position).Magnitude <= DISTANCE_THRESHOLD then
								TweenService:Create(
									part,
									TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Transparency = 1
									}
								):Play()
								Debris:AddItem(part, 1)
							else
								part:Destroy()
							end
						end

						Debris:AddItem(golden_Folder, 1)
					end

					local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")
					local gold_Attachment = humanoidRootPart and humanoidRootPart:FindFirstChild("Gold_Attachment")

					if gold_Attachment then
						if (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude <= DISTANCE_THRESHOLD then
							Debris:AddItem(gold_Attachment, 1)

							for _, emitter in ipairs(gold_Attachment:GetChildren()) do
								if emitter:IsA("ParticleEmitter") and emitter.Enabled then
									emitter.Enabled = false
								end
							end
						else
							gold_Attachment:Destroy()
						end
					end
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

			if humanoidRootPart then
				PlaySound.PlaySound_Character(humanoidRootPart, {
					Folder = "Power_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local weld = clone:FindFirstChild("Weld")

				if weld then
					weld.Part1 = humanoidRootPart
				end
			end

			for _, trail in ipairs(clone:GetChildren()) do
				if not trail:IsA("Trail") or trail.Enabled then
					continue
				end

				trail.Enabled = true
			end

			local cloud = clone:FindFirstChild("Cloud")

			if cloud then
				TweenService:Create(cloud, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
					Size = createVector(7.653, 4.096, 4.992),
					Transparency = 0
				}):Play()
			end
		end,
		Release = function(p: string, p2: string, _: string, p3)
			local skill_Releaser = p3.Skill_Releaser
			local child = skills:FindFirstChild((`{p3.Releaser_Id}_{p}_{p2}`))

			if child and child.Parent then
				local weld = child:FindFirstChild("Weld")

				if weld then
					child.Anchored = true
					weld:Destroy()
				end

				for _, trail in ipairs(child:GetChildren()) do
					if trail:IsA("Trail") and trail.Enabled then
						trail.Enabled = false
					end
				end

				local cloud = child:FindFirstChild("Cloud")

				if cloud then
					TweenService:Create(cloud, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(0, 0, 0),
						Transparency = 1
					}):Play()
				end

				task.wait(1)

				if child and child.Parent then
					child:Destroy()
				end
			end

			local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				PlaySound.FadingSound_Out(humanoidRootPart, 0.5, p2)
			end
		end
	}
}