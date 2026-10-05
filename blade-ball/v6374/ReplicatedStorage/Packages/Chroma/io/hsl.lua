local Color = require(script.Parent.Parent:WaitForChild("Color"))
local chroma = require(script.Parent.Parent:WaitForChild("chroma"))
local input = require(script.Parent:WaitForChild("input"))
local rgb2hsl = require(script:WaitForChild("rgb2hsl"))
local utils = require(script.Parent.Parent:WaitForChild("utils"))
local unpack2 = utils.unpack

function Color:hsl()
	return rgb2hsl(self._rgb)
end

function chroma.hsl(...)
	local v = table.pack(...)
	v[v.n + 1] = "hsl"
	return Color.new(unpack(v, 1, v.n + 1))
end

local format = input.format
format.hsl = require(script:WaitForChild("hsl2rgb"))
table.insert(input.autodetect, {
	p = 27,
	test = function(...)
		local v = unpack2(table.pack(...), "hsl")

		if type(v) == "table" and #v == 3 then
			return "hsl"
		end

		return nil
	end
})
return nil