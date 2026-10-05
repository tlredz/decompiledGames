local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.Modules.Utility)
return function(p)
	Utility:CreateSound("rbxassetid://18184524463", 0.8, 1, p.HumanoidRootPart, true)
	wait(1.1)
	Utility:CreateSound("rbxassetid://18184413892", 0.7, 1, p.HumanoidRootPart, true)
	wait(0.65)
end