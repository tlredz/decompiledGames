local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local trailPart = script.TrailPart
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor

local function ScaleParticleRelative(instance, currentScale: number)
	local currentScale2 = instance:GetAttribute("CurrentScale")
	local v = currentScale / (currentScale2 == nil and 1 or currentScale2)
	local keypoints = instance.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * v,
			keypoint.Envelope * v
		)
	end

	instance.Size = NumberSequence.new(numberSequenceKeypoints)
	instance.Speed = NumberRange.new(instance.Speed.Min * v, instance.Speed.Max * v)
	instance.Acceleration *= v
	instance:SetAttribute("CurrentScale", currentScale)
end

return function(p)
	local hrp = p.hrp
	local holding = p.holding

	if hrp == nil or hrp.Parent == nil or holding == nil then
		return
	end

	local clone = trailPart.Attachment:Clone()
	clone.Parent = hrp

	for _, emitter in ipairs(clone:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(2)
		end
	end

	local clone2 = trailPart.Attachment1:Clone()
	local clone3 = trailPart.Attachment2:Clone()
	clone2.Parent = hrp
	clone3.Parent = hrp

	for _, child in ipairs(clone2:GetChildren()) do
		child.Attachment0 = clone2
		child.Attachment1 = clone3
	end

	local clone4 = script.SpiralingTrail:Clone()
	clone4.CFrame = clone.WorldCFrame * CFrame.Angles(0, 0, 0) * CFrame.new(11, 0, 0)
	clone4.Parent = _WorldOrigin
	sound:Play("TrailLightInit", hrp)
	local v = sound:Play("TrailLightLoop", hrp)
	local v2 = time()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if holding.Value == false or holding:IsDescendantOf(Workspace) == false then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
			sound:FadeOut(v, 0.5)
			local position = hrp.Position

			for _, child in ipairs(clone:GetChildren()) do
				child.Enabled = false
			end

			for _, child in ipairs(clone4.A0:GetChildren()) do
				child.Enabled = false
			end

			heartbeatLoopFor2(1.2, function()
				local v3 = clone2
				local v4 = clone3
				clone.WorldPosition = position
				v3.WorldPosition = position
				v4.WorldPosition = position
			end, function()
				clone:Destroy()
				clone2:Destroy()
				clone3:Destroy()
				clone4:Destroy()
			end)
		else
			local v3 = time() - v2
			local unit = hrp.Velocity.Magnitude > 0.01 and hrp.Velocity.Unit or clone.WorldCFrame.LookVector
			clone4.CFrame = (CFrame.new(Vector3.new(), unit) + clone.WorldPosition) * CFrame.Angles(0, 0, v3 * 20) * CFrame.new(
				11,
				0,
				0
			)
		end
	end)
end