return {
	Blizzard = {
		Info = {
			DisplayName = "Mute",
			Description = "Disable all other pets",
			PetDescription = "At 3 stacks, disable the enemy pet for 3 turns"
		},
		Triggers = function(_)
			return {}
		end,
		Execute = function(_, object, p, _)
			object:petModels(function(_, p2, p3)
				if p2 == p.CatalystId[1] and p3 == p.CatalystId[2] then
					return
				end

				object:addEffect({ p2, p3 }, "PetDisabled", {
					Round = 2
				})
			end)
		end
	},
	Ice = {
		Info = {
			DisplayName = "Ice",
			Description = "Gain an icicle!",
			TurnPlayer = true
		},
		Triggers = function(_)
			return {
				{
					Event = "Correct",
					Condition = function(_, _, _, _, _, _, p)
						return p <= 3
					end
				}
			}
		end,
		Execute = function(_, object, p, p2)
			p2.Icicles = (p2.Icicles or 0) + 1

			if p2.Icicles < 3 then
				return
			end

			p2.Icicles = 0
			local _, _ = unpack(p.CatalystId)
			object:executeAbility(p2, "Blizzard")
		end
	},
	Thaw = {
		Info = {
			DisplayName = "Thaw",
			Description = "Lose an icicle on a strike",
			TurnPlayer = true,
			Silent = true
		},
		Triggers = function(_)
			return {
				{
					Event = "Strike",
					Condition = function(_, _, _, p)
						return (p.Icicles or 0) > 0
					end
				}
			}
		end,
		Execute = function(_, _, _, p)
			p.Icicles = math.max((p.Icicles or 0) - 1, 0)
		end
	}
}