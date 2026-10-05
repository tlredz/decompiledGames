local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local shockwaves = FX:WaitForChild("PhoenixEffects").Shockwaves
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local awaitHeartbeatLoopFor = heartbeatLoopFor.AwaitHeartbeatLoopFor
Random.new()

local function Shockwaves(position, p, p2, color, color2)
	local _ = Workspace.CurrentCamera
	local model = Instance.new("Model")
	model.Parent = _WorldOrigin
	model.Name = "MeshShockwaves"
	destroyAfter(model, p2 + 1)
	local v = 0.42 * p2
	local v2 = 0.58 * p2
	local clone = shockwaves.Groundwave:Clone()
	clone.Size = createVector(7.5, 0.9, 7.5) * p
	clone.CFrame = CFrame.new(position + createVector(0, 1, 0) * clone.Size.Y * 0.4)
	clone.Color = color
	clone.Parent = model
	local clone2 = shockwaves.InnerWind:Clone()
	local clone3 = shockwaves.OuterWind:Clone()

	if color2 then
		clone2.Color = color2
		clone3.Color = color2
	end

	clone2.Size = createVector(6, 1.2, 6) * p * 0.8
	clone2.CFrame = CFrame.new(position + createVector(0, 1, 0) * clone2.Size.Y * 0.45)
	clone3.Size = createVector(10, 3.5, 10) * p * 0.8
	clone3.CFrame = CFrame.new(position)
	clone2.Parent = model
	clone3.Parent = model
	heartbeatLoopFor2(v, function(p3)
		local transparency = p3 / v
		clone2.CFrame *= CFrame.Angles(0, -0.1, 0)
		clone2.Size = createVector(6, 1.2, 6) * p * (0.8 + 1.2 * transparency)
		clone2.CFrame = clone2.CFrame - clone2.CFrame.Position + position + createVector(0, 1, 0) * clone2.Size.Y * 0.45
		clone2.Transparency = transparency
		clone.Size = createVector(7.5, 0.7, 7.5) * p * (0.8 + 1.2 * transparency)
		clone.CFrame = clone.CFrame - clone.CFrame.Position + position + createVector(0, 1, 0) * clone.Size.Y * 0.4
		clone.Transparency = transparency
	end, function()
		clone2.Transparency = 1
		clone.Transparency = 1
	end)
	awaitHeartbeatLoopFor(v2, function(p3)
		local transparency = p3 / v2
		clone3.CFrame *= CFrame.Angles(0, -0.1, 0)
		clone3.Size = createVector(10, 3.5, 10) * p * (0.8 + 1.2 * transparency)
		clone3.Transparency = transparency
	end)
	clone3.Transparency = 1
end

return Shockwaves