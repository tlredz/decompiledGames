local Layers = require(script.Parent.Parent.Layers)

local function silverWash(p)
	local v = { (Layers.Paint(p.Host, {
			Palette = "Silver",
			Rotation = -75,
			Drift = p.Drift
		})) }
	return Layers.Result(v)
end

return silverWash