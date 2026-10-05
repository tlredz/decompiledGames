local Utils = require(script.Parent.Utils)
local createBaseControl = Utils.CreateBaseControl
return {
	Color3 = function(color: Color3)
		return createBaseControl(
			"Color3",
			(Color3.new(math.clamp(color.R, 0, 1), math.clamp(color.G, 0, 1), (math.clamp(color.B, 0, 1))))
		)
	end
}