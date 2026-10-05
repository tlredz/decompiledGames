return {
	["Cathedra Requiei"] = {
		Icon = "rbxassetid://92770253725081",
		DisplayText = nil,
		Description = "A relic altar of the Chapel. Its hymn ends every catch with quiet finality.",
		Rarity = "Legendary",
		Untradeable = true,
		RodPatches = {
			ReelGuiName = "requiem_cathedra"
		}
	},
	["Requiem Aeternum"] = {
		Icon = "rbxassetid://125870936572929",
		DisplayText = nil,
		Description = "shoutout leo",
		Rarity = "Legendary"
	},
	["Stellar Labrys"] = {
		Icon = "rbxassetid://79743967143450",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3541976252,
		TimeToExpire = DateTime.fromUniversalTime(2026, 2, 28, 17).UnixTimestamp
	},
	["Neon Beats"] = {
		Icon = "rbxassetid://110430726865005",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3560532970,
		TimeToExpire = DateTime.fromUniversalTime(2026, 3, 28, 17).UnixTimestamp
	},
	["Bubbly Benediction"] = {
		Icon = "rbxassetid://83330888347648",
		DisplayText = nil,
		Description = "Forged with curves as light as air, finished in the shimmer of morning dew; alike a floating iridescent pearl, crafted with whimsy and wonder...",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3577590568,
		TimeToExpire = DateTime.fromUniversalTime(2026, 4, 25, 16).UnixTimestamp
	},
	["Pretty Painter"] = {
		Icon = "rbxassetid://109838976433699",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3597204655,
		TimeToExpire = DateTime.fromUniversalTime(2026, 5, 30, 16).UnixTimestamp
	},
	["Requne Grape"] = {
		Icon = "rbxassetid://73371793379913",
		DisplayText = nil,
		Description = "sour grapes",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3604315513,
		TimeToExpire = DateTime.fromUniversalTime(2026, 6, 20, 16).UnixTimestamp
	},
	["Pow-Nom"] = {
		Icon = "rbxassetid://100480095498531",
		DisplayText = nil,
		Description = "chomp chomp chomp!",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3610395611,
		TimeToExpire = DateTime.fromUniversalTime(2026, 7, 25, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "pownom_requiem",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "BiteyProp",
							WeldToLimb = "HumanoidRootPart",
							BypassSetting = true
						}
					}
				}
			}
		}
	},
	Dovepoint = {
		Icon = "rbxassetid://126199875367977",
		DisplayText = nil,
		Description = "nature of elegance...",
		Rarity = "Legendary",
		Limited = true,
		TimeToExpire = DateTime.fromUniversalTime(2026, 8, 29, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "dovepoint_requiem",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "DoveProp",
							WeldToLimb = "Head",
							ActiveUnequipped = true
						}
					}
				}
			}
		}
	},
	["Ethereal Requiem"] = {
		Icon = "rbxassetid://78642288483730",
		DisplayText = nil,
		Description = "its blue and stuff man. idk what u want me to say",
		Rarity = "Legendary",
		Untradeable = true
	}
}