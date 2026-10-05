return {
	BeachStreak = {
		Info = {
			DisplayName = "Streak",
			Description = "Answer correctly to build your streak",
			TurnPlayer = true
		},
		Triggers = function(_)
			return {
				{
					Event = "Correct",
					Condition = function(_, _, _, _)
						return true
					end
				}
			}
		end,
		Execute = function(_, _, _, p)
			p.Streak = (p.Streak or 0) + 1
		end
	},
	BeachBreak = {
		Info = {
			DisplayName = "Break",
			Description = "",
			TurnPlayer = true,
			Silent = true
		},
		Triggers = function(_)
			return {
				{
					Event = "Strike",
					Condition = function(_, _, _, p)
						return (p.Streak or 0) > 0
					end
				}
			}
		end,
		Execute = function(_, _, _, p)
			p.Streak = 0
		end
	},
	BeachShield = {
		Info = {
			DisplayName = "Lifeguard",
			Description = "Gain a shield!",
			PetDescription = "Answer 5 words in a row without a mistake to gain a shield. Once per game.",
			TurnPlayer = true,
			Required = 5
		},
		Triggers = function(_)
			return {
				{
					Event = "AnswerBegan",
					Condition = function(p, object, p2, p3)
						if p3.ShieldUsed then
							return false
						end

						return not object:getEffectValue(object:getPlayerObj(p2), "Shield") and (p3.Streak or 0) >= (p.Required or 5)
					end
				}
			}
		end,
		Execute = function(_, object, p, p2)
			p2.ShieldUsed = true
			object:addEffect(object:getPlayerObj(p.CatalystId[1]), "Shield")
		end
	}
}