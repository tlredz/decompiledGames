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
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local xSpiral = FX:WaitForChild("LeopardEffects").XSpiral
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local awaitHeartbeatLoopFor = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
local NumSeqMap = require(interpolationScheme.Parent:WaitForChild("SequenceMaps"):WaitForChild("NumSeqMap"))

local function ScaleParticle(state, p)
	local keypoints = state.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	state.Size = NumberSequence.new(numberSequenceKeypoints)
	state.Speed = NumberRange.new(state.Speed.Min * p, state.Speed.Max * p)
	state.Acceleration *= p
end

local function ScaleAttachmentsAndEmittersWithin(folder, projectileSizeMult: number)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("Attachment") then
			descendant.Position *= projectileSizeMult
		elseif descendant:IsA("ParticleEmitter") then
			ScaleParticle(descendant, projectileSizeMult)
		end
	end
end

local function insertSoundInto(p, p2, p3)
	local clone = xSpiral[p2]:Clone()

	if p3 then
		clone:SetAttribute("PlaybackSpeed", clone:GetAttribute("PlaybackSpeed") * 0.9)
	end

	return (Util.UtilSoundWrapper.Play(clone, p))
end

local WindBall = require(script.Parent:WaitForChild("Modules").WindBall)
return function(data)
	local origin = data.origin
	local projectilePart = data.projectilePart
	local _ = data.rotPerFrame
	local fliesFor = data.fliesFor
	local projectileSizeMult = data.projectileSizeMult
	local transformedRig = data.transformedRig

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1100 or (projectilePart == nil or projectilePart.Parent == nil) then
		return
	end

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude < 110 then
		Util.CameraShaker:ShakeOnce(14, 14, 0.01, 0.25)
		local bloomEffect = Instance.new("BloomEffect")
		bloomEffect.Name = "LeopardZBloom"
		bloomEffect.Intensity = 4
		bloomEffect.Threshold = 0.4
		bloomEffect.Size = 64
		bloomEffect.Parent = Lighting
		heartbeatLoopFor2(0.2, function(_, _, p)
			bloomEffect.Intensity = 4 - 4 * p
			bloomEffect.Threshold = 0.4 + 0.6 * p
			bloomEffect.Size = 64 - 64 * p
		end, function()
			bloomEffect:Destroy()
		end)
	end

	local clone = xSpiral:Clone()
	ScaleAttachmentsAndEmittersWithin(clone, projectileSizeMult)
	clone.CFrame = projectilePart.CFrame
	clone.Parent = _WorldOrigin
	destroyAfter(clone, fliesFor + 4)
	local clone2 = xSpiral.XKick:Clone()

	if transformedRig then
		clone2:SetAttribute("PlaybackSpeed", clone2:GetAttribute("PlaybackSpeed") * 0.9)
	end

	Util.UtilSoundWrapper.Play(clone2, clone)
	local clone3 = xSpiral.XSpinLoop:Clone()

	if transformedRig then
		clone3:SetAttribute("PlaybackSpeed", clone3:GetAttribute("PlaybackSpeed") * 0.9)
	end

	local v = Util.UtilSoundWrapper.Play(clone3, clone)
	heartbeatLoopFor2(fliesFor, function()
		clone.CFrame += -clone.CFrame.Position + projectilePart.CFrame.Position + createVector(0, 6, 0)
	end, function()
		for _, effect in ipairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end
	end)
	local emitters = {}

	for _, emitter in ipairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			table.insert(emitters, emitter)
		end
	end

	local v2 = NumSeqMap.new(script.SizeGraph:GetAttribute("Sequence"), 60)
	local v3 = 1
	local v4 = false
	awaitHeartbeatLoopFor(fliesFor, function(_, _, p)
		local v5 = v2:GetValue(p) * 3.5
		local v6 = v5 / v3

		for _, v7 in ipairs(emitters) do
			ScaleParticle(v7, v6)
		end

		if v6 > 1.1 and v4 == false then
			local clone4 = xSpiral.XCharge:Clone()

			if transformedRig then
				clone4:SetAttribute("PlaybackSpeed", clone4:GetAttribute("PlaybackSpeed") * 0.9)
			end

			Util.UtilSoundWrapper.Play(clone4, clone)
			v4 = true
		end

		v3 = v5
	end, function()
		local v5 = v2:GetValue(1) * 3.5 / v3

		for _, v6 in ipairs(emitters) do
			ScaleParticle(v6, v5)
		end
	end)
	v:Stop()
	local clone4 = xSpiral.XTornado:Clone()

	if transformedRig then
		clone4:SetAttribute("PlaybackSpeed", clone4:GetAttribute("PlaybackSpeed") * 0.9)
	end

	Util.UtilSoundWrapper.Play(clone4, clone)
	local attachment = Instance.new("Attachment")
	attachment.Parent = clone

	for _, child in ipairs(script.AttachmentEmitters:GetChildren()) do
		local clone5 = child:Clone()
		clone5.Parent = attachment
		clone5:Emit(clone5:GetAttribute("EmitCount"))
	end

	local clone5 = FX:WaitForChild("LeopardEffects").WindBall:Clone()
	clone5.Size *= 0.7
	clone5.CFrame = CFrame.new(clone.Position)
	clone5.Parent = _WorldOrigin
	WindBall(
		clone5,
		FX:WaitForChild("LeopardEffects").WindBallFX,
		0.5,
		clone5.CFrame.Position,
		createVector(0, 360, 0),
		0
	)
end