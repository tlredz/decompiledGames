local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local heartShotProjectile = FX:WaitForChild("LoveEffects").HeartShotProjectile
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor

local function fireClientProjectile(origin, _, fliesFor, projectileRadius, fXContainer, fn, part)
	if part == nil then
		part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Shape = Enum.PartType.Ball
		part.Size = Vector3.new(projectileRadius, projectileRadius, projectileRadius) * 2
		part.Transparency = 1
	end

	part.Name = "Projectile"
	part:SetAttribute("ProjectileActive", true)
	part.CFrame = CFrame.new(origin)
	part.Parent = fXContainer
	destroyAfter(part, fliesFor + 2)
	local connection = nil
	connection = heartbeatLoopFor2(fliesFor, function(_, _, p)
		if part:GetAttribute("ProjectileActive") == true then
			part.CFrame = CFrame.lookAt(fn(p), fn(p + 0.01))
			return
		end

		connection:Disconnect()
		connection = nil
	end, function()
		part.CFrame = CFrame.lookAt(fn(1), fn(1.01))

		for _, effect in ipairs(part:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
				effect.Enabled = false
			end
		end

		part.Transparency = 1
	end)
	return part, connection
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
end

local function ScaleAttachmentsAndEmittersWithin(folder, p: number)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("Attachment") then
			descendant.Position *= p
		elseif descendant:IsA("ParticleEmitter") then
			ScaleParticle(descendant, p)
		end
	end
end

return function(data)
	local fXContainer = data.FXContainer
	local origin = data.origin
	local targetPos = data.targetPos
	local fliesFor = data.fliesFor
	local projectileRadius = data.projectileRadius
	local _ = data.projectileSpeed

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local _ = (targetPos - origin).Unit
	local clone = heartShotProjectile:Clone()
	clone.FX.BehindSpecs.Speed = NumberRange.new(140)
	clone.FX.MaybeSpecs.SpreadAngle = Vector2.new(-360, 360)
	ScaleAttachmentsAndEmittersWithin(clone, projectileRadius / 4)
	fireClientProjectile(origin, targetPos, fliesFor, projectileRadius, fXContainer, function(p)
		return origin + (targetPos - origin) * p * 1.1
	end, clone)

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude < 160 then
		local bloomEffect = Instance.new("BloomEffect")
		bloomEffect.Name = "PortalWaveBloom"
		bloomEffect.Intensity = 2
		bloomEffect.Threshold = 1
		bloomEffect.Size = 48
		bloomEffect.Parent = Lighting
		heartbeatLoopFor2(0.2, function(_, _, p)
			bloomEffect.Intensity = 2 - p
			bloomEffect.Threshold = 1 + p
			bloomEffect.Size = 48 - 24 * p
		end, function()
			bloomEffect:Destroy()
		end)
		Util.CameraShaker:ShakeOnce(6, 10, 0.01, 0.35)
	end

	local play = Util.Sound:Play("LoveV2ZLaunch", clone)
	play.PlaybackSpeed = 1 - 0.3 * data.chargedInterp
end