local Color = require(script.Parent.Parent:WaitForChild("Color"))
local chroma = require(script.Parent.Parent:WaitForChild("chroma"))
local input = require(script.Parent:WaitForChild("input"))
local rgb2hsv = require(script:WaitForChild("rgb2hsv"))
local utils = require(script.Parent.Parent:WaitForChild("utils"))
local unpack2 = utils.unpack

function Color:hsv()
	return rgb2hsv(self._rgb)
end

function chroma.hsv(...)
	local v = table.pack(...)
	v[v.n + 1] = "hsv"
	return Color.new(unpack(v, 1, v.n + 1))
end

local format = input.format
format.hsv = require(script:WaitForChild("hsv2rgb"))
table.insert(input.autodetect, {
	p = 26,
	test = function(...)
		local v = unpack2(table.pack(...), "hsv")

		if type(v) == "table" and #v == 3 then
			return "hsv"
		end

		return nil
	end
})
return nil