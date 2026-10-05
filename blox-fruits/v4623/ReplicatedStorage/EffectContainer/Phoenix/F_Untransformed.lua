local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local vector2 = Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))

local function StopBodyVelocity(char, instance)
	instance:Set(vector2)
	heartbeatLoopFor2(0.1, function(_)
		char.HumanoidRootPart.AssemblyLinearVelocity = vector2
	end, function()
		instance:Destroy()
	end)
	char.Humanoid.PlatformStand = false
end

return function(data)
	local char = data.char
	local flyUpDistance = data.flyUpDistance
	local flyUpTime = data.flyUpTime
	local v = flyUpDistance / flyUpTime
	local velocity = createVector(0, 1, 0) * v
	local v3 = Util.BodyMover.new(char):Create("BodyVelocity", {
		Velocity = velocity,
		MaxForce = createVector(0, 1.2980742e33, 0)
	})
	task.wait(flyUpTime)
	StopBodyVelocity(char, v3)
end