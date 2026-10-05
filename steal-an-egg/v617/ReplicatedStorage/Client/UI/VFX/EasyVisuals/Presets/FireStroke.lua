local Layers = require(script.Parent.Parent.Layers)

local function fireOutline(data)
	local host = data.Host
	local v = Layers.Paint(host, {
		Palette = "Fire",
		Rotation = -75,
		Drift = data.Drift
	})
	local turn = Layers.Turn(v, v.gradient, 0, data.Drift)
	local edge = Layers.Edge(host, data.Width)
	local v2 = { v, Layers.Paint(edge.outline, {
			Palette = "Fire",
			Rotation = 75,
			Drift = -data.Drift
		}), edge }
	return Layers.Result(v2, { turn })
end

return fireOutline