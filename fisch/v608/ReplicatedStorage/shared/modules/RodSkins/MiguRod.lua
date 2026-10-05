return {
	Breadweaver = {
		Icon = "rbxassetid://77297659910536",
		DisplayText = nil,
		Description = "🥖",
		Rarity = "Secret",
		Untradeable = true,
		RodPatches = {
			FishingPassives = {
				Generic_FallingWeapon = {
					OverrideModelName = false,
					ModelScale = 2,
					InitialOffset = CFrame.new(0, 35, 0),
					EndingOffset = CFrame.new(0, -47, 0),
					PivotOffset = CFrame.new(0, 10, 0) * CFrame.Angles(3.141592653589793, 0, 0),
					HitSoundName = "plaguereaver"
				}
			}
		}
	},
	["Golden MiguRod"] = {
		Icon = "rbxassetid://139314745688741",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary",
		Untradeable = true,
		RodPatches = {
			ReelGuiName = "migurod_golden"
		}
	},
	Makhroing = {
		Icon = "rbxassetid://131905453126352",
		DisplayText = nil,
		Description = "ooeeoo",
		Rarity = "Legendary",
		Untradeable = true,
		RodPatches = {
			ReelGuiName = "migurod_makhroing",
			FishingPassives = {
				Generic_FallingWeapon = {
					OverrideModelName = "LeekProp",
					ModelScale = 6,
					InitialOffset = CFrame.new(0, 35, 0),
					EndingOffset = CFrame.new(0, -25, 0)
				}
			}
		}
	},
	Boukar = {
		Icon = "rbxassetid://112161771415953",
		DisplayText = nil,
		Description = "im the yellow one",
		Rarity = "Legendary",
		Untradeable = true,
		RodPatches = {
			ReelGuiName = "migurod_boukar",
			FishingPassives = {
				Generic_FallingWeapon = {
					OverrideModelName = "BoukaPhoneProp",
					ModelScale = 6,
					InitialOffset = CFrame.new(0, 35, 0),
					EndingOffset = CFrame.new(0, -25, 0)
				}
			}
		}
	},
	["Supersonic Lance"] = {
		Icon = "rbxassetid://134079682851488",
		DisplayText = nil,
		Description = "",
		Rarity = "Secret",
		Untradeable = true
	},
	Baguette = {
		Icon = "rbxassetid://109169456576882",
		DisplayText = nil,
		Description = "🥖",
		Rarity = "Legendary"
	},
	["Chroma MiguRod"] = {
		Icon = "rbxassetid://77014167518233",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary"
	},
	Melodii = {
		Icon = "rbxassetid://104633963988052",
		DisplayText = nil,
		Description = "Pink, powerful, and pure pop magic, this keytar is more than ready for the big stage!",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3573839895,
		TimeToExpire = DateTime.fromUniversalTime(2026, 4, 18, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "migurod_melodii"
		}
	},
	["Mankind's Demise"] = {
		Icon = "rbxassetid://104889196843442",
		DisplayText = nil,
		Description = [[
MAY YOUR CATCHES BE MANY... AND YOUR WATERS RED
Model: @EmeraldTrooper
VFX: @Leo & @Error
Animations: @Tawou]],
		Rarity = "Legendary",
		Untradeable = true,
		RodPatches = {
			ReelGuiName = "migurod_mech",
			FishingPassives = {
				Generic_FallingWeapon = {
					OverrideModelName = "MechFistProp",
					HitSoundName = "mecharmhit"
				},
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "MKDCoin",
							WeldToLimb = "HumanoidRootPart",
							BypassSetting = true
						},
						{
							ModelName = "MKDWaterGun",
							WeldToLimb = "Left Arm",
							BypassSetting = true
						}
					}
				}
			},
			ClientFishingPassives = {
				MiguRodClient = {
					SFXSuffix = "_Mech"
				}
			}
		}
	},
	["Time Reaper"] = {
		Icon = "rbxassetid://80729486984864",
		DisplayText = nil,
		Description = "(concept by @jedk, music by @nekomimimodee)",
		Rarity = "Legendary",
		Limited = true,
		RodPatches = {
			ReelGuiName = "time_migurod",
			FishingPassives = {
				Generic_FallingWeapon = {
					OverrideModelName = "TimeScytheProp",
					HitSoundName = "timescythehit"
				},
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "goldwingprop1",
							WeldToLimb = "Torso",
							ActiveUnequipped = true
						},
						{
							ModelName = "goldwingprop2",
							WeldToLimb = "Torso",
							ActiveUnequipped = true
						},
						{
							ModelName = "goldwingprop3",
							WeldToLimb = "Torso",
							ActiveUnequipped = true
						},
						{
							ModelName = "goldwingprop4",
							WeldToLimb = "Torso",
							ActiveUnequipped = true
						},
						{
							ModelName = "GoldTorsoAura",
							WeldToLimb = "Torso",
							ActiveUnequipped = true
						}
					}
				}
			},
			ClientFishingPassives = {
				MiguRodClient = {
					SFXSuffix = "_Time"
				}
			}
		}
	}
}