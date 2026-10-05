game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local currentCamera = workspace.CurrentCamera
local assets = ReplicatedStorage:WaitForChild("Assets")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
ReplicatedStorage:WaitForChild("OtherEvent")
local guiTemplate = ReplicatedStorage:WaitForChild("GuiTemplate")
local skills = assets:WaitForChild("Skills")
local skills2 = workspace:WaitForChild("Skills")
local reverse_Mark = guiTemplate:WaitForChild("Reverse_Mark")
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
local Generate = require(moduleScript:WaitForChild("Generate"))
local _ = {
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

local ReverseMaster = {}

function ReverseMaster.Z(p, sound: string, data)
	local duration = data.Duration or 1
	local _ = data.RootPart_CFrame
	local rootPart_Position = data.RootPart_Position
	local targetRootPart_Position = data.TargetRootPart_Position
	local moving_Speed = data.Moving_Speed

	if (rootPart_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
		local clone = skills[p.Name][sound]:Clone()
		clone.CanCollide = false
		clone.Anchored = true
		clone.CFrame = CFrame.new(rootPart_Position, targetRootPart_Position)
		clone.Parent = skills2
		Debris:AddItem(clone, duration + 1)
		local clone2 = skills[p.Name][`{sound}_Part`]:Clone()
		clone2.Name = `{p.Name}_{sound}_Part`
		clone2.Parent = skills2
		Debris:AddItem(clone2, duration + 1)
		PlaySound.PlaySound_Character(clone, {
			Folder = "Enemy",
			Enemy = p.Name,
			Sound = sound
		})
		local movingObject = clone:FindFirstChild("MovingObject")

		if movingObject then
			movingObject.Size /= 3
			TweenService:Create(movingObject, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = movingObject.Size * 3
			}):Play()
		end

		if moving_Speed then
			local now = os.clock()
			local heartbeatConnection = nil
			local movingObject2 = clone:FindFirstChild("MovingObject")
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				local now2 = os.clock()

				if now + duration + 1 <= now2 or not Generate.CheckExist(clone) then
					if clone then
						clone:Destroy()
					end

					if heartbeatConnection then
						heartbeatConnection:Disconnect()
						heartbeatConnection = nil
					end
				else
					clone.CFrame += CFrame.new(rootPart_Position, targetRootPart_Position).LookVector * moving_Speed * dt

					if movingObject2 and movingObject2.Parent then
						movingObject2.CFrame *= CFrame.fromEulerAnglesXYZ(0, 0.1 * (1 + dt), 0)
					end
				end
			end)
		end

		task.wait(1.75)
		local movingObject2 = Generate.CheckExist(clone) and clone:FindFirstChild("MovingObject")

		if movingObject2 then
			TweenService:Create(movingObject2, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()

			for _, decal in ipairs(movingObject2:GetChildren()) do
				if decal:IsA("Decal") then
					TweenService:Create(decal, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end
			end
		end
	end
end

function ReverseMaster.Z_Hitted(enemy: string, _: string, p2)
	local hit_Character = p2.Hit_Character
	local action = p2.Action
	local child = skills2:FindFirstChild((`{enemy}_{action}_Part`))

	if hit_Character and hit_Character.Parent and child then
		local humanoidRootPart = hit_Character:FindFirstChild("HumanoidRootPart")

		if not child:GetAttribute("Last_Time") then
			child:SetAttribute("Last_Time", tick() - 1)
		end

		if humanoidRootPart and tick() - child:GetAttribute("Last_Time") >= 0.1 then
			child:SetAttribute("Last_Time", tick())
			PlaySound.PlaySound_Character(humanoidRootPart, {
				Folder = "Enemy",
				Enemy = enemy,
				Sound = `{action}_Hit`
			})
		end
	end
end

function ReverseMaster.X(parent, sound: string, data)
	local duration = data.Duration or 1
	local rootPart_CFrame = data.RootPart_CFrame
	local rootPart_Position = data.RootPart_Position
	local _ = data.TargetRootPart_Position

	if (rootPart_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
		local clone = skills[parent.Name][`{sound}_Left`]:Clone()
		clone.CanCollide = false
		clone.Anchored = false
		clone.CFrame = rootPart_CFrame
		clone.Parent = skills2
		Debris:AddItem(clone, duration + 1)
		local clone2 = skills[parent.Name][`{sound}_Right`]:Clone()
		clone2.CanCollide = false
		clone2.Anchored = false
		clone2.CFrame = rootPart_CFrame
		clone2.Parent = skills2
		Debris:AddItem(clone2, duration + 1)
		local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			local raid_Mark = parent:FindFirstChild("Raid_Mark")

			if raid_Mark then
				raid_Mark.Enabled = false
			end

			local clone3 = reverse_Mark:Clone()
			clone3.Adornee = humanoidRootPart
			clone3.Enabled = true
			clone3.Parent = parent
			local mark = clone3:FindFirstChild("Mark")

			if mark then
				TweenService:Create(mark, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageTransparency = 0
				}):Play()
			end

			PlaySound.PlaySound_Character(humanoidRootPart, {
				Folder = "Enemy",
				Enemy = parent.Name,
				Sound = sound
			})
		end

		local v = 0
		local lastTime = tick()
		Card_Jumpscare(clone)
		Card_Jumpscare(clone2)
		task.spawn(function()
			while humanoidRootPart and humanoidRootPart.Parent and tick() - lastTime <= duration + 0.5 do
				v = (v + 0.016666666666666666) % 1
				local v2 = 6.283185307179586 * v
				clone.CFrame = CFrame.Angles(0, v2, 0) * CFrame.new(0, 0, 10) + humanoidRootPart.Position
				clone2.CFrame = CFrame.Angles(0, v2, 0) * CFrame.new(0, 0, -10) + humanoidRootPart.Position
				task.wait()
			end
		end)
		task.wait(duration)
		Card_Disappear(clone)
		Card_Disappear(clone2)

		if humanoidRootPart and humanoidRootPart.Parent then
			local reverse_Mark2 = parent:FindFirstChild("Reverse_Mark")

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

			local raid_Mark = parent:FindFirstChild("Raid_Mark")

			if raid_Mark then
				raid_Mark.Enabled = true
			end

			PlaySound.FadingSound_Out(humanoidRootPart, 0.5, sound)
		end
	end
end

return ReverseMaster