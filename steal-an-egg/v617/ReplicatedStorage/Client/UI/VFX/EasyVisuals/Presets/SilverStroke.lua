local Layers = require(script.Parent.Parent.Layers)

local function silverOutline(data)
	local host = data.Host
	local v = Layers.Paint(host, {
		Palette = "Silver",
		Rotation = -80,
		Drift = data.Drift
	})
	local edge = Layers.Edge(host, data.Width)
	local v2 = { v, Layers.Paint(edge.outline, {
			Palette = "Silver",
			Rotation = -79,
			Drift = data.Drift * 0.56
		}), edge }
	return Layers.Result(v2)
end

return silverOutline