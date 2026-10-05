local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
Vector3.new()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local shockwave = FX:WaitForChild("BuddhaEffects").Shockwave
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = Util.LightningBolt2
local promise = Util.Promise
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local awaitHeartbeatLoopFor = heartbeatLoopFor.AwaitHeartbeatLoopFor

local function buddhaShockwave(position, p, instance)
	local _ = Workspace.CurrentCamera
	local model = Instance.new("Model")
	model.Parent = _WorldOrigin
	local clone = shockwave.Groundwave:Clone()
	clone.Size = createVector(7.5, 0.9, 7.5) * p
	clone.CFrame = CFrame.new(position + createVector(0, 1, 0) * clone.Size.Y * 0.4)
	clone.Parent = model
	local clone2 = shockwave.InnerWind:Clone()
	local clone3 = shockwave.OuterWind:Clone()
	clone2.Size = createVector(6, 1.2, 6) * p * 0.8
	clone2.CFrame = CFrame.new(position + createVector(0, 1, 0) * clone2.Size.Y * 0.45)
	clone3.Size = createVector(10, 3.5, 10) * p * 0.8
	clone3.CFrame = CFrame.new(position)
	clone2.Parent = model
	clone3.Parent = model
	Util.CameraShaker:ShakeOnce(20, 25, 0.3, 0.8)

	if instance then
		for _, child in pairs(model:GetChildren()) do
			Util.SetParentOverrideWithColor(child, model, instance.Parent, instance.Name)
		end
	end

	promise.try(function()
		awaitHeartbeatLoopFor(0.5, function(p2)
			local transparency = p2 / 0.5
			clone2.CFrame *= CFrame.Angles(0, -0.1, 0)
			clone2.Size = createVector(6, 1.2, 6) * p * (0.8 + 1.2 * transparency)
			clone2.CFrame = clone2.CFrame - clone2.CFrame.Position + position + createVector(0, 1, 0) * clone2.Size.Y * 0.45
			clone2.Transparency = transparency
			clone.Size = createVector(7.5, 0.7, 7.5) * p * (0.8 + 1.2 * transparency)
			clone.CFrame = clone.CFrame - clone.CFrame.Position + position + createVector(0, 1, 0) * clone.Size.Y * 0.4
			clone.Transparency = transparency
		end)
		clone2.Transparency = 1
		clone.Transparency = 1
	end)
	awaitHeartbeatLoopFor(0.7, function(p2)
		local transparency = p2 / 0.7
		clone3.CFrame *= CFrame.Angles(0, -0.1, 0)
		clone3.Size = createVector(10, 3.5, 10) * p * (0.8 + 1.2 * transparency)
		clone3.Transparency = transparency
	end)
	clone3.Transparency = 1
	model:Destroy()
end

return buddhaShockwave