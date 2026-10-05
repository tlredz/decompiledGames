return {
	CatEmoji = {
		Info = {
			DisplayName = "Mute",
			Description = "Disable a pet",
			PetDescription = "At 2 stacks, disable the enemy pet for 3 turns",
			Stacks = 2,
			DisabledTurns = 3,
			RotationCooldown = 8
		},
		Triggers = function(_)
			return {
				{
					Event = "Triggered",
					Condition = function(p, _, p2, p3, _, _, _, data)
						if data.PlayerId == p2 or data.AbilityId == "CatEmoji" or data.Instance.Negated then
							return false
						end

						local catEmojiStacks = (p3.CatEmojiStacks or 0) + 1
						p3.CatEmojiStacks = catEmojiStacks

						if catEmojiStacks < (p.Stacks or 2) then
							return false
						end

						p3.CatEmojiTarget = data.CatalystId
						return true
					end
				}
			}
		end,
		Instance = function(_, _, _, _, targetActiveId, targetActive)
			return {
				TargetActiveId = targetActiveId,
				TargetActive = targetActive
			}
		end,
		Execute = function(p, object, p2, p3)
			local catEmojiTarget = p3.CatEmojiTarget
			p3.CatEmojiStacks = 0
			p3.CatEmojiTarget = nil
			local v = object.ActiveQueue[p2.TargetActiveId]

			if v == p2.TargetActive then
				v.Instance.Negated = true
			end

			object:addEffect(catEmojiTarget, "PetDisabled", {
				Round = p.DisabledTurns or 3
			})
		end
	}
}