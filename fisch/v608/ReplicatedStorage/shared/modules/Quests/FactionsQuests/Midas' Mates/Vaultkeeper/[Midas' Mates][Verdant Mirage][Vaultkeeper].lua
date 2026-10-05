local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Midas' Mates][Verdant Mirage][Vaultkeeper]"] = {
		FactionsPanelDisplayTitle = "Vaultkeeper Quest",
		FactionsPanelDisplayDescription = "Catch x1 Blue Whale with a Hard random mutation",
		DisplayName = "[Midas' Mates] - Vaultkeeper Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 191, 0),
		QuestType = "Reputation",
		Description = "Catch x1 Blue Whale with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Blue Whale" },
				nil,
				nil,
				nil,
				nil,
				{
					"Heavenly",
					"Seasonal",
					"Hexed",
					"Abyssal",
					"Subspace"
				}
			}
		},
		Rewards = {
			{ "Reputation", "Midas' Mates", 250 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(600) },
			{ "Bait", "Hangman's Hook", 25 }
		}
	}
}