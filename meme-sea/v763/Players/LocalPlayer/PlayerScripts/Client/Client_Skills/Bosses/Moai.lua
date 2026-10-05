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
require(moduleScript:WaitForChild("Generate"))
local _ = {
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

function Moai_Disappear(instance)
	if instance and instance.Parent then
		for _, part in ipairs(instance:GetChildren()) do
			if part:IsA("BasePart") then
				TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					Transparency = 1
				}):Play()
			end
		end
	end
end

function Moai_Jumpscare(instance)
	for _, part in ipairs(instance:GetChildren()) do
		if part:IsA("BasePart") then
			TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
				Transparency = 0
			}):Play()
		end
	end
end

return {
	Z = function(instance, sound: string, data)
		local duration = data.Duration or 1
		local rootPart_CFrame = data.RootPart_CFrame
		local rootPart_Position = data.RootPart_Position
		local _ = data.TargetRootPart_Position

		if (rootPart_Position - currentCamera.CFrame.Position).Magnitude <= 1000 then
			local clone = skills[instance.Name][`{sound}_Left`]:Clone()
			clone.CanCollide = false
			clone.Anchored = false
			clone.CFrame = rootPart_CFrame
			clone.Parent = skills2
			Debris:AddItem(clone, duration + 1)
			local clone2 = skills[instance.Name][`{sound}_Right`]:Clone()
			clone2.CanCollide = false
			clone2.Anchored = false
			clone2.CFrame = rootPart_CFrame
			clone2.Parent = skills2
			Debris:AddItem(clone2, duration + 1)
			local clone3 = skills[instance.Name][`{sound}_Front`]:Clone()
			clone3.CanCollide = false
			clone3.Anchored = false
			clone3.CFrame = rootPart_CFrame
			clone3.Parent = skills2
			Debris:AddItem(clone3, duration + 1)
			local clone4 = skills[instance.Name][`{sound}_Back`]:Clone()
			clone4.CanCollide = false
			clone4.Anchored = false
			clone4.CFrame = rootPart_CFrame
			clone4.Parent = skills2
			Debris:AddItem(clone4, duration + 1)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				PlaySound.PlaySound_Character(humanoidRootPart, {
					Folder = "Enemy",
					Enemy = instance.Name,
					Sound = sound
				})
			end

			local v = 0
			local lastTime = tick()
			Moai_Jumpscare(clone)
			Moai_Jumpscare(clone2)
			Moai_Jumpscare(clone3)
			Moai_Jumpscare(clone4)
			task.spawn(function()
				while humanoidRootPart and humanoidRootPart.Parent and tick() - lastTime <= duration + 0.5 do
					v = (v + 0.01) % 1
					local v2 = 6.283185307179586 * v
					clone.CFrame = CFrame.Angles(0, v2, 0) * CFrame.new(0, 0, 10) + humanoidRootPart.Position
					clone2.CFrame = CFrame.Angles(0, v2, 0) * CFrame.new(0, 0, -10) + humanoidRootPart.Position
					clone3.CFrame = CFrame.Angles(0, v2, 0) * CFrame.new(10, 0, 0) + humanoidRootPart.Position
					clone4.CFrame = CFrame.Angles(0, v2, 0) * CFrame.new(-10, 0, 0) + humanoidRootPart.Position
					task.wait()
				end
			end)
			task.wait(duration)
			Moai_Disappear(clone)
			Moai_Disappear(clone2)
			Moai_Disappear(clone3)
			Moai_Disappear(clone4)

			if humanoidRootPart then
				PlaySound.FadingSound_Out(humanoidRootPart, 1, sound)
			end
		end
	end
}