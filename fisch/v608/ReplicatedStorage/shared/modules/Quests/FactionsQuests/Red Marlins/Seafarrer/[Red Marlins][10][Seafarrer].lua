local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Red Marlins][10][Seafarrer]"] = {
		FactionsPanelDisplayTitle = "Seafarrer Quest",
		FactionsPanelDisplayDescription = "Catch x10 Unusual or Rare fish",
		DisplayName = "[Red Marlins] - Seafarrer Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 148, 168),
		QuestType = "Reputation",
		Description = "Catch x10 fish \"UNUSUAL\" or \"RARE\"",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				10,
				nil,
				{ "Unusual", "Rare" },
				nil
			}
		},
		Rewards = {
			{ "Reputation", "Red Marlins", 50 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(100) },
			{ "Bait", "Hangman's Hook", 5 }
		}
	}
}