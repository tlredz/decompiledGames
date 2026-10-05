return {
	["Fire Elemental"] = {
		Icon = "rbxassetid://114006230603980",
		DisplayText = nil,
		Description = "Courage is fire.",
		Rarity = "Secret",
		Untradeable = true,
		DEV = true,
		RodPatches = {
			FishingPassives = {
				Generic_FallingWeapon = {
					ProgressGain = -1,
					OverrideModelName = false
				}
			}
		}
	},
	["Earth Elemental"] = {
		Icon = "rbxassetid://108009780916105",
		DisplayText = nil,
		Description = "Protect Mother Earth with this mighty sword.",
		Rarity = "Secret",
		Untradeable = true,
		DEV = true,
		RodPatches = {
			FishingPassives = {
				Generic_FallingWeapon = {
					ProgressGain = -1,
					OverrideModelName = false
				}
			}
		}
	},
	["Water Elemental"] = {
		Icon = "rbxassetid://77932361133136",
		DisplayText = nil,
		Description = "Time and tides wait for no man.",
		Rarity = "Secret",
		Untradeable = true,
		DEV = true,
		RodPatches = {
			FishingPassives = {
				Generic_FallingWeapon = {
					ProgressGain = -1,
					OverrideModelName = false
				}
			}
		}
	},
	["Glacial Blade"] = {
		Icon = "rbxassetid://132368383399280",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary",
		RodPatches = {
			FishingPassives = {
				Generic_FallingWeapon = {
					OverrideModelName = false
				}
			}
		}
	},
	["Stygian Winter"] = {
		Icon = "rbxassetid://103524738915161",
		DisplayText = nil,
		Description = "It hungers for warmth, promising only the silent, frigid embrace of the final winter",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3508116219,
		TimeToExpire = DateTime.fromUniversalTime(2026, 1, 17, 17).UnixTimestamp,
		RodPatches = {
			FishingPassives = {
				Generic_FallingWeapon = {
					OverrideModelName = false
				}
			}
		}
	}
}