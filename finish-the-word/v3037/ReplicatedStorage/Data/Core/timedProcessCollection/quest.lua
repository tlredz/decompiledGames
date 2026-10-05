return {
	DailyQuestReset = {
		init = function(_, _, _) end,
		deinit = function(_, object, _, p)
			object:auto_repl(not p)
			object:refreshDailyQuests()
			object:auto_repl(false)
			task.defer(function()
				object:scheduleQuestReset()
			end)
		end
	}
}