local ControlConversion = require(script.Parent.ControlConversion)
local ControlUtils = {}

function ControlUtils.ControlGroup(controls)
	return {
		EntryType = "ControlGroup",
		Controls = controls
	}
end

function ControlUtils.Ordered(p, order: number)
	local convertControl = ControlConversion.ConvertControl(p)
	convertControl.Order = order
	return convertControl
end

return ControlUtils