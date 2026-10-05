local import = _G.import("event")
local v = { "New", "Crescent", "Full" }

-- equivalent calls inferred from this helper; original call sites unknown
local function phaseForMatch(p, p2)
	local rotationInterval = p2.RotationInterval or 5
	return math.floor(math.max(p.RotationNumber, 0) / rotationInterval) % 3 + 1
end

local function hasSuffix(value, suffixes)
	local v2 = string.lower(value or "")

	for _, v3 in ipairs(suffixes or {}) do
		local v4 = string.lower(v3)

		if v2:sub(-#v4) == v4 then
			return true
		end
	end

	return false
end

local function containsLetters(value, letters)
	local v2 = string.lower(value or "")

	for _, v3 in ipairs(letters or {}) do
		if not string.find(v2, string.lower(v3), 1, true) then
			return false
		end
	end

	return true
end

return {
	PhaseShift = {
		Info = {
			DisplayName = "Shift",
			Description = "Change phase",
			PetDescription = "Every 5 rotations, change moon phase.",
			RotationInterval = 5
		},
		GetDescription = function(_, _, p)
			return "Phase: " .. v[p.Phase]
		end,
		Triggers = function(_)
			return {
				{
					Event = "GameBegan",
					Condition = function()
						return true
					end
				},
				{
					Event = "AnswerBegan",
					Condition = function(p, p2, _, p3)
						local v2 = phaseForMatch(p2, p) -- equivalent call inferred; original call site unknown
						return p3.LumiPhase ~= v2
					end
				}
			}
		end,
		Instance = function(p, p2)
			return {
				Phase = phaseForMatch(p2, p)
			}
		end,
		Execute = function(_, _, p, p2)
			if p2.LumiPhase ~= p.Phase then
				p2.LumiStacks = 0
			end

			p2.LumiPhase = p.Phase
		end
	},
	NewMoon = {
		Info = {
			DisplayName = "New",
			Description = "+7s",
			PetDescription = "When enemy uses a hard suffix, +7s.",
			Suffixes = {
				"ly",
				"ky",
				"gy",
				"kt",
				"kv",
				"ux",
				"pt",
				"x",
				"ing",
				"mn",
				"bt",
				"ght",
				"ph",
				"que",
				"eux",
				"oux",
				"nx",
				"tz",
				"tx",
				"ls",
				"ms",
				"cs"
			},
			Seconds = 7,
			TurnPlayer = false
		},
		Triggers = function(_)
			return {
				{
					Event = "Correct",
					Condition = function(p, _, _, p2, _, _, _, p3)
						return p2.LumiPhase == 1 and hasSuffix(p3, p.Suffixes)
					end
				}
			}
		end,
		Instance = function(p)
			return {
				Seconds = p.Seconds or 7
			}
		end,
		Execute = function(_, object, p)
			object:addEffect(object, "TimeModifier", {
				Add = p.Seconds,
				Round = 1
			})
		end
	},
	CrescentMoon = {
		Info = {
			DisplayName = "Crescent",
			Description = "Enemy -3s",
			PetDescription = "Enemy -3s.",
			Seconds = 3,
			Silent = true,
			TurnPlayer = false
		},
		Triggers = function(_)
			return {
				{
					Event = "AnswerBegan",
					Condition = function(_, _, _, p)
						return p.LumiPhase == 2
					end
				}
			}
		end,
		Instance = function(p)
			return {
				Seconds = p.Seconds or 3
			}
		end,
		Execute = function(_, object, p)
			object:addEffect(object, "TimeModifier", {
				Add = -p.Seconds,
				Round = 1
			})
		end
	},
	FullMoon = {
		Info = {
			DisplayName = "Full",
			Description = "Gain a stack",
			PetDescription = "When you enter a word with m and n in it, gain a stack. At 3 stacks, +1hp.",
			Letters = { "m", "n" },
			Stacks = 3,
			TurnPlayer = true
		},
		Triggers = function(_)
			return {
				{
					Event = "Correct",
					Condition = function(p, _, _, p2, _, _, _, p3)
						return p2.LumiPhase == 3 and containsLetters(p3, p.Letters)
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
			p2.LumiStacks = (p2.LumiStacks or 0) + 1

			if p2.LumiStacks < p.Stacks then
				return
			end

			p2.LumiStacks = 0
			local v2 = p.CatalystId[1]

			if (object.MaxHP[v2] or 2) <= object.HP[v2] then
				return
			end

			object:executeAbility(p2, "RecoverHP")
		end
	},
	RecoverHP = {
		Info = {
			DisplayName = "Full",
			Description = "+1hp"
		},
		Triggers = function()
			return {}
		end,
		Execute = function(_, object, p)
			local v2 = p.CatalystId[1]

			if (object.MaxHP[v2] or 2) <= object.HP[v2] then
				return
			end

			object.HP[v2] += 1
			import.firePlayers(object:players(), "regenerate", object:getPlayer(v2))
		end
	}
}