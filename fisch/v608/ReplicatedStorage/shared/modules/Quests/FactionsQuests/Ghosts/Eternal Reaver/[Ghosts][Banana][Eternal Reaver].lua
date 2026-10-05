local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
local ShadyScrip = require(ReplicatedStorage.shared.utils.ShadyScrip)
return {
	["[Ghosts][Banana][Eternal Reaver]"] = {
		FactionsPanelDisplayTitle = "Eternal Reaver Quest",
		FactionsPanelDisplayDescription = "Catch x1 Banana with a Hard random mutation",
		DisplayName = "[Ghosts] - Eternal Reaver Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(44, 255, 195),
		QuestType = "Reputation",
		Description = "Catch x1 Banana with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Banana" },
				nil,
				nil,
				nil,
				nil,
				{
					"Purified",
					"Fossilized",
					"Atlantean",
					"Mythical",
					"Blessed",
					"Heavenly"
				}
			}
		},
		Rewards = {
			{ "Reputation", "Ghosts", 600 },
			{ "LocalCurrency", ShadyScrip.CurrencyKey, ShadyScrip.FromCoins(CurrencyMigration.DoubloonsToCoins(2000)) },
			{ "Bait", "Hangman's Hook", 60 }
		}
	}
}