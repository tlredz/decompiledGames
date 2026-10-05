local createVector = vector.create
local CameraShakeInstance = require(script.Parent.CameraShakeInstance)
local v = {
	Bump = function()
		local v2 = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
		v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	SmallShake = function()
		local v2 = CameraShakeInstance.new(10, 12, 0.1, 0.2)
		v2.PositionInfluence = createVector(0.15, 0.15, 0)
		v2.RotationInfluence = createVector(0.1, 0.1, 1)
		return v2
	end,
	Earthquake = function()
		local v2 = CameraShakeInstance.new(0.6, 3.5, 2, 10)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(1, 1, 4)
		return v2
	end,
	BadTrip = function()
		local v2 = CameraShakeInstance.new(10, 0.15, 5, 10)
		v2.PositionInfluence = createVector(0, 0, 0.15)
		v2.RotationInfluence = createVector(2, 1, 4)
		return v2
	end,
	HandheldCamera = function()
		local v2 = CameraShakeInstance.new(1, 0.25, 5, 10)
		v2.PositionInfluence = createVector(0, 0, 0)
		v2.RotationInfluence = createVector(1, 0.5, 0.5)
		return v2
	end,
	Vibration = function()
		local v2 = CameraShakeInstance.new(0.4, 20, 2, 2)
		v2.PositionInfluence = createVector(0, 0.15, 0)
		v2.RotationInfluence = createVector(1.25, 0, 4)
		return v2
	end,
	RoughDriving = function()
		local v2 = CameraShakeInstance.new(1, 2, 1, 1)
		v2.PositionInfluence = createVector(0, 0, 0)
		v2.RotationInfluence = createVector(1, 1, 1)
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