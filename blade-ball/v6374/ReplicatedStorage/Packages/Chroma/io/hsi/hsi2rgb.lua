local number = require(script.Parent.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("number"))
local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack
local limit = utils.limit
local TWOPI = utils.TWOPI
local PITHIRD = utils.PITHIRD
local cos = math.cos

local function hsi2rgb(...)
	local v = unpack(table.pack(...), "hsi")
	local v2, v3, v4 = table.unpack(v, 1, 3)
	local v5 = number.isNaN(v2) and 0 or v2
	local v6 = number.isNaN(v3) and 0 or v3

	if v5 > 360 then
		v5 -= 360
	end

	if v5 < 0 then
		v5 += 360
	end

	local v7 = v5 / 360
	local v8, v9, v10

	if v7 < 0.3333333333333333 then
		v8 = (1 - v6) / 3
		v9 = (1 + v6 * cos(TWOPI * v7) / cos(PITHIRD - TWOPI * v7)) / 3
		v10 = 1 - (v8 + v9)
	elseif v7 < 0.6666666666666666 then
		local v11 = v7 - 0.3333333333333333
		v9 = (1 - v6) / 3
		v10 = (1 + v6 * cos(TWOPI * v11) / cos(PITHIRD - TWOPI * v11)) / 3
		v8 = 1 - (v9 + v10)
	else
		local v11 = v7 - 0.6666666666666666
		v10 = (1 - v6) / 3
		v8 = (1 + v6 * cos(TWOPI * v11) / cos(PITHIRD - TWOPI * v11)) / 3
		v9 = 1 - (v10 + v8)
	end

	local v11 = limit(v4 * v9 * 3)
	local v12 = limit(v4 * v10 * 3)
	local v13 = limit(v4 * v8 * 3)
	return {
		v11 * 255,
		v12 * 255,
		v13 * 255,
		not (#v > 3) and 1 or v[4]
	}
end

return hsi2rgb