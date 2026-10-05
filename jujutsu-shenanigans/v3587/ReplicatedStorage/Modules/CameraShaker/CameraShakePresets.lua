local createVector = vector.create
local CameraShakeInstance = require(script.Parent.CameraShakeInstance)
local v = {
	LightHit = function()
		local v2 = CameraShakeInstance.new(4, 7, 0.1, 0.75)
		v2.PositionInfluence = createVector(0.25, 0.25, 0)
		v2.RotationInfluence = createVector(0, 0, 0)
		return v2
	end,
	MediumHit = function()
		local v2 = CameraShakeInstance.new(6, 9.5, 0.1, 0.85)
		v2.PositionInfluence = createVector(0.325, 0.325, 0)
		v2.RotationInfluence = createVector(0, 0, 0)
		return v2
	end,
	GreaterMediumHit = function()
		local v2 = CameraShakeInstance.new(6.85, 11.2, 0, 0.95)
		v2.PositionInfluence = createVector(0.395, 0.395, 0)
		v2.RotationInfluence = createVector(0, 0, 0)
		return v2
	end,
	HeavyHit = function()
		local v2 = CameraShakeInstance.new(8, 14, 0, 1.25)
		v2.PositionInfluence = createVector(0.5, 0.5, 0)
		v2.RotationInfluence = createVector(0, 0, 0)
		return v2
	end,
	Snap = function()
		local v2 = CameraShakeInstance.new(8, 25, 0, 0.7)
		v2.PositionInfluence = createVector(0.6, 0.6, 0)
		v2.RotationInfluence = createVector(0, 0, 0)
		return v2
	end,
	SnapOh = function()
		local v2 = CameraShakeInstance.new(8, 25, 0, 1.4)
		v2.PositionInfluence = createVector(0.6, 0.6, 0)
		v2.RotationInfluence = createVector(0, 0, 0)
		return v2
	end,
	LightLoop = function()
		local v2 = CameraShakeInstance.new(7, 7, 0.04, 0.04)
		v2.PositionInfluence = createVector(0.1, 0.1, 0)
		v2.RotationInfluence = createVector(0, 0, 0)
		return v2
	end,
	HeavyLoop = function()
		local v2 = CameraShakeInstance.new(7, 12, 0.03, 0.03)
		v2.PositionInfluence = createVector(0.3, 0.3, 0)
		v2.RotationInfluence = createVector(0, 0, 0)
		return v2
	end,
	SmallBump = function()
		local v2 = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
		v2.PositionInfluence = createVector(0.01, 0.01, 0.01)
		v2.RotationInfluence = createVector(0.25, 0.25, 0.25)
		return v2
	end,
	QuickBumpSmall = function()
		local v2 = CameraShakeInstance.new(4, 14, 0, 0.3)
		v2.PositionInfluence = createVector(0.12, 0.18, 0.12)
		v2.RotationInfluence = createVector(1.2, 1.2, 1.2)
		return v2
	end,
	ViolenterBump = function()
		local v2 = CameraShakeInstance.new(4.5, 13.5, 0.1, 0.35)
		v2.PositionInfluence = createVector(0.3, 0.3, 0.3)
		v2.RotationInfluence = createVector(1.4, 1.4, 1.4)
		return v2
	end
}
return (setmetatable({}, {
	__index = function(_, p)
		local v2 = v[p]

		if type(v2) == "function" then
			return v2()
		end

		error("No preset found with index \"" .. p .. "\"")
	end
}))