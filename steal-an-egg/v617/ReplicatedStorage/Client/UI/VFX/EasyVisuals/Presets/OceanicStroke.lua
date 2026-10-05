local Layers = require(script.Parent.Parent.Layers)

local function oceanicOutline(data)
	local host = data.Host
	local v = Layers.Paint(host, {
		Palette = "Oceanic",
		Rotation = -75,
		Spin = 0.1,
		Drift = data.Drift
	})
	local edge = Layers.Edge(host, data.Width)
	local v2 = { v, Layers.Paint(edge.outline, {
			Palette = "Oceanic",
			Drift = -data.Drift
		}), edge }
	return Layers.Result(v2)
end

return oceanicOutline