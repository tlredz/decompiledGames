game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
		local monster_RootPart = data.Monster_RootPart
		local _ = data.RootPart_CFrame
		local rootPart_Position = data.RootPart_Position
		local _ = data.TargetRootPart_Position

		if (rootPart_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
			local clone = skills[p.Name][sound]:Clone()
			clone.CanCollide = false
			clone.Anchored = false
			clone.Parent = skills2
			Debris:AddItem(clone, duration + 1)
			local weld = clone:FindFirstChild("Weld")

			if weld then
				weld.Part1 = monster_RootPart
			end

			PlaySound.PlaySound_Character(p, {
				Folder = "Enemy",
				Enemy = p.Name,
				Sound = sound
			})

			for _, emitter in ipairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
					continue
				end

				Generate.SetParticle(emitter)
				emitter.Enabled = true
			end

			task.wait(1)

			if Generate.CheckExist(clone) then
				for _, emitter in ipairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") and emitter.Enabled then
						emitter.Enabled = false
					end
				end
			end
		end
	end
}