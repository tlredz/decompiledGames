local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
Vector3.new()
local inverse = CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local phoenixZ = FX:WaitForChild("PhoenixEffects").PhoenixZ
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
local PlaySchemes = require(interpolationScheme:WaitForChild("PlaySchemes"))

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

local function ScaleZ(p, folder)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant:SetAttribute("SpeedInitial", descendant:GetAttribute("SpeedInitial") * p)
			descendant:SetAttribute("SpeedGoal", descendant:GetAttribute("SpeedGoal") * p)
			descendant:SetAttribute("SizeFrom", descendant:GetAttribute("SizeFrom") * p)
			descendant.Size *= p
		elseif descendant:IsA("ParticleEmitter") then
			ScaleParticle(descendant, p)
		elseif descendant.ClassName == "Attachment" then
			descendant.Position *= p
		end
	end
end

return function(data)
	local player = data.player
	local char = data.char
	local origin = data.origin
	local fireDir = data.fireDir
	local explosionPos = data.explosionPos
	local explosionDelay = data.explosionDelay

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1200 then
		return
	end

	local clone = phoenixZ:Clone()
	ScaleZ(1.5, clone)
	clone:SetPrimaryPartCFrame(CFrame.lookAt(Vector3.new(), fireDir) * inverse + origin + createVector(0, 5, 0))
	clone.FireExplosion:SetPrimaryPartCFrame(CFrame.Angles(0, random:NextNumber(0, 6.283185307179586), 0) + explosionPos + createVector(
		0,
		5,
		0
	))
	clone.Parent = _WorldOrigin
	local playSchemes = PlaySchemes(clone.Beam:GetDescendants())
	destroyAfter(clone.Beam, playSchemes + 1)
	task.wait(explosionDelay)
	destroyAfter(clone, PlaySchemes(clone.FireExplosion:GetDescendants()) + 1)

	if (explosionPos - Workspace.CurrentCamera.CFrame.Position).Magnitude < 140 then
		Util.CameraShaker:ShakeOnce(25, 25, 0.1, 0.8)
	end

	local phoenixBF = localPlayer ~= player and char:FindFirstChild("PhoenixBF")

	if phoenixBF then
		local playingAnimationTracks = phoenixBF.PhoenixBF.AnimationController.Animator:GetPlayingAnimationTracks()

		for i = 2, #playingAnimationTracks do
			playingAnimationTracks[i]:Stop()
		end
	end
end