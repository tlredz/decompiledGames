return {
	Clockwork = {
		Info = {
			DisplayName = "Processing",
			Description = "Gain 2s on the clock",
			PetDescription = "Gain 2s on the clock",
			Seconds = 2
		},
		Triggers = function(_)
			return {
				{
					Event = "Passive",
					Condition = function()
						return true
					end
				}
			}
		end,
		Instance = function(_, _, playerId)
			return {
				PlayerId = playerId
			}
		end,
		Execute = function(p, object, p2)
			object:addEffect(object:getPlayerObj(p2.PlayerId), "TimeModifier", {
				Add = p.Seconds or 2
			})
		end
	}
}