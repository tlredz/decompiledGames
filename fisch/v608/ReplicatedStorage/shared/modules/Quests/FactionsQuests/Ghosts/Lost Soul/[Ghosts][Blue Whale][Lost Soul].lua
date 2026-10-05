local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
local ShadyScrip = require(ReplicatedStorage.shared.utils.ShadyScrip)
return {
	["[Ghosts][Blue Whale][Lost Soul]"] = {
		FactionsPanelDisplayTitle = "Lost Soul Quest",
		FactionsPanelDisplayDescription = "Catch x1 Blue Whale with a Medium random mutation",
		DisplayName = "[Ghosts] - Lost Soul Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(212, 255, 243),
		QuestType = "Reputation",
		Description = "Catch x1 Blue Whale with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Blue Whale" },
				nil,
				nil,
				nil,
				nil,
				{
					"Blessed",
					"Heavenly",
					"Solarblaze",
					"Lost",
					"Blighted"
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