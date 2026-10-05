return {
	p3598838673 = {
		Server = function(_, _, p, _)
			if not p then
				return false
			end

			local statistics = p.Statistics
			local lastStreak = statistics.LastStreak or 0
			local streak = statistics.Streak or 0

			if lastStreak < 2 or lastStreak < streak then
				return true
			end

			statistics:replicate("Streak", lastStreak)
			statistics:replicate("LastStreak", 0)
			return true
		end
	}
}