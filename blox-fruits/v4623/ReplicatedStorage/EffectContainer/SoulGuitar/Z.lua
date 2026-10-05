local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
local inverse = CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local guitarZ = FX:WaitForChild("SoulGuitarEffects").GuitarZ
local zExplosion = FX:WaitForChild("SoulGuitarEffects").ZExplosion
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
local PlaySchemes = require(interpolationScheme:WaitForChild("PlaySchemes"))
require(interpolationScheme.Parent.SequenceMaps.ColorSeqMap)
local Shockwaves = require(script.Parent:WaitForChild("Modules"):WaitForChild("Shockwaves"))
local DoubleSwirlyBeam1 = require(script.Parent:WaitForChild("Modules"):WaitForChild("DoubleSwirlyBeam1"))

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

local function SpeedUpParticle(descendant, p)
	descendant.Drag *= p
	descendant.Speed = NumberRange.new(descendant.Speed.Min * p, descendant.Speed.Max * p)
	descendant.Lifetime = NumberRange.new(descendant.Lifetime.Min / p, descendant.Lifetime.Max / p)
	descendant.Rate *= p
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
		elseif descendant.ClassName == "ParticleEmitter" then
			ScaleParticle(descendant, v2)
		end
	end

	folder:SetAttribute("ModelScale", modelScale)
end

return function(data)
	local player = data.player
	local origin = data.origin
	local goalPos = data.goalPos
	local beamDissipateAfter = data.beamDissipateAfter
	local beamExtendsForTime = data.beamExtendsForTime
	local beamDiameter = data.beamDiameter

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1200 then
		return
	end

	local clone = guitarZ:Clone()
	clone:SetPrimaryPartCFrame(CFrame.lookAt(Vector3.new(), (goalPos - origin).Unit) * inverse + origin)
	clone.Parent = _WorldOrigin
	destroyAfter(clone, PlaySchemes(clone:GetDescendants()) + 2)

	if player == game.Players.LocalPlayer then
		Util.CameraShaker:ShakeOnce(32, 32, 0.05, 0.4)
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "GuitarZColorInvert"
		colorCorrectionEffect.Contrast = -7
		colorCorrectionEffect.Parent = Lighting
		task.delay(0.05, function()
			colorCorrectionEffect:Destroy()
		end)
	end

	local model = Instance.new("Model")
	model.Parent = _WorldOrigin
	model.Name = "SoulGuitarZ"
	destroyAfter(model, beamDissipateAfter + 2)
	local v2 = beamDiameter / 2.4
	task.spawn(
		DoubleSwirlyBeam1,
		origin,
		goalPos,
		Color3.fromRGB(93, 255, 134),
		Color3.fromRGB(65, 255, 55),
		v2,
		beamExtendsForTime,
		beamDissipateAfter,
		Color3.fromRGB(51, 220, 127),
		Color3.fromRGB(124, 165, 101),
		Color3.fromRGB(167, 220, 53),
		Color3.fromRGB(160, 255, 179)
	)
	task.wait(beamExtendsForTime)
	task.spawn(Shockwaves, goalPos, 4.5 * v2 / 2, 1.4, Color3.fromRGB(85, 255, 139), Color3.new(0.427451, 1, 0.32549))
	local clone2 = zExplosion.Waves:Clone()
	clone2.CFrame = CFrame.new() + goalPos
	scalePart(clone2, v2 / 2)
	clone2.Parent = model
	local clone3 = zExplosion.ExplosionSource:Clone()
	clone3.CFrame = CFrame.new(goalPos)
	scalePart(clone3, v2 / 2)
	clone3.Color = Color3.fromRGB(103, 255, 101)

	for _, descendant in ipairs(clone3:GetDescendants()) do
		if descendant.ClassName == "ParticleEmitter" then
			SpeedUpParticle(descendant, 2)
		end
	end

	clone3.Parent = model
	clone3.Attachment.Pulse:Emit(1)
	clone3.Attachment.Pulse2:Emit(1)
	clone2.Attachment.BlackWaves:Emit(1)
	heartbeatLoopFor2(0.4, function(_, _, transparency)
		clone3.CFrame *= CFrame.Angles(0.05, 0.05, 0.02)
		clone3.Transparency = transparency
	end, function()
		clone3.Transparency = 1
	end)
	task.wait(0.4)
	clone2.Attachment.BlackWaves.Enabled = false

	for _, child in ipairs(clone3.Attachment:GetChildren()) do
		child.Enabled = false
	end
end