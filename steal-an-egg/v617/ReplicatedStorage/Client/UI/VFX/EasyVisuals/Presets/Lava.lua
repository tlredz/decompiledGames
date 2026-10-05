local Layers = require(script.Parent.Parent.Layers)

local function lavaWash(p)
	local v = { (Layers.Paint(p.Host, {
			Palette = "Lava",
			Drift = p.Drift
		})) }
	return Layers.Result(v)
end

return lavaWash