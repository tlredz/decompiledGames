require(script.Parent.Parent:WaitForChild("io"):WaitForChild("lch"))
local Color = require(script.Parent.Parent:WaitForChild("Color"))
local labconstants = require(script.Parent.Parent:WaitForChild("io"):WaitForChild("lab"):WaitForChild("lab-constants"))

function Color:saturate(value: number?)
	local lch = self:lch()
	lch[2] += labconstants.Kn * (value or 1)

	if lch[2] < 0 then
		lch[2] = 0
	end

	return Color.new(lch, "lch"):alpha(self:alpha(), true)
end

function Color:desaturate(value: number?)
	return self:saturate(-(value or 1))
end

return nil