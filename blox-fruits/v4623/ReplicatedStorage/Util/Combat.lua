local createVector = vector.create
local Combat = {}
local RayMapCollidable = require(game.ReplicatedStorage.Util.RayMapCollidable)
local Misc = require(game.ReplicatedStorage.Util.Misc)

function Combat.SafeRay(p, total, ...)
	if total.Magnitude == 0 then
		warn("Fixing NaN SafeRay")
		total += createVector(0, 0.01, 0)
	end

	local v, v2, v3 = RayMapCollidable(p, total, ...)

	if v then
		return v, v2 - total.Unit * 0.01, v3
	end

	return nil, v2, v3
end

function Combat.SafeRayLine(p, total, ...)
	if p == total then
		warn("Fixing NaN SafeRayLine")
		total += createVector(0, 0.01, 0)
	end

	local v, v2, v3 = RayMapCollidable(p, total - p, ...)

	if v then
		return v, v2 - (total - p).Unit * 0.01, v3
	end

	return nil, v2, v3
end

function Combat.SafeRayToCFrame(p, p2, ...)
	local safeRay, v, v2 = Combat.SafeRay(p, p2, ...)

	if safeRay then
		return Combat.AlignRayToSurface(v, v2, CFrame.lookAt(createVector(0, 0, 0), p2) + p)
	end
end

function Combat.SafeRayLineToCFrame(p, p2, ...)
	local safeRayLine, v, v2 = Combat.SafeRayLine(p, p, ...)

	if safeRayLine then
		return Combat.AlignRayToSurface(v, v2, CFrame.lookAt(p, p2))
	end
end

function Combat.CharacterHeight(instance)
	if not instance then
		error("Missing Character as 1st parameter!")
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return 1.5
	end

	local humanoid = instance:FindFirstChild("Humanoid")

	if humanoid then
		return humanoidRootPart.Size.Y * 0.5 + humanoid.HipHeight
	end

	return 1.5
end

function Combat.FixMouseHeight(p, p2, value)
	if not p2 then
		error("Missing Character as 2nd parameter!")
	end

	if Combat.Ray(p + createVector(0, 0.1, 0), createVector(-0, -0.2, -0)) then
		return p + Vector3.new(0, math.min(value or 3.5, Combat.CharacterHeight(p2)), 0)
	end

	return p
end

function Combat.LookAtXZ(p, p2)
	return CFrame.lookAt(p, (Vector3.new(p2.X, p.Y, p2.Z)))
end

function Combat.AlignRayToSurface(p, p2, p3)
	if p3 then
		return Misc.AlignCFrame(p3 - p3.Position + p, p2)
	end

	return CFrame.new(p, p + p2) * CFrame.Angles(-1.5707963267948966, 0, 0)
end

return Combat