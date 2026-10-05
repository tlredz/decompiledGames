local Layers = require(script.Parent.Parent.Layers)

local function shineOutlineSpin(data)
	local host = data.Host
	local color = data.Color or Layers.HostColor(host)
	local edge = Layers.Edge(host, data.Width)
	local v = Layers.Paint(edge.outline, {
		Palette = Layers.ShinePalette(color, 0.6)
	})
	local v2 = { (Layers.Turn(v, edge.outline, 0.75, data.Drift)) }
	return Layers.Result({ v, edge }, v2)
end

return shineOutlineSpin