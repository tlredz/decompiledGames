local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.Modules.Utility)
return function(p)
	Utility:CreateSound("rbxassetid://7384906695", 0.8, 1, p.HumanoidRootPart, true)
	wait(2.75)
	Utility:CreateSound("rbxassetid://7384913560", 0.6, 1, p.HumanoidRootPart, true)
	wait(0.5)
	Utility:CreateSound("rbxassetid://7384913560", 0.8, 1.5, p.HumanoidRootPart, true)
end