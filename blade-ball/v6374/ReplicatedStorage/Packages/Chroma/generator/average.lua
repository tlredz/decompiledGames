local collections = require(script.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("collections"))
local number = require(script.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("number"))
local Color = require(script.Parent.Parent:WaitForChild("Color"))
local utils = require(script.Parent.Parent:WaitForChild("utils"))
local clip_rgb = utils.clip_rgb
local array = collections.Array
local pow = math.pow
local sqrt = math.sqrt
local cos = math.cos
local sin = math.sin
local atan2 = math.atan2
local _average_lrgb

local function average(list, p: string?, list2)
	local v = p == nil and "lrgb" or p
	local count = #list

	if list2 == nil then
		list2 = table.create(count, 1)
	end

	local v2 = count / array.reduce(list2, function(p2: number, p3: number)
		return p2 + p3
	end)

	for k in list2 do
		list2[k] *= v2
	end

	local mapped = array.map(list, function(p2)
		return Color.new(p2)
	end)

	if v == "lrgb" then
		return _average_lrgb(mapped, list2)
	end

	local v3 = table.remove(mapped, 1)
	local v4 = v3:get(v)
	local v5 = {}
	local total = 0
	local total2 = 0

	for k in v4 do
		v4[k] = (v4[k] or 0) * list2[1]
		table.insert(v5, number.isNaN(v4[k]) and 0 or list2[1])

		if string.sub(v, k, k) ~= "h" or number.isNaN(v4[k]) then
			continue
		end

		local v6 = v4[k] / 180 * 3.141592653589793
		total += cos(v6) * list2[1]
		total2 += sin(v6) * list2[1]
	end

	local v6 = v3:alpha() * list2[1]

	for k, v7 in mapped do
		local v8 = v7:get(v)
		v6 += v7:alpha() * list2[k + 1]

		for k2 in v4 do
			if number.isNaN(v8[k2]) then
				continue
			end

			v5[k2] += list2[k + 1]

			if string.sub(v, k2, k2) == "h" then
				local v9 = v8[k2] / 180 * 3.141592653589793
				total += cos(v9) * list2[k + 1]
				total2 += sin(v9) * list2[k + 1]
			else
				v4[k2] += v8[k2] * list2[k + 1]
			end
		end
	end

	for k in v4 do
		if string.sub(v, k, k) == "h" then
			local v9 = atan2(total2 / v5[k], total / v5[k]) / 3.141592653589793 * 180

			while v9 < 0 do
				v9 += 360
			end

			while v9 >= 360 do
				v9 -= 360
			end

			v4[k] = v9
		else
			v4[k] /= v5[k]
		end
	end

	local v7 = v6 / count
	return Color.new(v4, v):alpha(v7 > 0.99999 and 1 or v7, true)
end

_average_lrgb = function(mapped, list)
	local v = #mapped
	local v2 = {
		0,
		0,
		0,
		0
	}

	for k, v3 in mapped do
		local v4 = list[k] / v
		local _rgb = v3._rgb
		v2[1] += pow(_rgb[1], 2) * v4
		v2[2] += pow(_rgb[2], 2) * v4
		v2[3] += pow(_rgb[3], 2) * v4
		v2[4] += _rgb[4] * v4
	end

	v2[1] = sqrt(v2[1])
	v2[2] = sqrt(v2[2])
	v2[3] = sqrt(v2[3])

	if v2[4] > 0.9999999 then
		v2[4] = 1
	end

	return Color.new(clip_rgb(v2))
end

return average