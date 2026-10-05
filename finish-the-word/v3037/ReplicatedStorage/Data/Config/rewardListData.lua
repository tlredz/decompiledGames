return {
	Mins10 = {
		TimeRequired = 50,
		Rewards = { "Cash200" }
	},
	Mins20 = {
		TimeRequired = 100,
		Rewards = { "TimeBoost" }
	},
	Mins30 = {
		TimeRequired = 150,
		Rewards = { "Cash100", "TimeBoost", "GreenSlime" }
	},
	Mins40 = {
		TimeRequired = 200,
		Rewards = { "Cash500", "TimeBoost2x", "FruityNeko" }
	},
	Day1 = {
		StreakRequired = 1,
		Rewards = { "Cash200" }
	},
	Day2 = {
		StreakRequired = 2,
		Rewards = { "Cash500", "TimeBoost2x", "Moon" }
	},
	Day3 = {
		StreakRequired = 3,
		Rewards = { "Cash500", "TimeBoost" }
	},
	Day4 = {
		StreakRequired = 4,
		Rewards = { "Cash700", "TimeBoost2x" }
	},
	Day5 = {
		StreakRequired = 5,
		Rewards = { "Cash700", "TimeBoost4x", "GamingChair" }
	},
	Day6 = {
		StreakRequired = 6,
		Rewards = { "Cash700", "TimeBoost4x", "Shower" }
	},
	Day7 = {
		StreakRequired = 7,
		Rewards = { "Cash700", "TimeBoost4x", "Basket" }
	},
	Group = {
		Rewards = { "Cash500", "TimeBoost", "Basket" },
		Condition = function(object, _, _)
			local success, result = pcall(function()
				return object:IsInGroup(189805512)
			end)
			return success and result or false
		end
	}
}