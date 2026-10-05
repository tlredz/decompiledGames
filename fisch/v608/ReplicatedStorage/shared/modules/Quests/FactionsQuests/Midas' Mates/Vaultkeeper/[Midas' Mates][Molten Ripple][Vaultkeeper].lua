local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Midas' Mates][Molten Ripple][Vaultkeeper]"] = {
		FactionsPanelDisplayTitle = "Vaultkeeper Quest",
		FactionsPanelDisplayDescription = "Catch x1 Molten Ripple with a Hard random mutation",
		DisplayName = "[Midas' Mates] - Vaultkeeper Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 191, 0),
		QuestType = "Reputation",
		Description = "Catch x1 Molten Ripple with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Molten Ripple" },
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
			{ "Reputation", "Midas' Mates", 350 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(700) },
			{ "Bait", "Hangman's Hook", 35 }
		}
	}
}