local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
local ShadyScrip = require(ReplicatedStorage.shared.utils.ShadyScrip)
return {
	["[Ghosts][Abyssborn Monstrosity][Phantom Corsair]"] = {
		FactionsPanelDisplayTitle = "Phantom Corsair Quest",
		FactionsPanelDisplayDescription = "Catch x1 Abyssborn Monstrosity with a Medium random mutation",
		DisplayName = "[Ghosts] - Phantom Corsair Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(166, 255, 230),
		QuestType = "Reputation",
		Description = "Catch x1 Abyssborn Monstrosity with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Abyssborn Monstrosity" },
				nil,
				nil,
				nil,
				nil,
				{
					"Purified",
					"Blessed",
					"Heavenly",
					"Hexed",
					"Seasonal",
					"Lost",
					"Electric",
					"Scorched"
				}
			}
		},
		Rewards = {
			{ "Reputation", "Ghosts", 150 },
			{ "LocalCurrency", ShadyScrip.CurrencyKey, ShadyScrip.FromCoins(CurrencyMigration.DoubloonsToCoins(380)) },
			{ "Bait", "Hangman's Hook", 15 }
		}
	}
}