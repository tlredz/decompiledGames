local import = _G.import("event")
return {
	ExtraLife = {
		Info = {
			DisplayName = "9 Lives",
			Description = "Start with 3 HP",
			PetDescription = "Start with 3 HP"
		},
		Triggers = function(_)
			return {
				{
					Event = "ChoiceBegan",
					Condition = function(_, p, p2)
						return p.RoundNumber == 1 and p.MaxHP[p2] < 3
					end
				}
			}
		end,
		Instance = function(_, object, playerId)
			return {
				PlayerId = playerId,
				UserId = object:getPlayer(playerId)
			}
		end,
		Execute = function(_, object, p)
			if object.Players[p.PlayerId] ~= p.UserId then
				return
			end

			object.MaxHP[p.PlayerId] = 3
			object.HP[p.PlayerId] = 3
			import.firePlayers(object:players(), "setHealth", p.UserId, 3)
		end
	}
}