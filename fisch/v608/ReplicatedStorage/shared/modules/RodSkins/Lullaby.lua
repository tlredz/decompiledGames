local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.utils.GeneralUtils.apply_op)
return {
	Seastrum = {
		Icon = "rbxassetid://132352066098304",
		DisplayText = nil,
		Description = "Where the crashing waves meet the quiet petals, making melodies out of wildflowers and ocean tides... <3",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3593047743,
		TimeToExpire = DateTime.fromUniversalTime(2026, 5, 23, 16).UnixTimestamp,
		ShowcaseOffset = CFrame.new(0, 10, 0) * CFrame.Angles(0, 0, 0)
	},
	["Porcelain Chord"] = {
		Icon = "rbxassetid://89631852041065",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3600992959,
		TimeToExpire = DateTime.fromUniversalTime(2026, 6, 6, 16).UnixTimestamp
	},
	["Hollowed Harp"] = {
		Icon = "rbxassetid://71571602767174",
		DisplayText = nil,
		Description = "No cost too great, no chord too complex...",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3609221922,
		TimeToExpire = DateTime.fromUniversalTime(2026, 7, 18, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "hollowed_lullaby",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "HollowedBodyAura",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						}
					}
				},
				MetronomeBuff = {
					MusicName = "LullabyHallowedHarp",
					MusicFactor = 1.5
				}
			},
			ClientFishingPassives = {
				MetronomeBuff = {
					BPM = {
						{ 0, 180 }
					},
					Speed = 0.5,
					MusicFactor = 1.5,
					FixedMusicOffset = 0,
					MusicName = "LullabyHallowedHarp"
				}
			}
		}
	},
	Serenity = {
		Icon = "rbxassetid://98745909030508",
		DisplayText = nil,
		Description = "Found hidden within the sands..",
		Rarity = "Secret",
		Untradeable = true
	},
	["EVIL LULLABY"] = {
		Icon = "rbxassetid://99471771785939",
		DisplayText = "EVIL LULLABY THAT KILLS EVERYONE IN A 64 STUD RADIUS",
		Description = "EVIL LULLABY THAT KILLS EVERYONE IN A 64 STUD RADIUS",
		Rarity = "Secret",
		Untradeable = true,
		DEV = true,
		RodPatches = {
			ClientFishingPassives = {
				MetronomeBuff = {
					Sections = {
						{
							Asset = "rbxassetid://95661750144510",
							Start = 70,
							End = 110
						}
					},
					Speed = 5,
					SectionCount = 2,
					BPM = {
						{ 0, 153 }
					},
					MusicFactor = 1.275,
					FixedMusicOffset = 0,
					MusicName = "LullabyStrengthening",
					BuffIcon = "rbxassetid://18197272991",
					BuffColor = ColorSequence.new(Color3.fromRGB(248, 135, 6), Color3.fromRGB(248, 135, 6))
				}
			},
			FishingPassives = {
				MetronomeBuff = {
					HitDuration = 1,
					BuffId = game.GameId == 5750914919 and "Unlucky" or "Fire",
					BuffData = game.GameId == 5750914919 and {
						Stack = 1,
						BoostValue = -1
					} or {
						Stack = 100,
						Damage = 400
					},
					MusicName = "LullabyStrengthening",
					MusicFactor = 2.5833333333333335,
					SectionCount = 1
				}
			}
		}
	},
	["Nameless Illuminator"] = {
		Icon = "rbxassetid://126397229270407",
		DisplayText = nil,
		Description = "(concept by @Jakegranger09)",
		Rarity = "Legendary",
		Limited = true,
		RodPatches = {
			ReelGuiName = "nameless_lullaby"
		}
	}
}