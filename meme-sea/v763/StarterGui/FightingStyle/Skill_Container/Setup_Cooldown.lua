game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local Cooldown_Module = require(moduleScript:WaitForChild("Cooldown_Module"))
local parent = script.Parent
local parent2 = parent.Parent

for _, image in ipairs(parent:GetChildren()) do
	if image:IsA("ImageLabel") then
		Cooldown_Module.SetCooldown(image, image.Cooldown, parent2)
	end
end