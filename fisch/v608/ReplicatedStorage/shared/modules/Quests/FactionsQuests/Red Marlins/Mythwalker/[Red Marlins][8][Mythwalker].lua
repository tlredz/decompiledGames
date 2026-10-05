local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Red Marlins][8][Mythwalker]"] = {
		FactionsPanelDisplayTitle = "Mythwalker Quest",
		FactionsPanelDisplayDescription = "Catch x5 Exotic fish",
		DisplayName = "[Red Marlins] - Mythwalker Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 7, 94),
		QuestType = "Reputation",
		Description = "Catch x5 fish \"EXOTIC\"",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				5,
				nil,
				{ "Exotic" },
				nil
			}
		},
		Rewards = {
			{ "Reputation", "Red Marlins", 115 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(230) },
			{ "Bait", "Hangman's Hook", 11 }
		}
	}
}