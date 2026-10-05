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
local _ = FX:WaitForChild("SoulGuitarEffects").SkullX
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
local lightningBolt2 = Util.LightningBolt2
local _ = Util.AttachmentPair

if lightningBolt2.VERSION == nil or lightningBolt2.VERSION < 1.1 then
	error("LightningBolt: This module needs to be updated with the latest code provided in the framework2 team create place")
end

local PulsingBeam = require(script.Parent:WaitForChild("Modules"):WaitForChild("PulsingBeam"))
local Spikes = require(script.Parent:WaitForChild("Modules"):WaitForChild("Spikes"))
local WindWave = require(script.Parent:WaitForChild("Modules"):WaitForChild("WindWave"))

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

return function(data)
	local player = data.player
	local origin = data.origin
	local lastsFor = data.lastsFor

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1250 then
		return
	end

	if player == game.Players.LocalPlayer or (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude < 120 then
		Util.CameraShaker:ShakeOnce(25, 25, 0.05, 1.2)
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "GuitarXColorInvert"
		colorCorrectionEffect.Contrast = -7
		colorCorrectionEffect.Parent = Lighting
		local bloomEffect = Instance.new("BloomEffect")
		bloomEffect.Name = "GuitarXBloom"
		bloomEffect.Intensity = 2
		bloomEffect.Threshold = 0.6
		bloomEffect.Size = 48
		bloomEffect.Parent = Lighting
		task.delay(0.1, function()
			colorCorrectionEffect.Contrast = 0
			task.wait(0.1)
			Util.CameraShaker:ShakeOnce(40, 40, 0.05, 1.2)
			colorCorrectionEffect.Contrast = -7
			task.wait(0.1)
			colorCorrectionEffect.Contrast = 0
			colorCorrectionEffect:Destroy()
			heartbeatLoopFor2(0.5, function(_, _, p)
				bloomEffect.Intensity = 2 - p
				bloomEffect.Threshold = 0.6 + 1.4 * p
				bloomEffect.Size = 48 - 24 * p
			end, function()
				bloomEffect:Destroy()
			end)
		end)
	end

	task.spawn(Spikes, origin, lastsFor, player)
	task.spawn(PulsingBeam, origin, lastsFor, player)
	task.spawn(WindWave, origin, 45, 145)
	local part = Instance.new("Part")
	part.CFrame = CFrame.new(origin + createVector(0, 10, 0))
	part.Anchored = true
	part.Transparency = 1
	part.CastShadow = false
	part.Locked = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	local clone = FX:WaitForChild("SoulGuitarEffects").BeamSound:Clone()
	clone.Parent = part
	Util.UtilSoundWrapper.Play(clone)
	part.Parent = _WorldOrigin
	local clone2 = FX:WaitForChild("SoulGuitarEffects").BeamSound:Clone()
	clone2.Parent = part
	task.delay(0.15, function()
		Util.UtilSoundWrapper.Play(clone2)
	end)
	task.delay(lastsFor + 5, function()
		part:Destroy()
	end)
end