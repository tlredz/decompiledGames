return {
	["Golden Astraeus Serenade"] = {
		Icon = "rbxassetid://84159783651636",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary",
		Untradeable = true
	},
	["Riviere Astrale"] = {
		Icon = "rbxassetid://105192728098147",
		DisplayText = "Rivière Astrale",
		Description = "",
		Rarity = "Legendary",
		Untradeable = true
	},
	["Purr of Rebellion"] = {
		Icon = "rbxassetid://79569123788277",
		DisplayText = nil,
		Description = "edgy, punk, purple, and full of purrs; strumming through any catch while staying super cute!",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3515233577,
		TimeToExpire = DateTime.fromUniversalTime(2026, 1, 24, 17).UnixTimestamp
	},
	Traxx = {
		Icon = "rbxassetid://87975687681812",
		DisplayText = "Traxx!",
		Description = "music: tba",
		Rarity = "Secret",
		Untradeable = true
	},
	["Stars Highways"] = {
		Icon = "rbxassetid://125306705530852",
		DisplayText = nil,
		Description = "Stardust clings to the fretboard, and every riff feels like an open road through the galaxy.. (concept by @CARRYING_BOX)",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3712471841,
		TimeToExpire = DateTime.fromUniversalTime(2026, 9, 19, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "stars_astraeus",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "StarsFloorAura",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						},
						{
							ModelName = "StarsTorsoAura",
							WeldToLimb = "Torso",
							ActiveUnequipped = true
						}
					}
				}
			}
		}
	}
}