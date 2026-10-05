local import = _G.import("event")
return {
	BloodFrenzy = {
		Info = {
			DisplayName = "Frenzy",
			Description = "Add a strike",
			PetDescription = "Add an extra strike, up to every 3 rounds",
			RoundCooldown = 3,
			TurnPlayer = false
		},
		Triggers = function(_)
			return {
				{
					Event = "Strike",
					Condition = function(_, p)
						return p.StrikeAbilityRound ~= p.RoundNumber
					end
				}
			}
		end,
		Execute = function(_, object)
			local turnPlayer = object.TurnPlayer
			local player = object:getPlayer(turnPlayer)

			if not player or player == "null" then
				return
			end

			object.StrikeAbilityRound = object.RoundNumber
			object.Strikes[turnPlayer] = math.min(5, (object.Strikes[turnPlayer] or 0) + 1)
			import.firePlayers(object:players(), "strike", player, object.Strikes[turnPlayer])

			if object.Strikes[turnPlayer] >= 5 then
				object:damage()
			end
		end
	}
}