local function createEgg(displayName: string, items, arePaidRandomItemsRestricted: boolean)
	return {
		DisplayName = displayName,
		Items = items,
		ArePaidRandomItemsRestricted = arePaidRandomItemsRestricted
	}
end

local function calculateNormalCoins()
	local v = math.random() * 100

	if v <= 50 then
		return 500
	end

	if v <= 80 then
		return 1000
	end

	if v <= 95 then
		return 5000
	end

	return 10000
end

local function calculatePremiumCoins()
	local v = math.random() * 100

	if v <= 50 then
		return 2500
	end

	if v <= 80 then
		return 5000
	end

	if v <= 95 then
		return 75000
	end

	return 250000
end

local function calculateCursedCoins()
	local v = math.random() * 100

	if v <= 50 then
		return 100
	end

	if v <= 80 then
		return 250
	end

	if v <= 95 then
		return 500
	end

	if v <= 99 then
		return 1000
	end

	return 5000
end

return {
	["Kraken Egg"] = {
		DisplayName = "Kraken Egg",
		Items = {
			{
				Category = "Coins",
				Chance = 53.96,
				Item = "C$",
				Amount = calculateNormalCoins
			},
			{
				Category = "Bait",
				Chance = 40.04,
				Item = "Truffle Worm",
				Amount = 5
			},
			{
				Category = "Cosmetic Case",
				Chance = 5.95,
				Item = "Cosmetic Case"
			},
			{
				Category = "Boat",
				Chance = 0.0499,
				Item = "King of the Kraken"
			},
			{
				Category = "Submarine",
				Chance = 0.0001,
				Item = "The Blubbernaut"
			}
		},
		ArePaidRandomItemsRestricted = false
	},
	["Megalodon Egg"] = {
		DisplayName = "Megalodon Egg",
		Items = {
			{
				Category = "Coins",
				Chance = 53.96,
				Item = "C$",
				Amount = calculateNormalCoins
			},
			{
				Category = "Bait",
				Chance = 40.04,
				Item = "Truffle Worm",
				Amount = 5
			},
			{
				Category = "Cosmetic Case",
				Chance = 5.95,
				Item = "Cosmetic Case"
			},
			{
				Category = "Boat",
				Chance = 0.0499,
				Item = "King of the Kraken"
			},
			{
				Category = "Submarine",
				Chance = 0.0001,
				Item = "The Blubbernaut"
			}
		},
		ArePaidRandomItemsRestricted = false
	},
	["Orca Egg"] = {
		DisplayName = "Orca Egg",
		Items = {
			{
				Category = "Coins",
				Chance = 53.96,
				Item = "C$",
				Amount = calculateNormalCoins
			},
			{
				Category = "Bait",
				Chance = 40.04,
				Item = "Truffle Worm",
				Amount = 5
			},
			{
				Category = "Cosmetic Case",
				Chance = 5.95,
				Item = "Cosmetic Case"
			},
			{
				Category = "Boat",
				Chance = 0.0499,
				Item = "King of the Kraken"
			},
			{
				Category = "Submarine",
				Chance = 0.0001,
				Item = "The Blubbernaut"
			}
		},
		ArePaidRandomItemsRestricted = false
	},
	["Whale Egg"] = {
		DisplayName = "Whale Egg",
		Items = {
			{
				Category = "Coins",
				Chance = 53.96,
				Item = "C$",
				Amount = calculateNormalCoins
			},
			{
				Category = "Bait",
				Chance = 40.04,
				Item = "Truffle Worm",
				Amount = 5
			},
			{
				Category = "Cosmetic Case",
				Chance = 5.95,
				Item = "Cosmetic Case"
			},
			{
				Category = "Boat",
				Chance = 0.0499,
				Item = "King of the Kraken"
			},
			{
				Category = "Submarine",
				Chance = 0.0001,
				Item = "The Blubbernaut"
			}
		},
		ArePaidRandomItemsRestricted = false
	},
	["Faberge Egg"] = {
		DisplayName = "Faberge Egg",
		Items = {
			{
				Category = "Coins",
				Chance = 48,
				Item = "C$",
				Amount = calculatePremiumCoins
			},
			{
				Category = "Bait",
				Chance = 40,
				Item = "Golden Tentacle",
				Amount = 5
			},
			{
				Category = "Cosmetic Case",
				Chance = 10,
				Item = "Cosmetic Case Legendary"
			},
			{
				Category = "Boat",
				Chance = 1.5,
				Item = "King of the Kraken"
			},
			{
				Category = "Submarine",
				Chance = 0.5,
				Item = "The Blubbernaut"
			}
		},
		ArePaidRandomItemsRestricted = true
	},
	["Kraken Egg Premium"] = {
		DisplayName = "Kraken Egg Premium",
		Items = {
			{
				Category = "Coins",
				Chance = 48,
				Item = "C$",
				Amount = calculatePremiumCoins
			},
			{
				Category = "Title",
				Chance = 40,
				Item = "Kraken Collector"
			},
			{
				Category = "Cosmetic Case",
				Chance = 10,
				Item = "Cosmetic Case Legendary"
			},
			{
				Category = "Boat",
				Chance = 1.5,
				Item = "King of the Kraken"
			},
			{
				Category = "Submarine",
				Chance = 0.5,
				Item = "The Blubbernaut"
			}
		},
		ArePaidRandomItemsRestricted = true
	},
	["Megalodon Egg Premium"] = {
		DisplayName = "Megalodon Egg Premium",
		Items = {
			{
				Category = "Coins",
				Chance = 48,
				Item = "C$",
				Amount = calculatePremiumCoins
			},
			{
				Category = "Title",
				Chance = 40,
				Item = "Kraken Collector"
			},
			{
				Category = "Cosmetic Case",
				Chance = 10,
				Item = "Cosmetic Case Legendary"
			},
			{
				Category = "Boat",
				Chance = 1.5,
				Item = "King of the Kraken"
			},
			{
				Category = "Submarine",
				Chance = 0.5,
				Item = "The Blubbernaut"
			}
		},
		ArePaidRandomItemsRestricted = true
	},
	["Orca Egg Premium"] = {
		DisplayName = "Orca Egg Premium",
		Items = {
			{
				Category = "Coins",
				Chance = 48,
				Item = "C$",
				Amount = calculatePremiumCoins
			},
			{
				Category = "Title",
				Chance = 40,
				Item = "Kraken Collector"
			},
			{
				Category = "Cosmetic Case",
				Chance = 10,
				Item = "Cosmetic Case Legendary"
			},
			{
				Category = "Boat",
				Chance = 1.5,
				Item = "King of the Kraken"
			},
			{
				Category = "Submarine",
				Chance = 0.5,
				Item = "The Blubbernaut"
			}
		},
		ArePaidRandomItemsRestricted = true
	},
	["Whale Egg Premium"] = {
		DisplayName = "Whale Egg Premium",
		Items = {
			{
				Category = "Coins",
				Chance = 48,
				Item = "C$",
				Amount = calculatePremiumCoins
			},
			{
				Category = "Title",
				Chance = 40,
				Item = "Kraken Collector"
			},
			{
				Category = "Cosmetic Case",
				Chance = 10,
				Item = "Cosmetic Case Legendary"
			},
			{
				Category = "Boat",
				Chance = 1.5,
				Item = "King of the Kraken"
			},
			{
				Category = "Submarine",
				Chance = 0.5,
				Item = "The Blubbernaut"
			}
		},
		ArePaidRandomItemsRestricted = nil
	},
	["Cursed Egg"] = {
		DisplayName = "Cursed Egg",
		Items = {
			{
				Category = "Embercoins",
				Chance = 48,
				Item = "E$",
				Amount = calculateCursedCoins
			},
			{
				Category = "Bait",
				Chance = 40,
				Item = "Golden Tentacle",
				Amount = 5
			},
			{
				Category = "Cosmetic Case",
				Chance = 10,
				Item = "Cursed"
			},
			{
				Category = "Boat",
				Chance = 1.5,
				Item = "Cthulhu Boat"
			},
			{
				Category = "Submarine",
				Chance = 0.5,
				Item = "Cthulunaut"
			}
		},
		ArePaidRandomItemsRestricted = false
	}
}