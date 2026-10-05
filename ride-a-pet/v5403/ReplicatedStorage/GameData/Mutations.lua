local Mutations = {
	Shocked = {
		WeatherName = "Thunder",
		StatMultiplier = 100,
		Gradient = { Color3.fromRGB(121, 190, 255), Color3.fromRGB(93, 131, 255) }
	},
	Volted = {
		WeatherName = "Volt",
		StatMultiplier = 200,
		Gradient = { Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 255, 127) }
	},
	Rage = {
		WeatherName = "Raging",
		StatMultiplier = 300,
		Gradient = { Color3.fromRGB(255, 106, 108), Color3.fromRGB(255, 47, 50) }
	},
	Void = {
		WeatherName = "Dreadful",
		StatMultiplier = 600,
		Gradient = { Color3.fromRGB(107, 58, 255), Color3.fromRGB(57, 28, 112) }
	},
	Eternal = {
		WeatherName = "Eternal",
		StatMultiplier = 1150,
		Gradient = { Color3.fromRGB(255, 158, 224), Color3.fromRGB(255, 77, 184), Color3.fromRGB(255, 20, 147) }
	},
	Magma = {
		Source = "Volcano",
		StatMultiplier = 900,
		Gradient = { Color3.fromRGB(255, 170, 0), Color3.fromRGB(255, 60, 0), Color3.fromRGB(120, 20, 0) }
	},
	Gold = {
		Chance = 10,
		StatMultiplier = 100,
		Gradient = { Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 170, 0) }
	},
	Diamond = {
		Chance = 1.333,
		StatMultiplier = 600,
		Gradient = { Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 170, 255) },
		HighlightFillColor = Color3.fromRGB(0, 170, 255),
		HighlightFillTransparency = 0.4
	},
	Rainbow = {
		Chance = 0.4,
		StatMultiplier = 1400,
		Gradient = { Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 255) }
	}
}

function Mutations.FactorFor(p)
	local v = p and Mutations[p]

	if type(v) == "table" then
		return 1 + (tonumber(v.StatMultiplier) or 0) / 100
	end

	return 1
end

function Mutations.ForWeather(p)
	for k, v in Mutations do
		if type(v) == "table" and v.WeatherName == p then
			return k
		end
	end

	return nil
end

function Mutations.FormatFactor(p)
	return string.format("%.10g", Mutations.FactorFor(p))
end

function Mutations.GradientFor(p)
	local v = p and Mutations[p]
	local gradient

	if type(v) == "table" then
		gradient = v.Gradient
	else
		gradient = false
	end

	if type(gradient) ~= "table" or #gradient == 0 then
		return nil
	end

	if #gradient == 1 then
		return ColorSequence.new(gradient[1])
	end

	local colorSequenceKeypoints = {}

	for k, v2 in gradient do
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new((k - 1) / (#gradient - 1), v2))
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

function Mutations.ColorFor(p)
	local v = p and Mutations[p]
	local gradient

	if type(v) == "table" then
		gradient = v.Gradient
	else
		gradient = false
	end

	if type(gradient) == "table" and #gradient ~= 0 then
		return gradient[1]
	end

	return nil
end

function Mutations.HexFor(p)
	local colorFor = Mutations.ColorFor(p)

	if colorFor then
		return string.format("#%02X%02X%02X", colorFor.R * 255, colorFor.G * 255, colorFor.B * 255)
	end

	return nil
end

function Mutations.IsSpawned(p)
	local v = p and Mutations[p]
	return type(v) == "table" and v.Chance ~= nil and v.WeatherName == nil
end

function Mutations.RollSpawned(object, p)
	local v = math.max(tonumber(p) or 1, 1)
	local v2 = {}

	for k, v3 in Mutations do
		if type(v3) == "table" and v3.Chance ~= nil and v3.WeatherName == nil then
			table.insert(v2, {
				Name = k,
				Chance = tonumber(v3.Chance) or 0
			})
		end
	end

	table.sort(v2, function(a, b)
		return a.Chance < b.Chance
	end)

	for _, v3 in v2 do
		local v4 = math.min(v3.Chance * v, 100)
		local v5

		if object then
			v5 = object:NextNumber() * 100
		else
			v5 = math.random() * 100
		end

		if v5 < v4 then
			return v3.Name
		end
	end

	return nil
end

Mutations.EventAttribute = "HatchMutationEventMultiplier"
Mutations.EventUntilAttribute = "HatchMutationEventUntil"

function Mutations.EventMultiplier()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local attribute = tonumber(ReplicatedStorage:GetAttribute(Mutations.EventAttribute))

	if attribute and not (attribute <= 1) then
		return attribute
	end

	return 1
end

function Mutations.CombinedFactor(p, p2)
	return Mutations.FactorFor(p) * Mutations.FactorFor(p2)
end

function Mutations.LabelFor(p, p2)
	local v = {}

	if p2 and Mutations[p2] then
		table.insert(v, "[" .. p2 .. "]")
	end

	if p and Mutations[p] then
		table.insert(v, "[" .. p .. "]")
	end

	return table.concat(v, " + ")
end

function Mutations.RichLabelFor(p, p2)
	local v = {}

	for _, v2 in { p2, p } do
		if not (v2 and Mutations[v2]) then
			continue
		end

		local hexFor = Mutations.HexFor(v2)
		local v3 = "[" .. v2 .. "]"

		if hexFor then
			v3 = string.format("<font color=\"%s\">%s</font>", hexFor, v3) or v3
		end

		table.insert(v, v3)
	end

	return table.concat(v, " + ")
end

return Mutations