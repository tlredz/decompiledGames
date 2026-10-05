return {
	Copperbound = {
		Icon = "rbxassetid://133348699433617",
		DisplayText = "Copperbound",
		Description = "Huh, I guess Shimmer really is powerful.",
		Rarity = "Legendary",
		Untradeable = true
	},
	Terra = {
		Icon = "rbxassetid://118509356047906",
		DisplayText = "Terra | WIP",
		Description = "WIP",
		Rarity = "Secret",
		Untradeable = true
	},
	Echolocator = {
		Icon = "rbxassetid://109887192447268",
		DisplayText = nil,
		Description = "The darkness doesn't need eyes to see you; it only needs to listen...",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3588993531,
		TimeToExpire = DateTime.fromUniversalTime(2026, 5, 16, 16).UnixTimestamp,
		RodPatches = {
			FishingPassives = {
				ShadowEntity = {
					ModelName = "Echolocator-Stardust"
				}
			}
		}
	},
	CritSlasher = {
		Icon = "rbxassetid://88457217323923",
		DisplayText = nil,
		Description = "Total sensory corruption; a shifting silhouette of razor-sharp static that blurs when you look...",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3600909708,
		TimeToExpire = DateTime.fromUniversalTime(2026, 6, 6, 16).UnixTimestamp,
		RodPatches = {
			FishingPassives = {
				ShadowEntity = {
					ModelName = "CritSlasher-Stardust"
				}
			}
		}
	},
	uLemon = {
		Icon = "rbxassetid://124417702473438",
		DisplayText = nil,
		Description = "sour selfies!",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3605587599,
		TimeToExpire = DateTime.fromUniversalTime(2026, 6, 27, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "ulemon_castbound",
			FishingPassives = {
				ShadowEntity = {
					ModelName = "uLemon-Stardust"
				}
			},
			ClientFishingPassives = {
				Castbound = {
					ImagesOverride = {
						"rbxassetid://108893396686942",
						"rbxassetid://76814325296387",
						"rbxassetid://108893396686942",
						"rbxassetid://76814325296387",
						"rbxassetid://108893396686942",
						"rbxassetid://76814325296387",
						"rbxassetid://108893396686942",
						"rbxassetid://76814325296387",
						"rbxassetid://108893396686942"
					}
				}
			}
		}
	},
	RoboChomp = {
		Icon = "rbxassetid://124539712307916",
		DisplayText = "RoboChomp!",
		Description = "Part machine, part beast, pure power.",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3609220773,
		TimeToExpire = DateTime.fromUniversalTime(2026, 7, 18, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "robochomp_castbound",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "RoboBodyAura",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						}
					}
				},
				ShadowEntity = {
					ModelName = "RoboChomp-Stardust"
				}
			},
			ClientFishingPassives = {
				Castbound = {
					ImagesOverride = {
						"rbxassetid://72215217646996",
						"rbxassetid://72215217646996",
						"rbxassetid://72215217646996",
						"rbxassetid://72215217646996",
						"rbxassetid://72215217646996",
						"rbxassetid://72215217646996",
						"rbxassetid://72215217646996",
						"rbxassetid://72215217646996",
						"rbxassetid://72215217646996"
					}
				}
			}
		}
	},
	Burgerbound = {
		Icon = "rbxassetid://129139485904175",
		DisplayText = nil,
		Description = "iamaburger (concept by @Dhryldlsx)",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3712471755,
		TimeToExpire = DateTime.fromUniversalTime(2026, 9, 19, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "burger_castbound",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "BurgerBackpack",
							WeldToLimb = "Torso",
							ActiveUnequipped = true,
							BypassSetting = true
						},
						{
							ModelName = "MiniBurgerProp",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true,
							BypassSetting = true
						}
					}
				},
				ShadowEntity = {
					ModelName = "burger-Stardust"
				}
			},
			ClientFishingPassives = {
				Castbound = {
					ImagesOverride = {
						"rbxassetid://135815153038878",
						"rbxassetid://135815153038878",
						"rbxassetid://135815153038878",
						"rbxassetid://135815153038878",
						"rbxassetid://135815153038878",
						"rbxassetid://135815153038878",
						"rbxassetid://135815153038878",
						"rbxassetid://135815153038878",
						"rbxassetid://135815153038878"
					}
				}
			}
		}
	}
}