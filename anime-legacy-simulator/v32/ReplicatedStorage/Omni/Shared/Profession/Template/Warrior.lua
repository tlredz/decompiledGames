return {
	Interface = "Default",
	Icon = "rbxassetid://93670476085226",
	MapName = "Heaven Island",
	Upgrades = {
		Strength = {
			Index = 1,
			MaxLevel = 30,
			Perks = {
				Damage = {
					Type = "Multi",
					Amount = 1,
					Increasing = {
						Type = "Add",
						Amount = 0.1
					}
				}
			},
			Requirement = {
				Type = "Kill",
				Amount = 1,
				Increasing = {
					Type = "Add",
					Amount = 1
				}
			}
		}
	}
}