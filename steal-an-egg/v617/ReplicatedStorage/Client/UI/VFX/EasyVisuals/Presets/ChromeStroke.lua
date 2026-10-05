local Layers = require(script.Parent.Parent.Layers)

local function chromeOutline(data)
	local host = data.Host
	local v = Layers.Paint(host, {
		Palette = "Chrome",
		Rotation = -90,
		Drift = data.Drift
	})
	local v2, v3

	if Layers.AcceptsEdge(host) then
		v2 = Layers.Edge(host, data.Width)
		v3 = Layers.Paint(v2.outline, {
			Palette = "Chrome",
			Rotation = -89,
			Drift = data.Drift * 0.58
		})
	end

	return Layers.Result({ v, v3, v2 })
end

return chromeOutline