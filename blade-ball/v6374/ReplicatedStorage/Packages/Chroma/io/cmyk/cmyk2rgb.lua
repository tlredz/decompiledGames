local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack

local function cmyk2rgb(...)
	local v = unpack(table.pack(...), "cmyk")
	local v2, v3, v4, v5 = table.unpack(v, 1, 4)
	local v6 = not (#v > 4) and 1 or v[5]

	if v5 == 1 then
		return {
			0,
			0,
			0,
			v6
		}
	end

	return {
		v2 >= 1 and 0 or 255 * (1 - v2) * (1 - v5),
		v3 >= 1 and 0 or 255 * (1 - v3) * (1 - v5),
		v4 >= 1 and 0 or 255 * (1 - v4) * (1 - v5),
		v6
	}
end

return cmyk2rgb