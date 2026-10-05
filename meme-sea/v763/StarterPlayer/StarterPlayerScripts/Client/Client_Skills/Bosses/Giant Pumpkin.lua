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
local GiantPumpkin = {}

function GiantPumpkin.Z(p, sound: string, data)
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

		local movingObject = clone:FindFirstChild("MovingObject")

		if movingObject then
			for _, emitter in ipairs(movingObject:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
					continue
				end

				Generate.SetParticle(emitter)
				emitter.Enabled = true
			end

			task.wait(1.5)
			TweenService:Create(movingObject, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()

			if Generate.CheckExist(clone) then
				for _, emitter in ipairs(movingObject:GetChildren()) do
					if emitter:IsA("ParticleEmitter") and emitter.Enabled then
						emitter.Enabled = false
					end
				end
			end
		end
	end
end

function GiantPumpkin.X(p, sound: string, data)
	local duration = data.Duration or 1
	local fall_Time = data.Fall_Time
	local _ = data.RootPart_CFrame
	local rootPart_Position = data.RootPart_Position
	local targetRootPart_Position = data.TargetRootPart_Position

	if (rootPart_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
		local clone = skills[p.Name][sound]:Clone()
		clone.CanCollide = false
		clone.Anchored = true
		clone.CFrame = CFrame.new(
			rootPart_Position,
			(Vector3.new(targetRootPart_Position.X, rootPart_Position.Y, targetRootPart_Position.Z))
		) * CFrame.new(0, 8, 0)
		clone.Parent = skills2
		Debris:AddItem(clone, duration + fall_Time)
		local v = {
			Amount = 10,
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

		for _, effect in ipairs(clone:GetDescendants()) do
			if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) or effect.Enabled then
				continue
			end

			Generate.SetParticle(effect)
			effect.Enabled = true
		end

		PlaySound.PlaySound_Character(clone, {
			Folder = "Enemy",
			Enemy = p.Name,
			Sound = sound
		})
		local ball = clone:FindFirstChild("Ball")
		local tween = TweenService:Create(ball, TweenInfo.new(fall_Time, Enum.EasingStyle.Linear), {
			Size = createVector(47.729, 42.46, 43.953),
			Transparency = 0
		})
		tween:Play()
		tween.Completed:Wait()
		Generate.Generate_FlyingRock(clone.Position, v.Amount, v.Size, v.Velocity)
		PlaySound.PlaySound_Character(clone, {
			Folder = "Enemy",
			Enemy = p.Name,
			Sound = `{sound}_Explosion`
		})

		for _, effect in ipairs(clone:GetDescendants()) do
			if not ((effect:IsA("ParticleEmitter") or effect:IsA("Trail")) and effect.Enabled) then
				continue
			end

			effect.Enabled = false

			if effect:GetAttribute("Emitting") then
				effect:Emit(5)
			end
		end

		task.wait(0.5)

		if Generate.CheckExist(clone) then
			TweenService:Create(ball, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(0, ball.Size.Y, 0),
				Transparency = 1
			}):Play()
		end
	end
end

return GiantPumpkin