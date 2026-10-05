return {
	DigitColors = {
		ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 138, 138))
		}),
		ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 235, 133)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(134, 138, 98))
		}),
		ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 23)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 78, 38))
		}),
		ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(194, 38, 41)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(118, 64, 64))
		}),
		ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 252, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(56, 85, 85))
		}),
		(ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(87, 0, 209)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(51, 47, 84))
		}))
	},
	PercentageColors = {
		{
			0,
			ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(198, 198, 198))
			})
		},
		{
			0.15,
			ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 127)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 225, 60))
			})
		},
		{
			0.35,
			ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 128, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 70, 0))
			})
		},
		{
			0.6,
			ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
			})
		},
		{
			1,
			ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 0, 235)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(105, 0, 205))
			})
		}
	},
	AnimationStyles = {
		Thump = {
			0.15,
			UDim2.new(0, 0, -0.01, 0),
			UDim2.new(0, 35, 0.05, 0),
			{ -3, 3 },
			"InBack"
		},
		SubtlePop = {
			0.15,
			UDim2.new(-0.02, 0, -0.02, 0),
			UDim2.new(0.02, 0, 0.05, 0),
			{ 0 },
			"OutBack"
		}
	}
}