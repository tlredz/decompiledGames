local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Midas' Mates][Gemstone Whale Shark][Midas Outsider]"] = {
		FactionsPanelDisplayTitle = "Midas Outsider Quest",
		FactionsPanelDisplayDescription = "Catch x1 Gemstone Whale Shark",
		DisplayName = "[Midas' Mates] - Outsider Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 252, 211),
		QuestType = "Reputation",
		Description = "Catch x1 Gemstone Whale Shark",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Gemstone Whale Shark" },
				nil,
				nil,
				nil,
				nil,
				nil
			}
		},
		Rewards = {
			{ "Reputation", "Midas' Mates", 20 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(30) },
			{ "Bait", "Hangman's Hook", 2 }
		}
	}
}