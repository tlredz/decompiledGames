local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
local currentCamera = Workspace.CurrentCamera
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local loveArrow = FX:WaitForChild("LoveEffects").LoveArrow
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Effect"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor

local function trailEffect(cFrame, value, value2)
	local v = value or 1
	local v2 = value2 or 1

	if (currentCamera.CFrame.p - cFrame.p).Magnitude > 1000 then
		return
	end

	Util.TweenModel(loveArrow.Parent.Wind, {
		Color = Color3.fromRGB(255, 133, 153),
		CFrame = cFrame * CFrame.new(0, 0, -8) * CFrame.Angles(1.5707963267948966, 0, 0),
		Size = createVector(0.25, 0, 0.25),
		Scale = 1.5 * v2
	}, {
		Tween = TweenInfo.new(0.75 * v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		Transparency = 1,
		Size = createVector(1, 2, 1),
		Scale = 2.5 * v2,
		CFrame = CFrame.new(0, 10, 0)
	})
	Util.TweenModel(loveArrow.Parent.Shockwave, {
		Color = Color3.fromRGB(255, 133, 153),
		CFrame = cFrame * CFrame.new(0, 0, -5) * CFrame.Angles(1.5707963267948966, 0, 0),
		Size = createVector(0.25, 1, 0.25),
		Scale = 1 * v2
	}, {
		Tween = TweenInfo.new(0.25 * v, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		Color = Color3.new(1, 1, 1),
		Transparency = 1,
		Size = createVector(0.75, 5, 0.75),
		Scale = 2 * v2,
		CFrame = CFrame.new(0, 15, 0)
	})
	Util.TweenModel(loveArrow.Parent.WindSwirl, {
		Color = Color3.fromRGB(255, 133, 153),
		CFrame = cFrame * CFrame.new(0, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0),
		Size = createVector(1.25, 0, 1.25),
		Scale = 1.5 * v2
	}, {
		Tween = TweenInfo.new(0.5 * v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		Transparency = 1,
		Size = createVector(0, 5, 0),
		Scale = 2.5 * v2,
		CFrame = CFrame.new(0, 15, 0) * CFrame.Angles(0, 1.57, 0)
	})
end

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
	local v = 0
	local connection = nil
	connection = heartbeatLoopFor2(fliesFor, function(_, _, p)
		local now = tick()

		if part:GetAttribute("ProjectileActive") == true then
			part.CFrame = CFrame.lookAt(fn(p), fn(p + 0.01))

			if now - v > 0.04 then
				trailEffect(part.CFrame, 0.75, 1.5)
				v = now
			end
		else
			connection:Disconnect()
			connection = nil
		end
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

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function lerp(p, p2, p3)
	return p2 * p3 + p * (1 - p3)
end

local function cubicBezier(p, origin, p2, p3, targetPos)
	local v = lerp(origin, p2, p)
	local v2 = lerp(p2, p3, p)
	local v3 = lerp(p3, targetPos, p)
	local v4 = lerp(v, v2, p)
	return lerp(v4, lerp(v2, v3, p), p)
end

return function(data)
	local fXContainer = data.FXContainer
	local origin = data.origin
	local targetPos = data.targetPos
	local fliesFor = data.fliesFor
	local projectileRadius = data.projectileRadius
	local _ = data.projectileSpeed

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1100 then
		return
	end

	local random = Random.new()
	local v = targetPos - origin
	local unit = v.Unit
	local cframe = CFrame.new(createVector(0, 0, 0), unit)
	local lerped = origin:Lerp(targetPos, random:NextNumber(0.25, 0.5))
	local v2 = cframe * Vector3.new(
		random:NextNumber(-v.Magnitude / 2, v.Magnitude / 2),
		random:NextNumber(-v.Magnitude / 4, v.Magnitude / 4),
		random:NextNumber(-v.Magnitude / 8, v.Magnitude / 8)
	) + lerped
	local _, v3 = Util.RayMap(lerped, v2 - lerped)
	local lerped2 = origin:Lerp(targetPos, random:NextNumber(0.5, 0.75))
	local v5 = cframe * Vector3.new(
		random:NextNumber(-v.Magnitude / 4, v.Magnitude / 4),
		random:NextNumber(-v.Magnitude / 4, v.Magnitude / 4),
		random:NextNumber(-v.Magnitude / 8, v.Magnitude / 8)
	) + lerped2
	local _, v6 = Util.RayMap(lerped2, v5 - lerped2)

	local function fn(p)
		return (cubicBezier(p, origin, v3, v6, targetPos))
	end

	local fn2 = v.Magnitude < 270 and function(p)
		local v8 = (targetPos - origin) * createVector(1, 0, 1)
		local v9 = (targetPos - origin) * createVector(0, 1, 0)
		return origin + v8 * p * 1.1 + v9 * p ^ 2 * 1.1
	end or fn
	local clone = loveArrow:Clone()
	fireClientProjectile(origin, targetPos, fliesFor, projectileRadius, fXContainer, fn2, clone)
	Util.Sound:Play("LoveV2ZLaunch2", clone)
end