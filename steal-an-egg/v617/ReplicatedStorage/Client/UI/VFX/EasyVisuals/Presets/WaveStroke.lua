local Layers = require(script.Parent.Parent.Layers)

local function bandAlpha(list)
	local numberSequenceKeypoints = table.create(#list)

	for k, v in list do
		numberSequenceKeypoints[k] = NumberSequenceKeypoint.new(v[1], v[2])
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local alpha = bandAlpha({
	{ 0, 0 },
	{ 0.25, 1 },
	{ 0.5, 1 },
	{ 0.75, 1 },
	{ 1, 0 }
})

local function waveOutline(data)
	local color = data.Color
	local edge = Layers.Edge(data.Host, data.Width)
	local v2 = { Layers.Paint(edge.outline, {
			Palette = Layers.FlatPalette(color),
			Alpha = alpha,
			Drift = data.Drift,
			AlphaDrift = data.Drift * 0.9
		}), edge }
	return Layers.Result(v2)
end

return waveOutline