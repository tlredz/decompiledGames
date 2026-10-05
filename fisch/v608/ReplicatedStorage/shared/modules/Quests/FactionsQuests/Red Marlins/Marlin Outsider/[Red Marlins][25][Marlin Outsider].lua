local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Red Marlins][25][Marlin Outsider]"] = {
		FactionsPanelDisplayTitle = "Marlin Outsider Quest",
		FactionsPanelDisplayDescription = "Catch x5 Common or Uncommon fish",
		DisplayName = "[Red Marlins] - Outsider Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 181, 182),
		QuestType = "Reputation",
		Description = "Catch x5 fish \"COMMON\" or \"UNCOMMON\"",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				5,
				nil,
				{ "Common", "Uncommon" },
				nil
			}
		},
		Rewards = {
			{ "Reputation", "Red Marlins", 10 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(15) },
			{ "Bait", "Hangman's Hook", 1 }
		}
	}
}