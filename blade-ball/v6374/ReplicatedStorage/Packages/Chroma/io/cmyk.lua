local Color = require(script.Parent.Parent:WaitForChild("Color"))
local chroma = require(script.Parent.Parent:WaitForChild("chroma"))
local input = require(script.Parent:WaitForChild("input"))
local rgb2cmyk = require(script:WaitForChild("rgb2cmyk"))
local utils = require(script.Parent.Parent:WaitForChild("utils"))
local unpack2 = utils.unpack

function Color:cmyk()
	return rgb2cmyk(self._rgb)
end

function chroma.cmyk(...)
	local v = table.pack(...)
	v[v.n + 1] = "cmyk"
	return Color.new(unpack(v, 1, v.n + 1))
end

local format = input.format
format.cmyk = require(script:WaitForChild("cmyk2rgb"))
table.insert(input.autodetect, {
	p = 29,
	test = function(...)
		local v = unpack2(table.pack(...), "cmyk")

		if type(v) == "table" and #v == 3 then
			return "cmyk"
		end

		return nil
	end
})
return nil