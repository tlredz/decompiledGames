local number = require(script.Parent.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("number"))
local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack

local function rgb2hsl(...)
	local v = unpack(table.pack(...), "rgba")
	local v2, v3, v4 = table.unpack(v, 1, 3)
	local v5 = v2 / 255
	local v6 = v3 / 255
	local v7 = v4 / 255
	local v8 = math.min(v5, v6, v7)
	local v9 = math.max(v5, v6, v7)
	local midpoint = (v9 + v8) / 2
	local naN = nil
	local v11

	if v9 == v8 then
		naN = number.NaN
		v11 = 0
	elseif midpoint < 0.5 then
		v11 = (v9 - v8) / (v9 + v8)
	else
		v11 = (v9 - v8) / (2 - v9 - v8)
	end

	if v5 == v9 then
		naN = (v6 - v7) / (v9 - v8)
	elseif v6 == v9 then
		naN = 2 + (v7 - v5) / (v9 - v8)
	elseif v7 == v9 then
		naN = 4 + (v5 - v6) / (v9 - v8)
	end

	local v12 = naN * 60

	if v12 < 0 then
		v12 += 360
	end

	if #v > 3 and v[4] ~= nil then
		return {
			v12,
			v11,
			midpoint,
			v[4]
		}
	end

	return { v12, v11, midpoint }
end

return rgb2hsl