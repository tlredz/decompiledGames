local module = require("../easing")
local module2 = require("../../../../tests/test")
module2("should have correct start and end", function()
	for k, v in pairs(module) do
		local v2 = v(0)
		local v3 = v(1)
		assert(math.abs(v2) < 0.0001, (`{k}(0) should be near 0, got {v2}`))
		assert(math.abs(1 - v3) < 0.0001, (`{k}(1) should be near 1, got {v3}`))
	end
end)
module2("should be within range", function()
	for k, v in pairs(module) do
		for i = 0, 1, 0.1 do
			local v2 = v(i)
			assert(v2 < 1.5, (`{k}({i}) should be less than 1.5, got {v2}`))
			assert(v2 > -0.5, (`{k}({i}) should be greater than -0.5, got {v2}`))
		end
	end
end)
return {}