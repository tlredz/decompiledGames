local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
require(ReplicatedStorage.Chest.Modules.PeodizService)
game:GetService("RunService")
return function(_) end