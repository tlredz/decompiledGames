local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack
local round = math.round

local function hsl2rgb(...)
	local v = unpack(table.pack(...), "hsl")
	local v2, v3, v4 = table.unpack(v, 1, 3)
	local v5, v6, v7

	if v3 == 0 then
		v5 = v4 * 255
		v6 = v5
		v7 = v6
		v6 = v7
	else
		local v9 = { 0, 0, 0 }
		local v10

		if v4 < 0.5 then
			v10 = v4 * (1 + v3)
		else
			v10 = v4 + v3 - v4 * v3
		end

		local v11 = 2 * v4 - v10
		local v12 = v2 / 360
		local v8 = {
			0,
			0,
			0,
			[1] = v12 + 0.3333333333333333,
			[2] = v12,
			[3] = v12 - 0.3333333333333333
		}

		for i = 1, 3 do
			if v8[i] < 0 then
				v8[i] += 1
			end

			if v8[i] > 1 then
				v8[i] -= 1
			end

			if 6 * v8[i] < 1 then
				v9[i] = v11 + (v10 - v11) * 6 * v8[i]
			elseif 2 * v8[i] < 1 then
				v9[i] = v10
			elseif 3 * v8[i] < 2 then
				v9[i] = v11 + (v10 - v11) * (0.6666666666666666 - v8[i]) * 6
			else
				v9[i] = v11
			end
		end

		v7 = round(v9[1] * 255)
		v6 = round(v9[2] * 255)
		v5 = round(v9[3] * 255)
	end

	if #v > 3 then
		return {
			v7,
			v6,
			v5,
			v[4]
		}
	end

	return {
		v7,
		v6,
		v5,
		1
	}
end

return hsl2rgb