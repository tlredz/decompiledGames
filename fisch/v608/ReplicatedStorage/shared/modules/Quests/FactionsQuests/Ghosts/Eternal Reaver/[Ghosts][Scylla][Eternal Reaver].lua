local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
local ShadyScrip = require(ReplicatedStorage.shared.utils.ShadyScrip)
return {
	["[Ghosts][Scylla][Eternal Reaver]"] = {
		FactionsPanelDisplayTitle = "Eternal Reaver Quest",
		FactionsPanelDisplayDescription = "Catch x1 Scylla with Very Hard random mutation",
		DisplayName = "[Ghosts] - Eternal Reaver Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(44, 255, 195),
		QuestType = "Reputation",
		Description = "Catch x1 Scylla with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Scylla" },
				nil,
				nil,
				nil,
				nil,
				{
					"Wrath",
					"Chaotic",
					"Hexed",
					"Aurora",
					"Electric",
					"Spirit"
				}
			}
		},
		Rewards = {
			{ "Reputation", "Ghosts", 800 },
			{ "LocalCurrency", ShadyScrip.CurrencyKey, ShadyScrip.FromCoins(CurrencyMigration.DoubloonsToCoins(2500)) },
			{ "Bait", "Hangman's Hook", 100 }
		}
	}
}