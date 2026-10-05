_G.import("event")
return {
	MonthlyReset = {
		init = function(_, _, _) end,
		deinit = function(_, object, _, p)
			print("monthly reset | isLoad:", p)
			object:monthlyReset(not p)
			task.defer(function()
				object:scheduleMonthlyReset()
			end)
		end
	}
}