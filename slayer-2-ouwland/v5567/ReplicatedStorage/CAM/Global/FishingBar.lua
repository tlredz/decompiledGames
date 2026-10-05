return {
	Fill = {
		StartingPercent = 50,
		WinPercent = 100,
		PercentStep = 1,
		PercentGainTick = 0.1
	},
	FastestWin = function(data)
		return math.ceil((data.WinPercent - data.StartingPercent) / data.PercentStep) * data.PercentGainTick
	end
}