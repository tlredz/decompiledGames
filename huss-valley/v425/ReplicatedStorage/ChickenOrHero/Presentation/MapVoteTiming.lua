local MapVoteTiming = {}

function MapVoteTiming.canPresent(p, p2, value, value2, value3, p3)
	if not p2 then
		return false
	end

	local v

	if type(value2) == "number" and type(value) == "number" then
		v = value2 < value
	else
		v = false
	end

	return math.max(v and p2 or p2 + (p3.ArrivalBreatherSeconds or 4), value3 or 0) <= p
end

function MapVoteTiming.shouldExpand(p, p2)
	return p == "Voting" and p2 >= 2
end

return MapVoteTiming