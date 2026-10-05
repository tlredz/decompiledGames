local parent = script.Parent.Parent.Parent
local PropertyStripBuilder = require(parent.PropertyStripBuilder)
return PropertyStripBuilder.Create({
	Type = "BeamEnabled",
	DisplayName = "Enabled",
	CanAutoCapture = true,
	Supports = function(beam)
		return beam:IsA("Beam")
	end,
	ValidateValue = function(flag: boolean)
		if type(flag) == "boolean" then
			return true, nil
		end

		return false, "BeamEnabled keyframes must contain a boolean Value."
	end,
	Capture = function(p)
		return p.Enabled
	end,
	Interpolate = function(flag: boolean, flag2: boolean, p: number)
		if p < 1 then
			return flag
		end

		return flag2
	end,
	Apply = function(p, enabled: boolean, _)
		p.Enabled = enabled
	end
})