return table.freeze({
	Order = {
		"EventSignup",
		"FreeSpin",
		"DoubleCoins",
		"DoubleGems",
		"CrossyRoad",
		"DonkeyKong",
		"FFACatchers"
	},
	Durations = {
		60,
		180,
		300,
		600,
		1200
	},
	Modes = {
		FreeSpin = {
			Name = "FREE SPIN",
			Description = "Give everyone currently online one free wheel spin across all servers.",
			OneShot = true
		},
		EventSignup = {
			Name = "EVENT SIGNUP",
			Description = "Invite all servers to the next game event after their match. Skips signed-up players and starter-pack offers.",
			OneShot = true
		},
		FFACatchers = {
			Name = "FFA CHASERS ONLY",
			Description = "Last one standing. 3 lives; hits knock you down for 3 seconds, then 3 seconds of invincibility.",
			MatchMode = true
		},
		DonkeyKong = {
			Name = "DONKEY KONG",
			Description = "Dodge barrels bouncing and rolling from the goal. Reach the other side for 2× gems for 15 minutes.",
			MatchMode = true
		},
		CrossyRoad = {
			Name = "CROSSY ROAD",
			Description = "Next match: cross 20 lanes of chasers. 10 left, 10 right. Reach the far side. Hits deal 30 damage and slow you for 1.5 seconds.",
			MatchMode = true
		},
		DoubleCoins = {
			Name = "2× COINS",
			Description = "Double coins earned from XP in the selected scope for the event duration. Does not stack with personal boosts."
		},
		DoubleGems = {
			Name = "2× GEMS",
			Description = "Double gems collected from pickups in the selected scope for the event duration. Does not stack with personal boosts."
		}
	}
})