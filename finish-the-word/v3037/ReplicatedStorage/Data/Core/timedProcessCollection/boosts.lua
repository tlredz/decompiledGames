return {
	WinBoost = {
		init = function(_, _, object)
			object:registerAura("WinMult", {
				Mult = 2
			})
			print("applied win boost")
		end,
		deinit = function(_, _, object)
			object:popAura("WinMult")
			print("removed win boost")
		end
	},
	StreakBoost = {
		init = function(_, _, object)
			object:registerAura("StreakMult", {
				Mult = 2
			})
			print("applied streak boost")
		end,
		deinit = function(_, _, object)
			object:popAura("StreakMult")
			print("removed streak boost")
		end
	},
	CashBoost = {
		init = function(_, _, object)
			object:registerAura("CashMult", {
				Mult = 2
			})
			print("applied cash boost")
		end,
		deinit = function(_, _, object)
			object:popAura("CashMult")
			print("removed cash boost")
		end
	},
	XpBoost = {
		init = function(_, _, object)
			object:registerAura("XpMult", {
				Mult = 2
			})
			print("applied xp boost")
		end,
		deinit = function(_, _, object)
			object:popAura("XpMult")
			print("removed xp boost")
		end
	}
}