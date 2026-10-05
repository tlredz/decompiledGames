local Weather = {
	StormRarity = {
		Thunder = 57,
		Volt = 28,
		Raging = 8,
		Dreadful = 5,
		Eternal = 2
	},
	Data = {
		Thunder = {
			Chance = 57,
			Description = "Grants Shocked Mutation to anything struck in the map",
			Image = "rbxassetid://98568328401151"
		},
		Volt = {
			Chance = 28,
			Description = "Grants Volted Mutation to anything struck in the map",
			Image = "rbxassetid://71614338203577"
		},
		Raging = {
			Chance = 8,
			Description = "Grants Rage Mutation to anything struck in the map",
			Image = "rbxassetid://92486396774171"
		},
		Dreadful = {
			Chance = 5,
			Description = "Grants Void Mutation to anything struck in the map",
			Image = "rbxassetid://74893357658449"
		},
		Eternal = {
			Chance = 2,
			Description = "Grants Eternal Mutation to anything struck in the map",
			Image = "rbxassetid://101112331351795"
		},
		Gigantuar = {
			Chance = 0,
			Description = "Eggs in the map are big some even bigger",
			Image = "rbxassetid://125923740441546",
			Gradient = { Color3.fromRGB(255, 158, 56), Color3.fromRGB(184, 104, 40), Color3.fromRGB(88, 52, 22) },
			GradientRotation = 90
		},
		Lucky = {
			Chance = 0,
			Description = "Increased Hatch Luck on every egg hatched",
			Image = "rbxassetid://90006632943385",
			LuckMultiplier = 1.1,
			Headline = "Increased Hatch Luck Has Begun",
			EndHeadline = "Increased Hatch Luck Has Ended",
			Gradient = { Color3.fromRGB(255, 226, 92), Color3.fromRGB(255, 190, 40), Color3.fromRGB(70, 190, 90) },
			GradientRotation = 90
		},
		MutationMadness = {
			Chance = 0,
			Description = "x2 Hatch Mutation odds (Gold, Diamond & Rainbow)",
			Image = "rbxassetid://80215125269214",
			MutationMultiplier = 2,
			Headline = "Mutation Madness Has Begun",
			EndHeadline = "Mutation Madness Has Ended",
			Gradient = { Color3.fromRGB(255, 215, 0), Color3.fromRGB(0, 220, 255), Color3.fromRGB(255, 80, 200) },
			GradientRotation = 90
		}
	}
}

function Weather.LuckMultiplierFor(value)
	if type(value) ~= "string" then
		return 1
	end

	local v = Weather.Data[value]

	if type(v) ~= "table" then
		return 1
	end

	local luckMultiplier = tonumber(v.LuckMultiplier)

	if luckMultiplier and not (luckMultiplier <= 1) then
		return (math.min(luckMultiplier, 2))
	end

	return 1
end

function Weather.MutationMultiplierFor(value)
	if type(value) ~= "string" then
		return 1
	end

	local v = Weather.Data[value]

	if type(v) ~= "table" then
		return 1
	end

	local mutationMultiplier = tonumber(v.MutationMultiplier)

	if mutationMultiplier and not (mutationMultiplier <= 1) then
		return (math.min(mutationMultiplier, 10))
	end

	return 1
end

function Weather.HeadlineFor(value, p)
	if type(value) ~= "string" then
		return nil
	end

	local v = Weather.Data[value]

	if type(v) ~= "table" then
		return nil
	end

	local endHeadline

	if p then
		endHeadline = v.EndHeadline
	else
		endHeadline = v.Headline
	end

	if type(endHeadline) == "string" and endHeadline ~= "" then
		return endHeadline
	end

	return nil
end

function Weather.GradientFor(value)
	local v

	if type(value) == "string" then
		v = Weather.Data and Weather.Data[value]
	else
		v = false
	end

	local gradient

	if type(v) == "table" then
		gradient = v.Gradient
	else
		gradient = false
	end

	if type(gradient) ~= "table" or #gradient == 0 then
		return nil
	end

	local colorSequence

	if #gradient == 1 then
		colorSequence = ColorSequence.new(gradient[1])
	else
		local colorSequenceKeypoints = {}

		for k, v2 in gradient do
			table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new((k - 1) / (#gradient - 1), v2))
		end

		colorSequence = ColorSequence.new(colorSequenceKeypoints)
	end

	return {
		Color = colorSequence,
		Rotation = tonumber(v.GradientRotation)
	}
end

Weather.Data.LuckyFuse = {
	Chance = 0,
	Description = "Increased Fusion Luck",
	Image = Weather.Data.Lucky.Image,
	FuseLuckBoost = 0.15,
	Headline = "Lucky Fuse Has Begun",
	EndHeadline = "Lucky Fuse Has Ended",
	Gradient = { Color3.fromRGB(170, 230, 255), Color3.fromRGB(80, 170, 255), Color3.fromRGB(85, 115, 235) },
	GradientRotation = 90
}
return Weather