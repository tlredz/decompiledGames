local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
local ShadyScrip = require(ReplicatedStorage.shared.utils.ShadyScrip)
return {
	["[Ghosts][Moon Idol Sea 2][Eternal Reaver]"] = {
		FactionsPanelDisplayTitle = "Eternal Reaver Quest",
		FactionsPanelDisplayDescription = "Catch x1 Moon Idol with a Very Hard random mutation",
		DisplayName = "[Ghosts] - Eternal Reaver Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(44, 255, 195),
		QuestType = "Reputation",
		Description = "Catch x1 Moon Idol with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Moon Idol" },
				nil,
				nil,
				nil,
				nil,
				{
					"Jackpot",
					"Wrath",
					"Chaotic",
					"Electric",
					"Sanguine",
					"Mastered",
					"Luminescent"
				}
			}
		},
		Rewards = {
			{ "Reputation", "Ghosts", 5000 },
			{ "LocalCurrency", ShadyScrip.CurrencyKey, ShadyScrip.FromCoins(CurrencyMigration.DoubloonsToCoins(4500)) },
			{ "Bait", "Hangman's Hook", 100 }
		}
	}
}