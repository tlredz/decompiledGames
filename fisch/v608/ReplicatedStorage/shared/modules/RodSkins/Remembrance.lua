local ReplicatedStorage = game:GetService("ReplicatedStorage")
local apply_op = require(ReplicatedStorage.shared.utils.GeneralUtils.apply_op)
return {
	Dawnmaker = {
		Icon = "rbxassetid://111634507509334",
		DisplayText = "Lua Marinha",
		Description = "Music by Juia (WIP)",
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
				}
			}
		}
	},
	["The Butterfly's Wake"] = {
		Icon = "rbxassetid://111159980770547",
		DisplayText = nil,
		Description = "",
		Rarity = "Legendary",
		Untradeable = true,
		RodPatches = {
			FishingPassives = {
				Generic_WeldAccessory = apply_op.DELETE
			}
		}
	},
	["The Duet"] = {
		Icon = "rbxassetid://90797490971894",
		DisplayText = nil,
		Description = [[
There's SOMETHING behind you...
by: @zomboss1116, @taconoodletoes, and @esmulambido]],
		Rarity = "Secret",
		Untradeable = true,
		RodPatches = {
			FishingPassives = {
				Generic_WeldAccessory = apply_op.DELETE
			},
			ReelGuiName = apply_op.MAP({
				remembrance_living = "theduet_violin",
				remembrance_departed = "theduet_knife"
			})
		}
	},
	["Cherry Boom"] = {
		Icon = "rbxassetid://110727524195002",
		DisplayText = nil,
		Description = "cherry cherry boom!!!!!",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3610407299,
		TimeToExpire = DateTime.fromUniversalTime(2026, 7, 25, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = "cherry_remembrance",
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "CherryBoomProp",
							WeldToLimb = "Left Arm",
							BypassSetting = true
						}
					}
				}
			}
		}
	},
	["Solstice Partners"] = {
		Icon = "rbxassetid://71083673037463",
		DisplayText = nil,
		Description = "(music by @nekomimimodee)",
		Rarity = "Legendary",
		Limited = true,
		DevProduct = 3713494771,
		TimeToExpire = DateTime.fromUniversalTime(2026, 9, 26, 16).UnixTimestamp,
		RodPatches = {
			ReelGuiName = apply_op.MAP({
				remembrance_living = "solstice_sun",
				remembrance_departed = "solstice_moon"
			}),
			FishingPassives = {
				Generic_WeldAccessory = {
					Models = {
						{
							ModelName = "SolsticeSunCloud",
							WeldToLimb = "HumanoidRootPart",
							OnlyMode = "Living",
							ActiveUnequipped = true,
							BypassSetting = true
						},
						{
							ModelName = "SolsticeMoonCloud",
							WeldToLimb = "HumanoidRootPart",
							OnlyMode = "Departed",
							ActiveUnequipped = true,
							BypassSetting = true
						}
					}
				}
			}
		}
	}
}