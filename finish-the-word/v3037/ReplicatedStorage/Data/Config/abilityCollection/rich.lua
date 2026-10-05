return {
	BonusCash = {
		Info = {
			DisplayName = "Greed",
			Description = "Gain 10% more cash from wins",
			PetDescription = "Gain 10% more cash from wins",
			Multiplier = 1.1
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
			object:addEffect(object:getPlayerObj(p2.PlayerId), "CashReward", {
				Mult = p.Multiplier or 1.1
			})
		end
	}
}