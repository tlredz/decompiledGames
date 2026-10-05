return {
	Score = {
		Info = {
			DisplayName = "Score",
			Description = "Steal 3s!",
			PetDescription = "Every 3 rotations, after your opponent gains a strike, steal 3s",
			RotationCooldown = 3
		},
		Triggers = function(_)
			return {
				{
					Event = "Strike",
					Condition = function(_, p, p2, _)
						return p2 ~= p.TurnPlayer
					end
				}
			}
		end,
		Execute = function(_, p, _, _)
			p.RoundTimer = math.max(p.RoundTimer - 3, 0)
		end
	}
}