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
		local _ = data.RootPart_CFrame
		local rootPart_Position = data.RootPart_Position
		local _ = data.TargetRootPart_Position

		if (rootPart_Position - currentCamera.CFrame.Position).Magnitude <= 1000 then
			local v = {
				50,
				5,
				50,
				1
			}
			local clone = skills[p.Name][sound]:Clone()
			clone.CanCollide = false
			clone.Anchored = true
			clone.CFrame = CFrame.new(rootPart_Position)
			clone.Parent = skills2
			PlaySound.PlaySound_Character(p, {
				Folder = "Enemy",
				Enemy = p.Name,
				Sound = sound
			})
			Debris:AddItem(clone, duration)
			Generate.Generate_Rock(clone.CFrame, v[1], v[2], v[3], v[4])
		end
	end
}