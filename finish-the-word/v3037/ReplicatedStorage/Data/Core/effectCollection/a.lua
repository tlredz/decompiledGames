local function modifier()
	return {
		Default = {
			Add = 0,
			Mult = 1
		},
		reduce = function(state, p)
			state.Add += p.Add or 0
			state.Mult += (p.Mult or 1) - 1
			return state
		end,
		apply = function() end
	}
end

return {
	TimeModifier = modifier(),
	TimerRate = {
		Default = {
			Add = 0,
			Mult = 1
		},
		reduce = function(p, p2)
			p.Mult *= p2.Mult or 1
			return p
		end,
		apply = function() end
	},
	CashReward = modifier(),
	Shield = {
		Default = false,
		reduce = function()
			return true
		end,
		apply = function() end
	},
	PetDisabled = {
		Default = false,
		reduce = function(_, p)
			return p.Value
		end,
		apply = function() end
	},
	Celebration = {
		Default = false,
		reduce = function()
			return true
		end,
		apply = function() end
	}
}