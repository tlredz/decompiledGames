local Color = require(script.Parent.Parent:WaitForChild("Color"))
require(script.Parent.Parent:WaitForChild("types"):WaitForChild("interpolation-mode"))
local interpolator = require(script.Parent.Parent:WaitForChild("interpolator"))

local function mix(p, p2, p3: number?, p4)
	local v = p3 == nil and 0.5 or p3
	local v2 = (p4 == nil or p4 == "") and "lrgb" or p4

	if not interpolator[v2] then
		error((`interpolation mode {v2} is not defined`))
	end

	local v3 = Color.new(p)
	local v4 = Color.new(p2)
	local alpha = v3:alpha()
	return interpolator[v2](v3, v4, v):alpha(alpha + v * (v4:alpha() - alpha))
end

return mix