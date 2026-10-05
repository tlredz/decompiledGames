return {
	["Fishcake Snack"] = {
		Icon = "rbxassetid://125606022310595",
		DisplayText = nil,
		Description = "fihcake",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3649482866,
		TimeToExpire = DateTime.fromUniversalTime(2026, 8, 15, 16).UnixTimestamp,
		RodPatches = {
			ShakeButtonName = "fishcake_shake",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "FishcakeProp",
							WeldToLimb = "HumanoidRootPart"
						}
					}
				}
			},
			ClientFishingPassives = {
				["Tranquility Rod"] = {
					RhythmGuiName = "TranquilityRodRhythmGameFih",
					RhythmGuiUpscrollName = "TranquilityRodRhythmGameUpsScrollFih"
				}
			}
		}
	},
	["Whalesong Orcarina"] = {
		Icon = "rbxassetid://121890599284968",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3714775365,
		TimeToExpire = DateTime.fromUniversalTime(2026, 10, 3, 16).UnixTimestamp,
		RodPatches = {
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "WhalesongMusicProp",
							WeldToLimb = "Torso",
							ActiveUnequipped = true
						}
					}
				}
			},
			ClientFishingPassives = {
				["Tranquility Rod"] = {
					RhythmGuiName = "TranquilityRodRhythmGameOrca",
					RhythmGuiUpscrollName = "TranquilityRodRhythmGameUpsScrollOrca"
				}
			}
		}
	}
}