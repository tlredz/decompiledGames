local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Midas' Mates][Golden Seahorse][Midas Outsider]"] = {
		FactionsPanelDisplayTitle = "Midas Outsider Quest",
		FactionsPanelDisplayDescription = "Catch x1 Golden Seahorse",
		DisplayName = "[Midas' Mates] - Outsider Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 252, 211),
		QuestType = "Reputation",
		Description = "Catch x1 Golden Seahorse",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Golden Seahorse" },
				nil,
				nil,
				nil,
				nil,
				nil
			}
		},
		Rewards = {
			{ "Reputation", "Midas' Mates", 15 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(20) },
			{ "Bait", "Hangman's Hook", 1 }
		}
	}
}