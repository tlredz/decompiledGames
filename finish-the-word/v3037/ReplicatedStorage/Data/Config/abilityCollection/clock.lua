return {
	ClockWork = {
		Info = {
			DisplayName = "Clockwork",
			Description = "Gain 2 seconds next round!",
			PetDescription = "Answer in under 5 seconds to gain 2 seconds on your next turn.",
			TurnPlayer = true
		},
		Triggers = function(_)
			return {
				{
					Event = "Correct",
					Condition = function(_, _, _, _, _, _, p)
						return p <= 5
					end
				}
			}
		end,
		Execute = function(_, object, p, _)
			local v = unpack(p.CatalystId)
			object:addActivation("Round", function()
				object:addEffect(object:getPlayerObj(v), "TimeModifier", {
					Add = 2,
					Round = 1,
					Rotation = 1
				})
			end)
		end
	}
}