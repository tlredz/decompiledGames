local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Midas' Mates][Bigfin Squid][Gildwarden]"] = {
		FactionsPanelDisplayTitle = "Gildwarden Quest",
		FactionsPanelDisplayDescription = "Catch x1 Colossal Squid with a Hard random mutation",
		DisplayName = "[Midas' Mates] - Gildwarden Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 255, 92),
		QuestType = "Reputation",
		Description = "Catch x1 Colossal Squid with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Colossal Squid" },
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
			{ "Reputation", "Midas' Mates", 200 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(400) },
			{ "Bait", "Hangman's Hook", 20 }
		}
	}
}