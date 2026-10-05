local createVector = vector.create
local CameraShakeInstance = require(script.Parent.CameraShakeInstance)
local v = {
	Fireball = function()
		local v2 = CameraShakeInstance.new(4, 7, 0, 1.5)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	Explosion = function()
		local v2 = CameraShakeInstance.new(9, 6, 0, 2.5)
		v2.PositionInfluence = createVector(0.4, 0.4, 0.4)
		v2.RotationInfluence = createVector(0.4, 0.4, 0.4)
		return v2
	end,
	SmallContainedExplosion = function()
		local v2 = CameraShakeInstance.new(9, 5, 0, 0.75)
		v2.PositionInfluence = createVector(0.2, 0.2, 0.2)
		v2.RotationInfluence = createVector(0.2, 0.2, 0.2)
		return v2
	end,
	ContainedBump = function()
		local v2 = CameraShakeInstance.new(5, 4, 0, 1.5)
		v2.PositionInfluence = createVector(0.1, 0.1, 0.1)
		v2.RotationInfluence = createVector(0.2, 0.2, 0.2)
		return v2
	end,
	RiftEnd = function()
		local v2 = CameraShakeInstance.new(9, 8, 0, 1.5)
		v2.PositionInfluence = createVector(0.1, 0.1, 0.1)
		v2.RotationInfluence = createVector(0.2, 0.2, 0.2)
		return v2
	end,
	TinyBump = function()
		local v2 = CameraShakeInstance.new(5, 2, 0, 0.6)
		v2.PositionInfluence = createVector(0.1, 0.1, 0.1)
		v2.RotationInfluence = createVector(0.05, 0.05, 0.05)
		return v2
	end,
	ContainedExplosion = function()
		local v2 = CameraShakeInstance.new(4, 8, 0, 1.5)
		v2.PositionInfluence = createVector(0.2, 0.2, 0.2)
		v2.RotationInfluence = createVector(0.6, 0.6, 0.6)
		return v2
	end,
	ContainedShoot = function()
		local v2 = CameraShakeInstance.new(8, 8, 0, 1.5)
		v2.PositionInfluence = createVector(0.2, 0.2, 0.2)
		v2.RotationInfluence = createVector(0.6, 0.6, 0.6)
		return v2
	end,
	SmoothContainedExplosion = function()
		local v2 = CameraShakeInstance.new(6.6, 4.5, 0, 1.5)
		v2.PositionInfluence = createVector(0.2, 0.2, 0.2)
		v2.RotationInfluence = createVector(0.6, 0.6, 0.6)
		return v2
	end,
	ImpactfulExplosion = function()
		local v2 = CameraShakeInstance.new(8, 6.5, 0, 1.5)
		v2.PositionInfluence = createVector(0.3, 0.3, 0.3)
		v2.RotationInfluence = createVector(0.4, 0.4, 0.4)
		return v2
	end,
	GuardianBlast = function()
		local v2 = CameraShakeInstance.new(13, 8.5, 0, 1.6)
		v2.PositionInfluence = createVector(0.4, 0.4, 0.4)
		v2.RotationInfluence = createVector(0.5, 0.5, 0.5)
		return v2
	end,
	MegaExplosion = function()
		local v2 = CameraShakeInstance.new(18, 10.5, 0, 2)
		v2.PositionInfluence = createVector(0.4, 0.4, 0.4)
		v2.RotationInfluence = createVector(0.65, 0.65, 0.65)
		return v2
	end,
	GuardExploTrav = function()
		local v2 = CameraShakeInstance.new(14, 10.5, 0, 2)
		v2.PositionInfluence = createVector(0.4, 0.4, 0.4)
		v2.RotationInfluence = createVector(0.65, 0.65, 0.65)
		return v2
	end,
	SmoothExplosion = function()
		local v2 = CameraShakeInstance.new(9.7, 4.5, 0, 1.75)
		v2.PositionInfluence = createVector(0.2, 0.2, 0.2)
		v2.RotationInfluence = createVector(0.6, 0.6, 0.6)
		return v2
	end,
	Death = function()
		local v2 = CameraShakeInstance.new(50, 50, 0, 1.75)
		v2.PositionInfluence = createVector(0.8, 0.8, 0.8)
		v2.RotationInfluence = createVector(0.6, 0.6, 0.6)
		return v2
	end,
	Dragon = function()
		local v2 = CameraShakeInstance.new(5, 6.5, 0, 0.75)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	Bump = function()
		local v2 = CameraShakeInstance.new(1, 1, 0.2, 1)
		v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
		v2.RotationInfluence = createVector(0.2, 0.2, 0.2)
		return v2
	end,
	FireBallRelease = function()
		local v2 = CameraShakeInstance.new(3, 3, 0, 0.2)
		v2.PositionInfluence = createVector(1, 1, 1)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	SmallBump3 = function()
		local v2 = CameraShakeInstance.new(2.5, 5, 0, 0.4)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(0.5, 0.5, 0.5)
		return v2
	end,
	SmallBump4 = function()
		local v2 = CameraShakeInstance.new(2.5, 5, 0, 0.75)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(0.5, 0.5, 0.5)
		return v2
	end,
	FireBallActivate = function()
		local v2 = CameraShakeInstance.new(2.5, 5, 0, 0.1)
		v2.PositionInfluence = createVector(0.4, 0.4, 0.4)
		v2.RotationInfluence = createVector(0.6, 0.6, 0.6)
		return v2
	end,
	Earthquake = function()
		local v2 = CameraShakeInstance.new(20, 12, 0.25, 3.5)
		v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
		v2.RotationInfluence = createVector(0.15, 0.15, 0.15)
		return v2
	end,
	ShortEarthquake = function()
		local v2 = CameraShakeInstance.new(20, 12, 0.25, 1.75)
		v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
		v2.RotationInfluence = createVector(0.15, 0.15, 0.15)
		return v2
	end,
	SmallCharge = function()
		local v2 = CameraShakeInstance.new(10, 17, 0.5, 2)
		v2.PositionInfluence = createVector(0.1, 0.1, 0.1)
		v2.RotationInfluence = createVector(0.1, 0.1, 0.1)
		return v2
	end,
	WindCharge = function()
		local v2 = CameraShakeInstance.new(15, 3, 0.1, 3.5)
		v2.PositionInfluence = createVector(0.1, 0.1, 0.1)
		v2.RotationInfluence = createVector(0.1, 0.1, 0.1)
		return v2
	end,
	MildCharge = function()
		local v2 = CameraShakeInstance.new(5, 7, 0, 0.75)
		v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
		v2.RotationInfluence = createVector(0.15, 0.15, 0.15)
		return v2
	end,
	ImpactFrame = function()
		local v2 = CameraShakeInstance.new(12, 9, 0, 0.75)
		v2.PositionInfluence = createVector(0.2, 0.2, 0.2)
		v2.RotationInfluence = createVector(0.15, 0.15, 0.15)
		return v2
	end,
	SustainedSmallCharge = function()
		local v2 = CameraShakeInstance.new(10, 17, 0.5, 3.5)
		v2.PositionInfluence = createVector(0.1, 0.1, 0.1)
		v2.RotationInfluence = createVector(0.1, 0.1, 0.1)
		return v2
	end,
	BigCharge = function()
		local v2 = CameraShakeInstance.new(13, 17, 0.25, 3.75)
		v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
		v2.RotationInfluence = createVector(0.2, 0.2, 0.2)
		return v2
	end,
	BeamRelease = function()
		local v2 = CameraShakeInstance.new(16, 19, 0.25, 3.75)
		v2.PositionInfluence = createVector(0.225, 0.225, 0.225)
		v2.RotationInfluence = createVector(0.2, 0.2, 0.2)
		return v2
	end,
	ChromaCharge = function()
		local v2 = CameraShakeInstance.new(13, 17, 1, 1.2)
		v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
		v2.RotationInfluence = createVector(0.2, 0.2, 0.2)
		return v2
	end,
	FastCharge = function()
		local v2 = CameraShakeInstance.new(13, 15, 0.25, 1.25)
		v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
		v2.RotationInfluence = createVector(0.2, 0.2, 0.2)
		return v2
	end,
	ImpactfulChargeBeam = function()
		local v2 = CameraShakeInstance.new(16, 18, 0.25, 1.25)
		v2.PositionInfluence = createVector(0.3, 0.3, 0.3)
		v2.RotationInfluence = createVector(0.2, 0.2, 0.2)
		return v2
	end,
	MildLongCharge = function()
		local v2 = CameraShakeInstance.new(8, 8, 0.25, 3)
		v2.PositionInfluence = createVector(0.1, 0.1, 0.1)
		v2.RotationInfluence = createVector(0.05, 0.05, 0.05)
		return v2
	end,
	QuickCharge = function()
		local v2 = CameraShakeInstance.new(13, 17, 0.25, 2)
		v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
		v2.RotationInfluence = createVector(0.2, 0.2, 0.2)
		return v2
	end,
	MegaCharge = function()
		local v2 = CameraShakeInstance.new(15, 18, 0.25, 4.25)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(0.2, 0.2, 0.2)
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
	end,
	Vibration2 = function()
		local v2 = CameraShakeInstance.new(0.4, 20, 2, 2)
		v2.PositionInfluence = createVector(0, 4, 0)
		v2.RotationInfluence = createVector(1.25, 0, 4)
		return v2
	end,
	SmallBump2 = function()
		local v2 = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
		v2.PositionInfluence = createVector(0.025, 0.025, 0.025)
		v2.RotationInfluence = createVector(0.25, 0.25, 0.25)
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