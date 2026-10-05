return {
	LovestormInterval = 7200,
	SuperchargedChance = 15,
	LovestormDuration = 900,
	SacredDuration = 1800,
	SacredTimeWindow = 300,
	SacredTimes = { 1771102800, 1771146000 },
	ExpiresAt = DateTime.fromUniversalTime(2026, 2, 21, 17),
	IsActive = function(p)
		return workspace:GetServerTimeNow() < p.ExpiresAt.UnixTimestamp
	end
}