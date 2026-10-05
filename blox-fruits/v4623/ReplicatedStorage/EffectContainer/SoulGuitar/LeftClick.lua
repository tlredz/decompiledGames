local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local guitarM1 = FX:WaitForChild("SoulGuitarEffects").GuitarM1
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

local function ScaleParticle(part, p)
	local keypoints = part.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	part.Size = NumberSequence.new(numberSequenceKeypoints)
	part.Speed = NumberRange.new(part.Speed.Min * p, part.Speed.Max * p)
	part.Acceleration *= p
end

local function scalePart(folder, modelScale)
	local modelScale2 = folder:GetAttribute("ModelScale")
	local v = modelScale2 == nil and 1 or modelScale2
	local position = folder.Position
	local v2 = modelScale / v

	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			local position2 = part.Position
			local v3 = part.CFrame - position2
			local v4 = position2 - position
			part.Size *= Vector3.new(v2, v2, v2)
			part.CFrame = v3 + position + v4 * v2
		elseif part.ClassName == "ParticleEmitter" then
			ScaleParticle(part, v2)
		end
	end

	folder:SetAttribute("ModelScale", modelScale)
end

return function(p)
	local _ = p.player
	local projectilePart = p.projectilePart
	local position = projectilePart.Position
	local lookVector = projectilePart.CFrame.LookVector

	if (position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local clone = guitarM1:Clone()
	clone:SetPrimaryPartCFrame(CFrame.lookAt(Vector3.new(), lookVector) + position)
	clone.Parent = _WorldOrigin
	PlaySchemes(clone:GetDescendants())
	destroyAfter(clone, 10)
	local children = clone.Notes:GetChildren()
	local v = {}

	for i = 1, #children do
		v[i] = math.random()
	end

	local forcefield = clone.Forcefield
	local v2 = 0.14
	local connection = nil
	connection = heartbeatLoopFor2(10, function(p2)
		if projectilePart == nil or projectilePart.Parent == nil then
			connection:Disconnect()
			connection = nil
		else
			for i, v3 in ipairs(children) do
				v3.CFrame = v3.CFrame.Rotation * CFrame.Angles(0, 0, math.sin(p2 + v[i] * 8) ^ 12 * 0.2 + 0.01) + CFrame.fromAxisAngle(
					forcefield.CFrame.LookVector,
					v[i] * v2
				) * (v3.Position - forcefield.Position) + forcefield.Position
			end
		end
	end)
	local pointLight = clone.MainPart.PointLight
	local v3 = ColorSeqMap.new(ColorSequence.new(Color3.fromRGB(182, 148, 255), Color3.fromRGB(10, 2, 255)))
	local faintLight = clone.ExpandingPart2.CentralAttachment.FaintLight
	local electricity = clone.Electricity
	heartbeatLoopFor2(0.135, function(_, _, p2)
		pointLight.Brightness = p2 * 10
	end, function()
		heartbeatLoopFor2(0.215, function(_, _, p2)
			pointLight.Brightness = 50 - p2 * 50
			pointLight.Color = v3:GetValue(p2)
			faintLight.Color = ColorSequence.new(v3:GetValue(p2))

			for _, v4 in ipairs(children) do
				v4.CFrame += (v4.Position - forcefield.Position).Unit * (0.5 - p2) * 3
			end

			scalePart(electricity, 6 - 5 * p2)
		end, function()
			pointLight:Destroy()
		end)
	end)
	local firedChangedConnection = nil
	firedChangedConnection = projectilePart:GetAttributeChangedSignal("Fired"):Connect(function()
		if projectilePart:GetAttribute("Fired") == false then
			return
		end

		firedChangedConnection:Disconnect()
		firedChangedConnection = nil
		v2 = 0.88

		for i, v4 in ipairs(children) do
			v4.Trail.Enabled = true
			v4.Trail.Lifetime = 0.2 + 0.3 * (1 - v[i])
		end

		local heartbeatConnection = nil
		time()
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if projectilePart == nil or projectilePart.Parent == nil then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil

				for _, descendant in pairs(clone:GetDescendants()) do
					if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
						descendant:Destroy()
					elseif descendant:IsA("Trail") then
						descendant.Enabled = false
					elseif descendant:IsA("BasePart") then
						descendant.Transparency = 1
					end
				end

				task.delay(2, function()
					clone:Destroy()
				end)
			elseif clone and clone.PrimaryPart then
				clone:SetPrimaryPartCFrame(CFrame.lookAt(Vector3.new(), lookVector) + projectilePart.Position)
			end
		end)
	end)
end