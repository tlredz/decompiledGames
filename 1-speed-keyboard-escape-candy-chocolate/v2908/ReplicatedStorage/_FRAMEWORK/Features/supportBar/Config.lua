require(script.Parent.Types)
return {
	broadcastIntervalSeconds = 5,
	displayOrder = 80,
	barSpringPeriod = 4,
	barSpringDamping = 0.55,
	countSpringPeriod = 3.5,
	countSpringDamping = 0.92,
	idleWobble = 0.0035,
	cruzName = "CRUZ",
	splinkName = "SPLINK",
	cruzColor = Color3.fromRGB(255, 196, 88),
	splinkColor = Color3.fromRGB(214, 230, 245),
	cruzGradient = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 236, 186)),
		ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255, 196, 88)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(196, 140, 48))
	}),
	splinkGradient = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 252)),
		ColorSequenceKeypoint.new(0.45, Color3.fromRGB(214, 230, 245)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(168, 196, 220))
	}),
	strokeColor = Color3.fromRGB(226, 234, 250),
	strokeGradient = ColorSequence.new(Color3.fromRGB(224, 245, 255), Color3.fromRGB(241, 165, 43)),
	textStrokeColor = Color3.fromRGB(20, 26, 40),
	statusColor = Color3.fromRGB(70, 90, 120),
	statusGradient = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(120, 150, 200)),
	defaults = {
		active = false,
		totalVotes = 250000,
		totalNoise = 0.02,
		totalGrowthPerMinute = 0,
		cruzShare = 0.5,
		shareNoise = 0.01,
		driftPerSecond = 0.004,
		autoMode = false,
		autoMinShare = 0.42,
		autoMaxShare = 0.58,
		autoIntervalSeconds = 30
	}
}