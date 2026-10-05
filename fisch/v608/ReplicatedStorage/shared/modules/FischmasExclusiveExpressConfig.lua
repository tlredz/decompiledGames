local FischmasExclusiveExpressConfig = {
	EventEndTimestamp = os.time({
		year = 2026,
		month = 1,
		day = 1,
		hour = 23,
		min = 59,
		sec = 59
	}),
	TimerUpdateInterval = 1,
	BellsPerSpin = 1000,
	SpinRewards = {
		{
			Name = "Party Hat Bobber",
			Type = "Bobber",
			ItemId = "Party Hat Bobber",
			Weight = 30,
			Chance = 30,
			Icon = "rbxassetid://0",
			Rarity = "Common"
		},
		{
			Name = "Balloon Doggy Bobber",
			Type = "Bobber",
			ItemId = "Balloon Doggy Bobber",
			Weight = 20,
			Chance = 20,
			Icon = "rbxassetid://0",
			Rarity = "Uncommon"
		},
		{
			Name = "Balloon Doggy",
			Type = "Skin",
			ItemId = "Balloon Doggy",
			Weight = 10,
			Chance = 10,
			Icon = "rbxassetid://0",
			TargetRod = "Silly Fun Happy Rod",
			Rarity = "Rare"
		},
		{
			Name = "Firerocket Racer",
			Type = "Boat",
			ItemId = "Firerocket Racer",
			Weight = 5,
			Chance = 5,
			Icon = "rbxassetid://0",
			Rarity = "Epic"
		},
		{
			Name = "Etherium",
			Type = "Skin",
			ItemId = "Etherium",
			Weight = 2,
			Chance = 2,
			Icon = "rbxassetid://0",
			TargetRod = "Seraphic Rod",
			Rarity = "Legendary"
		},
		{
			Name = "Memories Of Gold",
			Type = "Skin",
			ItemId = "Memories Of Gold",
			Weight = 1,
			Chance = 1,
			Icon = "rbxassetid://0",
			TargetRod = "Onirifalx",
			Rarity = "Legendary"
		}
	}
}

function FischmasExclusiveExpressConfig.GetTimeRemaining()
	return (math.max(0, FischmasExclusiveExpressConfig.EventEndTimestamp - os.time()))
end

function FischmasExclusiveExpressConfig.FormatTimeRemaining()
	local timeRemaining = FischmasExclusiveExpressConfig.GetTimeRemaining()

	if timeRemaining <= 0 then
		return "Event Ended!"
	end

	local v = math.floor(timeRemaining / 86400)
	local v2 = math.floor(timeRemaining % 86400 / 3600)

	if v > 0 then
		return string.format("Leaving in %dd %dh!", v, v2)
	end

	if v2 > 0 then
		local v3 = math.floor(timeRemaining % 3600 / 60)
		return string.format("Leaving in %dh %dm!", v2, v3)
	end

	local v3 = math.floor(timeRemaining % 3600 / 60)
	local v4 = timeRemaining % 60
	return string.format("Leaving in %dm %ds!", v3, v4)
end

function FischmasExclusiveExpressConfig.IsEventActive()
	return os.time() < FischmasExclusiveExpressConfig.EventEndTimestamp
end

function FischmasExclusiveExpressConfig.GetTotalWeight()
	local total = 0

	for _, spinReward in FischmasExclusiveExpressConfig.SpinRewards do
		total += spinReward.Weight
	end

	return total
end

return FischmasExclusiveExpressConfig