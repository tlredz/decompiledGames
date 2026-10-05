local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local currentCamera = workspace.CurrentCamera
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
ReplicatedStorage:WaitForChild("OtherEvent")
local skillFolder = ReplicatedStorage:WaitForChild("SkillFolder")
local guiTemplate = ReplicatedStorage:WaitForChild("GuiTemplate")
local skills = workspace:WaitForChild("Skills")
local character = workspace:WaitForChild("Character")
local monster = workspace:WaitForChild("Monster")
local reverse_Mark = guiTemplate:WaitForChild("Reverse_Mark")
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
local Generate = require(moduleScript:WaitForChild("Generate"))
local Setting = require(moduleScript:WaitForChild("Setting"))
local setting = Setting.Setting

function Card_Disappear(instance)
	local card = instance and instance.Parent and instance:FindFirstChild("Card")

	if card then
		TweenService:Create(card, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()

		for _, decal in ipairs(card:GetChildren()) do
			if decal:IsA("Decal") then
				TweenService:Create(decal, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end
		end
	end
end

function Card_Jumpscare(instance)
	local card = instance and instance.Parent and instance:FindFirstChild("Card")

	if card then
		TweenService:Create(card, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 0
		}):Play()

		for _, decal in ipairs(card:GetChildren()) do
			if decal:IsA("Decal") then
				TweenService:Create(decal, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 0
				}):Play()
			end
		end
	end
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
							Weapon_Effect = true
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
				local movingObject = clone:FindFirstChild("MovingObject")

				if movingObject then
					movingObject.Size /= 3
					TweenService:Create(
						movingObject,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = movingObject.Size * 3
						}
					):Play()
				end

				if moving_Speed then
					local now = os.clock()
					local heartbeatConnection = nil
					local movingObject2 = clone:FindFirstChild("MovingObject")
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						local now2 = os.clock()

						if now + duration + 1 <= now2 or not Generate.CheckExist(clone) then
							if clone and clone.Parent then
								clone:Destroy()
							end

							if heartbeatConnection then
								heartbeatConnection:Disconnect()
								heartbeatConnection = nil
							end
						else
							clone.CFrame += CFrame.new(position, mouse_Position).LookVector * moving_Speed * dt

							if movingObject2 and movingObject2.Parent then
								movingObject2.CFrame *= CFrame.fromEulerAnglesXYZ(0, 0.1, 0)
							end
						end
					end)
				end

				task.wait(1.75)
				local movingObject2 = Generate.CheckExist(clone) and clone:FindFirstChild("MovingObject")

				if movingObject2 then
					TweenService:Create(
						movingObject2,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()

					for _, decal in ipairs(movingObject2:GetChildren()) do
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
		Release = function(enemy: string, sound: string, _: string, data)
			local _ = data.Releaser_Id
			local skill_Releaser = data.Skill_Releaser
			local duration = data.Duration
			local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
				PlaySound.PlaySound_Character(humanoidRootPart, {
					Folder = "Weapon_Sound",
					Enemy = enemy,
					Sound = sound
				})
				local clone = reverse_Mark:Clone()
				clone.Adornee = humanoidRootPart
				clone.Enabled = true
				clone.Parent = skill_Releaser
				local mark = clone:FindFirstChild("Mark")

				if mark then
					TweenService:Create(mark, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						ImageTransparency = 0
					}):Play()
				end

				local clone2 = skillFolder[enemy][`{sound}_Left`]:Clone()
				clone2.CanCollide = false
				clone2.Anchored = false
				clone2.CFrame = humanoidRootPart.CFrame
				clone2.Parent = skills
				Debris:AddItem(clone2, duration + 1)
				local clone3 = skillFolder[enemy][`{sound}_Right`]:Clone()
				clone3.CanCollide = false
				clone3.Anchored = false
				clone3.CFrame = humanoidRootPart.CFrame
				clone3.Parent = skills
				Debris:AddItem(clone3, duration + 1)
				local v = 0
				local lastTime = tick()
				Card_Jumpscare(clone2)
				Card_Jumpscare(clone3)
				task.spawn(function()
					while humanoidRootPart and humanoidRootPart.Parent and tick() - lastTime <= duration + 0.5 do
						v = (v + 0.016666666666666666) % 1
						local v2 = 6.283185307179586 * v
						clone2.CFrame = CFrame.Angles(0, v2, 0) * CFrame.new(0, 0, 10) + humanoidRootPart.Position
						clone3.CFrame = CFrame.Angles(0, v2, 0) * CFrame.new(0, 0, -10) + humanoidRootPart.Position
						task.wait()
					end
				end)
				task.wait(duration)
				Card_Disappear(clone2)
				Card_Disappear(clone3)

				if humanoidRootPart and humanoidRootPart.Parent then
					local reverse_Mark2 = skill_Releaser:FindFirstChild("Reverse_Mark")

					if reverse_Mark2 then
						TweenService:Create(
							reverse_Mark2.Mark,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								ImageTransparency = 1
							}
						):Play()
						Debris:AddItem(reverse_Mark2, 1)
					end

					PlaySound.FadingSound_Out(humanoidRootPart, 0.5, sound)
				end
			end
		end
	}
}