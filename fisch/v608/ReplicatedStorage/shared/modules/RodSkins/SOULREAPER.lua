return {
	SHADYREAPER = {
		Icon = "rbxassetid://126638085598864",
		DisplayText = nil,
		Description = "...",
		Rarity = "Secret"
	},
	SOULEATER = {
		Icon = "rbxassetid://139355378163520",
		DisplayText = nil,
		Description = "a sound soul dwells within a sound mind and a sound body.",
		Rarity = "Secret",
		Untradeable = true
	},
	POGOMASTER = {
		Icon = "rbxassetid://137474550752648",
		DisplayText = nil,
		Description = "BOING BOING BOING",
		Rarity = "Secret",
		Untradeable = true
	},
	PIERCER = {
		Icon = "rbxassetid://137474550752648",
		DisplayText = nil,
		Description = "Wonderless.",
		Rarity = "Secret",
		Untradeable = true
	},
	["Cardboard Reaper"] = {
		Icon = "rbxassetid://85473287427712",
		DisplayText = nil,
		Description = "dont put this in water.",
		Rarity = "Secret",
		Untradeable = true
	},
	Lavenescence = {
		Icon = "rbxassetid://103234454682224",
		DisplayText = nil,
		Description = "Shredding through galaxies...",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3593149225,
		TimeToExpire = DateTime.fromUniversalTime(2026, 5, 23, 16).UnixTimestamp
	},
	["Wisteria Scythe"] = {
		Icon = "rbxassetid://103595489780082",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3602952841,
		TimeToExpire = DateTime.fromUniversalTime(2026, 6, 13, 16).UnixTimestamp
	},
	Archangelite = {
		Icon = "rbxassetid://88414090380925",
		DisplayText = nil,
		Description = "The heavens fractured when these twin blades were forged, and now they only harvest what they were meant to protect.",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3606759510,
		TimeToExpire = DateTime.fromUniversalTime(2026, 7, 4, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "archangelite_soulreaper",
			FishingPassives = {
				StarcallerCry = {
					VfxModelName = "ArchangeliteTombstone"
				},
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "ArchangeliteLeftKatana",
							WeldToLimb = "Left Arm"
						},
						{
							ModelName = "ArchangeliteWing",
							WeldToLimb = "Torso",
							ActiveUnequipped = true
						},
						{
							ModelName = "ArchangeliteBodyAura",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						},
						{
							ModelName = "ArchangeliteEyeAura",
							WeldToLimb = "Head",
							ActiveUnequipped = true
						}
					}
				}
			}
		}
	},
	["Shrimply Delicious"] = {
		Icon = "rbxassetid://113798263279674",
		DisplayText = nil,
		Description = "Are you seriously telling me a shrimp fried this rice?",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3611518611,
		TimeToExpire = DateTime.fromUniversalTime(2026, 8, 1, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "shrimply_soulreaper",
			FishingPassives = {
				StarcallerCry = {
					VfxModelName = "ShrimplyTombstone"
				}
			}
		}
	}
}