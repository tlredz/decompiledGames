local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Red Marlins][10][Marlin Outsider]"] = {
		FactionsPanelDisplayTitle = "Marlin Outsider Quest",
		FactionsPanelDisplayDescription = "Catch x2 Common or Uncommon fish",
		DisplayName = "[Red Marlins] - Outsider Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 181, 182),
		QuestType = "Reputation",
		Description = "Catch x2 fish \"COMMON\" or \"UNCOMMON\"",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				2,
				nil,
				{ "Common", "Uncommon" },
				nil
			}
		},
		Rewards = {
			{ "Reputation", "Red Marlins", 5 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(7) },
			{ "Bait", "Hangman's Hook", 1 }
		}
	}
}