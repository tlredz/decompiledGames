local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Midas' Mates][Gem Blobfish][Vaultkeeper]"] = {
		FactionsPanelDisplayTitle = "Vaultkeeper Quest",
		FactionsPanelDisplayDescription = "Catch x1 Gem Blobfish with a Hard random mutation",
		DisplayName = "[Midas' Mates] - Vaultkeeper Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 191, 0),
		QuestType = "Reputation",
		Description = "Catch x1 Gem Blobfish with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Gem Blobfish" },
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
			{ "Reputation", "Midas' Mates", 420 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(840) },
			{ "Bait", "Hangman's Hook", 42 }
		}
	}
}