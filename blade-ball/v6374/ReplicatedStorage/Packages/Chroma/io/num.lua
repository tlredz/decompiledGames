local Color = require(script.Parent.Parent:WaitForChild("Color"))
local chroma = require(script.Parent.Parent:WaitForChild("chroma"))
local input = require(script.Parent:WaitForChild("input"))
local rgb2num = require(script:WaitForChild("rgb2num"))

function Color:num()
	return rgb2num(self._rgb)
end

function chroma.num(...)
	local v = table.pack(...)
	v[v.n + 1] = "num"
	return Color.new(unpack(v, 1, v.n + 1))
end

local format = input.format
format.num = require(script:WaitForChild("num2rgb"))
table.insert(input.autodetect, {
	p = 57,
	test = function(...)
		local v = table.pack(...)

		if v.n == 1 and type(v[1]) == "number" and v[1] >= 0 and v[1] <= 16777215 then
			return "num"
		end

		return nil
	end
})
return nil