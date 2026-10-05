local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
local ShadyScrip = require(ReplicatedStorage.shared.utils.ShadyScrip)
return {
	["[Ghosts][Goldfin Octopus][Lost Soul]"] = {
		FactionsPanelDisplayTitle = "Lost Soul Quest",
		FactionsPanelDisplayDescription = "Catch x1 Goldfin Octopus with a Hard random mutation",
		DisplayName = "[Ghosts] - Lost Soul Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(212, 255, 243),
		QuestType = "Reputation",
		Description = "Catch x1 Goldfin Octopus with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Goldfin Octopus" },
				nil,
				nil,
				nil,
				nil,
				{
					"Ashen Fortune",
					"Solarblaze",
					"Crystalized",
					"Blighted",
					"Purified",
					"Abyssal",
					"Atlantean",
					"Mythical"
				}
			}
		},
		Rewards = {
			{ "Reputation", "Ghosts", 80 },
			{ "LocalCurrency", ShadyScrip.CurrencyKey, ShadyScrip.FromCoins(CurrencyMigration.DoubloonsToCoins(165)) },
			{ "Bait", "Hangman's Hook", 8 }
		}
	}
}