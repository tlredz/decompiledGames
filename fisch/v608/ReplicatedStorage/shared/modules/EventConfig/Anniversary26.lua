return {
	Location = "2nd Anniversary",
	StartsAt = DateTime.fromUniversalTime(2026, 10, 3, 18),
	ExpiresAt = DateTime.fromUniversalTime(2026, 10, 6, 18),
	IsActive = function(p)
		local serverTimeNow = workspace:GetServerTimeNow()
		return p.StartsAt.UnixTimestamp <= serverTimeNow and serverTimeNow < p.ExpiresAt.UnixTimestamp
	end
}