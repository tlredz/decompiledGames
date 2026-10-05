local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Red Marlins][15][Ironhook]"] = {
		FactionsPanelDisplayTitle = "Ironhook Quest",
		FactionsPanelDisplayDescription = "Catch x15 Legendary fish",
		DisplayName = "[Red Marlins] - Ironhook Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 62, 136),
		QuestType = "Reputation",
		Description = "Catch x15 fish \"LEGENDARY\"",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				15,
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