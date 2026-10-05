local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Red Marlins][25][Marauder]"] = {
		FactionsPanelDisplayTitle = "Marauder Quest",
		FactionsPanelDisplayDescription = "Catch x15 Mythical fish",
		DisplayName = "[Red Marlins] - Marauder Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 103, 164),
		QuestType = "Reputation",
		Description = "Catch x15 fish \"MYTHICAL\"",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				15,
				nil,
				{ "Mythical" },
				nil
			}
		},
		Rewards = {
			{ "Reputation", "Red Marlins", 120 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(240) },
			{ "Bait", "Hangman's Hook", 12 }
		}
	}
}