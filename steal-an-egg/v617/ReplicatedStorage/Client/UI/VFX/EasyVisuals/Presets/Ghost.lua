local Layers = require(script.Parent.Parent.Layers)

local function ghostWash(p)
	local v = { (Layers.Paint(p.Host, {
			Palette = "Ghost",
			Alpha = Layers.AlphaStops("Ghost"),
			Drift = p.Drift,
			AlphaDrift = p.Drift * 0.9
		})) }
	return Layers.Result(v)
end

return ghostWash