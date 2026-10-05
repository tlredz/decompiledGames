return {
	POISONED = {
		Icon = "rbxassetid://101411547748221",
		DisplayText = nil,
		Description = "#deadmansscythe",
		Rarity = "Secret",
		Untradeable = true
	},
	Twilight = {
		Icon = "rbxassetid://104202329596150",
		DisplayText = nil,
		Description = "",
		Rarity = "Secret",
		Untradeable = true,
		RodPatches = {
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "TwilightWing",
							WeldToLimb = "Torso"
						}
					}
				}
			}
		}
	},
	Polylute = {
		Icon = "rbxassetid://84853661403770",
		DisplayText = nil,
		Description = "...and his music was electric",
		Rarity = "Secret",
		Untradeable = true,
		RodPatches = {
			ClientFishingPassives = {
				Generic_Slashes = {
					TriggerMode = "Interval",
					SlashChance = 100,
					SlashInterval = 0.8,
					SlashDamage = 5,
					IntervalRamp = 0.3,
					AnimTime = 0.25,
					ChaoticSlashes = true,
					OnlyOnBar = false,
					SourceType = "Rod",
					SourceName = "Polylute",
					SoundName = "stabbystab",
					IconName = "Polylute",
					GradientColor = Color3.fromRGB(165, 0, 41)
				}
			},
			FishingPassives = {
				FallingNotes = {
					TriggerChance = 0
				}
			}
		}
	},
	Mimicry = {
		Icon = "rbxassetid://104446060205555",
		DisplayText = nil,
		Description = "The yearning to imitate the human form is sloppily reflected on the E.G.O, as if it were a reminder that it should remain a mere desire.",
		Rarity = "Secret",
		Untradeable = true,
		RodPatches = {
			ClientFishingPassives = {
				Generic_Slashes = {
					TriggerMode = "Interval",
					SlashChance = 100,
					SlashInterval = 0.8,
					SlashDamage = 5,
					IntervalRamp = 0.3,
					AnimTime = 0.25,
					ChaoticSlashes = true,
					OnlyOnBar = false,
					SourceType = "Rod",
					SourceName = "Mimicry",
					SoundName = "stabbystab",
					IconName = "Mimicry",
					GradientColor = Color3.fromRGB(122, 0, 4)
				}
			},
			FishingPassives = {
				FallingNotes = {
					TriggerChance = 0
				}
			}
		}
	}
}