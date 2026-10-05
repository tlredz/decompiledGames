local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Red Marlins][25][Seafarrer]"] = {
		FactionsPanelDisplayTitle = "Seafarrer Quest",
		FactionsPanelDisplayDescription = "Catch x25 Unusual or Rare fish",
		DisplayName = "[Red Marlins] - Seafarrer Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 148, 168),
		QuestType = "Reputation",
		Description = "Catch x25 fish \"UNUSUAL\" or \"RARE\"",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				25,
				nil,
				{ "Unusual", "Rare" },
				nil
			}
		},
		Rewards = {
			{ "Reputation", "Red Marlins", 70 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(140) },
			{ "Bait", "Hangman's Hook", 7 }
		}
	}
}