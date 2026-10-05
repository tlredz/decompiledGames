local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack
local max = math.max

local function rgb2cmyk(...)
	local v, v2, v3 = table.unpack(unpack(table.pack(...), "rgb"), 1, 3)
	local v4 = v / 255
	local v5 = v2 / 255
	local v6 = v3 / 255
	local v8 = 1 - max(v4, (max(v5, v6)))
	local v9 = not (v8 < 1) and 0 or 1 / (1 - v8)
	return {
		(1 - v4 - v8) * v9,
		(1 - v5 - v8) * v9,
		(1 - v6 - v8) * v9,
		v8
	}
end

return rgb2cmyk