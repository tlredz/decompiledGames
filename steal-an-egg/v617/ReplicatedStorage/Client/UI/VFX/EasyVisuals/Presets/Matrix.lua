local Layers = require(script.Parent.Parent.Layers)

local function matrixOutline(data)
	local host = data.Host
	local v = Layers.Paint(host, {
		Palette = "Matrix",
		Rotation = 90,
		Drift = data.Drift
	})
	local edge = Layers.Edge(host, data.Width)
	local v2 = Layers.Paint(edge.outline, {
		Palette = "Matrix",
		Rotation = 90,
		PhaseGoal = 0.5
	})
	task.delay(0.1, function()
		v2:Drift(data.Drift, 1)
	end)
	return Layers.Result({ v, v2, edge })
end

return matrixOutline