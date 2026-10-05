local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Red Marlins][10][Castaway]"] = {
		FactionsPanelDisplayTitle = "Castaway Quest",
		FactionsPanelDisplayDescription = "Catch x10 Common or Uncommon fish",
		DisplayName = "[Red Marlins] - Castaway Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 181, 182),
		QuestType = "Reputation",
		Description = "Catch x10 fish \"COMMON\" or \"UNCOMMON\"",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				10,
				nil,
				{ "Common", "Uncommon" },
				nil
			}
		},
		Rewards = {
			{ "Reputation", "Red Marlins", 15 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(20) },
			{ "Bait", "Hangman's Hook", 1 }
		}
	}
}