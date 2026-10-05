local parent = script.Parent.Parent.Parent
local PropertyStripBuilder = require(parent.PropertyStripBuilder)
return PropertyStripBuilder.Create({
	Type = "BeamBrightness",
	DisplayName = "Brightness",
	CanAutoCapture = true,
	Supports = function(beam)
		return beam:IsA("Beam")
	end,
	ValidateValue = function(value: number)
		if type(value) == "number" and value == value and value ~= 1e999 and value ~= -1e999 and not (value < 0) then
			return true, nil
		end

		return false, "BeamBrightness keyframes must contain a finite, non-negative number Value."
	end,
	Capture = function(p)
		return p.Brightness
	end,
	Interpolate = function(p: number, p2: number, p3: number)
		return p + (p2 - p) * p3
	end,
	Apply = function(self, brightness: number, _)
		self.Brightness = brightness
	end
})