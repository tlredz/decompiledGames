return {
	GetDayFromString = function(_, value)
		local match, v, v2 = value:match("(%d+)%-(%d+)%-(%d+)")

		if match and v and v2 then
			local v3 = os.time({
				year = tonumber(match),
				month = tonumber(v),
				day = tonumber(v2),
				hour = 0,
				min = 0,
				sec = 0
			})
			return (os.date("%A", v3))
		end

		warn("bad date format:", value)
		return false
	end
}