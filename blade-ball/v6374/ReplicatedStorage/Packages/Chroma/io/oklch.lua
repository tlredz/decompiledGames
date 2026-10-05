local Color = require(script.Parent.Parent:WaitForChild("Color"))
local chroma = require(script.Parent.Parent:WaitForChild("chroma"))
local input = require(script.Parent:WaitForChild("input"))
local rgb2oklch = require(script:WaitForChild("rgb2oklch"))
local utils = require(script.Parent.Parent:WaitForChild("utils"))
local unpack2 = utils.unpack

function Color:oklch()
	return rgb2oklch(self._rgb)
end

function chroma.oklch(...)
	local v = table.pack(...)
	v[v.n + 1] = "oklch"
	return Color.new(unpack(v, 1, v.n + 1))
end

local format = input.format
format.oklch = require(script:WaitForChild("oklch2rgb"))
table.insert(input.autodetect, {
	p = 37,
	test = function(...)
		local v = unpack2(table.pack(...), "oklch")

		if type(v) == "table" and #v == 3 then
			return "oklch"
		end

		return nil
	end
})
return nil