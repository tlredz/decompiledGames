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
			clone.CFrame = CFrame.new(rootPart_Position, targetRootPart_Position) * CFrame.new(0, 8, 0)
			clone.Parent = skills2
			Debris:AddItem(clone, duration)
			PlaySound.PlaySound_Character(clone, {
				Folder = "Enemy",
				Enemy = p.Name,
				Sound = sound
			})

			if moving_Speed then
				local now = os.clock()
				local heartbeatConnection = nil
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					local now2 = os.clock()

					if not (now + duration <= now2) and Generate.CheckExist(clone) then
						clone.CFrame += CFrame.new(rootPart_Position, targetRootPart_Position).LookVector * moving_Speed * dt
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

			local picture = clone:FindFirstChild("Picture")
			local attachment = picture and picture:FindFirstChild("Attachment")

			if attachment then
				for _, emitter in ipairs(attachment:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
						continue
					end

					Generate.SetParticle(emitter)
					emitter.Enabled = true
				end

				task.wait(2)

				if Generate.CheckExist(clone) then
					for _, emitter in ipairs(attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled then
							emitter.Enabled = false
						end
					end

					for _, decal in ipairs(picture:GetChildren()) do
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
		end
	end
}