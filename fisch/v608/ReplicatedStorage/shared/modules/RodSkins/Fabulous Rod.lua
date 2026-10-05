return {
	["Capella Vitrea"] = {
		Icon = "rbxassetid://78106692411652",
		DisplayText = nil,
		Description = "Stained glass and gilded seams. The Chapel's most dazzling benediction.",
		Rarity = "Legendary",
		Untradeable = true,
		RodPatches = {
			ReelGuiName = "fabulous_capella"
		}
	},
	["Legacy Fabulous"] = {
		Icon = "rbxassetid://104123308695417",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary"
	},
	["Minty Fab"] = {
		Icon = "rbxassetid://127280635954066",
		DisplayText = nil,
		Description = "YAY!",
		Rarity = "Secret"
	},
	["Fabulous Gift"] = {
		Icon = "rbxassetid://136796632836284",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary"
	},
	["XMAS Fabulous Rod"] = {
		Icon = "rbxassetid://86271193691404",
		DisplayText = nil,
		Description = "Only granted to Original Fabulous Rod owners; Merry Fischmas! [UNTRADEABLE]",
		Rarity = "Secret",
		Untradeable = true
	},
	["Golden Fabulous Rod"] = {
		Icon = "rbxassetid://113526624488599",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary",
		Untradeable = true
	},
	["Tiny Fabulous Rod"] = {
		Icon = "rbxassetid://98260957629074",
		DisplayText = nil,
		Description = "",
		Rarity = "Secret"
	},
	["Voided Fabulous Rod"] = {
		Icon = "rbxassetid://97653713781881",
		DisplayText = nil,
		Description = "🌀",
		Rarity = "Rare"
	},
	["Sweetheart Scissors"] = {
		Icon = "rbxassetid://124043760606140",
		DisplayText = nil,
		Description = "etched with patterns as delicate as lace, finished in the color of first blushes; alike a carefully cut ribbon, crafted with gentleness and care...",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3536672398,
		TimeToExpire = DateTime.fromUniversalTime(2026, 2, 21, 17).UnixTimestamp
	},
	["Cobalt Crusader"] = {
		Icon = "rbxassetid://105667410108587",
		DisplayText = nil,
		Description = "scarred with grooves as deep as battle wounds, tempered in the smoke of a cobalt fore; alike a steady war drum, forged with a heaviness that ends the fight...",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3560532969,
		TimeToExpire = DateTime.fromUniversalTime(2026, 3, 28, 17).UnixTimestamp
	},
	["Froggy Snips"] = {
		Icon = "rbxassetid://120072171588689",
		DisplayText = nil,
		Description = "ribbit!",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3604230217,
		TimeToExpire = DateTime.fromUniversalTime(2026, 6, 20, 16).UnixTimestamp
	},
	Nekobura = {
		Icon = "rbxassetid://137149730971275",
		DisplayText = nil,
		Description = "Powered by premium catnip and heavy machinery, I am officially ready to take over the digital world!",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3606736098,
		TimeToExpire = DateTime.fromUniversalTime(2026, 7, 4, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "nekobura_fabulous",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "NekoburaSpeaker",
							WeldToLimb = "HumanoidRootPart"
						},
						{
							ModelName = "NekoburaHeadphones",
							WeldToLimb = "Head",
							ActiveUnequipped = true
						},
						{
							ModelName = "NekoburaBodyAura",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						}
					}
				}
			}
		}
	},
	["Martyr's Battleaxe"] = {
		Icon = "rbxassetid://75471116258135",
		DisplayText = nil,
		Description = "A bond is never made, won't bend nor break..",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3610410885,
		TimeToExpire = DateTime.fromUniversalTime(2026, 7, 25, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "martyr_fabulous",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "MartyrShieldProp",
							WeldToLimb = "Left Arm"
						},
						{
							ModelName = "AxeBodyAura",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						}
					}
				}
			}
		}
	},
	["Fierce Sushi"] = {
		Icon = "rbxassetid://129461094966055",
		DisplayText = nil,
		Description = "i prefer sashimi :p (concept by @sourlemon.o, sfx by @Akira_Blade)",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3711360081,
		TimeToExpire = DateTime.fromUniversalTime(2026, 9, 12, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "sushi_fabulous",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "FishHatProp",
							WeldToLimb = "Head",
							ActiveUnequipped = true
						}
					}
				}
			}
		}
	},
	Caelinfernum = {
		Icon = "rbxassetid://83665019925883",
		DisplayText = nil,
		Description = "A striking fusion of regal authority and vibrant rebellion... (concept by @Navyii_)",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3714816761,
		TimeToExpire = DateTime.fromUniversalTime(2026, 10, 3, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "caelin_fab",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "fernum",
							WeldToLimb = "Left Arm",
							ActiveUnequipped = false,
							BypassSetting = true
						},
						{
							ModelName = "fernumBACK",
							WeldToLimb = "Torso",
							HideEquipped = true,
							BypassSetting = true
						},
						{
							ModelName = "CaeBodyAura",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						},
						{
							ModelName = "CaeWingsAura",
							WeldToLimb = "Torso",
							ActiveUnequipped = true
						}
					}
				}
			}
		}
	}
}