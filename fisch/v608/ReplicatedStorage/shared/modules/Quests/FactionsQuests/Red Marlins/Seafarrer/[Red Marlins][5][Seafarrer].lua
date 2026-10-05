local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Red Marlins][5][Seafarrer]"] = {
		FactionsPanelDisplayTitle = "Seafarrer Quest",
		FactionsPanelDisplayDescription = "Catch x5 Mythical fish",
		DisplayName = "[Red Marlins] - Seafarrer Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 148, 168),
		QuestType = "Reputation",
		Description = "Catch x5 fish \"MYTHICAL\"",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				5,
				nil,
				{ "Mythical" },
				nil
			}
		},
		Rewards = {
			{ "Reputation", "Red Marlins", 90 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(180) },
			{ "Bait", "Hangman's Hook", 9 }
		}
	}
}