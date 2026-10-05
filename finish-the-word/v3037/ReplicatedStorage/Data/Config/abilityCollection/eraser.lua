game:GetService("RunService")
local import = _G.import("event")
_G.import("clientUtil")
return {
	Save = {
		Info = {
			DisplayName = "Save",
			Description = "Erase a strike",
			TurnPlayer = true
		},
		Triggers = function(_)
			return {
				{
					Event = "Strike",
					Condition = function(p, p2, p3)
						return p2.Strikes[p3] == (p.Strikes or 1)
					end
				}
			}
		end,
		Instance = function(p, _)
			return {
				Damage = p.Damage
			}
		end,
		Execute = function(_, object, _, _)
			local strikes = object.Strikes
			local turnPlayer = object.TurnPlayer
			strikes[turnPlayer] -= 1
			import.firePlayers(object:players(), "updateStrikes", object.Strikes[object.TurnPlayer])
		end
	}
}