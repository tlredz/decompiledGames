local Layers = require(script.Parent.Parent.Layers)

local function ghostOutline(data)
	local host = data.Host
	local alphaStops = Layers.AlphaStops("Ghost")
	local v = Layers.Paint(host, {
		Palette = "Ghost",
		Alpha = alphaStops,
		Drift = data.Drift,
		AlphaDrift = data.Drift * 0.9
	})
	local edge = Layers.Edge(host, data.Width)
	local v2 = { v, Layers.Paint(edge.outline, {
			Palette = "Ghost",
			Alpha = alphaStops,
			Drift = -data.Drift * 0.9,
			AlphaDrift = -data.Drift * 0.9
		}), edge }
	return Layers.Result(v2)
end

return ghostOutline