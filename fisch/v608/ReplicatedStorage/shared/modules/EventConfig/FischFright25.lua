return {
	ExpiresAt = DateTime.fromUniversalTime(2025, 11, 3, 17),
	IsActive = function(p)
		return workspace:GetServerTimeNow() < p.ExpiresAt.UnixTimestamp
	end
}