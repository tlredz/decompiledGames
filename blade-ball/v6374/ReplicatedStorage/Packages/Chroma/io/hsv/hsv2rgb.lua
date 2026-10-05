local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack
local floor = math.floor

local function hsv2rgb(...)
	local v = unpack(table.pack(...), "hsv")
	local v2, v3, v4 = table.unpack(v, 1, 3)
	local v5 = nil
	local v6 = nil
	local v7 = nil
	local v8 = v4 * 255

	if v3 == 0 then
		v7 = v8
		v6 = v7
		v5 = v6
		v7 = v5
		v6 = v7
	else
		local v9 = v2 == 360 and 0 or v2

		if v9 > 360 then
			v9 -= 360
		end

		if v9 < 0 then
			v9 += 360
		end

		local v10 = v9 / 60
		local v11 = floor(v10)
		local v12 = v10 - v11
		local v13 = v8 * (1 - v3)
		local v14 = v8 * (1 - v3 * v12)
		local v15 = v8 * (1 - v3 * (1 - v12))

		if v11 == 0 then
			v7 = v13
			v6 = v15
			v5 = v8
		elseif v11 == 1 then
			v7 = v13
			v6 = v8
			v5 = v14
		elseif v11 == 2 then
			v7 = v15
			v6 = v8
			v5 = v13
		elseif v11 == 3 then
			v7 = v8
			v6 = v14
			v5 = v13
		elseif v11 == 4 then
			v7 = v8
			v6 = v13
			v5 = v15
		elseif v11 == 5 then
			v7 = v14
			v6 = v13
			v5 = v8
		end
	end

	return {
		v5,
		v6,
		v7,
		not (#v > 3) and 1 or v[4]
	}
end

return hsv2rgb