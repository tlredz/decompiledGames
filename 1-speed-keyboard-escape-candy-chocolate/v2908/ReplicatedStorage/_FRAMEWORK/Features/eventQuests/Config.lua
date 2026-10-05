local Themes = require(script.Parent.Themes)
require(script.Parent.Types)
return {
	enabled = true,
	questsPerDay = 3,
	daySeconds = 86400,
	products = {
		skip = 3613184790,
		refresh = 3613184835
	},
	events = {
		{
			event = "Halloween2026",
			currency = "CandyCorn",
			currencyName = "Candy Corn",
			theme = Themes.halloween
		},
		{
			event = "Summer2026",
			currency = "SummerCoins",
			currencyName = "Summer Coins",
			theme = Themes.summer
		}
	},
	pool = {
		{
			id = "run_studs",
			type = "Distance",
			label = "Run %d studs",
			target = 2000,
			reward = 300
		},
		{
			id = "win_button",
			type = "WinButton",
			label = "Hit one win button",
			target = 1,
			reward = 300
		},
		{
			id = "golden_key",
			type = "GoldenKey",
			label = "Get one golden key",
			target = 1,
			reward = 400
		},
		{
			id = "secret_key",
			type = "SecretKey",
			label = "Get one secret key",
			target = 1,
			reward = 800
		},
		{
			id = "collect_currency",
			type = "EventCoin",
			label = "Collect %d %s",
			target = 25,
			reward = 300
		},
		{
			id = "play_minutes",
			type = "Playtime",
			label = "Play %d minutes",
			target = 15,
			reward = 300
		}
	},
	distanceTickSeconds = 1,
	teleportFactor = 1.6,
	playtimeTickSeconds = 60
}