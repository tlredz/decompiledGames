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
return {
	Z = function(p, p2: string, data)
		local duration = data.Duration or 1
		local fall_Time = data.Fall_Time
		local _ = data.RootPart_CFrame
		local rootPart_Position = data.RootPart_Position
		local _ = data.TargetRootPart_Position

		if (rootPart_Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
			local v = {
				24,
				60,
				7,
				1
			}
			local clone = skills[p.Name][p2]:Clone()
			clone.CanCollide = false
			clone.Anchored = true
			clone.CFrame = CFrame.new(rootPart_Position) * CFrame.new(0, 100, 0)
			clone.Parent = skills2
			Debris:AddItem(clone, duration + fall_Time)
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(fall_Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					CFrame = clone.CFrame * CFrame.new(0, 100, 0):Inverse()
				}
			)
			tween:Play()
			tween.Completed:Wait()
			PlaySound.PlaySound_Character(clone, {
				Folder = "Enemy",
				Enemy = p.Name,
				Sound = `{p2}_Explosion`
			})
			Generate.Generate_Ground(clone, v[1], v[2], v[3], v[4])

			if clone and clone.Parent then
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(120, 120, 120)
				}):Play()
				TweenService:Create(clone, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end
		end
	end
}