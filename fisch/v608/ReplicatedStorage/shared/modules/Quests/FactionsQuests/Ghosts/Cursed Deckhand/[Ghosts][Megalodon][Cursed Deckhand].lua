local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
local ShadyScrip = require(ReplicatedStorage.shared.utils.ShadyScrip)
return {
	["[Ghosts][Megalodon][Cursed Deckhand]"] = {
		FactionsPanelDisplayTitle = "Cursed Deckhand Quest",
		FactionsPanelDisplayDescription = "Catch x1 Megalodon with a Hard random mutation",
		DisplayName = "[Ghosts] - Cursed Deckhand Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(184, 255, 237),
		QuestType = "Reputation",
		Description = "Catch x1 Megalodon with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Megalodon" },
				nil,
				nil,
				nil,
				nil,
				{
					"Blessed",
					"Ashen Fortune",
					"Heavenly",
					"Solarblaze",
					"Lost",
					"Crystalized",
					"Blighted"
				}
			}
		},
		Rewards = {
			{ "Reputation", "Ghosts", 250 },
			{ "LocalCurrency", ShadyScrip.CurrencyKey, ShadyScrip.FromCoins(CurrencyMigration.DoubloonsToCoins(500)) },
			{ "Bait", "Hangman's Hook", 25 }
		}
	}
}