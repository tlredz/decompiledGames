local createVector = vector.create
local module = require("../../utils/oklab")
local module2 = require("../../../../../tests/test")

local function testColors(fn)
	for i = 0, 4 do
		for i2 = 0, 4 do
			for i3 = 0, 4 do
				fn(vector.create(i, i2, i3) / 4)
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fuzzyEqual(vector2: Vector3, vector3: Vector3)
	local v = vector.abs(vector2 - vector3)
	return math.max(v.x, v.y, v.z) < 0.0001
end

module2("should be reversible lab to rgb", function()
	testColors(function(p)
		local v = module.fromSRGB(p)
		local SRGB = module.toSRGB(v)
		assert(fuzzyEqual(SRGB, p), (`expected {SRGB} to be equal to {p}`))
	end)
end)
module2("should be reversible rgb to lab", function()
	testColors(function(p)
		local SRGB = module.toSRGB(p)
		local v = module.fromSRGB(SRGB)
		assert(fuzzyEqual(v, p), (`expected {v} to be equal to {p}`))
	end)
end)
module2("should not be nan for negative numbers", function()
	local v = module.fromSRGB(createVector(-1, -1, -1))
	assert(v == v, "expected output to not be NaN")
end)
return {}