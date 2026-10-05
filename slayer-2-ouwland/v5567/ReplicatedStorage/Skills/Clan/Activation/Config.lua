local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
return {
	LOCK = 0.35,
	DEFAULT_DURATION = gameSettings.modeDuration,
	STAT_MARKS = {
		["Blood Bewitchment"] = {
			Duration = 10,
			Enemies = true,
			EnemyDuration = 4,
			["Movement Speed Factor"] = -0.06,
			["Stamina Drain Rate"] = 0.06,
			["Block Regen"] = -0.03
		},
		["Ghost Attendance Mode"] = {
			["Dash Speed Factor"] = 1,
			["Sword Damage Factor"] = 0.15
		},
		["Poison Draw Mode"] = {
			["Insect Damage Factor"] = 0.2,
			["Movement Speed Factor"] = 0.1,
			["Dash Speed Factor"] = 0.15,
			["Poison Damage Factor"] = 0.1,
			["Cooldown Reduction Factor"] = 0.05
		},
		["Poison Generation"] = {
			Duration = 7
		},
		["Flowing Motion"] = {
			Duration = 1
		},
		["Marechi's Blade"] = {
			Duration = 10
		},
		["Sleepless Knight Mode"] = {
			["Thunder Damage Factor"] = 0.2,
			["Movement Speed Factor"] = 0.05,
			["Additional Damage Factor"] = 0.03,
			["Cooldown Reduction Factor"] = 0.12,
			["Dash Speed Factor"] = 0.35
		},
		["Stone Skin Mode"] = {
			["Damage Reduction Factor"] = 0.1,
			["Movement Speed Factor"] = 0.05,
			["Stamina Regen Speed"] = 0.04,
			["Health Regen Speed"] = 0.05
		},
		["Serpent's Wrath Mode"] = {
			["Serpent Damage Factor"] = 0.15,
			["Additional Damage Factor"] = 0.03,
			["Movement Speed Factor"] = 0.05,
			["Stamina Regen Speed"] = 0.04
		},
		["Windstorm Vigor Mode"] = {
			["Wind Damage Factor"] = 0.2,
			["Additional Damage Factor"] = 0.1,
			["Movement Speed Factor"] = 0.05,
			["Stamina Cost Factor"] = -0.1
		},
		["Heart Ablaze Mode"] = {
			["Additional Damage Factor"] = 0.18,
			["Movement Speed Factor"] = 0.05,
			["Stamina Regen Speed"] = 0.05,
			["Burn Damage Factor"] = 0.2
		}
	}
}