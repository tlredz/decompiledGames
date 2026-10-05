return {
	LostDiver = {
		DisplayName = "Tidefall: Lost Diver",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(90, 180, 220),
		QuestType = "Major",
		AcceptIndicatorTag = "TidefallDiverNPC",
		Description = "Find the missing diver in the entry caves and bring him back.",
		CompletedDescription = "Report back to the Tidefall Diver.",
		List = {
			{
				"DataInstanceValue",
				"Cache.LostDiverSaved",
				true,
				"Rescue and return the lost diver"
			}
		},
		Rewards = {
			{ "DisplayOnly", "<b>Abyssal Tonic Unlocked</b>" }
		}
	}
}