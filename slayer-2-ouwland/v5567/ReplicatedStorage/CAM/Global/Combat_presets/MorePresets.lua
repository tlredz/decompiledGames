local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.CombatTypes)
return {
	Bear = {
		default = 0.32,
		default_before_hit = 0.4,
		run_swing_remove_on_first = 0,
		final = 1.85,
		Max = 3,
		NoAir = true,
		delay_before_swing = { 0.35, 0.35, 0.2 },
		delay_before_hit = {
			[3] = 0.35
		},
		MinHitboxSize = 5,
		finals = { 3 },
		Reaches = {
			Default = 4.5
		},
		Widths = {
			Default = 4
		},
		Effects = {
			Default = "Normal_Sickle_Slash_Effect"
		}
	},
	Bearcub = {
		default = 0.32,
		default_before_hit = 0.4,
		run_swing_remove_on_first = 0,
		final = 1.85,
		Max = 3,
		NoAir = true,
		delay_before_swing = { 0.35, 0.35, 0.2 },
		delay_before_hit = {
			[3] = 0.35
		},
		finals = { 3 },
		Effects = {
			Default = "Normal_Sickle_Slash_Effect"
		}
	},
	HandDemon = {
		default = 0.32,
		default_before_hit = 0.1,
		default_before_swing = 0.4,
		run_swing_remove_on_first = 0,
		final = 1.85,
		Max = 3,
		NoAir = true,
		regularStunDuration = 1.25,
		finalStunDuration = 2.25,
		delay_before_swing = {
			[3] = 0.65
		},
		MinHitboxSize = 10,
		finals = { 3 },
		Reaches = {
			Default = 3.5
		},
		Widths = {
			Default = 10,
			[3] = 12
		},
		Effects = {
			Default = "Normal_Punch_Effect"
		}
	},
	YetiDemon = {
		default = 0.32,
		default_before_hit = 0.4,
		run_swing_remove_on_first = 0,
		final = 1.85,
		Max = 3,
		NoAir = true,
		delay_before_swing = { 0.35, 0.35, 0.2 },
		delay_before_hit = {
			[3] = 0.35
		},
		MinHitboxSize = 9,
		YOffsets = {
			Default = -2
		},
		Widths = {
			Default = 12
		},
		finals = { 3 },
		Reaches = {
			Default = 7,
			[3] = 8.5
		},
		Effects = {
			Default = "Normal_Punch_Effect"
		}
	},
	SmallYeti = {
		default = 0.32,
		default_before_hit = 0.35,
		run_swing_remove_on_first = 0,
		final = 1.85,
		Max = 3,
		NoAir = true,
		delay_before_hit = {
			[3] = 0.25
		},
		YOffsets = {
			Default = 1
		},
		ZOffsets = {
			Default = 0.5
		},
		finals = { 3 },
		Effects = {
			Default = "Normal_Punch_Effect"
		}
	},
	Tamari = {
		default = 0.26,
		default_before_hit = 0.2,
		default_before_swing = 0.2,
		run_swing_remove_on_first = 0.092,
		final = 1.65,
		AnimSpeed = {
			Default = 1.125,
			[3] = 1.3,
			[4] = 1.5,
			[5] = 0.85
		},
		delay_before_swing = {
			[5] = 0.4,
			[7] = 0.255
		},
		delay_before_hit = {
			[6] = 0.16666666666666666,
			[5] = 0.35,
			[7] = 0.295
		},
		finals = { 5, 7 },
		Widths = {
			Default = 2
		},
		Reaches = {
			Default = 2
		},
		Effects = {
			Default = "Normal_Punch_Effect",
			[7] = "N/A"
		}
	},
	["Obi Manipulation"] = {
		default = 0.25,
		default_before_hit = 0.2,
		run_swing_remove_on_first = -0.025,
		final = 1.65,
		AnimSpeed = {
			Default = 1.15,
			[7] = 1.25
		},
		delay_before_swing = {
			[5] = 0.13,
			[1] = 0.07,
			[7] = 0.25
		},
		delay_before_hit = {
			[6] = 0.16666666666666666,
			[7] = 0.275
		},
		finals = { 5, 7 },
		Effects = {
			Default = "Normal_Punch_Effect",
			[7] = "N/A"
		},
		MinHitboxSize = 4,
		Reaches = {
			[5] = 4
		},
		Widths = {
			Default = 4
		}
	},
	Dream = {
		default = 0.425,
		default_before_hit = 0.1,
		default_before_swing = 0.05,
		run_swing_remove_on_first = 0.092,
		final = 1.65,
		finals = { 5, 7 },
		delay_before_hit = {
			Default = 0.1,
			[5] = 0.3,
			[7] = 0.3
		},
		Reaches = {
			Default = 5.5
		},
		Widths = {
			Default = 2,
			[5] = 3
		},
		Effects = {
			Default = "Normal_Punch_Effect",
			[7] = "N/A"
		}
	},
	["Axe and Mace"] = {
		default = 0.356,
		default_before_hit = 0.329,
		default_before_swing = 0.143,
		run_swing_remove_on_first = -0.024,
		final = 1.65,
		AnimSpeed = {
			Default = 1.2075,
			[5] = 2.1,
			[7] = 1.05,
			[-1] = 1.68
		},
		delay_before_swing = {
			[1] = 0.024,
			[2] = 0.19,
			[5] = 0.238,
			[7] = 0.095
		},
		delay_before_hit = {
			[5] = 0.381,
			[7] = 0.333
		},
		finals = { 5, 7 },
		Widths = {
			Default = 5
		},
		MinHitboxSize = 3,
		Reaches = {
			[4] = 5,
			[5] = 6.5,
			Default = 2.5
		},
		Effects = {
			Default = "Normal_Sword_Slash_Effect",
			[7] = "N/A"
		}
	},
	Reaper = {
		default = 0.325,
		default_before_hit = 0.3,
		default_before_swing = 0.125,
		run_swing_remove_on_first = 0.092,
		final = 1.65,
		CombatRunHit = true,
		AnimSpeed = {
			[6] = 1.3
		},
		delay_before_hit = {
			[2] = 0.1,
			[3] = 0.1,
			[4] = 0.15,
			[7] = 0.075
		},
		delay_before_swing = {
			[1] = 0.25,
			[6] = 0.25,
			[5] = 0.3
		},
		Widths = {
			Default = 3
		},
		Reaches = {
			Default = 1
		},
		finals = { 5, 7 },
		Effects = {
			Default = "Normal_Punch_Effect",
			[4] = "Normal_Sword_Slash_Effect",
			[7] = "N/A"
		}
	}
}