local Layers = require(script.Parent.Parent.Layers)

local function greenOutlineSpin(data)
	local edge = Layers.Edge(data.Host, data.Width)
	local v = Layers.Paint(edge.outline, {
		Palette = "Green",
		Alpha = Layers.AlphaStops("Green")
	})
	local v2 = { (Layers.Turn(v, edge.outline, 5, data.Drift)) }
	return Layers.Result({ v, edge }, v2)
end

return greenOutlineSpin