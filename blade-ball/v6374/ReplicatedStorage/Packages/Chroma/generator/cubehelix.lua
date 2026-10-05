require(script.Parent.Parent:WaitForChild("types"):WaitForChild("cubehelix-types"))
local chroma = require(script.Parent.Parent:WaitForChild("chroma"))
local utils = require(script.Parent.Parent:WaitForChild("utils"))
local clip_rgb = utils.clip_rgb
local TWOPI = utils.TWOPI
local pow = math.pow
local sin = math.sin
local cos = math.cos

local function cubehelix(p: number?, p2: number?, p3, p4: number?, p5)
	local v = p == nil and 300 or p
	local v2 = p2 == nil and -1.5 or p2
	local v3 = p3 == nil and 1 or p3
	local v4 = p4 == nil and 1 or p4
	local v5 = p5 == nil and { 0, 1 } or p5
	local v6 = 0
	local v7

	if type(v5) == "table" then
		v7 = v5[2] - v5[1]
	else
		v5 = { v5, v5 }
		v7 = 0
	end

	local function callF(_, p6: number)
		local v8 = TWOPI * ((v + 120) / 360 + v2 * p6)
		local v10 = pow(v5[1] + v7 * p6, v4)
		local v11

		if v6 == 0 then
			v11 = v3
		else
			v11 = v3[1] + p6 * v6
		end

		local v12 = v11 * v10 * (1 - v10) / 2
		local v13 = cos(v8)
		local v14 = sin(v8)
		local v15 = v10 + v12 * (v13 * -0.14861 + v14 * 1.78277)
		local v16 = v10 + v12 * (v13 * -0.29227 - v14 * 0.90649)
		local v17 = v10 + v12 * (v13 * 1.97294)
		return chroma(clip_rgb({
			v15 * 255,
			v16 * 255,
			v17 * 255,
			1
		}))
	end

	local object = setmetatable({}, {
		__call = callF
	})

	function object.start(p6: number?)
		if p6 == nil then
			return v
		end

		v = p6
		return object
	end

	function object.rotations(p6: number?)
		if p6 == nil then
			return v2
		end

		v2 = p6
		return object
	end

	function object.gamma(p6: number?)
		if p6 == nil then
			return v4
		end

		v4 = p6
		return object
	end

	function object.hue(p6)
		if p6 == nil then
			return v3
		end

		v3 = p6

		if type(v3) == "table" then
			v6 = v3[2] - v3[1]

			if v6 == 0 then
				v3 = v3[2]
			end
		else
			v6 = 0
		end

		return object
	end

	function object.lightness(list)
		if list == nil then
			return v5
		end

		if type(list) == "table" then
			v5 = list
			v7 = list[2] - list[1]
		else
			v5 = { list, list }
			v7 = 0
		end

		return object
	end

	function object.scale()
		return chroma.scale(object)
	end

	object.hue(v3)
	return object
end

return cubehelix