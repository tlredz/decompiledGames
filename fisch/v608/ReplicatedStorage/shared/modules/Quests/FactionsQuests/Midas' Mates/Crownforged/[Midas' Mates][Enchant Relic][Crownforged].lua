local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Midas' Mates][Enchant Relic][Crownforged]"] = {
		FactionsPanelDisplayTitle = "Crownforged Quest",
		FactionsPanelDisplayDescription = "Catch x1 Enchant Relic with a Medium random mutation",
		DisplayName = "[Midas' Mates] - Crownforged Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 234, 130),
		QuestType = "Reputation",
		Description = "Catch x1 Enchant Relic with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Enchant Relic" },
				nil,
				nil,
				nil,
				nil,
				{ "Hexed", "Sanguine", "Purified" }
			}
		},
		Rewards = {
			{ "Reputation", "Midas' Mates", 120 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(240) },
			{ "Bait", "Hangman's Hook", 12 }
		}
	}
}