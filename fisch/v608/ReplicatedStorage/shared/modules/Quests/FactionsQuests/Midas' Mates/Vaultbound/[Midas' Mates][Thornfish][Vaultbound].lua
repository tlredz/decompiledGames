local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
return {
	["[Midas' Mates][Thornfish][Vaultbound]"] = {
		FactionsPanelDisplayTitle = "Vaultbound Quest",
		FactionsPanelDisplayDescription = "Catch x1 Goldfin Octopus with an Easy random mutation",
		DisplayName = "[Midas' Mates] - Vaultbound Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 249, 181),
		QuestType = "Reputation",
		Description = "Catch x1 Goldfin Octopus with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Goldfin Octopus" },
				nil,
				nil,
				nil,
				nil,
				{
					"Electric",
					"Darkened",
					"Translucent",
					"Albino",
					"Glossy"
				}
			}
		},
		Rewards = {
			{ "Reputation", "Midas' Mates", 150 },
			{ "Currency", "Coins", CurrencyMigration.DoubloonsToCoins(300) },
			{ "Bait", "Hangman's Hook", 15 }
		}
	}
}