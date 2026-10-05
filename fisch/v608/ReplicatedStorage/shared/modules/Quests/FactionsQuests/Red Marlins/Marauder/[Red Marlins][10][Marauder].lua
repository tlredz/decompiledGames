local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Red Marlins][10][Marauder]"] = {
		FactionsPanelDisplayTitle = "Marauder Quest",
		FactionsPanelDisplayDescription = "Catch x10 Legendary fish",
		DisplayName = "[Red Marlins] - Marauder Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 103, 164),
		QuestType = "Reputation",
		Description = "Catch x10 fish \"LEGENDARY\"",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				10,
				nil,
				{ "Legendary" },
				nil
			}
		},
		Rewards = {
			{ "Reputation", "Red Marlins", 100 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(200) },
			{ "Bait", "Hangman's Hook", 10 }
		}
	}
}