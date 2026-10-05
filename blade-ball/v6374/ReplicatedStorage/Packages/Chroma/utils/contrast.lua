local Color = require(script.Parent.Parent:WaitForChild("Color"))
require(script.Parent.Parent:WaitForChild("ops"):WaitForChild("luminance"))

local function contrast(p, p2)
	local v = Color.new(p)
	local v2 = Color.new(p2)
	local luminance = v:luminance()
	local luminance2 = v2:luminance()

	if luminance2 < luminance then
		return (luminance + 0.05) / (luminance2 + 0.05)
	end

	return (luminance2 + 0.05) / (luminance + 0.05)
end

return contrast