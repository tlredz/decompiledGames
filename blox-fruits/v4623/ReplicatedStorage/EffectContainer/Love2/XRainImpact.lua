local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local _ = FX:WaitForChild("LoveEffects").LoveSkyHeart
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor

local function snapProjectileToImpactPos(folder, impactPos)
	folder:SetAttribute("ProjectileActive", false)
	folder.CFrame = folder.CFrame.Rotation + impactPos

	for _, effect in ipairs(folder:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = false
		end
	end

	folder.Transparency = 1
end

local function ScaleParticle(p, p2)
	local keypoints = p.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p2,
			keypoint.Envelope * p2
		)
	end

	p.Size = NumberSequence.new(numberSequenceKeypoints)
end

local currentCamera = Workspace.CurrentCamera
return function(p)
	local fXContainer = p.FXContainer
	local impactPos = p.impactPos
	local projectile = fXContainer:FindFirstChild("Projectile")

	if not projectile or (impactPos - currentCamera.CFrame.Position).Magnitude > 600 then
		return
	end

	snapProjectileToImpactPos(projectile, impactPos)

	for _, effect in ipairs(projectile:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = false
		end
	end

	for _, child in ipairs(projectile.Impact:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end

	local play = Util.Sound:Play("LoveV2XRainImpactFast", impactPos)
	play.PlaybackSpeed = random:NextNumber(2.1, 2.5)
end