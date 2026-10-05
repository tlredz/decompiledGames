local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
local ShadyScrip = require(ReplicatedStorage.shared.utils.ShadyScrip)
return {
	["[Ghosts][Long Pike][Dread Captain]"] = {
		FactionsPanelDisplayTitle = "Dread Captain Quest",
		FactionsPanelDisplayDescription = "Catch x1 Long Pike with a Medium random mutation",
		DisplayName = "[Ghosts] - Dread Captain Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(143, 255, 212),
		QuestType = "Reputation",
		Description = "Catch x1 Long Pike with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Long Pike" },
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
			{ "Reputation", "Ghosts", 300 },
			{ "LocalCurrency", ShadyScrip.CurrencyKey, ShadyScrip.FromCoins(CurrencyMigration.DoubloonsToCoins(1000)) },
			{ "Bait", "Hangman's Hook", 30 }
		}
	}
}