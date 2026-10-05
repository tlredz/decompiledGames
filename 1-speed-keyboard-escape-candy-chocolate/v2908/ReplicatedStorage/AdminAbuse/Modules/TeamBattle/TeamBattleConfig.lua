return {
	SyncChannelName = "TeamBattleSync",
	CountdownTickSound = "rbxassetid://139571940014575",
	CountdownFinalSound = "rbxassetid://6238869231",
	GoMessage = "EARN WINS FOR YOUR TEAM ! GO !",
	GoHoldSeconds = 3.5,
	Sounds = {
		"rbxassetid://81789245198334",
		"rbxassetid://104695245037953",
		"rbxassetid://94627193867884",
		"rbxassetid://120007441962737",
		"rbxassetid://93970609264491",
		"rbxassetid://98090122284200",
		"rbxassetid://81888427712271",
		"rbxassetid://127176623684925",
		"rbxassetid://71016572563090",
		"rbxassetid://100910937626709"
	},
	ActiveTeamCount = 2,
	CountdownSeconds = 10,
	CombatSeconds = 300,
	ResultsSeconds = 8,
	WinPayoutNotificationSeconds = 5,
	WinPayoutMultiplier = 10,
	LoserPayoutMultiplier = 2,
	LeadChangeConfirmSeconds = 3,
	LeadChangeMessageFormat = "%s takes the lead!",
	SpeedMultiplier = 1,
	ColorPool = {
		{
			name = "Red",
			pastilleColor = Color3.fromRGB(225, 60, 60),
			teamColor = BrickColor.new("Bright red")
		},
		{
			name = "Blue",
			pastilleColor = Color3.fromRGB(60, 120, 235),
			teamColor = BrickColor.new("Bright blue")
		},
		{
			name = "Green",
			pastilleColor = Color3.fromRGB(70, 200, 110),
			teamColor = BrickColor.new("Bright green")
		},
		{
			name = "Yellow",
			pastilleColor = Color3.fromRGB(235, 200, 55),
			teamColor = BrickColor.new("Bright yellow")
		},
		{
			name = "Purple",
			pastilleColor = Color3.fromRGB(175, 90, 225),
			teamColor = BrickColor.new("Bright violet")
		},
		{
			name = "Orange",
			pastilleColor = Color3.fromRGB(235, 140, 55),
			teamColor = BrickColor.new("Bright orange")
		},
		{
			name = "Cyan",
			pastilleColor = Color3.fromRGB(60, 210, 210),
			teamColor = BrickColor.new("Cyan")
		},
		{
			name = "Pink",
			pastilleColor = Color3.fromRGB(235, 110, 175),
			teamColor = BrickColor.new("Pink")
		},
		{
			name = "Void",
			pastilleColor = Color3.fromRGB(58, 42, 98),
			teamColor = BrickColor.new("Royal purple")
		},
		{
			name = "Coral",
			pastilleColor = Color3.fromRGB(255, 98, 88),
			teamColor = BrickColor.new(255, 98, 88)
		},
		{
			name = "Mint",
			pastilleColor = Color3.fromRGB(95, 248, 195),
			teamColor = BrickColor.new("Mint")
		},
		{
			name = "Lavender",
			pastilleColor = Color3.fromRGB(178, 148, 255),
			teamColor = BrickColor.new("Lilac")
		},
		{
			name = "Amber",
			pastilleColor = Color3.fromRGB(255, 168, 38),
			teamColor = BrickColor.new("Deep orange")
		},
		{
			name = "Slate",
			pastilleColor = Color3.fromRGB(92, 108, 132),
			teamColor = BrickColor.new("Steel blue")
		},
		{
			name = "Magenta",
			pastilleColor = Color3.fromRGB(248, 42, 148),
			teamColor = BrickColor.new("Magenta")
		},
		{
			name = "Jade",
			pastilleColor = Color3.fromRGB(32, 178, 128),
			teamColor = BrickColor.new("Teal")
		},
		{
			name = "Peach",
			pastilleColor = Color3.fromRGB(255, 178, 128),
			teamColor = BrickColor.new("Light orange")
		},
		{
			name = "Neon",
			pastilleColor = Color3.fromRGB(198, 255, 48),
			teamColor = BrickColor.new("Lime green")
		}
	},
	Notifications = {
		{
			atCombatRemaining = 240,
			text = "Team Battle: 4 minutes left!"
		},
		{
			atCombatRemaining = 120,
			text = "2 minutes left! Push for wins!"
		},
		{
			atCombatRemaining = 60,
			text = "Final minute!"
		},
		{
			atCombatRemaining = 10,
			text = "10 seconds!"
		}
	},
	Boosts = {
		{
			atCombatRemaining = 150,
			speedMultiplier = 1.8,
			text = "Speed boost!"
		},
		{
			atCombatRemaining = 60,
			speedMultiplier = 2.2,
			text = "Final rush! Max speed!"
		}
	}
}