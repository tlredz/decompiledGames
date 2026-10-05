return {
	Fortify = {
		Info = {
			DisplayName = "Fortify",
			Description = "Gain 1 sand!",
			PetDescription = "Gain 1 sand for each correct word. Lose 1 sand after a strike.",
			TurnPlayer = true,
			Silent = true
		},
		Triggers = function(_)
			return {
				{
					Event = "Correct",
					Condition = function(_, _, _, _, _, _, _)
						return true
					end
				}
			}
		end,
		Execute = function(_, _, _, p)
			p.Sand = (p.Sand or 0) + 1

			if p.Sand < 45 then
				return
			end

			p.Sand = 0
			p.ShieldReady = true
		end
	},
	Tidalwave = {
		Info = {
			DisplayName = "Tidal Wave",
			Description = "Lose 1 sand on a strike.",
			TurnPlayer = true
		},
		Triggers = function(_)
			return {
				{
					Event = "Strike",
					Condition = function(_, _, _, p)
						return (p.Sand or 0) > 0
					end
				}
			}
		end,
		Execute = function(_, _, _, p)
			p.Sand = math.max((p.Sand or 0) - 1, 0)
		end
	},
	SandDefense = {
		Info = {
			DisplayName = "Sand Defense",
			PetDescription = "After 45 sand stacks, gain a shield",
			Description = "Gain a shield",
			TurnPlayer = true
		},
		Triggers = function(_)
			return {
				{
					Event = "AnswerBegan",
					Condition = function(_, object, p, p2)
						return p2.ShieldReady and not object:getEffectValue(object:getPlayerObj(p), "Shield")
					end
				}
			}
		end,
		Execute = function(_, object, p, p2)
			p2.ShieldReady = false
			object:addEffect(object:getPlayerObj(p.CatalystId[1]), "Shield")
		end
	}
}