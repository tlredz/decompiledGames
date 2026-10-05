local number = require(script.Parent.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("number"))
local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack
local min = math.min
local max = math.max

local function rgb2hsl(...)
	local v, v2, v3 = table.unpack(unpack(table.pack(...), "rgb"), 1, 3)
	local v4 = min(v, v2, v3)
	local v5 = max(v, v2, v3)
	local v6 = v5 - v4
	local v7 = nil
	local v8 = v5 / 255
	local naN, v9

	if v5 == 0 then
		naN = number.NaN
		v9 = 0
	else
		v9 = v6 / v5

		if v == v5 then
			v7 = (v2 - v3) / v6
		end

		if v2 == v5 then
			v7 = 2 + (v3 - v) / v6
		end

		if v3 == v5 then
			v7 = 4 + (v - v2) / v6
		end

		naN = v7 * 60

		if naN < 0 then
			naN += 360
		end
	end

	return { naN, v9, v8 }
end

return rgb2hsl