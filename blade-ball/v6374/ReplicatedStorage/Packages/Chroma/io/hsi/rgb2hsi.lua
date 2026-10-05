local number = require(script.Parent.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("number"))
local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack
local TWOPI = utils.TWOPI
local min = math.min
local sqrt = math.sqrt
local acos = math.acos

local function rgb2hsi(...)
	local v, v2, v3 = table.unpack(unpack(table.pack(...), "rgb"), 1, 3)
	local v4 = v / 255
	local v5 = v2 / 255
	local v6 = v3 / 255
	local v7 = min(v4, v5, v6)
	local v8 = (v4 + v5 + v6) / 3
	local v9 = not (v8 > 0) and 0 or 1 - v7 / v8
	local naN

	if v9 == 0 then
		naN = number.NaN
	else
		local v13 = acos((v4 - v5 + (v4 - v6)) / 2 / sqrt((v4 - v5) * (v4 - v5) + (v4 - v6) * (v5 - v6)))

		if v5 < v6 then
			v13 = TWOPI - v13
		end

		naN = v13 / TWOPI
	end

	return { naN * 360, v9, v8 }
end

return rgb2hsi