local Color = require(script.Parent.Parent:WaitForChild("Color"))
local chroma = require(script.Parent.Parent:WaitForChild("chroma"))
local input = require(script.Parent:WaitForChild("input"))
local rgb2hex = require(script:WaitForChild("rgb2hex"))

function Color:hex(p2: string?)
	return rgb2hex(self._rgb, p2)
end

function chroma.hex(...)
	local v = table.pack(...)
	v[v.n + 1] = "hex"
	return Color.new(unpack(v, 1, v.n + 1))
end

local format = input.format
format.hex = require(script:WaitForChild("hex2rgb"))
table.insert(input.autodetect, {
	p = 49,
	test = function(value, ...)
		if table.pack(...).n == 0 and type(value) == "string" and #value >= 3 and #value <= 9 then
			return "hex"
		end

		return nil
	end
})
return nil