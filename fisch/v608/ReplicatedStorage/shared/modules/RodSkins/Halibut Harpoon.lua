return {
	["Pufferfish Harpoon"] = {
		Icon = "rbxassetid://93613551024849",
		DisplayText = nil,
		Description = [[
ough
Music: @TMZXZ
VFX: @RRmarr]],
		Rarity = "Legendary",
		Untradeable = true,
		RodPatches = {
			ReelGuiName = "halibutharpoon_puffer",
			ShakeButtonName = "halibutharpoon_puffer"
		}
	},
	["Test Halibut Skin"] = {
		Icon = "rbxassetid://93613551024849",
		DisplayText = nil,
		Description = "meow",
		Rarity = "Legendary"
	},
	["Party Puffer"] = {
		Icon = "rbxassetid://79529236944043",
		DisplayText = nil,
		Description = "It's my Puffer Partayyy!!! (100TH UPDATE SPECIAL)",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3710299905,
		TimeToExpire = DateTime.fromUniversalTime(2026, 9, 5, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "party_halibut",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "PufferPinata",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true,
							BypassSetting = true
						},
						{
							ModelName = "PartyBodyAura",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						}
					}
				}
			}
		}
	},
	["Salty Sardines"] = {
		Icon = "rbxassetid://99874327227741",
		DisplayText = nil,
		Description = "oouuu saltyyy! (concept by Ata @gtbtbya23)",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3713535237,
		TimeToExpire = DateTime.fromUniversalTime(2026, 9, 26, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "sardine_halibut",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "tinofsardines",
							WeldToLimb = "Torso",
							ActiveUnequipped = true
						}
					}
				}
			}
		}
	}
}