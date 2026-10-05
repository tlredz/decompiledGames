local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local trailPart = FX:WaitForChild("LightEffects").F.TrailPart
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor

local function ScaleParticleRelative(descendant, currentScale: number)
	local currentScale2 = descendant:GetAttribute("CurrentScale")
	local v = currentScale / (currentScale2 == nil and 1 or currentScale2)
	local keypoints = descendant.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * v,
			keypoint.Envelope * v
		)
	end

	descendant.Size = NumberSequence.new(numberSequenceKeypoints)
	descendant.Speed = NumberRange.new(descendant.Speed.Min * v, descendant.Speed.Max * v)
	descendant.Acceleration *= v
	descendant:SetAttribute("CurrentScale", currentScale)
end

local clone = trailPart:Clone()

for _, descendant in pairs(clone:GetDescendants()) do
	if descendant:IsA("ParticleEmitter") then
		ScaleParticleRelative(descendant, 0.5)
	elseif descendant:IsA("Attachment") then
		descendant.Position *= 0.25
	end
end

return function(p)
	local hrp = p.hrp
	local holding = p.holding

	if hrp == nil or hrp.Parent == nil or holding == nil then
		return
	end

	local clone2 = clone.Attachment:Clone()
	clone2.Parent = hrp

	for _, child in ipairs(clone2:GetChildren()) do
		child:Emit(2)
	end

	local clone3 = clone.Attachment1:Clone()
	local clone4 = clone.Attachment2:Clone()
	clone3.Parent = hrp
	clone4.Parent = hrp

	for _, child in ipairs(clone3:GetChildren()) do
		child.Attachment0 = clone3
		child.Attachment1 = clone4
	end

	sound:Play("TrailLightInit", hrp)
	local v = sound:Play("TrailLightLoop", hrp)
	local v2 = time()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if holding.Value ~= false and holding:IsDescendantOf(Workspace) ~= false then
			local _ = time() - v2
			return
		end

		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
		sound:FadeOut(v, 0.5)
		local position = hrp.Position

		for _, child in ipairs(clone2:GetChildren()) do
			child.Enabled = false
		end

		heartbeatLoopFor2(1.2, function()
			local v3 = clone3
			local v4 = clone4
			clone2.WorldPosition = position
			v3.WorldPosition = position
			v4.WorldPosition = position
		end, function()
			clone2:Destroy()
			clone3:Destroy()
			clone4:Destroy()
		end)
	end)
end