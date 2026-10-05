local Layers = require(script.Parent.Parent.Layers)

local function rainbowOutlineDrift(data)
	local edge = Layers.Edge(data.Host, data.Width)
	local v = { Layers.Paint(edge.outline, {
			Palette = "Rainbow",
			Drift = -data.Drift
		}), edge }
	return Layers.Result(v)
end

return rainbowOutlineDrift