local Layers = require(script.Parent.Parent.Layers)

local function shineWash(data)
	local host = data.Host
	local color = data.Color or Layers.HostColor(host)
	local v = { (Layers.Paint(host, {
			Palette = Layers.ShinePalette(color, 0.417505),
			Rotation = 60,
			Drift = data.Drift * 0.6
		})) }
	return Layers.Result(v)
end

return shineWash