local Layers = require(script.Parent.Parent.Layers)

local function bubblegumOutline(data)
	local host = data.Host
	local v = Layers.Paint(host, {
		Palette = "Bubblegum",
		Rotation = -90,
		Drift = data.Drift
	})
	local edge = Layers.Edge(host, data.Width)
	local v2 = Layers.Paint(edge.outline, {
		Palette = "Bubblegum",
		Rotation = -45,
		Drift = data.Drift * 0.9
	})
	local v3 = { (Layers.Breathe(edge, data.Width, data.Width * 3, data.Drift, 0.055)) }
	return Layers.Result({ v, v2, edge }, v3)
end

return bubblegumOutline