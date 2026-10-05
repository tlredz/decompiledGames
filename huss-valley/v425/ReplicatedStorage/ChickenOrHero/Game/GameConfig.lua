local MovementConfig = require(script.Parent.Parent.Movement.MovementConfig)
local speedScale = MovementConfig.SpeedScale
return table.freeze({
	MaxMatchPlayers = 30,
	MinPlayers = 2,
	Countdown = 5,
	SetupTime = 2,
	FirstSetupTime = 6,
	ResultsTime = 2.5,
	PostMatchLobbyTime = 12,
	SelectionTime = 10,
	ChoiceTime = 8,
	HeroTime = 20,
	RunTime = 30,
	CleanEscapesToWin = 3,
	LateJoinAsCatcher = false,
	PlayerCollisions = false,
	Tick = 0.05,
	MapName = "Map1",
	CharacterReadyTimeout = 6,
	Tackle = table.freeze({
		Duration = 0.4,
		Recovery = 0.6,
		Cooldown = 1.1,
		DistanceMultiplier = 1.15,
		RunDistanceMultiplier = 1.45,
		BoostStrength = 0.7,
		MaxDistance = 15,
		Animation = "DaggerDive",
		Distance = 4 * speedScale,
		Width = 3.4,
		Height = 5,
		Reach = 4,
		RunnerRadius = 0.9,
		Variants = table.freeze({ table.freeze({
				Name = "Short Dive",
				MinSpeedRatio = 0,
				Distance = 2 * speedScale,
				Reach = 4
			}), table.freeze({
				Name = "Medium Dive",
				MinSpeedRatio = 0.4,
				Distance = 4 * speedScale,
				Reach = 4.75
			}), table.freeze({
				Name = "Long Dive",
				MinSpeedRatio = 0.8,
				Distance = 7 * speedScale,
				Reach = 5.5
			}) })
	})
})