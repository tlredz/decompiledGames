local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
local ShadyScrip = require(ReplicatedStorage.shared.utils.ShadyScrip)
return {
	["[Ghosts][Tartaruga][Cursed Deckhand]"] = {
		FactionsPanelDisplayTitle = "Cursed Deckhand Quest",
		FactionsPanelDisplayDescription = "Catch x1 Tartaruga with a Very Hard random mutation",
		DisplayName = "[Ghosts] - Cursed Deckhand Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(184, 255, 237),
		QuestType = "Reputation",
		Description = "Catch x1 Tartaruga with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Tartaruga" },
				nil,
				nil,
				nil,
				nil,
				{
					"Wrath",
					"Tidal",
					"Carrot",
					"Hexed",
					"Chaotic",
					"Electric"
				}
			}
		},
		Rewards = {
			{ "Reputation", "Ghosts", 100 },
			{ "LocalCurrency", ShadyScrip.CurrencyKey, ShadyScrip.FromCoins(CurrencyMigration.DoubloonsToCoins(200)) },
			{ "Bait", "Hangman's Hook", 10 }
		}
	}
}