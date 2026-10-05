require(script.Parent.Parent:WaitForChild("io"):WaitForChild("lab"))
local Color = require(script.Parent.Parent:WaitForChild("Color"))
local labconstants = require(script.Parent.Parent:WaitForChild("io"):WaitForChild("lab"):WaitForChild("lab-constants"))

function Color:darken(value: number?)
	local lab = self:lab()
	lab[1] -= labconstants.Kn * (value or 1)
	return Color.new(lab, "lab"):alpha(self:alpha(), true)
end

function Color:brighten(value: number?)
	return self:darken(-(value or 1))
end

Color.darker = Color.darken
Color.brighter = Color.brighten
return nil