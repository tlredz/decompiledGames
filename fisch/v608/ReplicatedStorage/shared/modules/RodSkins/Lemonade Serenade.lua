return {
	["Limeade Serenade"] = {
		Icon = "rbxassetid://107930639196396",
		DisplayText = nil,
		Description = [[
<font color='#ffffff'><b>Exclusive effect:</b></font>
While equipped or favorited, can catch the <font color='#a8ff61'><b>Lime</b></font> mutation!]],
		DescriptionRich = true,
		Rarity = "Legendary",
		Untradeable = true,
		RodPatches = {
			ReelGuiName = "limereel",
			ClientFishingPassives = {
				LemonadeSerenade = {
					OverrideDropletIcon = "rbxassetid://72869417128595"
				}
			},
			FishingPassives = {
				Lemonade = {
					LemonModelName = "Lime"
				}
			}
		}
	},
	["Berrynade Serenade"] = {
		Icon = "rbxassetid://124609453717114",
		DisplayText = nil,
		Description = [[
<font color='#ffffff'><b>Exclusive effect:</b></font>
While equipped or favorited, can catch the <font color='#ff6c6e'><b>Strawberry</b></font> mutation!]],
		DescriptionRich = true,
		Rarity = "Legendary",
		Untradeable = true,
		RodPatches = {
			ReelGuiName = "berryreel",
			ClientFishingPassives = {
				LemonadeSerenade = {
					OverrideDropletIcon = "rbxassetid://102288565494973"
				}
			},
			FishingPassives = {
				Lemonade = {
					LemonModelName = "Strawberry"
				}
			}
		}
	},
	["Bananade Serenade"] = {
		Icon = "rbxassetid://99806070039312",
		DisplayText = nil,
		Description = [[
<font color='#ffffff'><b>Exclusive effect:</b></font>
While equipped or favorited, can catch the <font color='#fff8a9'><b>Banana</b></font> mutation!]],
		DescriptionRich = true,
		Rarity = "Legendary",
		Untradeable = true,
		RodPatches = {
			ReelGuiName = "bananareel",
			ClientFishingPassives = {
				LemonadeSerenade = {
					OverrideDropletIcon = "rbxassetid://128473315667069"
				}
			},
			FishingPassives = {
				Lemonade = {
					LemonModelName = "Banana"
				}
			}
		}
	},
	["Blueberry Serenade"] = {
		Icon = "rbxassetid://125010478693935",
		DisplayText = nil,
		Description = [[
<font color='#ffffff'><b>Exclusive effect:</b></font>
While equipped or favorited, can catch the <font color='#4a74ff'><b>Blueberry</b></font> mutation!]],
		DescriptionRich = true,
		Rarity = "Legendary",
		Untradeable = true,
		RodPatches = {
			ReelGuiName = "blueberryreel",
			ClientFishingPassives = {
				LemonadeSerenade = {
					OverrideDropletIcon = "rbxassetid://101789593248393"
				}
			}
		}
	},
	["Lavender Serenade"] = {
		Icon = "rbxassetid://91265993700506",
		DisplayText = nil,
		Description = [[
<font color='#ffffff'><b>Exclusive effect:</b></font>
While equipped or favorited, can catch the <font color='#d8bcff'><b>Lavender</b></font> mutation!]],
		DescriptionRich = true,
		Rarity = "Legendary",
		Untradeable = true,
		RodPatches = {
			ReelGuiName = "lavenderreel",
			ClientFishingPassives = {
				LemonadeSerenade = {
					OverrideDropletIcon = "rbxassetid://114093776088040"
				}
			}
		}
	},
	["Mango Tango"] = {
		Icon = "rbxassetid://84894830102103",
		DisplayText = "Mango Tango!",
		Description = "Have you ever eaten a mango? I love mangoes and I hope you do too. Enjoy my mango skin!",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3646432188,
		TimeToExpire = DateTime.fromUniversalTime(2026, 8, 15, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "mango_lemonade",
			ShakeButtonName = "mango_tango",
			ClientFishingPassives = {
				LemonadeSerenade = {
					OverrideDropletIcon = "rbxassetid://88830423136016"
				}
			},
			FishingPassives = {
				Lemonade = {
					LemonModelName = "MangoFriend"
				},
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "MangoFriendProp",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						},
						{
							ModelName = "MangoBodyAura",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						}
					}
				}
			}
		}
	},
	Lemeownade = {
		Icon = "rbxassetid://132044214271805",
		DisplayText = nil,
		Description = "meow (but hydrated)",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3710327789,
		TimeToExpire = DateTime.fromUniversalTime(2026, 9, 5, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "lemon_lemonade",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "LemonKittyProp",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						}
					}
				}
			},
			ClientFishingPassives = {
				LemonadeSerenade = {
					OverrideDropletIcon = "rbxassetid://110201553596763"
				}
			}
		}
	},
	Boukaloid = {
		Icon = "rbxassetid://112161771415953",
		DisplayText = nil,
		Description = "im the yellow one",
		Rarity = "Legendary",
		Untradeable = true,
		RodPatches = {
			ReelGuiName = "migurod_boukar",
			FishingPassives = {
				Lemonade = {
					LemonModelName = "BoukaPhoneProp"
				}
			}
		}
	}
}