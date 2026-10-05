local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Midas' Mates][Golden Seahorse][Coin-Bitten]"] = {
		FactionsPanelDisplayTitle = "Coin-Bitten Quest",
		FactionsPanelDisplayDescription = "Catch x1 Colossal Squid with a Medium random mutation",
		DisplayName = "[Midas' Mates] - Coin-Bitten Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 252, 211),
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
				{ "Hexed", "Sanguine" }
			}
		},
		Rewards = {
			{ "Reputation", "Midas' Mates", 70 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(140) },
			{ "Bait", "Hangman's Hook", 7 }
		}
	}
}