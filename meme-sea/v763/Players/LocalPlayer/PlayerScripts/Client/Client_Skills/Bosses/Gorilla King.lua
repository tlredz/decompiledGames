game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local Debris = game:GetService("Debris")
local currentCamera = workspace.CurrentCamera
local assets = ReplicatedStorage:WaitForChild("Assets")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
ReplicatedStorage:WaitForChild("OtherEvent")
local skills = assets:WaitForChild("Skills")
local skills2 = workspace:WaitForChild("Skills")
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
local Generate = require(moduleScript:WaitForChild("Generate"))
return {
	Z = function(p, sound: string, data)
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
			Debris:AddItem(clone, duration)
			PlaySound.PlaySound_Character(p, {
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

					if now + duration <= now2 or not Generate.CheckExist(clone) then
						if clone then
							clone:Destroy()
						end

						if heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end
					else
						clone.CFrame += CFrame.new(rootPart_Position, targetRootPart_Position).LookVector * moving_Speed * dt

						if movingObject and movingObject.Parent then
							movingObject.CFrame *= CFrame.fromEulerAnglesXYZ(0, 0.1 * (1 + dt), 0)
						end
					end
				end)
			end

			task.wait(1)

			if Generate.CheckExist(clone) then
				for _, trail in ipairs(clone:GetChildren()) do
					if trail:IsA("Trail") and trail.Enabled then
						trail.Enabled = false
					end
				end
			end
		end
	end
}