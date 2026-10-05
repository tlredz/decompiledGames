local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Red Marlins][5][Ironhook]"] = {
		FactionsPanelDisplayTitle = "Ironhook Quest",
		FactionsPanelDisplayDescription = "Catch x25 Mythical fish",
		DisplayName = "[Red Marlins] - Ironhook Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 62, 136),
		QuestType = "Reputation",
		Description = "Catch x25 fish \"MYTHICAL\"",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				25,
				nil,
				{ "Mythical" },
				nil
			}
		},
		Rewards = {
			{ "Reputation", "Red Marlins", 140 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(280) },
			{ "Bait", "Hangman's Hook", 14 }
		}
	}
}