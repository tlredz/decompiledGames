local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Midas' Mates][Mustard][Vaultkeeper]"] = {
		FactionsPanelDisplayTitle = "Vaultkeeper Quest",
		FactionsPanelDisplayDescription = "Catch x1 Manatee with a Very Hard random mutation",
		DisplayName = "[Midas' Mates] - Vaultkeeper Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 191, 0),
		QuestType = "Reputation",
		Description = "Catch x1 Manatee with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Manatee" },
				nil,
				nil,
				nil,
				nil,
				{ "Chaotic", "Hexed", "Electric" }
			}
		},
		Rewards = {
			{ "Reputation", "Midas' Mates", 1000 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(2000) },
			{ "Bait", "Hangman's Hook", 50 }
		}
	}
}