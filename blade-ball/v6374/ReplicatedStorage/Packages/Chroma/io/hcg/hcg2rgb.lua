local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack
local floor = math.floor

local function hcg2rgb(...)
	local v = unpack(table.pack(...), "hcg")
	local v2, v3, v4 = table.unpack(v, 1, 3)
	local v5 = nil
	local v6 = nil
	local v7 = nil
	local v8 = v4 * 255
	local v9 = v3 * 255

	if v3 == 0 then
		v7 = v8
		v6 = v7
		v5 = v6
		v7 = v5
		v6 = v7
	else
		local v10 = v2 == 360 and 0 or v2

		if v10 > 360 then
			v10 -= 360
		end

		if v10 < 0 then
			v10 += 360
		end

		local v11 = v10 / 60
		local v12 = floor(v11)
		local v13 = v11 - v12
		local v14 = v8 * (1 - v3)
		local v15 = v14 + v9 * (1 - v13)
		local v16 = v14 + v9 * v13
		local v17 = v14 + v9

		if v12 == 0 then
			v7 = v14
			v6 = v16
			v5 = v17
		elseif v12 == 1 then
			v7 = v14
			v6 = v17
			v5 = v15
		elseif v12 == 2 then
			v7 = v16
			v6 = v17
			v5 = v14
		elseif v12 == 3 then
			v7 = v17
			v6 = v15
			v5 = v14
		elseif v12 == 4 then
			v7 = v17
			v6 = v14
			v5 = v16
		elseif v12 == 5 then
			v7 = v15
			v6 = v14
			v5 = v17
		end
	end

	return {
		v5,
		v6,
		v7,
		not (#v > 3) and 1 or v[4]
	}
end

return hcg2rgb