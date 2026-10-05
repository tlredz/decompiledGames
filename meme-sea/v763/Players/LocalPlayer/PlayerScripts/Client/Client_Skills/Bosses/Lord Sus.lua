local createVector = vector.create
game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
local LordSus = {}

function LordSus.Z(p, sound: string, data)
	local duration = data.Duration or 1
	local fall_Time = data.Fall_Time
	local _ = data.RootPart_CFrame
	local rootPart_Position = data.RootPart_Position
	local targetRootPart_Position = data.TargetRootPart_Position

	if (rootPart_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
		local v = {
			25,
			55,
			6,
			2.25
		}
		local v2 = {
			Amount = 15,
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
		local clone = skills[p.Name][sound]:Clone()
		clone.CanCollide = false
		clone.Anchored = true
		clone.CFrame = CFrame.new(targetRootPart_Position) * CFrame.new(0, 33, 0)
		clone.Parent = skills2
		local clone2 = skills[p.Name][`{sound}_Part`]:Clone()
		clone2.Name = `{p.Name}_{sound}_Part`
		clone2.Parent = skills2
		Debris:AddItem(clone2, duration + 1)
		Debris:AddItem(clone, duration + fall_Time)
		PlaySound.PlaySound_Character(clone, {
			Folder = "Enemy",
			Enemy = p.Name,
			Sound = sound
		})
		local sword = clone:FindFirstChild("Sword")
		local attachment = clone:FindFirstChild("Attachment")
		local wave = clone:FindFirstChild("Wave")

		if sword and attachment and wave then
			for _, part in ipairs(sword:GetChildren()) do
				if not (part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation")) then
					continue
				end

				TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
					Transparency = 0
				}):Play()
			end

			for _, effect in ipairs(sword:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) or effect.Enabled then
					continue
				end

				Generate.SetParticle(effect)
				effect.Enabled = true
			end

			local tween = TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
				CFrame = clone.CFrame * CFrame.new(0, 33, 0):Inverse()
			})
			tween:Play()
			tween.Completed:Wait()
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = Folders
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			local raycastResult = workspace:Raycast(clone.Position, clone.CFrame.UpVector * -10, raycastParams)
			Color3.fromRGB(163, 162, 165)
			local _ = Enum.Material.Concrete

			if raycastResult and raycastResult.Instance then
				Generate.Generate_FlyingRock(clone.Position, v2.Amount, v2.Size, v2.Velocity)
				Generate.Generate_Ground(clone, v[1], v[2], v[3], v[4])

				for _, emitter in ipairs(attachment:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
						continue
					end

					Generate.SetParticle(emitter)
					emitter.Enabled = true
				end
			else
				task.spawn(function()
					local lastTime = tick()

					while clone and clone.Parent and tick() - lastTime <= 2.5 do
						local clone3 = wave:Clone()
						clone3.Transparency = 0.1
						clone3.CFrame = clone.CFrame * CFrame.new(0, -1.35, -0.84)
						clone3.Anchored = true
						clone3.Parent = clone
						Debris:AddItem(clone3, 1)
						TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Cubic), {
							Size = createVector(175, 10, 175),
							Transparency = 1
						}):Play()
						task.wait(0.25)
					end
				end)
			end

			task.wait(0.75)

			if attachment and attachment.Parent then
				for _, emitter in ipairs(attachment:GetChildren()) do
					if emitter:IsA("ParticleEmitter") and emitter.Enabled then
						emitter.Enabled = false
					end
				end
			end

			if sword and sword.Parent then
				for _, effect in ipairs(sword:GetDescendants()) do
					if not ((effect:IsA("ParticleEmitter") or effect:IsA("Beam")) and effect.Enabled) then
						continue
					end

					effect.Enabled = false
				end
			end

			task.wait(1)

			if sword and sword.Parent then
				for _, part in ipairs(sword:GetChildren()) do
					if not (part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation")) then
						continue
					end

					TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
						Transparency = 1
					}):Play()
				end
			end
		end
	end
end

function LordSus.Z_Hitted(enemy: string, _: string, p2)
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

return LordSus