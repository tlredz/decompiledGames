local OfferRules = {
	status = function(p, p2)
		if type(p) ~= "table" then
			return "Unavailable"
		end

		local startsAt = p.StartsAt or 0
		local endsAt = p.EndsAt or 0

		if type(startsAt) ~= "number" or type(endsAt) ~= "number" or startsAt ~= startsAt or endsAt ~= endsAt or startsAt < 0 or endsAt < 0 or endsAt > 0 and endsAt <= startsAt then
			return "Unavailable"
		end

		if startsAt > 0 and p2 < startsAt then
			return "Upcoming"
		end

		if endsAt > 0 and endsAt <= p2 then
			return "Expired"
		end

		return "Active"
	end
}

function OfferRules.active(p, p2)
	return OfferRules.status(p, p2) == "Active"
end

function OfferRules.countdown(p, p2)
	local status = OfferRules.status(p, p2)

	if status == "Expired" then
		return "OFFER ENDED"
	elseif status == "Unavailable" then
		return ""
	end

	local startsAt = status == "Upcoming" and p.StartsAt or p.EndsAt

	if not startsAt or startsAt <= 0 then
		return ""
	end

	local v = math.max(0, (math.ceil(startsAt - p2)))
	local v2 = math.floor(v / 3600)
	local v3 = math.floor(v % 3600 / 60)
	local v4 = v % 60
	local v5 = v2 >= 24 and string.format("%dd %02d:%02d:%02d", math.floor(v2 / 24), v2 % 24, v3, v4) or string.format(
		"%02d:%02d:%02d",
		v2,
		v3,
		v4
	)
	return (status == "Upcoming" and "STARTS IN " or "ENDS IN ") .. v5
end

function OfferRules.ukSaturdayDeadline(p, p2, p3)
	local unixTimestamp = DateTime.fromUniversalTime(p, p2, p3, 15).UnixTimestamp
	assert(os.date("!*t", unixTimestamp).wday == 7, "Weekly shop date must be a Saturday")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function lastSunday(p4)
		local unixTimestamp2 = DateTime.fromUniversalTime(p, p4, 31, 1).UnixTimestamp
		return unixTimestamp2 - (os.date("!*t", unixTimestamp2).wday - 1) * 86400
	end

	local unixTimestamp2 = DateTime.fromUniversalTime(p, 3, 31, 1).UnixTimestamp
	return unixTimestamp - (unixTimestamp2 - (os.date("!*t", unixTimestamp2).wday - 1) * 86400 <= unixTimestamp and unixTimestamp < lastSunday(10) and 3600 or 0)
end

return OfferRules