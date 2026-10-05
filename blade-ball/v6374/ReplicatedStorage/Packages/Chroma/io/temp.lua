local Color = require(script.Parent.Parent:WaitForChild("Color"))
local chroma = require(script.Parent.Parent:WaitForChild("chroma"))
local input = require(script.Parent:WaitForChild("input"))
local rgb2temperature = require(script:WaitForChild("rgb2temperature"))

function Color:temperature()
	return rgb2temperature(self._rgb)
end

Color.kelvin = Color.temperature
Color.temp = Color.kelvin

function chroma.temperature(...)
	local v = table.pack(...)
	v[v.n + 1] = "temp"
	return Color.new(unpack(v, 1, v.n + 1))
end

chroma.kelvin = chroma.temperature
chroma.temp = chroma.kelvin
local format = input.format
format.temperature = require(script:WaitForChild("temperature2rgb"))
input.format.kelvin = input.format.temperature
input.format.temp = input.format.kelvin
return nil