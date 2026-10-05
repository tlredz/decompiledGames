local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Midas' Mates][Carrot Shark][Coin-Bitten]"] = {
		FactionsPanelDisplayTitle = "Coin-Bitten Quest",
		FactionsPanelDisplayDescription = "Catch x1 Carrot Shark with a Medium random mutation",
		DisplayName = "[Midas' Mates] - Coin-Bitten Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 252, 211),
		QuestType = "Reputation",
		Description = "Catch x1 Carrot Shark with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Carrot Shark" },
				nil,
				nil,
				nil,
				nil,
				{ "Hexed", "Sanguine" }
			}
		},
		Rewards = {
			{ "Reputation", "Midas' Mates", 100 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(200) },
			{ "Bait", "Hangman's Hook", 10 }
		}
	}
}