return {
	ExpiresAt = DateTime.fromUniversalTime(2025, 12, 6, 17),
	IsActive = function(p)
		return workspace:GetServerTimeNow() < p.ExpiresAt.UnixTimestamp
	end
}