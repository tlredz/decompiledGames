local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Red Marlins][5][Marlin Outsider]"] = {
		FactionsPanelDisplayTitle = "Marlin Outsider Quest",
		FactionsPanelDisplayDescription = "Catch x1 Rare or Unusual fish",
		DisplayName = "[Red Marlins] - Outsider Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 181, 182),
		QuestType = "Reputation",
		Description = "Catch x1 fish \"RARE\" or \"UNUSUAL\"",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				nil,
				{ "Rare", "Unusual" },
				nil
			}
		},
		Rewards = {
			{ "Reputation", "Red Marlins", 8 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(10) },
			{ "Bait", "Hangman's Hook", 1 }
		}
	}
}