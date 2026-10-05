local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()
return {
	Toggle = {
		Keycode = Enum.KeyCode.Semicolon,
		KeycodeReps = 2
	},
	Prefix = ":",
	Clearances = {
		Default = isStudio and 6 or nil,
		Group = {
			Id = 12851171,
			Ranks = {
				[255] = 7,
				[254] = 7,
				[6] = 7,
				[5] = 0.75
			}
		},
		PlaceIds = {
			[17047024836] = {
				Group = {
					Id = 12851171,
					Ranks = {
						[4] = 0.5
					}
				}
			},
			[130395143593224] = {
				Group = {
					Id = 12851171,
					Ranks = {
						[4] = 0.5
					}
				}
			}
		}
	}
}