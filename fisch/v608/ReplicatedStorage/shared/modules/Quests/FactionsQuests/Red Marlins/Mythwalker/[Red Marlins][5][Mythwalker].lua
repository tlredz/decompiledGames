local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Red Marlins][5][Mythwalker]"] = {
		FactionsPanelDisplayTitle = "Mythwalker Quest",
		FactionsPanelDisplayDescription = "Catch x2 Secret fish",
		DisplayName = "[Red Marlins] - Mythwalker Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 7, 94),
		QuestType = "Reputation",
		Description = "Catch x2 fish \"SECRET\"",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				2,
				nil,
				{ "Secret" },
				nil
			}
		},
		Rewards = {
			{ "Reputation", "Red Marlins", 150 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(300) },
			{ "Bait", "Hangman's Hook", 15 }
		}
	}
}