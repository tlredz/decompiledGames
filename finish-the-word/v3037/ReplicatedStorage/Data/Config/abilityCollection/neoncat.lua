_G.import("event")
return {
	Charge = {
		Info = {
			DisplayName = "Charge",
			Description = "Gain a charge",
			PetDescription = "Answer in under 3s to gain a charge.",
			MaxAnswerTime = 3,
			TurnPlayer = true
		},
		Triggers = function(_)
			return {
				{
					Event = "Correct",
					Condition = function(p, _, _, p2, _, _, p3)
						return not ((p2.Charge or 0) >= 3) and p3 <= (p.MaxAnswerTime or 4)
					end
				}
			}
		end,
		Execute = function(_, _, _, p)
			p.Charge = (p.Charge or 0) + 1
		end
	},
	Skip = {
		Info = {
			DisplayName = "Skip",
			Description = "Skip your turn",
			PetDescription = "Skip your turn.",
			MaxAnswerTime = 3,
			TurnPlayer = true
		},
		Triggers = function(_)
			return {
				{
					Event = "AnswerBegan",
					Condition = function(_, _, _, p)
						return (p.Charge or 0) >= 3
					end
				}
			}
		end,
		Execute = function(_, p, _, _)
			p.Skip = true
		end
	}
}