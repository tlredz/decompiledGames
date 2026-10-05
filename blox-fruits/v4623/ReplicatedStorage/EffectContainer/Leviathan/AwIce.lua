workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.MasterClock
game:GetService("TweenService")
local _ = Util.Debris
local _ = Util.Sound
local misc = Util.Luno.Misc
local _ = Util.PartCache
return function(data)
	local cFrame = data.CFrame
	local _ = data.Scaler
	local _ = data.Duration
	local _ = data.CanCollide
	misc.cameraInRange(cFrame.p, 3000)
end