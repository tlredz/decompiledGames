local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
ReplicatedStorage:WaitForChild("Assets")
local FX = require(game.ReplicatedStorage.FX)
FX:WaitForChild("Dough")
workspace:WaitForChild("_WorldOrigin")
local _ = workspace.CurrentCamera
local _ = Util.Misc
local _ = Util.DistributedLoop
local _ = Util.Tween
local Screen = {}

function Screen.new()
	return (setmetatable({}, {
		__index = Screen
	}))
end

return Screen