local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyMigration = require(ReplicatedStorage.shared.utils.CurrencyMigration)
local ShadyScrip = require(ReplicatedStorage.shared.utils.ShadyScrip)
return {
	["[Ghosts][Dogefin][Phantom Corsair]"] = {
		FactionsPanelDisplayTitle = "Phantom Corsair Quest",
		FactionsPanelDisplayDescription = "Catch x1 Leviathan with an Easy random mutation",
		DisplayName = "[Ghosts] - Phantom Corsair Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(166, 255, 230),
		QuestType = "Reputation",
		Description = "Catch x1 Leviathan with a specific mutation",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Leviathan" },
				nil,
				nil,
				nil,
				nil,
				{
					"Frozen",
					"Studded",
					"Glossy",
					"Prismize",
					"Greedy",
					"Solarblaze"
				}
			}
		},
		Rewards = {
			{ "Reputation", "Ghosts", 180 },
			{ "LocalCurrency", ShadyScrip.CurrencyKey, ShadyScrip.FromCoins(CurrencyMigration.DoubloonsToCoins(450)) },
			{ "Bait", "Hangman's Hook", 18 }
		}
	}
}