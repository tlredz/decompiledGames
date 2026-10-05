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
local loveSkyHeart = FX:WaitForChild("LoveEffects").LoveSkyHeart
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local awaitHeartbeatLoopFor = heartbeatLoopFor.AwaitHeartbeatLoopFor

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

return function(data)
	local fXContainer = data.FXContainer
	local impactPos = data.impactPos
	local skyHeartLastsFor = data.skyHeartLastsFor
	local projectile = fXContainer:FindFirstChild("Projectile")

	if not projectile or (impactPos - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1500 then
		return
	end

	snapProjectileToImpactPos(projectile, impactPos)
	local clone = loveSkyHeart:Clone()
	clone:PivotTo(clone.PrimaryPart.CFrame.Rotation + impactPos)
	clone.Parent = _WorldOrigin
	destroyAfter(clone, skyHeartLastsFor + 3)
	local heartPart = clone.HeartPart
	local shockwave = heartPart.EmitOnPulse.Shockwave
	local children = heartPart.ResizeWithHeart:GetChildren()
	local v = 1

	local function scaleHeart(p)
		local v2 = p / v
		heartPart.Size *= v2

		for _, v4 in ipairs(children) do
			ScaleParticle(v4, v2)
		end

		if v < 1 and p > 1 then
			shockwave:Emit(1)
		end

		v = p
	end

	scaleHeart(0.01)
	local v2 = Util.Sound:Play("LoveV2XSkyHeartLoop", heartPart)

	for _, emitter in ipairs(heartPart:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") and emitter.Name ~= "Shockwave" then
			emitter.Enabled = true
		end
	end

	heartPart.Transparency = 0.1
	awaitHeartbeatLoopFor(skyHeartLastsFor, function(p)
		scaleHeart(math.sin(15 * p) ^ 2 * 1.25 + 0.5)
		heartPart.CFrame *= CFrame.Angles(0, 0.1, 0)
	end)

	for _, emitter in ipairs(heartPart:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	heartPart.Transparency = 1
	Util.Sound:FadeOut(v2, 0.5)
end