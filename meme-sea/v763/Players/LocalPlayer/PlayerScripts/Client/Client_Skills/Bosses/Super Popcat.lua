game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local currentCamera = workspace.CurrentCamera
local assets = ReplicatedStorage:WaitForChild("Assets")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
ReplicatedStorage:WaitForChild("OtherEvent")
local skills = assets:WaitForChild("Skills")
local skills2 = workspace:WaitForChild("Skills")
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
local Generate = require(moduleScript:WaitForChild("Generate"))
local SuperPopcat = {}

function SuperPopcat.Z(p, sound: string, data)
	local duration = data.Duration or 1
	local _ = data.RootPart_CFrame
	local rootPart_Position = data.RootPart_Position
	local targetRootPart_Position = data.TargetRootPart_Position
	local moving_Speed = data.Moving_Speed

	if (rootPart_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
		local clone = skills[p.Name][sound]:Clone()
		clone.Name = `{p.Name}_{sound}`
		clone.CanCollide = false
		clone.Anchored = true
		clone.CFrame = CFrame.new(rootPart_Position, targetRootPart_Position)
		clone.Parent = skills2
		Debris:AddItem(clone, duration + 2)
		PlaySound.PlaySound_Character(clone, {
			Folder = "Enemy",
			Enemy = p.Name,
			Sound = sound
		})

		if moving_Speed then
			local now = os.clock()
			local heartbeatConnection = nil
			local movingObject = clone:FindFirstChild("MovingObject")
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				local now2 = os.clock()

				if now + duration + 2 <= now2 or not Generate.CheckExist(clone) then
					if clone then
						clone:Destroy()
					end

					if heartbeatConnection then
						heartbeatConnection:Disconnect()
						heartbeatConnection = nil
					end
				else
					if not clone:GetAttribute("Hitted") then
						clone.CFrame += CFrame.new(rootPart_Position, targetRootPart_Position).LookVector * moving_Speed * dt
					end

					if movingObject and movingObject.Parent then
						movingObject.CFrame *= CFrame.fromEulerAnglesXYZ(0, 0.1, 0)
					end
				end
			end)
		end

		task.wait(1.5)
		local movingObject = Generate.CheckExist(clone) and not clone:GetAttribute("Hitted") and Generate.CheckExist(clone) and clone:FindFirstChild("MovingObject")

		if movingObject then
			TweenService:Create(movingObject, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
				Transparency = 1
			}):Play()
		end
	end
end

function SuperPopcat.Z_Prison(p: string, _: string, data)
	local _ = data.Hit_Character
	local action = data.Action
	local hit_Position = data.Hit_Position

	if (hit_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
		local child = skills2:FindFirstChild((`{p}_{action}`))

		if child and not child:GetAttribute("Hitted") then
			child.Name = `{p}_{action}_Hitted`
			TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
				CFrame = CFrame.new(hit_Position)
			}):Play()
			local movingObject = child:FindFirstChild("MovingObject")

			if movingObject and movingObject.Transparency ~= 0 then
				TweenService:Create(movingObject, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
					Transparency = 0
				}):Play()
			end

			child:SetAttribute("Hitted", true)
			task.wait(1.5)

			if child and child.Parent then
				PlaySound.FadingSound_Out(child, 0.5, action)
				local movingObject2 = child:FindFirstChild("MovingObject")

				if movingObject2 then
					TweenService:Create(movingObject2, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						Size = movingObject2.Size * 1.5,
						Transparency = 1
					}):Play()
				end
			end
		end
	end
end

return SuperPopcat