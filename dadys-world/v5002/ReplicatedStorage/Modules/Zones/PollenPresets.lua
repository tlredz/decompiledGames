local PollenPresets = {
	Presets = {
		SpringBreeze = {
			displayName = "Spring Breeze",
			trailColor = Color3.fromRGB(144, 238, 144)
		},
		GoldenDust = {
			displayName = "Golden Dust",
			trailColor = Color3.fromRGB(255, 215, 0)
		},
		ToxicSpore = {
			displayName = "Toxic Spore",
			trailColor = Color3.fromRGB(148, 0, 211)
		}
	}
}

function PollenPresets.Get(p)
	return PollenPresets.Presets[p] or PollenPresets.Presets.SpringBreeze
end

function PollenPresets.GetPresetNames()
	local result = {}

	for k in pairs(PollenPresets.Presets) do
		table.insert(result, k)
	end

	table.sort(result)
	return result
end

return PollenPresets