local Layers = require(script.Parent.Parent.Layers)

local function rainbowWash(p)
	local v = { (Layers.Paint(p.Host, {
			Palette = "Rainbow",
			Rotation = 0,
			Drift = p.Drift
		})) }
	return Layers.Result(v)
end

return rainbowWash