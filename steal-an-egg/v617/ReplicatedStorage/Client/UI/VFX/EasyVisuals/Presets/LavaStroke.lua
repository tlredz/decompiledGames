local Layers = require(script.Parent.Parent.Layers)

local function lavaOutline(data)
	local host = data.Host
	local v = Layers.Paint(host, {
		Palette = "Lava",
		Drift = data.Drift
	})
	local edge = Layers.Edge(host, data.Width)
	local v2 = { v, Layers.Paint(edge.outline, {
			Palette = "Lava",
			Drift = -data.Drift
		}), edge }
	return Layers.Result(v2)
end

return lavaOutline