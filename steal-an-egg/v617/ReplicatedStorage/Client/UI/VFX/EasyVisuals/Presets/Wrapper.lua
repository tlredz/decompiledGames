local Layers = require(script.Parent.Parent.Layers)

local function wrapperWash(data)
	local v = Layers.Paint(data.Host, {
		Palette = data.Color,
		Drift = data.Drift
	})
	Layers.Replay(v, data.Chain)
	return Layers.Result({ v })
end

return wrapperWash