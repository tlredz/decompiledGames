return {
	["Dutchman's Penance"] = {
		Icon = "rbxassetid://120990713757649",
		DisplayText = nil,
		Description = "Whispers from the locker, forged in the depths of a restless sea; a phantom's blade that never stays buried...",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3581115425,
		TimeToExpire = DateTime.fromUniversalTime(2026, 5, 2, 16).UnixTimestamp,
		RodPatches = {
			FishingPassives = {
				StarcallerCry = {
					VfxModelName = "GravityVfxDutchman"
				},
				MeteorShower = {
					MeteorModelName = "DutchmanMeteor"
				}
			},
			ClientFishingPassives = {
				CollapsingStars = {
					VfxName = "DutchmanStar"
				}
			}
		}
	},
	["Moonlit Divinity"] = {
		Icon = "rbxassetid://90709540394226",
		DisplayText = nil,
		Description = "cc slop",
		Rarity = "Legendary",
		Untradeable = true
	},
	["Olympian Dawnmaker"] = {
		Icon = "rbxassetid://111634507509334",
		DisplayText = "Lua Marinha",
		Description = "Music by Juia",
		Rarity = "Secret",
		Untradeable = true,
		RodPatches = {
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "MarinhaVFXWings",
							WeldToLimb = "Torso",
							ActiveUnequipped = true
						},
						{
							ModelName = "MarinhaMoonVFX",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						}
					}
				},
				StarcallerCry = {
					VfxModelName = "GravityVfxBlue"
				},
				MeteorShower = {
					MeteorModelName = "MarinhaMeteor"
				}
			}
		}
	},
	Celestiana = {
		Icon = "rbxassetid://86523054434589",
		DisplayText = nil,
		Description = "Guarding the plushie kingdom with the power of rainbows and magic!",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3597241758,
		TimeToExpire = DateTime.fromUniversalTime(2026, 5, 30, 16).UnixTimestamp,
		RodPatches = {
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "CelestianaPlush",
							WeldToLimb = "Left Arm"
						}
					}
				},
				StarcallerCry = {
					VfxModelName = "GravityVfxCelestiana"
				},
				MeteorShower = {
					MeteorModelName = "CelestianaMeteor"
				}
			},
			ClientFishingPassives = {
				CollapsingStars = {
					VfxName = "CelestianaStar"
				}
			}
		}
	},
	["Platinum Menace"] = {
		Icon = "rbxassetid://110103765656673",
		DisplayText = nil,
		Description = "A violet-hued masterpiece crafted for those who refuse to back down from destiny...",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3602739807,
		TimeToExpire = DateTime.fromUniversalTime(2026, 6, 13, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "olympian_platinum",
			FishingPassives = {
				StarcallerCry = {
					VfxModelName = "GravityVfxPlatinum"
				},
				MeteorShower = {
					MeteorModelName = "OlympianGodbreakerMeteor"
				}
			},
			ClientFishingPassives = {
				CollapsingStars = {
					VfxName = "PlatinumStar"
				}
			}
		}
	},
	["Fishi Citrus"] = {
		Icon = "rbxassetid://80921344881749",
		DisplayText = nil,
		Description = "orange you glad?",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3605587601,
		TimeToExpire = DateTime.fromUniversalTime(2026, 6, 27, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "fishi_olympian",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "FishiProp",
							WeldToLimb = "Torso"
						}
					}
				},
				StarcallerCry = {
					VfxModelName = "GravityVfxFishi"
				},
				MeteorShower = {
					MeteorModelName = "FishiMeteor"
				}
			},
			ClientFishingPassives = {
				CollapsingStars = {
					VfxName = "FishiStar"
				}
			}
		}
	},
	["Olympian Ascension"] = {
		Icon = "rbxassetid://133584966227365",
		DisplayText = nil,
		Description = "Obtained from Olympian Godbreaker's Mastery!",
		Rarity = "Legendary",
		Untradeable = true
	},
	["Surgeon's Sword"] = {
		Icon = "rbxassetid://128994370960405",
		DisplayText = nil,
		Description = "The weak do not get to decide how they die..",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3608023454,
		TimeToExpire = DateTime.fromUniversalTime(2026, 7, 11, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "surgeon_olympian",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "SurgeonHat",
							WeldToLimb = "Head",
							ActiveUnequipped = true
						},
						{
							ModelName = "SurgeonCape",
							WeldToLimb = "Torso",
							ActiveUnequipped = true
						}
					}
				},
				StarcallerCry = {
					VfxModelName = "GravityVfxSurgeon"
				},
				MeteorShower = {
					MeteorModelName = "SurgeonMeteor"
				}
			},
			ClientFishingPassives = {
				CollapsingStars = {
					VfxName = "SurgeonStar"
				}
			}
		}
	},
	Amouria = {
		Icon = "rbxassetid://125394873471617",
		DisplayText = nil,
		Description = "It dances between my fingers like a harmless toy, but a single misstep wakes the sleeping, beautiful blade. <3",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3612546443,
		TimeToExpire = DateTime.fromUniversalTime(2026, 8, 8, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "amouria_olympian",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "AmouriaWings",
							WeldToLimb = "Torso",
							ActiveUnequipped = true
						},
						{
							ModelName = "AmouriaTiara",
							WeldToLimb = "Head",
							ActiveUnequipped = true
						}
					}
				},
				StarcallerCry = {
					VfxModelName = "GravityVfxAmouria"
				},
				MeteorShower = {
					MeteorModelName = "AmouriaMeteor"
				}
			},
			ClientFishingPassives = {
				CollapsingStars = {
					VfxName = "AmouriaStar"
				}
			}
		}
	},
	["Angel's Minigame"] = {
		Icon = "rbxassetid://131572261690368",
		DisplayText = nil,
		Description = "Sing with the choir, battle alongside the angels...",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3708116319,
		TimeToExpire = DateTime.fromUniversalTime(2026, 8, 22, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "angels_olympian",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "AngelHeadWings",
							WeldToLimb = "Head",
							ActiveUnequipped = true
						}
					}
				},
				StarcallerCry = {
					VfxModelName = "GravityVfxAngel"
				},
				MeteorShower = {
					MeteorModelName = "AngelMeteor"
				}
			},
			ClientFishingPassives = {
				CollapsingStars = {
					VfxName = "AngelStar"
				}
			}
		}
	},
	Fishymotion = {
		Icon = "rbxassetid://112387352572944",
		DisplayText = nil,
		Description = "you cant even fathom these stacks",
		Rarity = "Legendary",
		Limited = true,
		RodPatches = {
			ReelGuiName = "money_olympian",
			FishingPassives = {
				StarcallerCry = {
					VfxModelName = "GravityVfxMoney"
				},
				MeteorShower = {
					MeteorModelName = "MoneyMeteor"
				}
			},
			ClientFishingPassives = {
				CollapsingStars = {
					VfxName = "MoneyStar"
				}
			}
		}
	},
	["Golden Veilsplitter"] = {
		Icon = "rbxassetid://108962999958744",
		DisplayText = nil,
		Description = "Obtained for being a member of the Crew in 1st place during Season 3.",
		Rarity = "Secret",
		Untradeable = true,
		RodPatches = {
			FishingPassives = {
				MeteorShower = {
					MeteorModelName = "GoldenVeilsplitterMeteor"
				}
			}
		}
	},
	["Silver Veilsplitter"] = {
		Icon = "rbxassetid://133697732808967",
		DisplayText = nil,
		Description = "Obtained for being a member of the Crew in 2nd place during Season 3.",
		Rarity = "Secret",
		Untradeable = true,
		RodPatches = {
			FishingPassives = {
				MeteorShower = {
					MeteorModelName = "SilverVeilsplitterMeteor"
				}
			}
		}
	},
	["Bronze Veilsplitter"] = {
		Icon = "rbxassetid://124311581962676",
		DisplayText = nil,
		Description = "Obtained for being a member of the Crew in 3rd place during Season 3.",
		Rarity = "Secret",
		Untradeable = true,
		RodPatches = {
			FishingPassives = {
				MeteorShower = {
					MeteorModelName = "BronzeVeilsplitterMeteor"
				}
			}
		}
	},
	Veilsplitter = {
		Icon = "rbxassetid://107208409695350",
		DisplayText = nil,
		Description = "Obtained for being in the top 50 Crews during Season 3.",
		Rarity = "Secret",
		Untradeable = true,
		RodPatches = {
			FishingPassives = {
				MeteorShower = {
					MeteorModelName = "VeilsplitterMeteor"
				}
			}
		}
	}
}