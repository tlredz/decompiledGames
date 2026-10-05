local number = require(script.Parent.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("number"))
local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack

local function rgb2hcg(...)
	local v, v2, v3 = table.unpack(unpack(table.pack(...), "rgb"), 1, 3)
	local v4 = math.min(v, v2, v3)
	local v5 = math.max(v, v2, v3)
	local v6 = v5 - v4
	local v7 = v6 * 100 / 255
	local v8 = v4 / (255 - v6) * 100
	local v9 = nil
	local naN

	if v6 == 0 then
		naN = number.NaN
	else
		if v == v5 then
			v9 = (v2 - v3) / v6
		end

		if v2 == v5 then
			v9 = 2 + (v3 - v) / v6
		end

		if v3 == v5 then
			v9 = 4 + (v - v2) / v6
		end

		naN = v9 * 60

		if naN < 0 then
			naN += 360
		end
	end

	return { naN, v7, v8 }
end

return rgb2hcg