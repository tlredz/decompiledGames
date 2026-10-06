local v = {
	Default = Color3.new(1, 1, 1),
	TextLighten = 0.35,
	List = {
		Blizzard = Color3.fromRGB(95, 216, 255),
		Clear = Color3.fromRGB(174, 183, 189),
		Cloudy = Color3.fromRGB(138, 169, 207),
		Rain = Color3.fromRGB(60, 140, 255),
		Heatwave = Color3.fromRGB(255, 138, 43),
		["Toxic Fog"] = Color3.fromRGB(139, 224, 58),
		Aurora = Color3.fromRGB(61, 242, 176),
		Eclipse = Color3.fromRGB(157, 77, 255),
		Thunderstorm = Color3.fromRGB(255, 226, 52),
		["Meteor Shower"] = Color3.fromRGB(255, 90, 60)
	}
}

function v.GetAccent(p: string?)
	return p and v.List[p] or v.Default
end

function v.GetTextColor(p: string?)
	return v.GetAccent(p):Lerp(v.Default, v.TextLighten)
end

return table.freeze(v)