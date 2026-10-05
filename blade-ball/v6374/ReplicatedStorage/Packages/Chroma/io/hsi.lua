local Color = require(script.Parent.Parent:WaitForChild("Color"))
local chroma = require(script.Parent.Parent:WaitForChild("chroma"))
local input = require(script.Parent:WaitForChild("input"))
local rgb2hsi = require(script:WaitForChild("rgb2hsi"))
local utils = require(script.Parent.Parent:WaitForChild("utils"))
local unpack2 = utils.unpack

function Color:hsi()
	return rgb2hsi(self._rgb)
end

function chroma.hsi(...)
	local v = table.pack(...)
	v[v.n + 1] = "hsi"
	return Color.new(unpack(v, 1, v.n + 1))
end

local format = input.format
format.hsi = require(script:WaitForChild("hsi2rgb"))
table.insert(input.autodetect, {
	p = 28,
	test = function(...)
		local v = unpack2(table.pack(...), "hsi")

		if type(v) == "table" and #v == 3 then
			return "hsi"
		end

		return nil
	end
})
return nil