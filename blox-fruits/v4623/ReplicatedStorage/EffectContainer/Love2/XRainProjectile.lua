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
local loveRainArrow = FX:WaitForChild("LoveEffects").LoveRainArrow
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
	task.delay(0.016666666666666666, function()
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
	end)
	return part, connection
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function cubicHermite(p, origin, p2, p3, p4)
	return (2 * p ^ 3 - 3 * p ^ 2 + 1) * origin + (p ^ 3 - 2 * p ^ 2 + p) * p2 + (-2 * p ^ 3 + 3 * p ^ 2) * p3 + (p ^ 3 - p ^ 2) * p4
end

return function(data)
	local fXContainer = data.FXContainer
	local origin = data.origin
	local targetPos = data.targetPos
	local fliesFor = data.fliesFor
	local projectileRadius = data.projectileRadius
	local closestRootPos = data.closestRootPos
	local closestVictimDist = data.closestVictimDist
	local projectileSpeed = data.projectileSpeed

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1500 then
		return
	end

	local unit = (targetPos - origin).Unit
	random:NextNumber(0, 6.283185307179586)
	local fn

	if closestRootPos == nil then
		fn = function(p)
			return origin + (targetPos - origin) * p * 1.1
		end
	else
		local v = closestVictimDist / projectileSpeed
		local v2 = origin + unit * closestVictimDist
		local v3 = unit * projectileSpeed
		local v4 = closestRootPos - createVector(0, 1, 0)
		local v5 = closestRootPos - (origin + (v2 - origin) * 0.75)

		fn = function(p)
			local v6 = p * fliesFor

			if not (v6 < v) then
				return v4 + v5 * (v6 - v)
			end

			return cubicHermite(v6 / v, origin, v3, v4, v5)
		end
	end

	local clone = loveRainArrow:Clone()
	local clone2 = script.Parent.V.SummonHeart.EmitOnPulse:Clone()

	for _, child in pairs(clone2:GetChildren()) do
		if child.Name == "ShockwaveStart2" then
			child:Destroy()
		else
			child.Lifetime = NumberRange.new(child.Lifetime.Min * 0.4, child.Lifetime.Max * 0.4)
			child.Rate = 25
			child.Enabled = true
		end
	end

	clone2.Parent = clone
	fireClientProjectile(origin, targetPos, fliesFor, projectileRadius, fXContainer, fn, clone)
	local play = Util.Sound:Play("LoveV2XRainLaunch", clone)
	play.PlaybackSpeed = random:NextNumber(1, 1.3)
end