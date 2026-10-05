local v = {
	CoinTournaments = {
		{
			EntryFee = 250,
			Reward = 3000,
			Map = "Classic"
		},
		{
			EntryFee = 500,
			Reward = 6000,
			Map = "TimesSquare"
		},
		{
			EntryFee = 1000,
			Reward = 12000,
			Map = "MoonMap"
		},
		{
			EntryFee = 2500,
			Reward = 30000,
			Map = "Heaven"
		},
		{
			EntryFee = 5000,
			Reward = 60000,
			Map = "Underworld"
		}
	},
	DailyStrikes = 5,
	WinsNeededToWin = 3,
	MAX_MATCHMAKING_ELO = 10000,
	TROPHY_ELO_WEIGHT = 500,
	MAX_MATCH_HISTORY = 50,
	MAX_REJOIN_TIME = 300,
	PLAYERS_OPTIONS = { 4, 8, 16 },
	ROUND_OPTIONS = { 1, 2 },
	CANCELLED_SYMBOL = "\0",
	TOURNAMENTS_RELEASE_UNIX = DateTime.fromUniversalTime(2024, 2, 23, 17).UnixTimestamp
}
return table.freeze(v)