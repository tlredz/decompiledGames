local createVector = vector.create
local CameraShakeInstance = require(script.Parent.CameraShakeInstance)
local v = {
	NoShake = function()
		local v2 = CameraShakeInstance.new(0, 0, 0, 0)
		v2.PositionInfluence = createVector(0, 0, 0)
		v2.RotationInfluence = createVector(0, 0, 0)
		return v2
	end,
	SmallBump = function()
		local v2 = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
		v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	SmallBump2 = function()
		local v2 = CameraShakeInstance.new(2.25, 2.75, 0, 0.5)
		v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	SmallerBump = function()
		local v2 = CameraShakeInstance.new(2.25, 2, 0.1, 0.5)
		v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
		v2.RotationInfluence = createVector(0.5, 0.5, 0.5)
		return v2
	end,
	Roar = function()
		local v2 = CameraShakeInstance.new(4, 10, 0, 2.5)
		v2.PositionInfluence = createVector(1, 1, 1)
		v2.RotationInfluence = createVector(1, 1, 4)
		return v2
	end,
	SmallerBump2 = function()
		local v2 = CameraShakeInstance.new(1.5, 3.5, 0.1, 0.75)
		v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
		v2.RotationInfluence = createVector(0.7, 0.7, 0.7)
		return v2
	end,
	SmallestBump = function()
		local v2 = CameraShakeInstance.new(1, 3, 0.1, 0.75)
		v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
		v2.RotationInfluence = createVector(0.7, 0.7, 0.7)
		return v2
	end,
	SmallestBump2 = function()
		local v2 = CameraShakeInstance.new(1, 2, 0.1, 0.5)
		v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
		v2.RotationInfluence = createVector(0.7, 0.7, 0.7)
		return v2
	end,
	Flash = function()
		local v2 = CameraShakeInstance.new(5, 10, 0, 0.5)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(4, 1, 1)
		return v2
	end,
	Bump = function()
		local v2 = CameraShakeInstance.new(3, 7, 0.1, 1.2)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	Bump2 = function()
		local v2 = CameraShakeInstance.new(3.5, 7.5, 0.2, 1.3)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	Summon = function()
		local v2 = CameraShakeInstance.new(3, 3.5, 2, 5)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(3, 1, 3)
		return v2
	end,
	Explosion = function()
		local v2 = CameraShakeInstance.new(5, 10, 0, 1.5)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(4, 1, 1)
		return v2
	end,
	Explosion2 = function()
		local v2 = CameraShakeInstance.new(3.75, 7.5, 0.1, 1.5)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(2.5, 1, 1)
		return v2
	end,
	Stand = function()
		local v2 = CameraShakeInstance.new(4, 9, 0, 1.5)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(4, 1, 1)
		return v2
	end,
	HandheldCamera = function()
		local v2 = CameraShakeInstance.new(1, 0.25, 5, 10)
		v2.PositionInfluence = createVector(0, 0, 0)
		v2.RotationInfluence = createVector(1, 0.5, 0.5)
		return v2
	end,
	Bump1 = function()
		local v2 = CameraShakeInstance.new(5, 4, 0.3, 0.75)
		v2.PositionInfluence = createVector(0.35, 0.35, 0.35)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	BK1 = function()
		local v2 = CameraShakeInstance.new(1.5, 4, 0.3, 0.75)
		v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	Critical1 = function()
		local v2 = CameraShakeInstance.new(6, 4, 0.3, 0.75)
		v2.PositionInfluence = createVector(0.5, 0.5, 0.5)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	AnotherBump3 = function()
		local v2 = CameraShakeInstance.new(3.2, 7, 0.15, 1.25)
		v2.PositionInfluence = createVector(0.6, 0.6, 0.6)
		v2.RotationInfluence = createVector(1.1, 1.1, 1.1)
		return v2
	end,
	Earthquake = function()
		local v2 = CameraShakeInstance.new(0.6, 3.5, 2, 10)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(1, 1, 4)
		return v2
	end,
	Gura1 = function()
		local v2 = CameraShakeInstance.new(4, 10, 0, 3)
		v2.PositionInfluence = createVector(0.5, 0.5, 0.5)
		v2.RotationInfluence = createVector(1, 1, 4)
		return v2
	end,
	BadTrip = function()
		local v2 = CameraShakeInstance.new(10, 0.15, 5, 10)
		v2.PositionInfluence = createVector(0, 0, 0.15)
		v2.RotationInfluence = createVector(2, 1, 4)
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
	NewBump = function()
		local v2 = CameraShakeInstance.new(2.5, 7, 0.1, 0.5)
		v2.PositionInfluence = createVector(0.5, 0.5, 0.5)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	LekHum = function()
		local v2 = CameraShakeInstance.new(5, 8.5, 0.1, 1)
		v2.PositionInfluence = createVector(0.5, 0.5, 0.5)
		v2.RotationInfluence = createVector(1, 1.25, 1.25)
		return v2
	end,
	Astrum = function()
		local v2 = CameraShakeInstance.new(6, 20, 0, 1)
		v2.PositionInfluence = createVector(0.5, 0.5, 0.5)
		v2.RotationInfluence = createVector(1, 1, 4)
		return v2
	end,
	Devastate = function()
		local v2 = CameraShakeInstance.new(40, 25, 0.3, 0.75)
		v2.PositionInfluence = createVector(0.5, 0.5, 0.5)
		v2.RotationInfluence = createVector(2, 2, 2)
		return v2
	end,
	BK2 = function()
		local v2 = CameraShakeInstance.new(3.5, 5.5, 0.3, 0.75)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	GuraEarthquake = function()
		local v2 = CameraShakeInstance.new(2.5, 150, 2, 5)
		v2.PositionInfluence = createVector(0.35, 0.35, 0.35)
		v2.RotationInfluence = createVector(1, 1, 2)
		return v2
	end,
	GateOpen = function()
		local v2 = CameraShakeInstance.new(2, 50, 2, 4)
		v2.PositionInfluence = createVector(0.35, 0.35, 0.35)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	IslandShake = function()
		local v2 = CameraShakeInstance.new(2.5, 120, 2, 25)
		v2.PositionInfluence = createVector(0.5, 0.5, 0.5)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	Mochi1 = function()
		local v2 = CameraShakeInstance.new(4, 7.5, 0, 3)
		v2.PositionInfluence = createVector(0.4, 0.4, 0.4)
		v2.RotationInfluence = createVector(1, 1, 3.5)
		return v2
	end,
	Gura2 = function()
		local v2 = CameraShakeInstance.new(4, 10, 0, 3)
		v2.PositionInfluence = createVector(0.9, 0.9, 0.9)
		v2.RotationInfluence = createVector(2, 2, 7)
		return v2
	end,
	Bisento1 = function()
		local v2 = CameraShakeInstance.new(4, 10, 0, 3)
		v2.PositionInfluence = createVector(0.75, 0.75, 0.75)
		v2.RotationInfluence = createVector(1, 1, 4)
		return v2
	end,
	Saber_X = function()
		local v2 = CameraShakeInstance.new(4, 10, 0, 3)
		v2.PositionInfluence = createVector(0.5, 0.5, 0.5)
		v2.RotationInfluence = createVector(1, 1, 4)
		return v2
	end,
	Allosaurus_X = function()
		local v2 = CameraShakeInstance.new(4, 10, 0, 5)
		v2.PositionInfluence = createVector(1, 1, 1)
		v2.RotationInfluence = createVector(1, 1, 4)
		return v2
	end,
	HellSword_X = function()
		local v2 = CameraShakeInstance.new(5, 6, 0, 3)
		v2.PositionInfluence = createVector(1, 1, 1)
		v2.RotationInfluence = createVector(1, 1, 4)
		return v2
	end,
	SwordHit = function()
		local v2 = CameraShakeInstance.new(2, 4, 0.1, 0.8)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	HydraRoar = function()
		local v2 = CameraShakeInstance.new(6, 10, 0, 3)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(4, 1, 1)
		return v2
	end,
	FastExplosion = function()
		local v2 = CameraShakeInstance.new(5, 10, 0, 0.25)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	SmallExplosion = function()
		local v2 = CameraShakeInstance.new(3, 10, 0, 1.5)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(4, 1, 1)
		return v2
	end,
	WaterStyleV = function()
		local v2 = CameraShakeInstance.new(3, 15, 0, 1)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(4, 1, 1)
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