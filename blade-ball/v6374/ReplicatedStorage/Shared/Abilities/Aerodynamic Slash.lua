local RunService = game:GetService("RunService")
require(script.Parent._Types)
return {
	cooldown = RunService:IsStudio() and 2 or 35,
	cooldownReductionPerUpgrade = 3,
	iconId = "rbxassetid://0"
}