return {
	Shield = {
		Info = {
			DisplayName = "Love",
			Description = "Block damage this turn",
			PetDescription = "Every 3 turns, block damage this turn",
			RotationCooldown = 3,
			TurnPlayer = true
		},
		Triggers = function(_)
			return {
				{
					Event = "AnswerBegan",
					Condition = function(_, object, p)
						return not object:getEffectValue(object:getPlayerObj(p), "Shield")
					end
				}
			}
		end,
		Execute = function(_, object, p, _)
			object:addEffect(object:getPlayerObj(p.CatalystId[1]), "Shield", {
				Round = 1
			})
		end
	}
}