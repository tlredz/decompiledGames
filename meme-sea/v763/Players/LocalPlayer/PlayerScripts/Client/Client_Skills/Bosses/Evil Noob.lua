local createVector = vector.create
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
local EvilNoob = {}

function EvilNoob.Z(p, sound: string, data)
	local duration = data.Duration or 1
	local _ = data.RootPart_CFrame
	local rootPart_Position = data.RootPart_Position
	local targetRootPart_Position = data.TargetRootPart_Position
	local moving_Speed = data.Moving_Speed

	if (rootPart_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
		local clone = skills[p.Name][sound]:Clone()
		clone.CanCollide = false
		clone.Anchored = true
		clone.CFrame = CFrame.new(
			rootPart_Position,
			(Vector3.new(targetRootPart_Position.X, rootPart_Position.Y, targetRootPart_Position.Z))
		)
		clone.Parent = skills2
		Debris:AddItem(clone, duration + 1)
		local clone2 = skills[p.Name][`{sound}_Part`]:Clone()
		clone2.Name = `{p.Name}_{sound}_Part`
		clone2.Parent = skills2
		Debris:AddItem(clone2, duration + 1)
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

		clone:SetAttribute("Flying_Rock", true)
		Generate.Flying_Rock(clone, {
			DestroyTime = 2,
			Cooldown = 0.1,
			Loops = 3,
			Duration = 1.5,
			Raycast = createVector(0, -20, 0),
			Size_X = {
				Min = 1,
				Max = 3
			},
			Size_Y = {
				Min = 1,
				Max = 3
			},
			Size_Z = {
				Min = 1,
				Max = 3
			},
			Left_Right = {
				Min = -75,
				Max = 75
			},
			Up_Down = {
				Min = 75,
				Max = 100
			},
			Front_Back = {
				Min = -75,
				Max = 75
			}
		})

		for _, effect in ipairs(clone:GetDescendants()) do
			if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) or effect.Enabled then
				continue
			end

			Generate.SetParticle(effect)
			effect.Enabled = true
		end

		task.wait(1.5)

		if Generate.CheckExist(clone) then
			clone:SetAttribute("Flying_Rock", nil)

			for _, effect in ipairs(clone:GetDescendants()) do
				if not ((effect:IsA("ParticleEmitter") or effect:IsA("Trail")) and effect.Enabled) then
					continue
				end

				effect.Enabled = false
			end
		end
	end
end

function EvilNoob.Z_Hitted(enemy: string, _: string, p2)
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

function EvilNoob.X(instance, sound: string, data)
	local duration = data.Duration or 1
	local rootPart_CFrame = data.RootPart_CFrame
	local rootPart_Position = data.RootPart_Position
	local _ = data.TargetRootPart_Position

	if (rootPart_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
		local clone = skills[instance.Name][sound]:Clone()
		clone.CanCollide = false
		clone.Anchored = false
		clone.CFrame = rootPart_CFrame
		clone.Parent = skills2
		Debris:AddItem(clone, duration + 1)
		local clone2 = skills[instance.Name][`{sound}_Part`]:Clone()
		clone2.Name = `{instance.Name}_{sound}_Part`
		clone2.Parent = skills2
		Debris:AddItem(clone2, duration + 1)
		local weld = Instance.new("Weld")
		weld.Parent = clone
		local part

		if instance then
			part = instance:FindFirstChild("HumanoidRootPart")
		end

		weld.Part0 = part
		weld.Part1 = clone
		PlaySound.PlaySound_Character(instance, {
			Folder = "Enemy",
			Enemy = instance.Name,
			Sound = sound
		})
		local middle = clone:FindFirstChild("Middle")

		if middle then
			for _, emitter in ipairs(middle:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
					continue
				end

				Generate.SetParticle(emitter)
				emitter.Enabled = true
			end

			task.wait(duration)

			if clone and clone.Parent then
				for _, emitter in ipairs(middle:GetChildren()) do
					if emitter:IsA("ParticleEmitter") and emitter.Enabled then
						emitter.Enabled = false
					end
				end
			end
		end
	end
end

function EvilNoob.X_Hitted(enemy: string, _: string, p2)
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

return EvilNoob