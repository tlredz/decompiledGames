local import = _G.import("event")
return {
	Wither = {
		Info = {
			DisplayName = "Troll",
			Description = "Reduce HP for a turn",
			PetDescription = "Every 10 rounds, reduce opponent HP for a turn",
			RotationCooldown = 10,
			TurnPlayer = false,
			UniqueRound = true
		},
		Triggers = function(_)
			return {
				{
					Event = "AnswerBegan",
					Condition = function(_, p)
						return p.HP[p.TurnPlayer] > 1
					end
				}
			}
		end,
		Instance = function(_, object, _)
			return {
				TargetPlayerIndex = object.TurnPlayer,
				TargetUserId = object:getPlayer(object.TurnPlayer)
			}
		end,
		Execute = function(_, object, data)
			local targetPlayerIndex = data.TargetPlayerIndex
			local targetUserId = data.TargetUserId

			if object.Players[targetPlayerIndex] ~= targetUserId or object.HP[targetPlayerIndex] <= 1 then
				return
			end

			object:attack(data.CatalystId, targetPlayerIndex)
			object:takeDamage(targetPlayerIndex)
			object:addActivation("EndRound", function()
				if object.Players[targetPlayerIndex] ~= targetUserId or (object.MaxHP[targetPlayerIndex] or 2) <= object.HP[targetPlayerIndex] then
					return
				end

				object.HP[targetPlayerIndex] += 1
				import.firePlayers(object:players(), "regenerate", targetUserId)
			end)
		end
	}
}