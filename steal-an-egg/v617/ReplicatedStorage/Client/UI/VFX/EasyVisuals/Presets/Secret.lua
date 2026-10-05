local Layers = require(script.Parent.Parent.Layers)

local function secretOutline(data)
	local host = data.Host
	local v = Layers.Paint(host, {
		Palette = "Zebra",
		Rotation = 90,
		Drift = data.Drift
	})
	local v2, v3

	if Layers.AcceptsEdge(host) then
		v2 = Layers.Edge(host, data.Width)
		v3 = Layers.Paint(v2.outline, {
			Palette = "Zebra",
			StartPhase = 0.5,
			Rotation = 90,
			PhaseGoal = 0.5,
			Drift = data.Drift
		})
	end

	return Layers.Result({ v, v3, v2 })
end

return secretOutline