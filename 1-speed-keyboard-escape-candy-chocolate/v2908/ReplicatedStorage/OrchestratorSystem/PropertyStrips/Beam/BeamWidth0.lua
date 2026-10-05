local parent = script.Parent.Parent.Parent
local PropertyStripBuilder = require(parent.PropertyStripBuilder)
return PropertyStripBuilder.Create({
	Type = "BeamWidth0",
	DisplayName = "Width0",
	CanAutoCapture = true,
	Supports = function(beam)
		return beam:IsA("Beam")
	end,
	ValidateValue = function(value: number)
		if type(value) == "number" and value == value and value ~= 1e999 and value ~= -1e999 and not (value < 0) then
			return true, nil
		end

		return false, "BeamWidth0 keyframes must contain a finite, non-negative number Value."
	end,
	Capture = function(p)
		return p.Width0
	end,
	Interpolate = function(p: number, p2: number, p3: number)
		return p + (p2 - p) * p3
	end,
	Apply = function(self, width: number, _)
		self.Width0 = width
	end
})