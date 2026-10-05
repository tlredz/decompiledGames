-- equivalent calls inferred from this helper; original call sites unknown
local function getSuffix(value, suffixLength)
	local v = string.lower(value or "")
	return v:sub(-math.min(#v, suffixLength))
end

return {
	Chip = {
		Info = {
			DisplayName = "Chip",
			Description = "Gain a stack",
			PetDescription = "After repeating the suffix 3 times, enemy loses 3s",
			Stacks = 3,
			SuffixLength = 2,
			Damage = 3,
			RotationCooldown = 4,
			TurnPlayer = true
		},
		Triggers = function(_)
			return {
				{
					Event = "Correct",
					Condition = function(p, _, _, p2, _, _, _, value)
						local suffixLength = p.SuffixLength or 2
						local suffix = getSuffix(value, suffixLength) -- equivalent call inferred; original call site unknown
						local v

						if p2.ChipLastSuffix == nil then
							v = false
						else
							v = suffix == p2.ChipLastSuffix
						end

						p2.ChipLastSuffix = suffix
						return v
					end
				}
			}
		end,
		Instance = function(data, _, _, _, _, value)
			local suffixLength = data.SuffixLength or 2
			return {
				Suffix = getSuffix(value, suffixLength),
				Stacks = data.Stacks or 3,
				Damage = data.Damage or 3
			}
		end,
		Execute = function(_, object, data, p)
			p.ChipStacks = (p.ChipStacks or 0) + 1

			if p.ChipStacks < data.Stacks then
				return
			end

			p.ChipStacks = 0
			local _, _ = unpack(data.CatalystId)
			object:executeAbility(p, "ChipTimeCut", {
				Damage = data.Damage
			})
		end
	},
	ChipTimeCut = {
		Info = {
			DisplayName = "Chip",
			Description = "Steal 3s"
		},
		Triggers = function()
			return {}
		end,
		Instance = function(p)
			return {
				Damage = p.Damage or 3
			}
		end,
		Execute = function(_, object, p)
			object:addEffect(object, "TimeModifier", {
				Add = -p.Damage,
				Round = 1
			})
		end
	}
}