local Layers = require(script.Parent.Parent.Layers)

local function iceOutline(data)
	local host = data.Host
	local v = Layers.Paint(host, {
		Palette = "Ice",
		Rotation = -65,
		Drift = data.Drift
	})
	local edge = Layers.Edge(host, data.Width)
	local v2 = { v, Layers.Paint(edge.outline, {
			Palette = "Ice",
			Rotation = -61,
			Drift = data.Drift * 0.23
		}), edge }
	return Layers.Result(v2)
end

return iceOutline