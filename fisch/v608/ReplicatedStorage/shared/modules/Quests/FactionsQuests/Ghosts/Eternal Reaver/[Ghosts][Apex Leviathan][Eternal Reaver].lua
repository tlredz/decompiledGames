local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
local ShadyScrip = require(ReplicatedStorage.shared.utils.ShadyScrip)
return {
	["[Ghosts][Apex Leviathan][Eternal Reaver]"] = {
		FactionsPanelDisplayTitle = "Eternal Reaver Quest",
		FactionsPanelDisplayDescription = "Catch x1 Mosslurker with a Hard random mutation",
		DisplayName = "[Ghosts] - Eternal Reaver Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(44, 255, 195),
		QuestType = "Reputation",
		Description = "Catch x1 Mosslurker with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Mosslurker" },
				nil,
				nil,
				nil,
				nil,
				{
					"Subspace",
					"Exploded",
					"Sunken",
					"Celestial",
					"Sanguine",
					"Purified"
				}
			}
		},
		Rewards = {
			{ "Reputation", "Ghosts", 500 },
			{ "LocalCurrency", ShadyScrip.CurrencyKey, ShadyScrip.FromCoins(CurrencyMigration.DoubloonsToCoins(1500)) },
			{ "Bait", "Hangman's Hook", 50 }
		}
	}
}