local Color = require(script.Parent.Parent:WaitForChild("Color"))
local hex2rgb = require(script.Parent:WaitForChild("hex"):WaitForChild("hex2rgb"))
local input = require(script.Parent:WaitForChild("input"))
local rgb2hex = require(script.Parent:WaitForChild("hex"):WaitForChild("rgb2hex"))
local w3cx11 = require(script.Parent.Parent:WaitForChild("colors"):WaitForChild("w3cx11"))

function Color:name()
	local v = rgb2hex(self._rgb, "rgb")

	for k, v2 in w3cx11 do
		if v2 == v then
			return string.lower(k)
		end
	end

	return v
end

function input.format.named(value: string)
	local v = string.lower(value)

	if w3cx11[v] then
		return hex2rgb(w3cx11[v])
	end

	error((`unknown color name: {v}`))
end

table.insert(input.autodetect, {
	p = 58,
	test = function(value, ...)
		if select("#", ...) == 0 and type(value) == "string" and w3cx11[string.lower(value)] then
			return "named"
		end

		return nil
	end
})
return nil