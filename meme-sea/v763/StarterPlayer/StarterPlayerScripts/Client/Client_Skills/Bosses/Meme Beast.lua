local createVector = vector.create
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
local MemeBeast = {}

function MemeBeast.Z(p, sound: string, data)
	local duration = data.Duration or 1
	local _ = data.RootPart_CFrame
	local rootPart_Position = data.RootPart_Position
	local targetRootPart_Position = data.TargetRootPart_Position
	local moving_Speed = data.Moving_Speed

	if (rootPart_Position - currentCamera.CFrame.Position).Magnitude <= 2000 then
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

		for _, effect in ipairs(clone:GetChildren()) do
			if effect:IsA("ParticleEmitter") and not effect.Enabled then
				Generate.SetParticle(effect)
				effect.Enabled = true
			elseif effect:IsA("Trail") and not effect.Enabled then
				effect.Enabled = true
			end
		end

		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Size = createVector(60, 60, 60),
			Transparency = 0.5
		}):Play()
		local bubble = clone:FindFirstChild("Bubble")

		if bubble then
			TweenService:Create(bubble, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
				Size = createVector(65, 65, 65),
				Transparency = 0.5
			}):Play()
		end

		task.wait(2.5)

		if clone and clone.Parent then
			for _, effect in ipairs(clone:GetChildren()) do
				if not ((effect:IsA("ParticleEmitter") or effect:IsA("Trail")) and effect.Enabled) then
					continue
				end

				effect.Enabled = false
			end

			TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				Transparency = 1
			}):Play()

			if bubble then
				TweenService:Create(bubble, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					Transparency = 1
				}):Play()
			end
		end
	end
end

function MemeBeast.X(p, sound: string, data)
	local duration = data.Duration or 1
	local _ = data.RootPart_CFrame
	local rootPart_Position = data.RootPart_Position
	local _ = data.TargetRootPart_Position
	local hitbox_Size = data.Hitbox_Size
	local hitbox_CFrame = data.Hitbox_CFrame

	if (rootPart_Position - currentCamera.CFrame.Position).Magnitude <= 2000 then
		local clone = skills[p.Name][sound]:Clone()
		clone.CanCollide = false
		clone.Anchored = true
		clone.Size = Vector3.new(hitbox_Size.X, 0, 0)
		clone.CFrame = hitbox_CFrame
		clone.Parent = skills2
		Debris:AddItem(clone, duration + 0.5)
		PlaySound.PlaySound_Character(p, {
			Folder = "Enemy",
			Enemy = p.Name,
			Sound = sound
		})
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {
			Size = Vector3.new(hitbox_Size.X, 125, 125),
			Transparency = 0.5
		}):Play()
		task.wait(0.5)

		if clone and clone.Parent then
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {
				Size = Vector3.new(hitbox_Size.X, 0, 0),
				Transparency = 1
			}):Play()
		end
	end
end

return MemeBeast