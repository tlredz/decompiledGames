local createVector = vector.create
local CameraShakeInstance = require(script.Parent.CameraShakeInstance)
local v = {
	Bump = function()
		local v2 = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
		v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	BigBump = function()
		local v2 = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
		v2.PositionInfluence = createVector(0.8, 0.8, 0.8)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	SmallBump = function()
		local v2 = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
		v2.PositionInfluence = createVector(0.01, 0.01, 0.01)
		v2.RotationInfluence = createVector(0.5, 0.5, 0.5)
		return v2
	end,
	SmallestBump = function()
		local v2 = CameraShakeInstance.new(1.25, 2, 0.05, 0.405)
		v2.PositionInfluence = createVector(0.005, 0.005, 0.005)
		v2.RotationInfluence = createVector(0.25, 0.25, 0.25)
		return v2
	end,
	Loop = function()
		local v2 = CameraShakeInstance.new(0.5, 1, 0.05, 0.35)
		v2.PositionInfluence = createVector(0.01, 0.01, 0.01)
		v2.RotationInfluence = createVector(0.25, 0.25, 0.25)
		return v2
	end,
	Explosion = function()
		local v2 = CameraShakeInstance.new(5, 10, 0, 1.5)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(4, 1, 1)
		return v2
	end,
	BumpRemaked = function()
		local v2 = CameraShakeInstance.new(2, 5, 0, 1)
		v2.PositionInfluence = createVector(0.2, 0.2, 0.2)
		v2.RotationInfluence = createVector(3, 1, 1)
		return v2
	end,
	BigExplosion = function()
		local v2 = CameraShakeInstance.new(20, 40, 0, 2)
		v2.PositionInfluence = createVector(0.55, 0.55, 0.55)
		v2.RotationInfluence = createVector(5, 2, 2)
		return v2
	end,
	ReallyBigExplosion = function()
		local v2 = CameraShakeInstance.new(30, 50, 0, 1.5)
		v2.PositionInfluence = createVector(1, 1, 1)
		v2.RotationInfluence = createVector(5, 2, 2)
		return v2
	end,
	SmallExplosion = function()
		local v2 = CameraShakeInstance.new(5, 10, 0, 1.5)
		v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
		v2.RotationInfluence = createVector(4, 1, 1)
		return v2
	end,
	ExplosionNormal = function()
		local v2 = CameraShakeInstance.new(5, 10, 0, 1.5)
		v2.PositionInfluence = createVector(3, 3, 3)
		v2.RotationInfluence = createVector(4, 1, 1)
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