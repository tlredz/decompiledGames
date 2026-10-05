local v = game.GameId == 5750914919
return {
	ExpiresAt = DateTime.fromUniversalTime(2026, 1, 3, 17),
	PartStartTimes = {
		DateTime.fromUniversalTime(2025, 12, 1, 17),
		DateTime.fromUniversalTime(2025, 12, 13, 17),
		DateTime.fromUniversalTime(2025, 12, 20, 17),
		DateTime.fromUniversalTime(2025, 12, 25, 17),
		(DateTime.fromUniversalTime(2025, 12, 28, 17))
	},
	HintUnlockTimes = v and {
		3600,
		7200,
		14400,
		43200,
		86400
	} or table.create(5, -1e999),
	CarbonOffers = {
		["Gingerbread Man"] = 5,
		["Glass of Eggnog"] = 2,
		["Santa's Present"] = 3,
		["Hot Cocoa"] = 6
	},
	AquariumGiftCooldown = v and 3600 or 300,
	MaxAquariumGiftCapacity = 10,
	AquariumGiftChances = {
		Present = 75,
		["Snowy Present"] = 20,
		["Santa's Present"] = 5
	},
	IsActive = function(p)
		return workspace:GetServerTimeNow() < p.ExpiresAt.UnixTimestamp
	end
}