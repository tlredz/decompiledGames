return {
	QAString = {
		Icon = "rbxassetid://78296151720703",
		DisplayText = nil,
		Description = ":3",
		Rarity = "Secret",
		Untradeable = true,
		RodPatches = {
			ReelGuiName = "noiseform_qastring",
			FishingPassives = {
				ShadowEntity = {
					ModelName = "Noiseform-Goober"
				}
			}
		}
	},
	["Chromatic Noiseform"] = {
		Icon = "rbxassetid://137518162486641",
		DisplayText = nil,
		Description = "rainbow",
		Rarity = "Secret"
	},
	SideTrackz = {
		Icon = "rbxassetid://103705131325574",
		DisplayText = nil,
		Description = "Remix: LexyDoesStuff",
		Rarity = "Secret",
		Untradeable = true,
		RodPatches = {
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "SidetraxzArrows",
							WeldToLimb = "Torso",
							ActiveUnequipped = true
						}
					}
				},
				ShadowEntity = {
					ModelName = "Noiseform-SideTrackz",
					DontOverrideTransparency = true
				}
			}
		}
	},
	Retraxx = {
		Icon = "rbxassetid://75672027402673",
		DisplayText = nil,
		Description = "Music: Rotteen",
		Rarity = "Secret",
		Untradeable = true,
		RodPatches = {
			FishingPassives = {
				ShadowEntity = {
					ModelName = "Noiseform-Retraxx",
					DontOverrideTransparency = true
				}
			}
		}
	},
	Kaboom = {
		Icon = "rbxassetid://77368742337920",
		DisplayText = "Kaboom!",
		Description = "Some instruments are built for melodies, but this one was engineered to start a riot!",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3605587704,
		TimeToExpire = DateTime.fromUniversalTime(2026, 6, 27, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "kaboom_noiseform",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "KaboomBomb",
							WeldToLimb = "Torso",
							ActiveUnequipped = true
						},
						{
							ModelName = "KaboomBodyAura",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						}
					}
				},
				ShadowEntity = {
					ModelName = "Noiseform-Kaboom",
					DontOverrideTransparency = true
				}
			},
			ClientFishingPassives = {
				Noiseform = {
					StarImage = "BeamStar_Kaboom"
				}
			}
		}
	},
	Ecosync = {
		Icon = "rbxassetid://128733867847086",
		DisplayText = nil,
		Description = "oh how nostalgic...!",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3609216181,
		TimeToExpire = DateTime.fromUniversalTime(2026, 7, 18, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "ecosync_noiseform",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "EcosyncLaptop",
							WeldToLimb = "HumanoidRootPart"
						}
					}
				},
				ShadowEntity = {
					ModelName = "Ecosync-Noiseform",
					DontOverrideTransparency = true
				}
			},
			ClientFishingPassives = {
				Noiseform = {
					StarImage = "BeamStar_Ecosync"
				}
			}
		}
	},
	["Infrared Tunes"] = {
		Icon = "rbxassetid://138867659843065",
		DisplayText = nil,
		Description = "Rockin' in the infrared moonlight, bumping beats only the best can produce!",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3611566973,
		TimeToExpire = DateTime.fromUniversalTime(2026, 8, 1, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "infrared_noiseform",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "InfraredBodyAura",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						},
						{
							ModelName = "InfraredSpeakers",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						}
					}
				},
				ShadowEntity = {
					ModelName = "Infrared-Noiseform",
					DontOverrideTransparency = true
				}
			},
			ClientFishingPassives = {
				Noiseform = {
					StarImage = "BeamStar_Infrared"
				}
			}
		}
	},
	["Dubstep Gun"] = {
		Icon = "rbxassetid://104018287685921",
		DisplayText = nil,
		Description = "",
		Rarity = "Secret",
		Untradeable = true
	},
	Revenant = {
		Icon = "rbxassetid://120176669546622",
		DisplayText = nil,
		Description = "Enchained eternally.\n[Music: DM Dokuro]",
		Rarity = "Secret",
		Untradeable = true,
		RodPatches = {
			ReelGuiName = "revenant",
			FishingPassives = {
				ShadowEntity = {
					ModelName = "RevenantNPC",
					DontOverrideTransparency = true
				}
			},
			ClientFishingPassives = {
				Noiseform = {
					StarImage = "BeamStar_Revenant"
				}
			}
		}
	},
	["Chroma Revenant"] = {
		Icon = "rbxassetid://88776433857758",
		DisplayText = nil,
		Description = "Enchained eternally, in a colorful way.\n[Music: DM Dokuro]",
		Rarity = "Secret",
		Untradeable = true,
		RodPatches = {
			ReelGuiName = "revenant",
			FishingPassives = {
				ShadowEntity = {
					ModelName = "RevenantNPC",
					DontOverrideTransparency = true
				}
			},
			ClientFishingPassives = {
				Noiseform = {
					StarImage = "BeamStar_ChromaRevenant"
				}
			}
		}
	},
	Ravereign = {
		Icon = "rbxassetid://104207741584372",
		DisplayText = nil,
		Description = "Was that your intention?\n[Music: DM Dokuro]",
		Rarity = "Secret",
		Untradeable = true,
		RodPatches = {
			ReelGuiName = "noiseform_ravereign",
			FishingPassives = {
				ShadowEntity = {
					ModelName = "Noiseform-Mastery",
					DontOverrideTransparency = true
				}
			}
		}
	},
	Rawrboard = {
		Icon = "rbxassetid://91101825121596",
		DisplayText = nil,
		Description = "do u even sk8 bro???",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3709279607,
		TimeToExpire = DateTime.fromUniversalTime(2026, 8, 29, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "rawrboard_noiseform",
			FishingPassives = {
				ShadowEntity = {
					ModelName = "Rawrboard-Noiseform",
					DontOverrideTransparency = true
				},
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "DinoProp",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						}
					}
				}
			},
			ClientFishingPassives = {
				Noiseform = {
					StarImage = "BeamStar_Rawrboard"
				}
			}
		}
	},
	Petrichor = {
		Icon = "rbxassetid://88872352624998",
		DisplayText = nil,
		Description = "Forecast says rain, but the strings say otherwise; creating my own atmosphere, one chord at a time.. (concept by @skylarest, music by @nekomimimodee)",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3713496089,
		TimeToExpire = DateTime.fromUniversalTime(2026, 9, 26, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "petrichor_noiseform",
			FishingPassives = {
				ShadowEntity = {
					ModelName = "Petrichor-Noiseform",
					DontOverrideTransparency = true
				},
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "PetrichorBodyAura",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						}
					}
				}
			},
			ClientFishingPassives = {
				Noiseform = {
					StarImage = "BeamStar_Petrichor"
				}
			}
		}
	}
}