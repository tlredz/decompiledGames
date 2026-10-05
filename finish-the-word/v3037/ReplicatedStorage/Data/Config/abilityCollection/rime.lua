local function hasSuffix(value, suffixes)
	local v = string.lower(value or "")

	for _, v2 in ipairs(suffixes or {}) do
		local v3 = string.lower(v2)

		if v:sub(-#v3) == v3 then
			return true
		end
	end

	return false
end

return {
	Rime = {
		Info = {
			DisplayName = "Shadow",
			Description = "Gain a stack",
			PetDescription = "Gain a stack when writing a word that ends with -x, -ly, -ing or -mn.",
			Suffixes = {
				"x",
				"ly",
				"ing",
				"mn"
			},
			Stacks = 3,
			Seconds = 6,
			TurnPlayer = true
		},
		Triggers = function(_)
			return {
				{
					Event = "Correct",
					Condition = function(p, _, _, _, _, _, _, p2)
						return (hasSuffix(p2, p.Suffixes))
					end
				}
			}
		end,
		Instance = function(p)
			return {
				Stacks = p.Stacks or 3,
				Seconds = p.Seconds or 3
			}
		end,
		Execute = function(_, object, p, p2)
			p2.RimeStacks = (p2.RimeStacks or 0) + 1

			if p2.RimeStacks < p.Stacks then
				return
			end

			p2.RimeStacks = 0
			object:executeAbility(p2, "RimeTimeCut", {
				Seconds = p.Seconds
			})
		end
	},
	RimeTimeCut = {
		Info = {
			DisplayName = "Pressure",
			Description = "Steal 6s",
			PetDescription = "After 3 stacks, steal 6s"
		},
		Triggers = function()
			return {}
		end,
		Instance = function(p)
			return {
				Seconds = p.Seconds or 3
			}
		end,
		Execute = function(_, object, p)
			object:addActivation("EndRound", function()
				object:addEffect(object, "TimeModifier", {
					Add = -p.Seconds,
					Round = 1
				})
			end)
		end
	}
}