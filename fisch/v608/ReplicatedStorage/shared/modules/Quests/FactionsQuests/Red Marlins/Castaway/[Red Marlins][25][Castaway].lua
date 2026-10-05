local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Red Marlins][25][Castaway]"] = {
		FactionsPanelDisplayTitle = "Castaway Quest",
		FactionsPanelDisplayDescription = "Catch x25 Common or Uncommon fish",
		DisplayName = "[Red Marlins] - Castaway Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 181, 182),
		QuestType = "Reputation",
		Description = "Catch x25 fish \"COMMON\" or \"UNCOMMON\"",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				25,
				nil,
				{ "Common", "Uncommon" },
				nil
			}
		},
		Rewards = {
			{ "Reputation", "Red Marlins", 30 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(45) },
			{ "Bait", "Hangman's Hook", 3 }
		}
	}
}