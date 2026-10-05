local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Red Marlins][25][Marauder][Legendary]"] = {
		FactionsPanelDisplayTitle = "Marauder Quest",
		FactionsPanelDisplayDescription = "Catch x25 Legendary fish",
		DisplayName = "[Red Marlins] - Marauder Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 103, 164),
		QuestType = "Reputation",
		Description = "Catch x25 fish \"LEGENDARY\"",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				25,
				nil,
				{ "Legendary" },
				nil
			}
		},
		Rewards = {
			{ "Reputation", "Red Marlins", 130 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(260) },
			{ "Bait", "Hangman's Hook", 13 }
		}
	}
}