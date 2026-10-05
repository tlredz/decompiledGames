local Color = require(script.Parent.Parent:WaitForChild("Color"))
local chroma = require(script.Parent.Parent:WaitForChild("chroma"))
local input = require(script.Parent:WaitForChild("input"))
local rgb2lab = require(script:WaitForChild("rgb2lab"))
local utils = require(script.Parent.Parent:WaitForChild("utils"))
local unpack2 = utils.unpack

function Color:lab()
	return rgb2lab(self._rgb)
end

function chroma.lab(...)
	local v = table.pack(...)
	v[v.n + 1] = "lab"
	return Color.new(unpack(v, 1, v.n + 1))
end

local format = input.format
format.lab = require(script:WaitForChild("lab2rgb"))
table.insert(input.autodetect, {
	p = 25,
	test = function(...)
		local v = unpack2(table.pack(...), "lab")

		if type(v) == "table" and #v == 3 then
			return "lab"
		end

		return nil
	end
})
return nil