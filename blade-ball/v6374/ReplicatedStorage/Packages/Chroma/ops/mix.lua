local Color = require(script.Parent.Parent:WaitForChild("Color"))
require(script.Parent.Parent:WaitForChild("types"):WaitForChild("interpolation-mode"))
local mix = require(script.Parent.Parent:WaitForChild("generator"):WaitForChild("mix"))

function Color.interpolate(p, p2, value: number?, p3)
	return mix(p, p2, value or 0.5, p3)
end

Color.mix = Color.interpolate
return nil