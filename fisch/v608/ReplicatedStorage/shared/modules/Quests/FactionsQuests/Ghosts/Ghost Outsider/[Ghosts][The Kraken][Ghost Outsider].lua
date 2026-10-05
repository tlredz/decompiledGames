local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.utils.CurrencyMigration)
local ShadyScrip = require(ReplicatedStorage.shared.utils.ShadyScrip)
return {
	["[Ghosts][The Kraken][Ghost Outsider]"] = {
		FactionsPanelDisplayTitle = "Ghost Outsider Quest",
		FactionsPanelDisplayDescription = "Catch x1 The Kraken",
		DisplayName = "[Ghosts] - Outsider Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(212, 255, 243),
		QuestType = "Reputation",
		Description = "Catch x1 The Kraken",
		CompletedDescription = "Great Job! Claim the rewards on the faction panel!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "The Kraken" },
				nil,
				nil,
				nil,
				nil,
				nil
			}
		},
		Rewards = {
			{ "Reputation", "Ghosts", 10 },
			{ "LocalCurrency", ShadyScrip.CurrencyKey, 10 },
			{ "Bait", "Hangman's Hook", 1 }
		}
	}
}