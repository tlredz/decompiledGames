return {
	["Heaven's Aria"] = {
		Icon = "rbxassetid://102156621928069",
		DisplayText = nil,
		Description = "literally just the heavens rod model lol",
		Rarity = "Secret",
		Untradeable = true
	},
	["Golden Pinion's Aria"] = {
		Icon = "rbxassetid://129877904085924",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary",
		Untradeable = true
	},
	["Frigid Beauty"] = {
		Icon = "rbxassetid://96775190616863",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary"
	},
	["Galactic Virge"] = {
		Icon = "rbxassetid://87098437005757",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3577607846,
		TimeToExpire = DateTime.fromUniversalTime(2026, 4, 25, 16).UnixTimestamp
	},
	["Vespera's Dream"] = {
		Icon = "rbxassetid://70786949474912",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3588993526,
		TimeToExpire = DateTime.fromUniversalTime(2026, 5, 16, 16).UnixTimestamp
	},
	["Meanie Dog"] = {
		Icon = "rbxassetid://98535926469832",
		DisplayText = nil,
		Description = "oi chip a weenie",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3606731543,
		TimeToExpire = DateTime.fromUniversalTime(2026, 7, 4, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "meaniedog_pinions",
			ClientFishingPassives = {
				["Pinion's Aria"] = {
					OVERRIDE_NOTE_IMG = "rbxassetid://135702897895116",
					OVERRIDE_NOTE_HIT_SOUND_NAME = "NoteHitMeanieDog"
				}
			}
		}
	},
	["Sterling Parasol"] = {
		Icon = "rbxassetid://123306170864181",
		DisplayText = nil,
		Description = "jellyfish elegance",
		Rarity = "Legendary",
		Limited = true,
		RodPatches = {
			ReelGuiName = "sterling_pinions",
			ClientFishingPassives = {
				["Pinion's Aria"] = {
					OVERRIDE_NOTE_HIT_SOUND_NAME = "NoteHitSterling"
				}
			}
		}
	},
	["Summertime Encore"] = {
		Icon = "rbxassetid://84687273724896",
		DisplayText = nil,
		Description = "meow",
		Rarity = "Secret",
		Untradeable = true,
		RodPatches = {
			ReelGuiName = "pinionsaria_summertime",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "SummertimeRootAura",
							WeldToLimb = "HumanoidRootPart"
						},
						{
							ModelName = "SummertimeLeftArmAura",
							WeldToLimb = "Left Arm"
						},
						{
							ModelName = "SummertimeRightArmAura",
							WeldToLimb = "Right Arm"
						}
					}
				}
			},
			ClientFishingPassives = {
				["Pinion's Aria"] = {
					OVERRIDE_NOTE_IMG = { "rbxassetid://128397713270410", "rbxassetid://132936308793360" }
				}
			}
		}
	},
	["Triple Fishstaff"] = {
		Icon = "rbxassetid://102747351343209",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3710367643,
		TimeToExpire = DateTime.fromUniversalTime(2026, 9, 5, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "fish_pinions",
			ClientFishingPassives = {
				["Pinion's Aria"] = {
					OVERRIDE_NOTE_IMG = { "rbxassetid://133515667999454" },
					OVERRIDE_NOTE_HIT_SOUND_NAME = "NoteHitSterling"
				}
			}
		}
	}
}