local createVector = vector.create
local CameraShakeInstance = require(script.Parent.CameraShakeInstance)
local v = {
	["Regular Explosion"] = function()
		local v2 = CameraShakeInstance.new(1.5, 10, 0, 0.5)
		v2.PositionInfluence = createVector(0.7, 0.7, 0.7)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	["Regular Explosion Smooth"] = function()
		local v2 = CameraShakeInstance.new(0.7, 10, 0, 0.7)
		v2.PositionInfluence = createVector(0.45, 0.45, 0.45)
		v2.RotationInfluence = createVector(0.5, 0.5, 0.5)
		return v2
	end,
	["Regular Explosion Super Smooth"] = function()
		local v2 = CameraShakeInstance.new(0.5, 15, 0, 0.2)
		v2.PositionInfluence = createVector(0.2, 0.2, 0.2)
		v2.RotationInfluence = createVector(0.2, 0.2, 0.2)
		return v2
	end,
	CombatBump = function()
		local v2 = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
		v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	Bump = function()
		local v2 = CameraShakeInstance.new(4, 13, 0.1, 0.6)
		v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	Bump2 = function()
		local v2 = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
		v2.PositionInfluence = createVector(0.3, 0.3, 0.3)
		v2.RotationInfluence = createVector(2, 2, 2)
		return v2
	end,
	Bump3 = function()
		local v2 = CameraShakeInstance.new(1, 2, 0.1, 0.75)
		v2.PositionInfluence = createVector(0.3, 0.3, 0.3)
		v2.RotationInfluence = createVector(2, 2, 2)
		return v2
	end,
	Bump4 = function()
		local v2 = CameraShakeInstance.new(3, 12, 0.6, 1)
		v2.PositionInfluence = createVector(0.3, 0.3, 0.3)
		v2.RotationInfluence = createVector(0.5, 0.5, 0.5)
		return v2
	end,
	Hit = function()
		local v2 = CameraShakeInstance.new(2.75, 12.5, 0.1, 0.5)
		v2.PositionInfluence = createVector(0.15, 0.15, 0.15)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	Clash = function()
		local v2 = CameraShakeInstance.new(6, 22, 0.1, 0.5)
		v2.PositionInfluence = createVector(0.3, 0.3, 0.3)
		v2.RotationInfluence = createVector(1, 1, 1)
		return v2
	end,
	Explosion = function()
		local v2 = CameraShakeInstance.new(5, 10, 0, 1.5)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(4, 1, 1)
		return v2
	end,
	Explosion2 = function()
		local v2 = CameraShakeInstance.new(3.5, 8, 0, 1.5)
		v2.PositionInfluence = createVector(0.25, 0.25, 0.25)
		v2.RotationInfluence = createVector(1, 1, 1)
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
	end,
	Fast = function()
		local v2 = CameraShakeInstance.new(0.5, 20, 0, 0.25)
		v2.PositionInfluence = createVector(0.6, 0.6, 0.6)
		v2.RotationInfluence = createVector(0.5, 0.5, 0.5)
		return v2
	end,
	["Fast Hard"] = function()
		local v2 = CameraShakeInstance.new(1.5, 20, 0, 0.15)
		v2.PositionInfluence = createVector(1, 1, 1)
		v2.RotationInfluence = createVector(0.5, 0.5, 0.5)
		return v2
	end,
	["Pilar Hard"] = function()
		local v2 = CameraShakeInstance.new(2, 20, 0, 0.2)
		v2.PositionInfluence = createVector(1, 1, 1)
		v2.RotationInfluence = createVector(0.5, 0.5, 0.5)
		return v2
	end,
	["Fast Smooth"] = function()
		local v2 = CameraShakeInstance.new(0.3, 20, 0, 0.12)
		v2.PositionInfluence = createVector(1, 1, 1)
		v2.RotationInfluence = createVector(0.5, 0.5, 0.5)
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