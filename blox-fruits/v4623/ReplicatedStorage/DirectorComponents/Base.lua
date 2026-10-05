local class = {}
class.__index = class
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Director"))

function class.Init(_) end

function class.Destroy(_) end

return {
	new = function(instance, _)
		return (setmetatable({
			Instance = instance
		}, class))
	end,
	ancestor = nil
}