local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
local ShadyScrip = require(ReplicatedStorage.shared.utils.ShadyScrip)
return {
	["[Ghosts][Ancient Kraken][Phantom Corsair]"] = {
		FactionsPanelDisplayTitle = "Phantom Corsair Quest",
		FactionsPanelDisplayDescription = "Catch x1 Ancient Kraken with an Easy random mutation",
		DisplayName = "[Ghosts] - Phantom Corsair Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(166, 255, 230),
		QuestType = "Reputation",
		Description = "Catch x1 Ancient Kraken with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Ancient Kraken" },
				nil,
				nil,
				nil,
				nil,
				{
					"Frozen",
					"Studded",
					"Glossy",
					"Prismize",
					"Greedy"
				}
			}
		},
		Rewards = {
			{ "Reputation", "Ghosts", 850 },
			{ "LocalCurrency", ShadyScrip.CurrencyKey, ShadyScrip.FromCoins(CurrencyMigration.DoubloonsToCoins(2500)) },
			{ "Bait", "Hangman's Hook", 85 }
		}
	}
}