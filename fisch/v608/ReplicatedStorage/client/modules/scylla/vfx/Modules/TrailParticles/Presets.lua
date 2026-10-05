local createVector = vector.create
local Presets = {
	Default = {
		Velocity = createVector(1, 1, 100),
		MinSpeedMult = 0.1,
		MaxSpeedMult = 1.3,
		FadeIn = 0.8,
		FadeOut = 1,
		Resolution = 2,
		Contrast = 1.1,
		TrailLife = 1,
		NoiseStrength = function(p: number)
			return p ^ 2.5
		end,
		VelocityDrag = function(vector2: Vector3)
			return vector2
		end
	},
	Explosion = {
		Velocity = createVector(1, 1, 300),
		MinSpeedMult = 0.3,
		MaxSpeedMult = 1.3,
		FadeIn = 0.8,
		FadeOut = 1,
		Resolution = 2,
		Contrast = 10,
		NoiseStrength = function(p)
			return p ^ 2
		end,
		VelocityDrag = function(vector2: Vector3)
			return vector2 - createVector(0, 0, 10)
		end
	},
	Swirl = {
		Velocity = createVector(1, 1, 300),
		MinSpeedMult = 0.3,
		MaxSpeedMult = 1.3,
		FadeIn = 0.8,
		FadeOut = 1,
		Resolution = 2,
		Contrast = 14,
		NoiseStrength = function(p)
			return p ^ 2
		end,
		VelocityDrag = function(vector2: Vector3)
			return vector2 - createVector(0, 0, 10)
		end
	},
	Spring = {
		Velocity = createVector(1, 1, 120),
		MinSpeedMult = 0.3,
		MaxSpeedMult = 1.3,
		FadeIn = 0.8,
		FadeOut = 1,
		Resolution = 2,
		Contrast = 1.1,
		NoiseStrength = function(p)
			return p ^ 5
		end,
		VelocityDrag = function(vector2: Vector3)
			return vector2 - createVector(0, 0, 2)
		end
	},
	Line = {
		Velocity = createVector(1, 1, 100),
		MinSpeedMult = 0.3,
		MaxSpeedMult = 1.3,
		FadeIn = 0.8,
		FadeOut = 1,
		Resolution = 2,
		Contrast = 1.5,
		NoiseStrength = function(p)
			return p ^ 2
		end,
		VelocityDrag = function(vector2: Vector3)
			return vector2
		end
	},
	LineDrag = {
		Velocity = createVector(1, 1, 120),
		MinSpeedMult = 0.3,
		MaxSpeedMult = 1.3,
		FadeIn = 0.8,
		FadeOut = 1,
		Resolution = 2,
		Contrast = 1.5,
		NoiseStrength = function(p)
			return p ^ 2
		end,
		VelocityDrag = function(vector2: Vector3)
			return vector2 - createVector(0, 0, 5)
		end
	},
	Static = {
		Velocity = createVector(0, 0, 0),
		MinSpeedMult = 1,
		MaxSpeedMult = 1,
		FadeIn = 1,
		FadeOut = 1,
		Resolution = 2,
		Contrast = 1.1,
		NoiseStrength = function(p)
			return p ^ 2.5
		end,
		VelocityDrag = function(vector2: Vector3)
			return vector2
		end
	}
}
setmetatable(Presets, {
	__index = function(_, p)
		error(string.format("%q is not a valid member of %q", tostring(p), script.Name), 2)
	end
})
return Presets