local v = {
	Panel = {
		CardColor = Color3.fromRGB(64, 72, 94),
		CardGradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(236, 240, 250)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(96, 112, 150))
		}),
		CardCorner = UDim.new(0.12, 0),
		PlateCorner = UDim.new(0.15, 0),
		PlateStrokeColor = Color3.fromRGB(226, 234, 250),
		TitleColor = Color3.fromRGB(255, 255, 255),
		TitleStrokeColor = Color3.fromRGB(20, 26, 40),
		RarityColor = nil,
		SubTextColor = Color3.fromRGB(214, 224, 244),
		BonusColor = Color3.fromRGB(255, 232, 168),
		AmountColor = Color3.fromRGB(236, 244, 255),
		AmountStrokeColor = Color3.fromRGB(20, 26, 40),
		SeparatorColor = Color3.fromRGB(150, 166, 200),
		StarColor = Color3.fromRGB(255, 216, 110),
		StarStrokeColor = Color3.fromRGB(20, 26, 40),
		ButtonCorner = UDim.new(0.25, 0),
		OwnedColor = Color3.fromRGB(0, 150, 128),
		OwnedStrokeColor = Color3.fromRGB(150, 255, 236),
		OwnedTextColor = Color3.fromRGB(226, 255, 248)
	},
	Soft = {
		CardColor = Color3.fromRGB(240, 205, 150),
		CardGradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255, 247, 241)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(206, 158, 92))
		}),
		CardCorner = UDim.new(0.3, 0),
		PlateCorner = UDim.new(0.5, 0),
		PlateStrokeColor = Color3.fromRGB(255, 236, 200),
		TitleColor = Color3.fromRGB(92, 54, 20),
		TitleStrokeColor = Color3.fromRGB(255, 235, 200),
		RarityColor = Color3.fromRGB(150, 96, 52),
		SubTextColor = Color3.fromRGB(198, 126, 92),
		BonusColor = Color3.fromRGB(74, 42, 10),
		AmountColor = Color3.fromRGB(255, 247, 230),
		AmountStrokeColor = Color3.fromRGB(150, 96, 40),
		SeparatorColor = Color3.fromRGB(193, 135, 70),
		StarColor = Color3.fromRGB(255, 216, 110),
		StarStrokeColor = Color3.fromRGB(120, 70, 10),
		ButtonCorner = UDim.new(0.5, 0),
		OwnedColor = Color3.fromRGB(0, 165, 140),
		OwnedStrokeColor = Color3.fromRGB(210, 255, 240),
		OwnedTextColor = Color3.fromRGB(240, 255, 250)
	}
}
return {
	styleFor = function(value: string?)
		return v[value or "Panel"] or v.Panel
	end
}