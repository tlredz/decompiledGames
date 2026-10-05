return {
	RankedReset = {
		init = function(_, _, _) end,
		deinit = function(_, object, _, p)
			object:rankedReset(not p)
			task.defer(function()
				object:scheduleRankedReset()
			end)
		end
	}
}