local import = _G.import("event")
return {
	Regenerate = {
		Info = {
			DisplayName = "Regenerate",
			Description = "Heal 1 HP",
			PetDescription = "On turn 20, heal 1 HP",
			TurnPlayer = true
		},
		Triggers = function(_)
			return {
				{
					Event = "AnswerBegan",
					Condition = function(_, p)
						return p.RotationNumber == 20
					end
				}
			}
		end,
		Execute = function(_, object, _)
			if object.HP[object.TurnPlayer] >= 2 then
				return
			end

			local HP = object.HP
			local turnPlayer = object.TurnPlayer
			HP[turnPlayer] += 1
			import.firePlayers(object:players(), "regenerate", object:getPlayer(object.TurnPlayer))
		end
	}
}