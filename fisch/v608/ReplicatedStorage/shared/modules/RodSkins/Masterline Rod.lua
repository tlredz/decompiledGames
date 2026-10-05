return {
	["Grand Symphony"] = {
		Icon = "rbxassetid://104833142043877",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3551325634,
		TimeToExpire = DateTime.fromUniversalTime(2026, 3, 14, 17).UnixTimestamp
	},
	["Golden Masterline Rod"] = {
		Icon = "rbxassetid://75851873464014",
		DisplayText = nil,
		Description = "You're a true master.",
		Rarity = "Legendary",
		Untradeable = true
	},
	Nyasterline = {
		Icon = "rbxassetid://129182215923823",
		DisplayText = nil,
		Description = "mrroew :3",
		Rarity = "Secret",
		Untradeable = true,
		DEV = true,
		RodPatches = {
			FishingPassives = {
				RandomPassives = {
					IntervalMin = 120,
					IntervalMax = 300,
					CountMin = 1,
					CountMax = 3,
					BlacklistRods = {},
					SingletonPassives = {},
					BlacklistPassives = {},
					IncludeStats = {},
					IncludeMutationPools = true,
					IncludeOwnedLimiteds = true,
					RequirePassiveOrMutation = true,
					NeverDev = true,
					ForcedRods = {
						"Nico's Yarncaster",
						"Nico's Yarncaster",
						"Nico's Yarncaster",
						"Nico's Yarncaster",
						"Nico's Yarncaster"
					}
				}
			}
		}
	},
	["Final Census"] = {
		Icon = "rbxassetid://93155573791864",
		DisplayText = nil,
		Description = "The ink dries faster than the heartbeat slows; your time belongs to the page...",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3604280734,
		TimeToExpire = DateTime.fromUniversalTime(2026, 6, 20, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "masterline_finalcensus",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "FinalCensusBook",
							WeldToLimb = "Left Arm",
							BypassSetting = true
						},
						{
							ModelName = "FinalCensusBodyAura",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						},
						{
							ModelName = "FinalCensusEye",
							WeldToLimb = "Head",
							ActiveUnequipped = true
						},
						{
							ModelName = "FinalCensusRyukHand",
							WeldToLimb = "Torso",
							ActiveUnequipped = true
						}
					}
				}
			}
		}
	},
	["Gummy Bam"] = {
		Icon = "rbxassetid://104149804820775",
		DisplayText = "Gummy Bam!",
		Description = "squish squish",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3608006506,
		TimeToExpire = DateTime.fromUniversalTime(2026, 7, 11, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "masterline_gummybam",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "GummyBamBear",
							WeldToLimb = "Torso"
						}
					}
				}
			}
		}
	},
	Malisteel = {
		Icon = "rbxassetid://104152709748175",
		DisplayText = nil,
		Description = "...!",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3611519906,
		TimeToExpire = DateTime.fromUniversalTime(2026, 8, 1, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "malisteel_masterline",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "MalisteelBodyAura",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						}
					}
				}
			}
		}
	},
	Tenna = {
		Icon = "rbxassetid://116754356791390",
		DisplayText = nil,
		Description = "It's... T V TIMEE!!!",
		Rarity = "Secret",
		Untradeable = true,
		DEV = true,
		RodPatches = {
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "Tenna_Head",
							WeldToLimb = "Head"
						},
						{
							ModelName = "Tenna_LeftArm",
							WeldToLimb = "Left Arm"
						},
						{
							ModelName = "Tenna_RightArm",
							WeldToLimb = "Right Arm"
						},
						{
							ModelName = "Tenna_LeftLeg",
							WeldToLimb = "Left Leg"
						},
						{
							ModelName = "Tenna_RightLeg",
							WeldToLimb = "Right Leg"
						},
						{
							ModelName = "Tenna_Torso",
							WeldToLimb = "Torso"
						}
					}
				}
			}
		}
	},
	["Sanctuarium Lucis Seraphim"] = {
		Icon = "rbxassetid://103012947078657",
		DisplayText = nil,
		Description = "Sanctuary light given form. Carried only by those who finished the mission.",
		Rarity = "Legendary",
		Untradeable = true,
		RodPatches = {
			ReelGuiName = "masterline_sanctuarium"
		}
	},
	Masterscepter = {
		Icon = "rbxassetid://129267712691429",
		DisplayText = nil,
		Description = "You're a true master.",
		Rarity = "Legendary",
		Untradeable = true,
		RodPatches = {
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "MasterlineAura",
							WeldToLimb = "HumanoidRootPart"
						}
					}
				}
			}
		}
	},
	["Brutal Redemption"] = {
		Icon = "rbxassetid://94917573316259",
		DisplayText = nil,
		Description = "It sleeps behind teeth of steel, but now it wakes to feed...",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3708108906,
		TimeToExpire = DateTime.fromUniversalTime(2026, 8, 22, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "brutal_masterline",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "BrutalBodyAura",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true,
							HaloColorSelector = "Model#ColorChanging >> Instance"
						},
						{
							ModelName = "BrutalLeftArmAura",
							WeldToLimb = "Left Arm",
							ActiveUnequipped = true,
							HaloColorSelector = "Model#ColorChanging >> Instance"
						},
						{
							ModelName = "BrutalEyeCensor",
							WeldToLimb = "Head",
							ActiveUnequipped = true,
							HaloColorSelector = "Model#ColorChanging >> Instance"
						}
					}
				}
			}
		}
	},
	["Mysterious Cape"] = {
		Icon = "rbxassetid://79734286308752",
		DisplayText = nil,
		Description = "suspicious.",
		Rarity = "Secret",
		Untradeable = true,
		RodPatches = {
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "Flower_Head",
							WeldToLimb = "Head"
						},
						{
							ModelName = "Flower_LeftArm",
							WeldToLimb = "Left Arm"
						},
						{
							ModelName = "Flower_RightArm",
							WeldToLimb = "Right Arm"
						},
						{
							ModelName = "Flower_LeftLeg",
							WeldToLimb = "Left Leg"
						},
						{
							ModelName = "Flower_RightLeg",
							WeldToLimb = "Right Leg"
						},
						{
							ModelName = "Flower_Torso",
							WeldToLimb = "Torso"
						},
						{
							ModelName = "Flower_Cape",
							WeldToLimb = "Torso"
						}
					}
				}
			}
		}
	},
	["Partnade Serenade"] = {
		Icon = "rbxassetid://136227109185460",
		DisplayText = nil,
		Description = "A serenade made entirely of parts. Takes on the color of your halo.",
		Rarity = "Legendary",
		Untradeable = true
	},
	AntiMatter = {
		Icon = "rbxassetid://71861657072952",
		DisplayText = nil,
		Description = "your flesh, woven by the vacuum of the dark cosmos; your touch, riddled with cataclysmic energy.. (concept by @Navyii_, sfx by @Akira_Blade)",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3711332917,
		TimeToExpire = DateTime.fromUniversalTime(2026, 9, 12, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "anti_masterline",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "MaskProp",
							WeldToLimb = "Head",
							ActiveUnequipped = true
						},
						{
							ModelName = "EmblemProp",
							WeldToLimb = "Torso",
							ActiveUnequipped = true
						},
						{
							ModelName = "RightClawProp",
							WeldToLimb = "Right Arm",
							ActiveUnequipped = true,
							BypassSetting = true
						},
						{
							ModelName = "LeftKnifeProp",
							WeldToLimb = "Left Arm",
							ActiveUnequipped = true
						},
						{
							ModelName = "AntiBodyAura",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						}
					}
				}
			}
		}
	}
}