return {
	["Joyous Lollipop"] = {
		Icon = "rbxassetid://87104386529082",
		DisplayText = nil,
		Description = "YAAAAAAAAAAAAAAAAAAAAAAAAAY",
		Rarity = "Legendary",
		Limited = true,
		RodPatches = {
			ReelGuiName = "joyous_crowbar",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "JoyousDogProp",
							WeldToLimb = "HumanoidRootPart",
							ActiveUnequipped = true
						}
					}
				},
				ReRod = {
					PropName = "LollipopSwing",
					VfxName = "CrowbarVFX",
					SoundName = "rerod"
				}
			}
		}
	},
	Exclamatorius = {
		Icon = "rbxassetid://91426815829978",
		DisplayText = nil,
		Description = "! - concept by Axo @Dhryldlsx)",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3709303696,
		TimeToExpire = DateTime.fromUniversalTime(2026, 8, 29, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "exclamatorius_crowbar",
			FishingPassives = {
				ReRod = {
					PropName = "ExclamationSwing",
					VfxName = "ExclamationVfx",
					SoundName = "exclamation"
				}
			}
		}
	}
}