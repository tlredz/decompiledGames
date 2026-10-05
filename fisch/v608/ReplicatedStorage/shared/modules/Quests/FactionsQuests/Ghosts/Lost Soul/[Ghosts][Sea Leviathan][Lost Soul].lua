local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
local ShadyScrip = require(ReplicatedStorage.shared.utils.ShadyScrip)
return {
	["[Ghosts][Sea Leviathan][Lost Soul]"] = {
		FactionsPanelDisplayTitle = "Lost Soul Quest",
		FactionsPanelDisplayDescription = "Catch x1 Mossjaw with an Easy random mutation",
		DisplayName = "[Ghosts] - Lost Soul Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(212, 255, 243),
		QuestType = "Reputation",
		Description = "Catch x1 Mossjaw with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Mossjaw" },
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
			{ "Reputation", "Ghosts", 150 },
			{ "LocalCurrency", ShadyScrip.CurrencyKey, ShadyScrip.FromCoins(CurrencyMigration.DoubloonsToCoins(300)) },
			{ "Bait", "Hangman's Hook", 15 }
		}
	}
}