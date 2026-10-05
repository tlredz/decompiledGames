local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local shiny = FX:WaitForChild("LightEffects").V.Shiny
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local awaitHeartbeatLoopFor = heartbeatLoopFor.AwaitHeartbeatLoopFor

local function ScaleParticleRelative(child, currentScale: number)
	local currentScale2 = child:GetAttribute("CurrentScale")
	local v = currentScale / (currentScale2 == nil and 1 or currentScale2)
	local keypoints = child.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * v,
			keypoint.Envelope * v
		)
	end

	child.Size = NumberSequence.new(numberSequenceKeypoints)
	child.Speed = NumberRange.new(child.Speed.Min * v, child.Speed.Max * v)
	child.Acceleration *= v
	child:SetAttribute("CurrentScale", currentScale)
end

return function(p)
	local hrp = p.hrp
	local impactPos = p.impactPos

	if (impactPos - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	if hrp ~= nil and hrp.Parent ~= nil then
		local attachment = Instance.new("Attachment")
		attachment.Position = createVector(0, -3.5, 0)
		attachment.Parent = hrp
		destroyAfter(attachment, 2)
		local clone = shiny.Parent.LightCircles:Clone()
		clone.Parent = attachment
		task.delay(clone:GetAttribute("DisableAfter"), function()
			clone.Enabled = false
		end)
	end

	task.wait(0.1)
	local clone = shiny:Clone()
	clone.CFrame = CFrame.new(impactPos)
	clone.Parent = _WorldOrigin
	destroyAfter(clone, 5)
	Util.Sound:Play("LightWindUp", impactPos, 120, 2, 0.75)

	for _, child in ipairs(clone.EmitThese:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end

	for _, child in ipairs(clone.Attachment:GetChildren()) do
		child:Emit(1)
	end

	local beams = clone.Beams
	awaitHeartbeatLoopFor(0.13999999999999999, function(_, _, p2)
		beams.Beam1.Brightness = 10 * p2
		beams.Beam2.Brightness = 10 * p2
	end, function()
		beams.Beam1.Brightness = 10
		beams.Beam2.Brightness = 10
	end)

	for _, child in ipairs(clone.Attachment:GetChildren()) do
		child.Enabled = false
	end

	awaitHeartbeatLoopFor(0.13999999999999999, function(_, _, p2)
		beams.Beam1.Brightness = 10 * (1 - p2)
		beams.Beam2.Brightness = 10 * (1 - p2)
	end, function()
		beams.Beam1.Brightness = 0
		beams.Beam2.Brightness = 0
	end)
	heartbeatLoopFor2(0.105, function(_, _, p2)
		for _, child in ipairs(clone.EmitThese:GetChildren()) do
			ScaleParticleRelative(child, 1 - p2)
		end

		for _, child in ipairs(clone.Attachment:GetChildren()) do
			ScaleParticleRelative(child, 1 - p2)
		end
	end, function()
		for _, child in ipairs(clone.FinalEmit:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end
	end)
end