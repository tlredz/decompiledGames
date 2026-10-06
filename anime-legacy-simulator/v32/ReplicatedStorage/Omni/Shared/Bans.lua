local Bans = {
	Durations = {
		["1 Hour"] = 3600,
		["1 Day"] = 86400,
		["3 Days"] = 259200,
		["7 Days"] = 604800,
		["30 Days"] = 2592000,
		Permanent = 0
	},
	DurationOrder = {
		"1 Hour",
		"1 Day",
		"3 Days",
		"7 Days",
		"30 Days",
		"Permanent"
	},
	BannedGuildReservation = "Banned"
}

function Bans.GetExpiresAt(p: string)
	local duration = Bans.Durations[p]

	if not duration then
		return nil
	end

	if duration == 0 then
		return 0
	end

	return os.time() + duration
end

function Bans.GetKickMessage(p: number?)
	if not p or p <= 0 then
		return "[OMNI] You have been permanently banned!"
	end

	local v = math.ceil(math.max(p - os.time(), 0) / 3600)

	if v >= 24 then
		return (`[OMNI] You have been banned! Time left: {math.ceil(v / 24)} day(s).`)
	end

	return (`[OMNI] You have been banned! Time left: {v} hour(s).`)
end

return Bans