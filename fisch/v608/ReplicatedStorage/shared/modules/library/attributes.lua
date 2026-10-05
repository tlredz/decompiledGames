local byName = {
	Glitched = {
		Name = "Glitched",
		Type = "Independent",
		DisplayOrder = 1,
		PriceMultiply = 0,
		Color = Color3.fromRGB(35, 113, 32),
		Bold = true
	},
	Shiny = {
		Name = "Shiny",
		Type = "Independent",
		DisplayOrder = 2,
		PriceMultiply = 1.85,
		Color = Color3.fromRGB(255, 240, 188),
		Italic = true
	},
	Sparkling = {
		Name = "Sparkling",
		Type = "Independent",
		DisplayOrder = 3,
		PriceMultiply = 1.85,
		Color = Color3.fromRGB(255, 240, 188),
		Italic = true
	},
	Giant = {
		Name = "Giant",
		Type = "WeightClass",
		DisplayOrder = 101,
		Color = Color3.fromRGB(139, 255, 137),
		WeightRequirement = 1.99
	},
	Big = {
		Name = "Big",
		Type = "WeightClass",
		DisplayOrder = 102,
		Color = Color3.fromRGB(139, 255, 137),
		WeightRequirement = 1
	},
	Tiny = {
		Name = "Tiny",
		Type = "WeightClass",
		DisplayOrder = 103,
		Color = Color3.fromRGB(110, 158, 155),
		WeightRequirement = 0.5
	},
	Small = {
		Name = "Small",
		Type = "WeightClass",
		DisplayOrder = 104,
		Color = Color3.fromRGB(147, 213, 186),
		WeightRequirement = 0.99
	}
}
local ordered = {}
local weightClasses = {}

for _, v4 in byName do
	table.insert(ordered, v4)

	if v4.Type == "WeightClass" then
		table.insert(weightClasses, v4)
	end
end

table.sort(weightClasses, function(a, b)
	return (a.WeightRequirement < 1 and 1 / a.WeightRequirement or a.WeightRequirement) > (b.WeightRequirement < 1 and 1 / b.WeightRequirement or b.WeightRequirement)
end)
table.sort(ordered, function(a, b)
	return a.DisplayOrder < b.DisplayOrder
end)
return {
	byName = byName,
	weightClasses = weightClasses,
	ordered = ordered
}