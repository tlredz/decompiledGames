local Layers = require(script.Parent.Parent.Layers)

local function deathOutline(data)
	local host = data.Host
	local v = Layers.Paint(host, {
		Palette = "Death",
		Rotation = -90,
		Drift = data.Drift
	})
	local edge = Layers.Edge(host, data.Width)
	local v2 = { v, Layers.Paint(edge.outline, {
			Palette = "Death",
			Rotation = -85,
			Drift = -data.Drift - 0.001
		}), edge }
	return Layers.Result(v2)
end

return deathOutline