return {
	Hints = {
		{
			Name = "Dash",
			Text = {
				PC = "Dash   Q + WASD",
				Pad = {
					"Dash ",
					{
						Key = "Dash"
					}
				}
			},
			When = {
				NotOnCooldown = "Dash"
			}
		},
		{
			Name = "Run",
			Text = {
				Mobile = {
					{
						Icon = "RunIcon"
					},
					" to run"
				}
			},
			When = {
				Mounted = false
			}
		},
		{
			Name = "ToolUse",
			Group = "Tap",
			Priority = 0,
			Text = {
				Mobile = {
					{
						Icon = "Mouse"
					},
					" to use"
				}
			},
			When = {
				ToolEquipped = true,
				CombatAvailable = false
			}
		},
		{
			Name = "CombatUse",
			Group = "Tap",
			Priority = 1,
			Text = {
				Mobile = {
					"Hold ",
					{
						Icon = "Fist"
					},
					" to attack"
				}
			},
			When = {
				CombatAvailable = true,
				NotWhileDown = "Combat"
			}
		},
		{
			Name = "HorseGear",
			Group = "Tap",
			Priority = 3,
			Text = {
				PC = {
					{
						Bind = "Run"
					},
					" to change gear"
				},
				Pad = {
					"Change gear ",
					{
						Key = "Run"
					}
				},
				Mobile = {
					{
						Icon = "Mouse"
					},
					" to change gear"
				}
			},
			When = {
				Mounted = true
			}
		},
		{
			Name = "Updraft",
			Group = "Tap",
			Priority = 2,
			Text = {
				Mobile = {
					"Press ",
					{
						Icon = "Fist"
					},
					" again to updraft"
				}
			},
			When = {
				CombatAvailable = true,
				ComboStarted = true
			}
		},
		{
			Name = "Emote",
			Text = {
				PC = {
					{
						Bind = "Emotes"
					},
					" to emote"
				},
				Pad = {
					"Emote ",
					{
						Key = "Emotes"
					}
				}
			},
			When = {
				EmotesOwned = true,
				NotWhileDown = "Emotes"
			}
		}
	}
}