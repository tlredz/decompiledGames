local Layers = require(script.Parent.Parent.Layers)

local function cleanGoldWash(p)
	local v = { (Layers.Paint(p.Host, {
			Palette = "CleanGold",
			Rotation = 45,
			Drift = p.Drift
		})) }
	return Layers.Result(v)
end

return cleanGoldWash