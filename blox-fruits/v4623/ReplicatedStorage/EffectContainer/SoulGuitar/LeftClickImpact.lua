local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local guitarM1Impact = FX:WaitForChild("SoulGuitarEffects").GuitarM1Impact
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
local PlaySchemes = require(interpolationScheme:WaitForChild("PlaySchemes"))
local ColorSeqMap = require(interpolationScheme.Parent.SequenceMaps.ColorSeqMap)

local function RandomVectorOffsetBetween(p, p2, p3)
	return (CFrame.lookAt(Vector3.new(), p) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p3), (math.cos(p2))))),
		0,
		0
	)).LookVector
end

local function ScaleParticle(descendant, p)
	local keypoints = descendant.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	descendant.Size = NumberSequence.new(numberSequenceKeypoints)
	descendant.Speed = NumberRange.new(descendant.Speed.Min * p, descendant.Speed.Max * p)
	descendant.Acceleration *= p
end

local function scalePart(folder, modelScale)
	local modelScale2 = folder:GetAttribute("ModelScale")
	local v = modelScale2 == nil and 1 or modelScale2
	local position = folder.Position
	local v2 = modelScale / v

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local position2 = descendant.Position
			local v3 = descendant.CFrame - position2
			local v4 = position2 - position
			descendant.Size *= Vector3.new(v2, v2, v2)
			descendant.CFrame = v3 + position + v4 * v2
		elseif descendant:IsA("Attachment") then
			local worldPosition = descendant.WorldPosition
			local v3 = descendant.WorldCFrame - worldPosition
			local v4 = worldPosition - position
			descendant.WorldCFrame = v3 + position + v4 * v2
		elseif descendant.ClassName == "Beam" then
			descendant.Width0 *= v2
			descendant.Width1 *= v2
		elseif descendant.ClassName == "ParticleEmitter" then
			ScaleParticle(descendant, v2)
		end
	end

	folder:SetAttribute("ModelScale", modelScale)
end

return function(p)
	local _ = p.player
	local hitPos = p.hitPos

	if (hitPos - Workspace.CurrentCamera.CFrame.Position).Magnitude > 700 then
		return
	end

	local clone = guitarM1Impact:Clone()
	clone:SetPrimaryPartCFrame(CFrame.new(hitPos))
	clone.Parent = _WorldOrigin
	PlaySchemes(clone:GetDescendants())
	destroyAfter(clone, 5)

	if (hitPos - Workspace.CurrentCamera.CFrame.Position).Magnitude < 60 then
		Util.CameraShaker:ShakeOnce(22, 22, 0.1, 0.8)
	end

	local children = clone.Notes:GetChildren()
	local v = {}

	for i = 1, #children do
		children[i].Size *= 2.5
		v[i] = math.random()
	end

	local pointLight = clone.MainPart.PointLight
	local v2 = ColorSeqMap.new(ColorSequence.new(Color3.fromRGB(182, 148, 255), Color3.fromRGB(10, 2, 255)))
	heartbeatLoopFor2(0.4, function(_, _, p2)
		pointLight.Brightness = 100 - p2 * 100
		pointLight.Range = 80 - p2 * 80
	end, function()
		for _, child in ipairs(clone.Electricity:GetChildren()) do
			if child.ClassName == "ParticleEmitter" then
				child.Enabled = false
			end
		end
	end)
	heartbeatLoopFor2(1.23, function(_, _, transparency)
		if clone.Parent == nil then
			return
		end

		pointLight.Color = v2:GetValue(transparency)
		clone.ExpandingPart2.CentralAttachment.FaintLight.Color = ColorSequence.new(v2:GetValue(transparency))

		for i, v3 in ipairs(children) do
			v3.CFrame += (v3.Position - clone.Electricity.Position).Unit * 1
			v3.CFrame = CFrame.Angles(1.5707963267948966, 0, 6.283185307179586 * v[i] + 36 * transparency ^ 0.27) + v3.Position
			v3.Transparency = transparency
		end

		scalePart(clone.Electricity, 12 - 11 * transparency)
	end, function()
		for _, v3 in ipairs(children) do
			v3.Transparency = 1
		end
	end)
end