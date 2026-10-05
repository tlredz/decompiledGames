return {
	Void = {
		Info = {
			DisplayName = "Void",
			Description = "Negate an ability",
			PetDescription = "Negate an ability",
			RotationCooldown = 5
		},
		Triggers = function(_)
			return {
				{
					Event = "Triggered",
					Condition = function(_, p, p2, _, p3, _, p4, data)
						if not (p4 and data and p.ActiveQueue[p4] == data) then
							return false
						end

						return data.PlayerId ~= p2 and data.AbilityId ~= p3 and not data.Instance.Negated
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
		Execute = function(_, p, p2)
			local v = p.ActiveQueue[p2.TargetActiveId]

			if not v or v ~= p2.TargetActive then
				return
			end

			v.Instance.Negated = true
		end
	}
}