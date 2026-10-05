local import = _G.import("questCollection")
return {
	claimQuest = function(p, p2, p3, value)
		if not (p2 and p3) then
			return "Player data not loaded"
		end

		if type(value) ~= "string" then
			return "Invalid quest"
		end

		local v = import:get(value)

		if not v then
			return "Quest template not found"
		end

		local dailyQuest = p2.DailyQuests[value]

		if not dailyQuest then
			return "Quest not active"
		end

		if dailyQuest.Claimed then
			return "Quest already claimed"
		end

		if dailyQuest.Progress < v.Goal then
			return "Quest not completed"
		end

		return true, p, p2, p3, value
	end
}