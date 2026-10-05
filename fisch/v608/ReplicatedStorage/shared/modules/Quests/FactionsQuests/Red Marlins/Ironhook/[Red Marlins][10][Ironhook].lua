local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Red Marlins][10][Ironhook]"] = {
		FactionsPanelDisplayTitle = "Ironhook Quest",
		FactionsPanelDisplayDescription = "Catch x3 Exotic fish",
		DisplayName = "[Red Marlins] - Ironhook Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 62, 136),
		QuestType = "Reputation",
		Description = "Catch x3 fish \"EXOTIC\"",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				3,
				nil,
				{ "Exotic" },
				nil
			}
		},
		Rewards = {
			{ "Reputation", "Red Marlins", 110 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(220) },
			{ "Bait", "Hangman's Hook", 11 }
		}
	}
}