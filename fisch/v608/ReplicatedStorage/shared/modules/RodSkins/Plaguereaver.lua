return {
	Malevolence = {
		Icon = "rbxassetid://115428247709900",
		DisplayText = nil,
		Description = "A jagged edge steeped in malice, it flays the heavens with a merciless, silent grin...",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3555876607,
		TimeToExpire = DateTime.fromUniversalTime(2026, 3, 21, 17).UnixTimestamp
	},
	["Dragon Slayer"] = {
		Icon = "rbxassetid://86527436827331",
		DisplayText = nil,
		Description = "HEAVY!!!!",
		Rarity = "Rare"
	},
	Wildhunt = {
		Icon = "rbxassetid://115746609386971",
		DisplayText = nil,
		Description = "..The ripping and tearing tempest that will bring about their ruin.",
		Rarity = "Rare",
		Untradeable = true
	},
	Bunblade = {
		Icon = "rbxassetid://121605206779829",
		DisplayText = nil,
		Description = "A lace-trimmed hilt dusted in shimmer, it caresses the meadows with a twitching, bunny-nose wish...",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3569790581,
		TimeToExpire = DateTime.fromUniversalTime(2026, 4, 11, 16).UnixTimestamp
	},
	["Twilight's Wildcard"] = {
		Icon = "rbxassetid://126848674356191",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3584845793,
		TimeToExpire = DateTime.fromUniversalTime(2026, 5, 9, 16).UnixTimestamp
	},
	Pearsicle = {
		Icon = "rbxassetid://71617658195304",
		DisplayText = nil,
		Description = "i eat pears",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3602870204,
		TimeToExpire = DateTime.fromUniversalTime(2026, 6, 13, 16).UnixTimestamp
	},
	Poltergeist = {
		Icon = "rbxassetid://129498978883945",
		DisplayText = nil,
		Description = "Boo!",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3607994820,
		TimeToExpire = DateTime.fromUniversalTime(2026, 7, 11, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "plaguereaver_poltergeist",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "PoltergeistBodyAura",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						}
					}
				}
			}
		}
	},
	["The Best Skin Ever"] = {
		Icon = "rbxassetid://99576566410113",
		DisplayText = nil,
		Description = "masterpiece",
		Rarity = "Secret",
		Untradeable = true
	},
	Blackout = {
		Icon = "rbxassetid://104512640913340",
		DisplayText = nil,
		Description = "!",
		Rarity = "Secret",
		Untradeable = true
	},
	Wikihada = {
		Icon = "rbxassetid://101270684885661",
		DisplayText = nil,
		Description = "!",
		Rarity = "Secret",
		Untradeable = true
	},
	["Sage of Heaven's Staff"] = {
		Icon = "rbxassetid://99265266495073",
		DisplayText = "Great Ascended Immortal Venerable Sage of Heaven's Equal Wiki Staff",
		Description = [[
Credits to:
@BuBuu2004B (Buu)
@DARKNESXD425 (Theo)
@emeraldtrooper444 (emeraldtrooper)
@Falconboy2900 (Error10145)
@Noul1 (Jaf)
@Sokzerro (zerro)]],
		Rarity = "Secret",
		Untradeable = true,
		RodPatches = {
			ReelGuiName = "plaguereaver_swk",
			ShakeButtonName = "plaguereaver_swk",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "SWKRootAura",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						},
						{
							ModelName = "SWKTorsoAura",
							WeldToLimb = "Torso",
							ActiveUnequipped = true
						},
						{
							ModelName = "SWKCrownThing",
							WeldToLimb = "Head",
							ActiveUnequipped = true
						}
					}
				},
				Generic_FallingWeapon = {
					HitSoundName = "swk_impact"
				}
			}
		}
	},
	Plaguecleaver = {
		Icon = "rbxassetid://105616394811361",
		DisplayText = nil,
		Description = "It's plague rips and cleaves through rot..",
		Rarity = "Legendary",
		Untradeable = true
	},
	["Shackled Claymore"] = {
		Icon = "rbxassetid://132802742291778",
		DisplayText = nil,
		Description = "Awarded to highly contributing players!",
		Rarity = "Secret",
		Untradeable = true
	},
	["Crest of Galactica"] = {
		Icon = "rbxassetid://109685313940151",
		DisplayText = nil,
		Description = "When two galaxies collide, they exchange stars with the space around them; forever entangled, destined to become whole..",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3709271266,
		TimeToExpire = DateTime.fromUniversalTime(2026, 8, 29, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "galactica_plague",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "PlanetProp",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						},
						{
							ModelName = "GalaFloorAura",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						},
						{
							ModelName = "GalaBodyAura",
							WeldToLimb = "Torso",
							ActiveUnequipped = true
						}
					}
				},
				Generic_FallingWeapon = {
					HitSoundName = "gala_blast"
				}
			}
		}
	},
	Talismania = {
		Icon = "rbxassetid://102085910471466",
		DisplayText = nil,
		Description = "(concept by @fishpeets911)",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3712471788,
		TimeToExpire = DateTime.fromUniversalTime(2026, 9, 19, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "bell_plaguereaver",
			FishingPassives = {
				Generic_FallingWeapon = {
					HitSoundName = "bell_blast"
				}
			}
		}
	}
}