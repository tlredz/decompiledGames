return {
	Seagull = {
		Info = {
			DisplayName = "Seagull",
			Description = "Gain a stack",
			PetDescription = "Answer in under 2 seconds to gain a stack.",
			Stacks = 3,
			TurnPlayer = true
		},
		Triggers = function(_)
			return {
				{
					Event = "Correct",
					Condition = function(_, p, _, p2, _, _, p3)
						return p3 <= 2 and p.RotationNumber >= (p2.SeagullStackCooldownUntil or 0)
					end
				}
			}
		end,
		Instance = function(p)
			return {
				Stacks = p.Stacks or 3
			}
		end,
		Execute = function(_, object, p, p2)
			p2.SeagullStacks = (p2.SeagullStacks or 0) + 1

			if p2.SeagullStacks < p.Stacks then
				return
			end

			p2.SeagullStacks = 0
			object:executeAbility(p2, "SeagullCooldownIncrease")
		end
	},
	SeagullCooldownIncrease = {
		Info = {
			DisplayName = "Foul Play",
			Description = "Increase enemy pet's cooldowns by 2",
			PetDescription = "Up to every 6 rotations, after 2 stacks, increase enemy pet's cooldowns by 2"
		},
		Triggers = function()
			return {}
		end,
		Execute = function(_, p, _, p2)
			for _, catalyst in pairs(p.Catalysts) do
				for _, v in pairs(catalyst) do
					if v == p2 then
						continue
					end

					for _, ability in pairs(v.Abilities) do
						ability.LastRotationTriggered += 2
						ability.LastTriggered += 2
					end
				end
			end

			p2.SeagullStackCooldownUntil = p.RotationNumber + 6
		end
	}
}