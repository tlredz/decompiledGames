local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Midas' Mates][Treble Bass][Crownforged]"] = {
		FactionsPanelDisplayTitle = "Crownforged Quest",
		FactionsPanelDisplayDescription = "Catch x1 Treble Bass with a Medium random mutation",
		DisplayName = "[Midas' Mates] - Crownforged Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 234, 130),
		QuestType = "Reputation",
		Description = "Catch x1 Treble Bass with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Treble Bass" },
				nil,
				nil,
				nil,
				nil,
				{ "Hexed", "Sanguine", "Purified" }
			}
		},
		Rewards = {
			{ "Reputation", "Midas' Mates", 150 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(300) },
			{ "Bait", "Hangman's Hook", 15 }
		}
	}
}