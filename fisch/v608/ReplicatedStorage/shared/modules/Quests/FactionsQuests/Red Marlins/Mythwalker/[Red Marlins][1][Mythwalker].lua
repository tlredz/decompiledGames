local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Red Marlins][1][Mythwalker]"] = {
		FactionsPanelDisplayTitle = "Mythwalker Quest",
		FactionsPanelDisplayDescription = "Catch x1 Secret fish",
		DisplayName = "[Red Marlins] - Mythwalker Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 7, 94),
		QuestType = "Reputation",
		Description = "Catch x1 fish \"SECRET\"",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				nil,
				{ "Secret" },
				nil
			}
		},
		Rewards = {
			{ "Reputation", "Red Marlins", 125 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(250) },
			{ "Bait", "Hangman's Hook", 12 }
		}
	}
}