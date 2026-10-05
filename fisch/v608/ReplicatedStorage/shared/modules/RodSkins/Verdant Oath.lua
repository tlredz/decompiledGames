return {
	Fruitshido = {
		Icon = "rbxassetid://73138245347390",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3569790582,
		TimeToExpire = DateTime.fromUniversalTime(2026, 4, 11, 16).UnixTimestamp
	},
	Chromancer = {
		Icon = "rbxassetid://96692820822135",
		DisplayText = nil,
		Description = "The sound of metal piercing the ears of your opponent as you wield this chrome masterpiece..",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3708138536,
		TimeToExpire = DateTime.fromUniversalTime(2026, 8, 22, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "chrome_verdant",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "ChromancerSpine",
							WeldToLimb = "Torso",
							ActiveUnequipped = true
						}
					}
				}
			}
		}
	}
}