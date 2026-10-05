local Layers = require(script.Parent.Parent.Layers)

local function goldWash(p)
	local v = { (Layers.Paint(p.Host, {
			Palette = "Gold",
			Rotation = -75,
			Drift = p.Drift
		})) }
	return Layers.Result(v)
end

return goldWash